# Plan de pruebas MG — entrega final

**Evidencia:** `[PROMPT-MG-SEC-10]`.

| ID | HU | Precondición | Resultado esperado | Estado local |
|---|---|---|---|---|
| T-019 | HU-019 | `.env` local | secretos fuera del repositorio | OK |
| T-020 | HU-020 | Docker + MySQL | migraciones idempotentes | OK |
| T-023 | HU-023 | CSV demo | previsualización y errores por fila | Pendiente UI |
| T-024 | HU-024 | seed demo | expedientes visibles | OK |
| T-025 | HU-025 | tutores demo | asignación/historial | OK |
| T-026 | HU-026 | asignación previa | reemplazada + nueva vigente | OK |
| T-028 | HU-028 | tutores | historial tribunal | OK |
| T-029 | HU-029 | defensas demo | cruces detectables | OK |
| T-031 | HU-031 | defensa demo | nota publicada | OK |
| T-034 | HU-034 | asignación demo | reunión/asistencia | OK |
| T-038 | HU-038 | seed demo | A1–A9 calculables según casos | OK por datos de demo |
| T-040 | HU-040 | bitácora demo | consulta filtrable | OK |

La ejecución definitiva en Docker Desktop del usuario debe registrar la evidencia real de navegador y no se inventa aquí.
