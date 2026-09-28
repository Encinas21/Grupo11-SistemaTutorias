# A2 — SRS MG v1

**Evidencia:** `[PROMPT-MG-SEC-8-A2]`.

## Requisitos funcionales

- **RF-MG-01 [HU-023]** Importar padrón con previsualización, validación y detalle.
- **RF-MG-02 [HU-024]** Gestionar expediente, etapas y estados.
- **RF-MG-03 [HU-025/026]** Asignar/cambiar Tutor conservando historial.
- **RF-MG-04 [HU-027]** Generar documentos provisionales con correlativo/snapshot.
- **RF-MG-05 [HU-028/029/030]** Gestionar tribunales, agenda y citaciones.
- **RF-MG-06 [HU-031]** Registrar y publicar calificaciones.
- **RF-MG-07 [HU-032/033]** Reportes por estudiante y cohorte.
- **RF-MG-08 [HU-034/035]** Reuniones y validación.
- **RF-MG-09 [HU-036/037]** Hitos e informes.
- **RF-MG-10 [HU-038/039]** Alertas y dashboard.
- **RF-MG-11 [HU-040]** Bitácora consultable.

## Reglas de negocio

- **RN-MG-01..08 [HU-023..031]** validaciones de expediente, tutor, tribunales, agenda, notas y documentos según el prompt.
- **RN-MG-09..11 [HU-034]** reuniones retrospectivas, sin cruce y sin modificar tutorías existentes.
- **RN-MG-12..13 [HU-037]** estado calculado del informe sin alterar estado del expediente.
- **RN-MG-22 [HU-038]** riesgo de abandono es alerta; no cambia estado automáticamente.

Cifras institucionales no confirmadas se mantienen parametrizadas y etiquetadas.
