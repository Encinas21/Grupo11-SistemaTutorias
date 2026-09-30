-- Reparación preventiva para bases que ejecutaron una versión previa de 016.
-- No marca estudiantes como egresados: solo retira procesos que no cumplen los requisitos.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

UPDATE expedientes_mg x
JOIN estudiantes e ON e.id_estudiante=x.id_estudiante
SET x.estado='retirado',
    x.observaciones=CONCAT(COALESCE(NULLIF(x.observaciones,''),''),
      CASE WHEN COALESCE(x.observaciones,'')='' THEN '' ELSE '\\n' END,
      'Retirado por validación académica: el estudiante no cumple requisitos de egreso.')
WHERE x.estado='activo'
  AND (e.estado_academico NOT IN ('egresado','titulado') OR e.semestre<9
       OR EXISTS (SELECT 1 FROM inscripciones i WHERE i.id_estudiante=e.id_estudiante AND i.estado='activa'));
