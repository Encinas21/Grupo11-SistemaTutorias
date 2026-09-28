-- 016_mg_egresados_y_coherencia.sql
-- Regla operativa: solo estudiantes que culminaron la carrera pueden iniciar MG.
-- Compatible con bases creadas por versiones anteriores: si la columna
-- estado_academico no existe, se agrega mediante SQL dinámico compatible con MySQL 8.
-- La migración es idempotente y puede reintentarse después de un fallo.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

SET @col_existe := (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'estudiantes'
      AND column_name = 'estado_academico'
);
SET @sql_estado := IF(
    @col_existe = 0,
    'ALTER TABLE estudiantes ADD COLUMN estado_academico ENUM(''activo'',''egresado'',''titulado'') NOT NULL DEFAULT ''activo'' AFTER semestre',
    'SELECT 1'
);
PREPARE stmt_estado FROM @sql_estado;
EXECUTE stmt_estado;
DEALLOCATE PREPARE stmt_estado;

UPDATE estudiantes e
JOIN usuarios u ON u.id_usuario=e.id_usuario
SET e.semestre=9, e.estado_academico='egresado'
WHERE u.usuario IN ('estudiante1','estudiante2','estudiante3','estudiante4','estudiante5','estudiante6');

UPDATE inscripciones i
JOIN estudiantes e ON e.id_estudiante=i.id_estudiante
JOIN usuarios u ON u.id_usuario=e.id_usuario
SET i.estado='finalizada'
WHERE u.usuario IN ('estudiante1','estudiante2','estudiante3','estudiante4','estudiante5','estudiante6');

-- Los demás estudiantes de demostración conservan su estado académico actual.
