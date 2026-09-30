-- 018_mg_regla_egreso_y_limpieza.sql
-- Regla académica confirmada por el responsable del proyecto: MG requiere noveno semestre
-- culminado, estado egresado/titulado y ninguna inscripción activa. No altera estudiantes.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

UPDATE expedientes_mg x
JOIN estudiantes e ON e.id_estudiante=x.id_estudiante
SET x.estado='retirado', x.etapa_actual='finalizado', x.fecha_cierre=COALESCE(x.fecha_cierre,CURDATE()),
    x.observaciones=CONCAT(COALESCE(NULLIF(x.observaciones,''),''),CASE WHEN COALESCE(x.observaciones,'')='' THEN '' ELSE '\n' END,
      'Retirado por validación académica: no cumple egreso, noveno semestre culminado o no tiene inscripciones activas.')
WHERE x.estado='activo'
  AND (e.semestre<9 OR e.estado_academico NOT IN ('egresado','titulado')
       OR EXISTS (SELECT 1 FROM inscripciones i WHERE i.id_estudiante=e.id_estudiante AND i.estado='activa'));

UPDATE asignaciones_tutor a JOIN expedientes_mg x ON x.id_expediente=a.id_expediente
SET a.estado='finalizada',a.fecha_fin=COALESCE(a.fecha_fin,CURDATE()),
    a.motivo_fin=COALESCE(a.motivo_fin,'Expediente retirado por validación académica.')
WHERE x.estado='retirado' AND a.estado='vigente';

UPDATE tutorias t JOIN estudiantes e ON e.id_estudiante=t.id_estudiante
SET t.estado='cancelada'
WHERE t.estado IN ('pendiente','confirmada')
  AND e.estado_academico IN ('egresado','titulado');
