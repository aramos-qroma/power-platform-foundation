# Actividad y conectores — Default re-audit (2026-08-05)

Snapshot 2026-08-05, cuenta `ext.aramos@qroma.com.pe`, método az+REST paginado ([detalle v0.0.1](../v0.0.1/ACTIVITY.md) — las limitaciones de atribución runtime siguen vigentes).

## Conectores de las 134 apps

| Conector | # apps | # referencias |
|---|---|---|
| SharePoint | 80 | 80 |
| Excel Online (Empresas) | 34 | 34 |
| Flujos lógicos | 15 | 37 |
| Usuarios de Office 365 | 15 | 15 |
| Office 365 Outlook | 14 | 14 |
| OneDrive para la Empresa | 10 | 10 |
| Excel | 8 | 8 |
| Power BI | 5 | 5 |
| Aprobaciones estándar | 2 | 2 |
| SQL Server | 2 | 2 |
| Spatial Services | 1 | 1 |
| Microsoft Dataverse | 1 | 1 |
| Logic flows | 1 | 4 |
| Microsoft Teams | 1 | 1 |
| Aprobaciones | 1 | 1 |

- 23 apps sin ningún conector (mayoría cascarones de prueba o SharePoint form apps sin fuentes extra).
- **4 apps con API premium**, 2 con gateway on-premise (SQL).
- **Dataverse: 1 sola app** (DEMO CVs) — se mantiene el hallazgo v0.0.1: el Default no usa su Dataverse; los datos viven en SharePoint (80 apps) y Excel Online (34).
- Cambio vs v0.0.1 (43 apps visibles): el perfil real es SharePoint-céntrico, no Excel-céntrico — la página 1 sobre-representaba apps legacy 2021-2023.

## Señales de actividad

- 59 de 134 apps editadas desde 2026-02 → **el Default sigue recibiendo desarrollo activo**; el bloqueo de creación de entornos a no-admins (hardening 2026-07-23) canaliza a todos los makers nuevos aquí.
- 57 apps compartidas (máx: 63 usuarios — Evaluación de Desempeño Operarios de DesarrolloTI).
- Cuentas funcionales como owners (DesarrolloTI Qroma, Reportes Comerciales, Reportes BI, Laboratorio Control de Calidad) — buena práctica a formalizar en FRAMEWORK §3.
