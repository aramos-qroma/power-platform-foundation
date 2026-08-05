# Actividad de aplicaciones + Dataverse del entorno Default

Snapshot: **2026-07-23**. Cuenta de auditoría: `ext.aramos@qroma.com.pe`

---

## 1. Verificar uso de Dataverse en el Default — ninguna app lo usa

Un entorno de Power Platform tiene **como máximo un (1) Dataverse**. El Default **sí** tiene Dataverse aprovisionado (`dataverse=Y`, 22 solutions). Por diseño, cualquier app del Default que use Dataverse apuntaría a **esa única instancia/organización** — no hay Dataverse por-app; es por-entorno.

**Pero en la práctica ninguna de las 43 apps toca Dataverse.** Verificado leyendo los `connectionReferences` de las 43 apps vía admin API:

| Connector | # apps |
|---|---|
| Excel (`shared_excel`) | 24 |
| OneDrive for Business | 23 |
| SharePoint Online | 14 |
| Office 365 (Outlook/Users) | 8 |
| Excel Online (Business) | 3 |
| Word Online (Business) | 2 |
| SQL Server | 2 |
| **Dataverse** (`commondataserviceforapps`/`cds`) | **0** |

**Conclusión:** las 43 apps del Default **no comparten un Dataverse** — comparten el **entorno** (misma frontera de seguridad, mismo alcance DLP, mismo contexto de conexiones), pero sus datos viven en **Excel/OneDrive, listas SharePoint y SQL Server**, fuera de Dataverse. Las 22 solutions del Default son artefactos de solución/flows, no tablas de negocio de estas canvas apps.

Implicancia de gobierno: migrar estas apps a un entorno gobernado **no** requiere migración de datos Dataverse; el riesgo real está en las **conexiones** (OneDrive/SharePoint/SQL personales de cada dueño) y en el **security group VACIO** del Default (abierto a todo el tenant).

---

## 2. Actividad real de las aplicaciones

### Medir mantenimiento con la admin API — ver CSV `apps-activity`
Por app: `owner, status, created, modified, lastPublish, sharedUsers, sharedGroups, premium, onPrem`.

- 43 apps, **todas `status=Ready`** y todas publicadas alguna vez.
- **Última publicación de todo el Default: 2023-03-07.** Nada publicado desde entonces → base 100% legacy.
- **12 compartidas** (≥1 usuario), 31 sin compartir. Máx. compartición = 3 usuarios (AUDITORIA INTERNA APT).
- **5 usan API premium**, **2 usan gateway on-premise** (SQL) → costo/licencia y dependencia de infra local.

Limitación: esto mide *mantenimiento* (edición/publicación/compartir), **no uso runtime** (aperturas/usuarios). Una app sin editar desde 2022 puede seguir usándose a diario.

### Medir uso runtime real — solo a nivel tenant (Graph `auditLogs/signIns`)
Fuente nueva encontrada: **Graph `auditLogs/signIns` responde 200** con el token `az` delegado (requiere Entra ID P1, presente). Muestra logins reales a Power Apps:

- **Página más reciente (999 sign-ins) cubre solo 10 días** (2026-07-14 → 07-23) → el tenant genera **~100-170 lanzamientos/día** (tope 999 alcanzado en 10 días ⇒ ~3.000/mes).
- **153 usuarios activos distintos** en esos 10 días. 987/999 exitosos (12 fallos de auth).
- Top usuarios: `vigilante3` (36), `jlazaro` (23), `maleon` (21), `despachofacturas` (19), `jbustios` (19)…

**→ Power Apps está muy vivo en Qroma: 150+ personas lo usan a diario.** El supuesto de "todo legacy/abandonado" es falso a nivel plataforma.

### Delimitar el alcance — atribución por app/entorno no disponible con esta cuenta
Los sign-ins apuntan todos a `PowerApps - apps.powerapps.com` (el player), **agregado tenant-wide**: no distinguen cuál de las 43 apps del Default se abrió, ni siquiera si fue una app del Default vs Sandbox/Producción. Se probaron las 3 fuentes que sí dan detalle por-app y **todas denegaron**:

| Fuente (uso runtime por-app) | Resultado |
|---|---|
| Power Apps analytics REST (`.../environments/{env}/analytics`) | **404** (solo vía UI admin center / Kusto) |
| O365 Management Activity API (`LaunchPowerApp`) | **401** (requiere app-registration + `ActivityFeed.Read` + suscripción) |
| Purview unified audit query (Graph `security/auditLog/queries`) | **403** — `ext.aramos ... dont have any permissions` (falta rol Purview) |
| Permisos compartidos por app (UPNs) (`.../apps/{id}/permissions`) | **200 pero `{"value":[]}`** — no expone los principales |

**Para obtener uso runtime por app** (qué apps del Default se abren y quién) hace falta una de estas (todas fuera del toolkit `az`+`curl` actual):
1. Asignar rol **Purview / Audit Reader** a la cuenta y usar `security/auditLog/queries` con `operationFilters:['LaunchPowerApp']` (trae nombre de app + usuario).
2. Registrar una **app en Entra** con permiso app-only `ActivityFeed.Read` sobre O365 Management API e iniciar la suscripción `Audit.General`.
3. Abrir **Power Platform Admin Center → Analytics → Power Apps** (UI, exporta a Power BI).

---

## Aplicar al roadmap
- **Punto 4 (clasificar mantener/migrar/archivar):** el proxy de compartición + la última edición 2023 bastan para marcar las 15 apps de prueba/demo como archivables. Para las 28 de negocio, **conseguir el audit log de Purview por-app antes de archivar** — hay uso real en el tenant y no queremos matar una app viva.
- **Dataverse:** no es un blocker de migración (0 apps lo usan). El plan de migración desde Default debe centrarse en **re-crear conexiones** (OneDrive/SharePoint/SQL) bajo cuentas de servicio y en cerrar el **security group abierto**, no en mover tablas.
