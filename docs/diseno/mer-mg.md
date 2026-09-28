# B5 — MER MG

**Evidencia:** `[PROMPT-MG-SEC-8-B5]`.

Entidades principales: `modalidades_grado`, `cohortes_mg`, `calendario_mg`, `expedientes_mg`, `expediente_etapas`, `asignaciones_tutor`, `plantillas_documento`, `documentos_generados`, `tribunales_defensa`, `defensas_mg`, `calificaciones_mg`, `reuniones_mg`, `informes_avance`, `alertas_atendidas`, `bitacora_mg`.

Relaciones clave: cohorte 1:N hitos; expediente N:1 estudiante/modalidad/cohorte; expediente 1:N etapas/asignaciones/defensas/reuniones/informes; defensa 1:0..1 calificación.
