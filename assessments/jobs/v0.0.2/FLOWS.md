# Flows entorno Default — primera auditoría (2026-08-05)

## Estado

| Estado | # |
|---|---|
| Started (activos) | 216 |
| Stopped | 181 |
| Suspended | 31 |

## Reasignación o apagado de flows huérfanos (hallazgo principal)

**169 de 428 flows (39%) pertenecen a 47 usuarios YA ELIMINADOS del tenant** (identificados como "usuario eliminado" en la tabla por owner). De ellos, **47 siguen en Started** — corren con conexiones del usuario eliminado (o fallan silenciosamente) y nadie puede mantenerlos. Ningún flow huérfano tiene co-owner conocido. Acción sugerida: inventariar sus conexiones, reasignar los Started que importen a cuentas funcionales, apagar el resto.

## Por owner (top 20)

| Owner | # | Started | Stopped | Suspended |
|---|---|---|---|---|
| Javier David Munoz Tintaya | 46 | 32 | 11 | 3 |
| (usuario eliminado da2df52d…) | 26 | 0 | 26 | 0 |
| (usuario eliminado 9ec26276…) | 26 | 7 | 19 | 0 |
| Rosa Maria Del Carmen Guerra Amaya | 17 | 16 | 1 | 0 |
| Reportes Comerciales | 16 | 8 | 6 | 2 |
| Paul Alejandro Valdivia Gago | 14 | 13 | 1 | 0 |
| (usuario eliminado d05b5922…) | 13 | 0 | 13 | 0 |
| Hanna Adelma Alessandra Orellana Grajeda | 13 | 9 | 0 | 4 |
| Juan Oscar Campos Davalos | 12 | 2 | 10 | 0 |
| Daniela Andrea Jara Uribe | 10 | 6 | 4 | 0 |
| (usuario eliminado c5a9d275…) | 10 | 0 | 10 | 0 |
| (usuario eliminado 1d62689f…) | 9 | 0 | 9 | 0 |
| Reportes BI | 8 | 6 | 2 | 0 |
| Notify Qroma | 8 | 3 | 5 | 0 |
| (usuario eliminado 3dcda98e…) | 7 | 5 | 1 | 1 |
| (usuario eliminado dfa9dee1…) | 7 | 1 | 3 | 3 |
| Ronald Michael Cruz Melo | 6 | 3 | 3 | 0 |
| DesarrolloTI Qroma | 6 | 5 | 0 | 1 |
| Miguel Alonso Grande Espino | 5 | 2 | 3 | 0 |
| Ana Chaveli Cotrina Ramos | 5 | 3 | 2 | 0 |
| _otros 89 owners_ | 164 | 95 | 52 | 17 |

## Triggers más comunes

| Trigger | # flows |
|---|---|
| Programado (recurrencia) | 118 |
| Manual (botón/app) | 101 |
| Respuesta de Forms | 73 |
| Archivo nuevo SharePoint | 38 |
| Al llegar correo | 29 |
| Item nuevo SharePoint | 27 |
| Item modificado SharePoint | 11 |
| GetOnUpdatedFileItems | 4 |
| ForASelectedMessageV2 | 4 |
| Archivo nuevo OneDrive | 3 |
| OnNewEmailV2 | 3 |
| WebhookChatMessageTrigger | 2 |

## Conectores más usados

| Conector | # flows |
|---|---|
| Office 365 Outlook | 161 |
| Excel Online (Business) | 155 |
| SharePoint | 151 |
| Microsoft Forms | 73 |
| Power BI | 49 |
| Microsoft Teams | 42 |
| Planner | 40 |
| OneDrive for Business | 24 |
| Standard approvals | 22 |
| Microsoft Dataverse | 10 |
| SQL Server | 10 |
| Office 365 Users | 9 |
| Word Online (Business) | 7 |
| Notifications | 6 |
| Mail | 4 |

## Depuración de duplicados por nombre (copias "Guardar como")

| Nombre | # copias | Owners |
|---|---|---|
| Programar la ejecución de un script de Office en Excel | 5 | (usuario eliminado d7559aac…) |
| Cuando se envía una respuesta nueva -> Obtener los detalles  | 4 | (usuario eliminado 9ec26276…), Adrian Santos Mendoza Soplopuco, Reportes Comerciales |
| Guarda adjunto de correos con asunto "plan" | 3 | Ernesto Rodrigo Arevalo Villanueva, Maria Alejandra Teresa Carrillo Carpio, Maria Cristina Sanchez Tupac Yupanqui |
| Follow up on a message | 3 | (usuario eliminado 530cfe9a…), Rosa Maria Del Carmen Guerra Amaya, Sheila Stephanie Cabrejo Olano |
| Mantenimiento | 3 | (usuario eliminado c5a9d275…), Hanna Adelma Alessandra Orellana Grajeda, Juan Oscar Campos Davalos |
| DISTRIBUCIÓN | 3 | (usuario eliminado c5a9d275…), Hanna Adelma Alessandra Orellana Grajeda, Juan Oscar Campos Davalos |
| ACUOSO | 3 | (usuario eliminado c5a9d275…), Hanna Adelma Alessandra Orellana Grajeda, Juan Oscar Campos Davalos |
| Enviar archivos específicos creados en OneDrive para la Empr | 2 | Ronald Michael Cruz Melo |
| Induccion a Terceros V2 | 2 | (usuario eliminado 9ec26276…), (usuario eliminado d05b5922…) |
| Send an email to responder when response submitted in Micros | 2 | (usuario eliminado 69a3694b…), (usuario eliminado cf6d07e5…) |
| Induccion a Terceros: Version 3 | 2 | (usuario eliminado 9ec26276…), (usuario eliminado d05b5922…) |
| Inducción de contratistas new V4 | 2 | (usuario eliminado 1d62689f…), (usuario eliminado d05b5922…) |

## Revisión de flows suspendidos (31)

Suspendido = deshabilitado por la plataforma (violación DLP, facturación o conexión rota); revisar caso por caso.

| Flow | Owner | Últ. modificación |
|---|---|---|
| asdasda | Adrian Santos Mendoza Soplopuco | 2026-07-20 |
| Guarda adjunto de correos con asunto "plan" | Ernesto Rodrigo Arevalo Villanueva | 2026-07-08 |
| Garantizar un tiempo de concentración adecuado | Daniela Fabiola Mayca Rodriguez | 2026-06-22 |
| Cuando se crea un archivo -> Crear archivo | Reportes Comerciales | 2026-05-22 |
| C&C - Vacaciones | (usuario eliminado 3dcda98e…) | 2026-04-19 |
| Crear resumen diario de tareas de Planner por cubo | Felipe Andres Capcha Orellana | 2026-03-12 |
| Crear resumen diario de tareas de Planner por cubo | Felipe Andres Capcha Orellana | 2026-03-12 |
| RPA_KEYVAULT_EJECUCION_AUTOMATICA_TXT_EDI | DesarrolloTI Qroma | 2026-03-10 |
| APT | Hanna Adelma Alessandra Orellana Grajeda | 2026-03-04 |
| DISTRIBUCIÓN | Hanna Adelma Alessandra Orellana Grajeda | 2026-03-04 |
| Alerta de la maestra clientes | Reportes Comerciales | 2026-03-02 |
| Send C&C Report Email | Diego Antonio Arce Esteban | 2026-02-11 |
| AMP | Hanna Adelma Alessandra Orellana Grajeda | 2026-01-09 |
| APT EXT | Hanna Adelma Alessandra Orellana Grajeda | 2026-01-09 |
| MESA DE COMPRAS | Maricielo Vera Odar | 2025-10-28 |
