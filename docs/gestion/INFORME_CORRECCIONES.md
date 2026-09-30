# Informe de correcciones – Modalidades de Grado (entrega incremental)

## Alcance aplicado en esta entrega

| Hallazgo | Causa | Corrección | Archivos principales | Prueba ejecutada |
|---|---|---|---|---|
| Estudiantes de semestres iniciales podían aparecer en MG por seeds de demostración | Seeds insertaban expedientes para usuarios demo sin validar egreso y 016 marcaba estudiantes demo como egresados | Se retiraron inserciones ficticias de expedientes de los seeds; 016 ya no promueve cuentas demo; se exige semestre 9, estado egresado/titulado y cero inscripciones activas | `database/migrations/015_mg_seed_demo.sql`, `016_mg_egresados_y_coherencia.sql`, `database/00_init_complete.sql`, `database/init.sql`, `models/MgExpedienteModel.php` | Revisión estática de SQL; `php -l` |
| Expedientes inválidos se borraban físicamente | Migración 019 usaba DELETE y podía destruir historial real | Migración 019 ahora marca como retirado/finalizado y finaliza asignaciones; el listado normal oculta retirados. No se elimina historial en esta versión | `database/migrations/018_mg_regla_egreso_y_limpieza.sql`, `019_mg_eliminar_expedientes_no_elegibles.sql`, `models/MgExpedienteModel.php` | Revisión estática de SQL; no se ejecutó sobre MySQL |
| Expediente no podía pasar de previa a MG1 | No existía transición previa→mg1 | Se agregó método transaccional `iniciarMg1`, control de etapa/estado, cierre de previa, registro de MG1 y botón con CSRF | `models/MgExpedienteModel.php`, `controllers/mg_expedientes.php`, `views/mg/expedientes/ficha.php` | `php -l`; flujo no ejecutado en MySQL |
| Citaciones no se relacionaban con la defensa | Documentos se vinculaban solo al expediente | Migración 020 agrega `id_defensa`, plantillas provisionales y generación transaccional de dos citaciones a tribunal y una al estudiante; A9 verifica documentos por defensa | `020_mg_citaciones.sql`, `MgDocumentoModel.php`, `mg_defensas.php`, `MgSeguimientoModel.php`, `views/mg/defensas/ver.php` | `php -l`; no se ejecutó integración con MySQL |
| Runner podía volver a ejecutar migraciones históricas sobre esquema incluido en init | La instalación inicial no registraba las migraciones 009–016 como aplicadas | Runner reconoce el esquema base completo y registra 009–016 antes de ejecutar nuevas migraciones | `scripts/migrar.php` | `php -l`; no se ejecutó contra MySQL |
| Inicialización fija nombre de base y no eliminaba tablas MG al reconstruir | SQL usaba `CREATE DATABASE/USE` fijo y DROP incompleto | Init usa la base seleccionada por Docker, incluye tablas MG en DROP y `init.sql` queda idéntico | `database/00_init_complete.sql`, `database/init.sql` | Comparación de archivos |
| Auxiliar MG carecía de permisos de edición que figuran en matriz | Permisos de rol incompletos | Se agregaron permisos de expediente/tribunal/defensa y generación de documentos conforme al prompt | `includes/permisos.php` | `php -l` |

## Regla de elegibilidad

La regla confirmada para esta entrega es: semestre 9, situación académica `egresado` o `titulado`, y ninguna inscripción activa. No se marcan estudiantes como egresados automáticamente. Los estudiantes deben tener su situación académica registrada con datos institucionales reales antes de crear el expediente.

## Verificaciones realmente ejecutadas

- `php -l` para todos los archivos PHP: resultado registrado al preparar el ZIP.
- Comparación de `database/00_init_complete.sql` y `database/init.sql`: idénticos.
- Búsqueda estática de DELETE físico de expedientes en migraciones: no se encontró en 018/019 actualizadas.
- Integración con Docker/MySQL: NO EJECUTADA en este entorno (no hay Docker ni cliente MySQL disponible).

## Pendientes del prompt que no deben marcarse como implementados

- HU-029: reprogramar/cancelar/marcar realizada defensa, validar choques y preservar el historial completo.
- HU-030: generación en lote por fecha, reimpresión directa desde documentos y prueba de snapshots de plantillas.
- HU-023: endurecer importador CSV (BOM, autodetección de delimitador, codificación, filas con columnas extra y duplicados internos).
- Alertas atendidas con vigencia/reapertura; corrección completa A4 y pruebas A1–A9.
- HU-031–033: tabla por defensa, promedio provisional, reporte integral imprimible, tutor en CSV y gráfico por cohorte.
- Seguridad transversal: helper de errores PDO, limitación de intentos de login, logout POST+CSRF, sanitización de plantillas, cabeceras/CSP y pruebas de acceso por rol.
- Smoke test HTTP por rol y matriz de pruebas de seguridad ejecutada.
- El archivo externo `PLAN_IMPLEMENTACION_MODALIDADES_GRADO_v1 - TECNOLOGIAS WEB.txt` no está incluido en el ZIP original; se requiere para verificar trazabilidad exacta de HU-019 a HU-040.

## Limitaciones

Esta entrega es incremental, no se declara el criterio de aceptación final como completo. La base de datos real del usuario no está disponible aquí, por lo que no se han inventado estudiantes egresados, tutores asignados ni resultados de pruebas de integración.
