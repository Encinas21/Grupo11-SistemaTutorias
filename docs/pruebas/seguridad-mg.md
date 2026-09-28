# Seguridad MG

**Evidencia:** `[PROMPT-MG-SEC-7]`.

Checklist:
- `require_role` y `requerir_permiso` en controllers MG: revisado.
- POST con `validar_csrf()`: revisado en operaciones mutables.
- Acciones mutables no dependen de GET: revisado.
- PDO preparado: revisado en modelos/controllers de MG.
- Escape HTML con `e()`: aplicado en vistas.
- Estudiante/Tutor: controles de pertenencia en expedientes, documentos, defensas y calificaciones.
- CSV: límite 2 MB y protección de fórmula en exportación.
- Bitácora: cambios sensibles registrados.
- `.env`: ignorado por Git; `.env.example` sin secretos reales.

Casos de seguridad que deben repetirse en la demo: cambiar `id_expediente` en URL, POST sin CSRF, CSV con `=SUM(A1:A2)`, HTML no confiable en plantillas y acceso de estudiante a otro expediente.
