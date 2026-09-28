-- Migración: aprobación de tutorías por el administrador, fecha límite para
-- notas y sistema de notificaciones.
-- Ejecutar sobre una base de datos existente (no recrea nada, es aditiva).

USE student_portal_db;

-- 1) Nuevo estado "rechazada" para que el tutor o el administrador
--    puedan rechazar una solicitud de tutoría.
ALTER TABLE tutorias
    MODIFY estado ENUM('pendiente', 'confirmada', 'rechazada', 'realizada', 'cancelada')
    NOT NULL DEFAULT 'pendiente';

-- 2) Fecha límite para que el docente registre la nota tras culminar la tutoría.
--    Si ya ejecutaste esta migración antes, comenta o elimina esta línea
--    (MySQL 8.0 solo soporta "ADD COLUMN IF NOT EXISTS" desde la versión 8.0.29).
ALTER TABLE tutorias
    ADD COLUMN fecha_limite_notas DATE NULL AFTER estado;

-- Completa la fecha límite de tutorías que ya estén "realizada" y no la tengan.
UPDATE tutorias
SET fecha_limite_notas = DATE_ADD(fecha, INTERVAL 5 DAY)
WHERE estado = 'realizada' AND fecha_limite_notas IS NULL;

-- 3) Tabla de notificaciones.
CREATE TABLE IF NOT EXISTS notificaciones (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    tipo VARCHAR(40) NOT NULL DEFAULT 'general',
    mensaje VARCHAR(255) NOT NULL,
    url VARCHAR(255) NULL,
    leida TINYINT(1) NOT NULL DEFAULT 0,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX idx_notificaciones_usuario_leida (id_usuario, leida)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- 4) Migra tutorías ya "realizada" que todavía no tienen una nota asociada:
--    crea la calificación en 0 (dentro del curso ligado a la materia de la
--    tutoría) para que el docente la vea en su listado y solo tenga que
--    editarla, en lugar de no ver nada que corregir.
INSERT INTO calificaciones (id_inscripcion, tipo, nota, observacion, fecha)
SELECT
    i.id_inscripcion,
    CONCAT('Tutoría: ', m.nombre_materia) AS tipo,
    0 AS nota,
    'Nota pendiente de registrar por el docente tras la tutoría.' AS observacion,
    COALESCE(t.fecha_limite_notas, DATE_ADD(t.fecha, INTERVAL 5 DAY)) AS fecha
FROM tutorias t
JOIN materias m ON m.id_materia = t.id_materia
JOIN estudiantes e ON e.id_estudiante = t.id_estudiante
JOIN inscripciones i ON i.id_estudiante = e.id_estudiante AND i.id_curso = m.id_curso
WHERE t.estado = 'realizada'
  AND m.id_curso IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM calificaciones c2
      WHERE c2.id_inscripcion = i.id_inscripcion
        AND c2.tipo = CONCAT('Tutoría: ', m.nombre_materia)
  );
