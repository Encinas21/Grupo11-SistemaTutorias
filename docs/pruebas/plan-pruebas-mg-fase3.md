# Plan de pruebas — Fase 3 (HU-034 a HU-040)

- HU-034: registrar reunión pasada, rechazar fecha futura, rechazar antigüedad mayor al parámetro y detectar cruce de Tutor/estudiante.
- HU-035: validar/observar reunión; comprobar que Tutor no puede editar una reunión validada y que la corrección deja motivo en bitácora.
- HU-036: filtrar calendario por cohorte y verificar semáforo próximo/vencido/cumplido.
- HU-037: registrar informe 0..100, verificar presentado/presentado tarde y que el expediente no cambia de estado por informe faltante.
- HU-038: abrir panel y comprobar A1..A9, marcar una alerta con nota y verificar que desaparece de abiertas.
- HU-039: comprobar KPIs de activos, MG1/MG2, defensas 14 días, alertas altas, cartas del mes y carga por Tutor.
- HU-040: filtrar bitácora por tabla, acción y fecha; verificar antes/después, usuario e IP.

Seguridad: CSRF en POST, permisos por rol, pertenencia de Tutor/estudiante y consultas parametrizadas.
