# Plan de pruebas MG — Fase 1

| ID | Caso | Resultado esperado |
|---|---|---|
| HU-023-01 | CSV válido | Previsualización OK y creación al confirmar |
| HU-023-02 | CSV con 5 filas erróneas | Las 5 filas quedan con error y las otras 45 se crean |
| HU-023-03 | Reimportar | No duplica expedientes |
| HU-024-01 | Filtrar expediente | Lista paginada respeta filtros |
| HU-024-02 | Estudiante cambia id URL | Acceso denegado |
| HU-024-03 | Ingreso MG2 | Se cierra etapa anterior y se abre MG2 |
| HU-025-01 | Asignar Tutor | Una sola asignación vigente y notificaciones |
| HU-025-02 | Tutor con carga recomendada | Muestra advertencia, no bloquea |
| HU-026-01 | Cambiar Tutor | Asignación anterior queda reemplazada |
| HU-027-01 | Generar carta | Número correlativo y A4 imprimible |
| HU-027-02 | Reimprimir | Snapshot idéntico aunque cambie la plantilla |
