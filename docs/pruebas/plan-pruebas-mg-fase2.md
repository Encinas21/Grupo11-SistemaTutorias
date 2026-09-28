# Pruebas Fase 2 — HU-028 a HU-033

- **HU-028 [CONFIRMADO]/[PROPUESTA]**: asignar la cantidad configurada de tribunales; reemplazo conserva historial; coincidencia Tutor/Tribunal se maneja como advertencia.
- **HU-029 [CONFIRMADO]**: crear defensa con fecha, hora y ambiente; rechazar cruces de ambiente, estudiante o tribunal; permitir varios días; registrar autorización cuando la fecha quede fuera del calendario (la decisión institucional no la toma el sistema).
- **HU-030 [PROPUESTA]**: documentos de citación se dejan preparados para reutilizar el motor de documentos; la plantilla oficial sigue pendiente.
- **HU-031 [PENDIENTE]**: nota 0-100 provisional, publicación controlada, bitácora; promedio simple solo informativo.
- **HU-032 [PROPUESTA]**: reporte imprimible por estudiante.
- **HU-033 [PROPUESTA]**: reporte por cohorte, Chart.js por CDN y CSV UTF-8 BOM con `;` y protección contra fórmulas.

## Seguridad
1. POST sin CSRF debe rechazarse.
2. Estudiante no puede abrir el expediente de otro estudiante cambiando `id_expediente`.
3. Docente solo puede abrir expedientes con Tutor vigente propio.
4. Auxiliar no puede asignar tribunales ni registrar notas.
5. Exportación CSV antepone `'` a valores que comienzan con `=`, `+`, `-` o `@`.
