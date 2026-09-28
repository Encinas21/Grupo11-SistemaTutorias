# A3 — Backlog MG HU-019 a HU-040

**Evidencia:** `[PROMPT-MG-SEC-8-A3]`.

| HU | Como | Quiero | Para | Prioridad | Dependencia |
|---|---|---|---|---|---|
| HU-019 | Admin | separar configuración | no depender de secretos | Must | Docker |
| HU-020 | Admin | migraciones idempotentes | versionar BD | Must | HU-019 |
| HU-021 | Coordinador | parámetros MG | centralizar cifras | Must | HU-020 |
| HU-022 | Coordinador | catálogo/cohortes/calendario | preparar operación | Must | HU-021 |
| HU-023 | Coordinador/Auxiliar | importar CSV | crear expedientes | Must | HU-022 |
| HU-024 | Responsable MG | gestionar expediente | seguir etapas | Must | HU-023 |
| HU-025 | Coordinador | asignar Tutor | formalizar acompañamiento | Must | HU-024 |
| HU-026 | Coordinador | cambiar Tutor | conservar historial | Must | HU-025 |
| HU-027 | Coordinador | generar carta | documentar asignación | Must | HU-025 |
| HU-028 | Coordinador | asignar tribunales | preparar defensa | Must | HU-024 |
| HU-029 | Coordinador | programar defensa | organizar agenda | Must | HU-028 |
| HU-030 | Coordinador | generar citaciones | notificar | Must | HU-029 |
| HU-031 | Coordinador | registrar/publicar nota | cerrar evaluación | Must | HU-029 |
| HU-032 | Responsable | ver reporte estudiante | consultar trazabilidad | Must | HU-024..031 |
| HU-033 | Coordinador | reportar cohorte | monitorear avance | Must | HU-024..032 |
| HU-034 | Tutor | registrar reunión/asistencia | evidenciar seguimiento | Should | HU-025 |
| HU-035 | Coordinador | validar reunión | controlar calidad | Should | HU-034 |
| HU-036 | Coordinador | ver hitos | anticipar fechas | Should | HU-022 |
| HU-037 | Tutor/Coordinación | registrar informe | medir avance | Should | HU-036 |
| HU-038 | Coordinador | ver alertas | detectar riesgos | Should | HU-034..037 |
| HU-039 | Coordinador | ver dashboard | resumir KPIs | Should | HU-038 |
| HU-040 | Coordinador/Admin | consultar bitácora | auditar cambios | Should | HU-025..039 |

### Criterios resumidos

- Cada HU implementada exige permisos, CSRF, validación de servidor, PDO preparado y evidencia de prueba.
- `[PENDIENTE]` institucional no se convierte en regla dura.
- P3 permanece anotado y no implementado.
