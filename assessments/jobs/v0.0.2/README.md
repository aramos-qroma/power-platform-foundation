# Assessment v0.0.2 — post-eliminación issue #1 (2026-08-05)

Job: eliminar las apps listadas en [issue #1](https://github.com/aramos-qroma/power-platform-foundation/issues/1) y re-inventariar el tenant.

## 1. Eliminar las apps del issue #1

- **30/30 apps eliminadas** del entorno Default (30 únicas; el issue duplicaba las 2 de Anthony Colqui). Cada una verificada con `GET → 404` post-delete.
- Registro pre-delete (appId, dueño, shared, última edición): [`scripts/deleted-apps.jsonl`](../../../scripts/deleted-apps.jsonl).
- Restore posible ~7 días desde la eliminación (hasta ~2026-08-12) vía admin API `.../apps/{id}/restore`.
- 6 de las 30 tenían usuarios compartidos (proxy de uso): Catalogo Tailoy2 (2), Registro Puesto Vacante (2), Prueba_Base, SISCOMER, Formulario de Puesto Vacante, DISTRIBUCION QROMA AQP (1 c/u). Eliminadas igual por orden explícita del issue.

## 2. Re-inventariar el tenant (2026-08-05)

CSVs: [`inventories/*/2026/08/05/current.csv`](../../inventories/).

| Recurso | Total | Default |
|---|---|---|
| Environments | 27 | 1 |
| Apps | **150** | **134** |
| Flows | **465** | **428** |


## 3. Eliminar una aplicación (procedimiento)

Requisitos: `az` CLI con sesión de cuenta **Power Platform Administrator** (`az login --tenant qroma.com.pe --use-device-code`). Sin `pwsh`/`pac` — todo vía REST.

1. **Identificar la app** — inventario más reciente en `assessments/inventories/apps/` o dry-run por nombre:
   ```bash
   scripts/delete-app.sh -a "NOMBRE EXACTO" -n
   ```
   Resuelve por displayName (exige match único; ante ambigüedad lista candidatos y aborta) o por appId GUID. Sin `-e <envId>` usa el entorno Default.
2. **Revisar la metadata** que imprime (dueño, última edición, `sharedUsers`). Si `sharedUsers > 0`, confirmar con el dueño antes de borrar — la atribución de uso real por app está bloqueada (Purview 403), shared es el único proxy.
3. **Eliminar** (una app por invocación):
   ```bash
   scripts/delete-app.sh -a <appId|nombre>        # pide confirmación "yes"
   scripts/delete-app.sh -a <appId> -y            # sin confirmación (batch)
   ```
   El script guarda la metadata pre-delete en `scripts/deleted-apps.jsonl`, ejecuta `DELETE` en el admin API y verifica `GET → 404`.
4. **Restaurar si hace falta** (ventana ~7 días): `POST .../scopes/admin/environments/{envId}/apps/{appId}/restore?api-version=2017-08-01` con token de `https://service.powerapps.com/`.
5. **Re-inventariar** tras un lote: regenerar `inventories/apps/YYYY/MM/DD/current.csv` (extracción con paginación `nextLink`) y actualizar el assessment del job.

## 4. Re-auditar el Default completo

Primer audit sobre el universo real (134 apps / 428 flows), no la página 1:

- **Apps** → [`APPLICATIONS.md`](APPLICATIONS.md): **89 de negocio / 45 prueba-demo** (45 nuevas candidatas a eliminar). 51 apps editadas desde 2026-02 — **el Default no es legacy: es donde aterrizan todos los makers nuevos** tras bloquear la creación de entornos. Categorías: Auditoria/Calidad 25, RRHH 19, Produccion 18, TI 16, Logistica 10, Comercial 9.
- **Conectores** → [`ACTIVITY.md`](ACTIVITY.md): perfil real SharePoint-céntrico (80 apps), no Excel-céntrico como sugería la página 1. Dataverse: 1 app de 134.
- **Flows** → [`FLOWS.md`](FLOWS.md): 216 Started / 181 Stopped / 31 Suspended. **Hallazgo crítico: 169 flows (39%) son huérfanos — sus creadores ya no existen en el tenant (47 usuarios eliminados); 47 de esos flows siguen activos** sin dueño que los mantenga.
- Inventario detallado: [`apps-activity/2026/08/05/current.csv`](../../inventories/apps-activity/2026/08/05/current.csv).

## Resolver pendientes

- [x] Re-auditar Default completo (134 apps reales, no 13) → [`APPLICATIONS.md`](APPLICATIONS.md), [`ACTIVITY.md`](ACTIVITY.md).
- [x] Re-auditar flows del Default (428 reales) → [`FLOWS.md`](FLOWS.md).

## Próximos pasos

Nada de esta sección se implementa en este job — es la propuesta de diseño. La viabilidad IaC fue verificada contra el provider Terraform `microsoft/power-platform` **3.9.1** (el que ya está lockeado en [`infrastructure/`](../../../infrastructure/)).

### 1. Gobernar la creación de entornos vía IaC

Hoy `infrastructure/` ya modela `powerplatform_environment` con nomenclatura FRAMEWORK §1 (workspaces dev/sbx/prd + tfvars), pero nada está aplicado (state vacío) y el directorio no está versionado. Pasos:

1. **Versionar `infrastructure/`** (hoy untracked) — sin IaC en git no hay postura auditable.
2. **Security group obligatorio en sbx/prd.** Los tfvars actuales dejan `security_group_id` comentado → el entorno se crearía **abierto a todo el tenant** (el hallazgo central del assessment: 14 envs sin grupo). Corregir: descomentar en `sbx.tfvars`/`prd.tfvars` + agregar `lifecycle { precondition }` en `environment.tf` que falle si `stage != "dev"` y `security_group_id == ""`.
3. **Managed Environment para prd** — nuevo `managed-environment.tf`:
   ```hcl
   resource "powerplatform_managed_environment" "prd" {
     count                      = local.stage == "prd" ? 1 : 0
     environment_id             = powerplatform_environment.this.id
     is_group_sharing_disabled  = true
     limit_sharing_mode         = "ExcludeSharingToSecurityGroups"
     max_limit_user_sharing     = 5
     is_usage_insights_disabled = false
     solution_checker_mode      = "Warn"
     suppress_validation_emails = true
     maker_onboarding_markdown  = "Entorno gobernado por IaC. Ver FRAMEWORK.md."
     maker_onboarding_url       = "https://github.com/aramos-qroma/power-platform-foundation"
   }
   ```
   Nota: los 9 argumentos son obligatorios; `protection_level` es read-only (computed) — no se setea, se deriva.
4. **`powerplatform_tenant_settings` con precaución.** Permite fijar por IaC lo ya aplicado a mano en el hardening (`disable_environment_creation_by_non_admin_users = true`, etc. — ver [`v0.0.1/DEFAULT-HARDENING.md`](../v0.0.1/DEFAULT-HARDENING.md)). Es un **singleton tenant-global**: un solo root module dueño, `lifecycle { prevent_destroy = true }`, y saber que `terraform destroy` restaura los valores capturados en el state (no es no-op).
5. **Backend remoto**: migrar de `backend "local"` a `azurerm` (crear el dir `backends/` que `terraform.tf` ya referencia pero no existe).
6. **Auth CI**: service principal con **OIDC** (workload identity federation) para pipelines; `use_cli` solo local. El provider soporta ambos.

Resultado: crear un entorno = PR con tfvars nuevos que pasa validación de nomenclatura + security group + managed env, no un click en el admin center (creación manual ya bloqueada para no-admins vía hardening).

### 2. Aplicar DLP por entorno vía IaC

`powerplatform_data_loss_prevention_policy` (3.9.1) soporta scoping por entorno: `environment_type = "OnlyEnvironments"` + `environments = [ids]`. Grupos `business_connectors` / `non_business_connectors` / `blocked_connectors`, clasificación default para conectores nuevos, y patrones de custom connectors.

1. **Prerequisito: completar FRAMEWORK §5** (catálogo de conectores permitidos — hoy pendiente). Insumo real: la tabla de frecuencia de [`ACTIVITY.md`](ACTIVITY.md) (SharePoint 80 apps, Excel Online 34, …) define el grupo business de facto.
2. **Estrategia recomendada**: mantener la política tenant existente (`Bloqueo de Apps de Almacenamiento Externo`) como baseline documentado, y crear **una política IaC por entorno gobernado** (1:1 con cada `powerplatform_environment`), nombre según FRAMEWORK §1.6:
   ```hcl
   resource "powerplatform_data_loss_prevention_policy" "this" {
     display_name                      = "dlp-${local.environment_name}"   # ej. dlp-pe-rrhh-bienestar-prd-use
     environment_type                  = "OnlyEnvironments"
     environments                      = [powerplatform_environment.this.id]
     default_connectors_classification = "Blocked"   # conector nuevo = bloqueado hasta clasificarlo

     business_connectors = [
       { id = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline" },
       { id = "/providers/Microsoft.PowerApps/apis/shared_excelonlinebusiness" },
       { id = "/providers/Microsoft.PowerApps/apis/shared_office365users" },
       { id = "/providers/Microsoft.PowerApps/apis/shared_office365" },
     ]
     non_business_connectors = []
     blocked_connectors      = []   # con default Blocked, lo no listado queda bloqueado
     custom_connectors_patterns = [
       { order = 1, host_url_pattern = "https://*.qroma.com.pe", data_group = "Business" },
       { order = 2, host_url_pattern = "*", data_group = "Blocked" },
     ]
   }
   ```
3. **Default env**: no se le puede aplicar este patrón 1:1 (no lo crea IaC), pero la misma política `OnlyEnvironments` puede apuntar su ID para reemplazar el ajuste manual actual cuando FRAMEWORK §5 esté cerrado.

Referencias: [DLP policy](https://registry.terraform.io/providers/microsoft/power-platform/3.9.1/docs/resources/data_loss_prevention_policy) · [managed environment](https://registry.terraform.io/providers/microsoft/power-platform/3.9.1/docs/resources/managed_environment) · [tenant settings](https://registry.terraform.io/providers/microsoft/power-platform/3.9.1/docs/resources/tenant_settings)
