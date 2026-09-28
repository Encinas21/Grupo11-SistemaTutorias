# B5 — Diccionario de datos MG

**Evidencia:** `[PROMPT-MG-SEC-8-B5]`.

| Tabla | Campo representativo | Tipo | Regla/origen |
|---|---|---|---|
| expedientes_mg | id_expediente | INT PK | Generado por BD |
| expedientes_mg | id_estudiante | INT FK | `estudiantes` |
| expedientes_mg | etapa_actual | ENUM | Flujo MG |
| asignaciones_tutor | estado | ENUM | vigente/finalizada/reemplazada |
| defensas_mg | fecha/hora/ambiente | DATE/TIME/VARCHAR | Validación de cruces |
| reuniones_mg | asistencia/estado_validacion | ENUM | HU-034/035 |
| informes_avance | porcentaje_avance | TINYINT | 0–100 |
| bitacora_mg | datos_antes/datos_despues | JSON | Auditoría |

Los campos cuya fuente institucional está pendiente se identifican en `parametros_mg` y documentación.
