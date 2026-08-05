# Hardening del entorno Default — snapshot 2026-07-23

Cuenta: `ext.aramos@qroma.com.pe` (Power Platform Admin).  
Env ID: `Default-faed75e0-b942-4b73-85ac-7a32b852ceb8`

## Aplicado vía API BAP

| Objetivo | Acción | Resultado |
|---|---|---|
| Dejar de ser “prod disfrazada” | Rename → **Productividad personal (default)** | OK |
| Menos makers “libres” (crear envs) | `disableEnvironmentCreationByNonAdminUsers=true` | OK |
| | `disableTrialEnvironmentCreationByNonAdminUsers=true` | OK |
| | `disableDeveloperEnvironmentCreationByNonAdminUsers=true` | OK |
| | `disableTeamsEnvironmentCreationByNonAdminUsers=true` | OK |
| | `disablePortalsCreationByNonAdminUsers=true` | OK |
| Evitar share con toda la empresa | `disableShareWithEveryone=true` (ya estaba) | ya OK |
| | `disableConnectionSharingWithEveryone=true` | OK |
| Limitar conectores nuevos | DLP `Bloqueo de Apps de Almacenamiento Externo`: `defaultApiGroup` **lbi → blocked** | OK |
| | Blocked existentes: OneDrive consumer, Dropbox, Google Drive | sin cambio |
| No borrar Default | N/A | imposible por diseño |

## Aplicado después — Managed Env y sharing limits, opción A

| Objetivo | Acción | Resultado |
|---|---|---|
| Managed Environment | `protectionLevel: Basic → Standard` | OK |
| Sharing limits canvas | `limitSharingMode=excludeSharingToSecurityGroups` | OK |
| Tope de personas | `maxLimitUserSharing=1` (antes 5) | OK |

Endpoint que funcionó:
`POST .../environments/{id}/governanceConfiguration?api-version=2016-11-01`

Efecto: makers **no** pueden compartir canvas apps con security groups; máx. **5 personas** por app en shares nuevos (~1 h en aplicarse). Shares existentes no se revocan solos. Correr apps en managed puede requerir licencia premium.

## No aplicado — API no disponible o riesgo

| Objetivo | Motivo | Cómo hacerlo |
|---|---|---|
| Tenant isolation inbound/outbound | Endpoint isolation no expuesto / 404 | Admin center → Settings → Tenant isolation |
| DLP estricto (mover Excel/SP/SQL/Outlook a grupos duros) | Rompería las **43 apps** del Default (usan Excel/OneDrive/SP/SQL) | Tras migrar apps de negocio a envs con SG |
| Migrar apps/flows a `pe-…-prd/sbx/dev` + SG | Trabajo de proyecto (roadmap §5–6), no un toggle | Plan de migración del assessment |
| Security group en Default | **No soportado** por Microsoft | N/A |

## Estado DLP tras el cambio

- Política: **Bloqueo de Apps de Almacenamiento Externo** (`fd2ba79c-d1c5-473e-8abb-d7057e18dbc9`)
- `defaultApiGroup=blocked` → **conectores nuevos** quedan bloqueados hasta revisión admin
- Conectores ya clasificados en LBI (Excel, OneDrive BF, SharePoint, SQL, Outlook, Dataverse, Box, …) **siguen permitidos**
- HBI sigue vacío (0 APIs “business only”) → no hay segregación business/non-business real aún

## Efecto inmediato para usuarios

1. Solo **admins** pueden crear Production/Sandbox/Trial/Developer/Teams/Portals.
2. Makers no pueden compartir app/conexión con **Everyone**.
3. Default se llama **Productividad personal (default)** en el admin center.
4. Un conector que Microsoft publique mañana no se usa hasta que un admin lo saque de Blocked.

## Pendiente manual en portal

1. **Managed Environment** en Default + sharing limits (ej. max 20 users / no groups).
2. **Tenant isolation** (block all inbound/outbound salvo allowlist).
3. SG en los **14 envs no-Default** con `securityGroup=VACIO`.
4. Migración de apps de negocio fuera del Default.
