# Governance Power Platform Qroma

## Roadmap

- [x] Auditar apps del entorno Default
  - 43 apps. Por cada una: owner, actividad (proxy), de qué trata.
- [x] Revision de actividad en aplicacion y Dataverse del Default
  - 0/43 apps usan Dataverse (todo Excel/OneDrive/SharePoint/SQL). Uso runtime real solo alcanzable tenant-wide (153 usuarios activos/10d); atribución por-app requiere rol Purview/O365 Mgmt API.
- [ ] Eliminar apps duplicadas y no usadas del Default.
- [ ] Auditar flows del Default (164 flows) — dueños, estado, de qué tratan.
- [ ] Auditar solutions del Default (22) y demás envs Dataverse legibles.
- [ ] Clasificar cada app/flow: mantener · migrar · archivar.
- [ ] Diseñar esquema prod / sandbox / dev + grupos Entra por entorno.
- [ ] Plan de migración desde Default + asignar security groups a los 14 envs abiertos.
- [ ] Managed Environments + DLP + bloquear creación de envs a no-admins.
