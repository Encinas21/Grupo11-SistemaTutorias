-- Migración completa y segura del módulo Tutorías v2.
-- Compatible con una base existente del proyecto Grupo11.
-- Ejecutar UNA vez desde el contenedor MySQL.
USE student_portal_db;
SET NAMES utf8mb4;

-- 1) Aula de la materia.
-- Esta era la causa del error: versiones anteriores de 'materias' no tenían la columna aula.
ALTER TABLE materias ADD COLUMN IF NOT EXISTS aula VARCHAR(100) NOT NULL DEFAULT 'Aula 101' AFTER id_curso;

UPDATE materias SET aula='Laboratorio 2' WHERE nombre_materia='Base de Datos I';
UPDATE materias SET aula='Laboratorio 1' WHERE nombre_materia='Programación I';
UPDATE materias SET aula='Laboratorio 3' WHERE nombre_materia='Tecnología Web I';
UPDATE materias SET aula='Aula 204' WHERE nombre_materia='Matemática Discreta';

-- 2) Teléfonos bolivianos: 8 dígitos.
ALTER TABLE usuarios MODIFY telefono VARCHAR(8) NULL;

-- El CHECK puede existir ya en algunas instalaciones; se intenta agregar solo si no existe.
SET @existe_chk := (
    SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA=DATABASE()
      AND TABLE_NAME='usuarios'
      AND CONSTRAINT_NAME='chk_telefono_bolivia'
);
SET @sql_chk := IF(@existe_chk=0,
    'ALTER TABLE usuarios ADD CONSTRAINT chk_telefono_bolivia CHECK (telefono IS NULL OR telefono REGEXP ''^[0-9]{8}$'')',
    'SELECT 1');
PREPARE stmt_chk FROM @sql_chk;
EXECUTE stmt_chk;
DEALLOCATE PREPARE stmt_chk;

-- 3) Carreras adicionales.
INSERT INTO carreras (id_carrera, nombre_carrera) VALUES
(3,'Contaduría Pública'),(4,'Derecho'),(5,'Ingeniería Comercial'),(6,'Arquitectura'),
(7,'Ingeniería Civil'),(8,'Psicología'),(9,'Marketing y Comunicación'),(10,'Ingeniería Industrial')
ON DUPLICATE KEY UPDATE nombre_carrera=VALUES(nombre_carrera);

-- 4) Campos necesarios en tutorías v2.
ALTER TABLE tutorias MODIFY id_estudiante INT NULL;
ALTER TABLE tutorias MODIFY estado ENUM('disponible','pendiente','confirmada','rechazada','realizada','cancelada') NOT NULL DEFAULT 'disponible';
ALTER TABLE tutorias ADD COLUMN IF NOT EXISTS turno_horario ENUM('manana','tarde','noche') NOT NULL DEFAULT 'manana' AFTER estado;
ALTER TABLE tutorias ADD COLUMN IF NOT EXISTS fecha_limite_notas DATE NULL AFTER turno_horario;
ALTER TABLE tutorias ADD COLUMN IF NOT EXISTS fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP AFTER observaciones;

UPDATE tutorias SET turno_horario = CASE
    WHEN hora_inicio >= '19:00:00' THEN 'noche'
    WHEN hora_inicio >= '13:00:00' THEN 'tarde'
    ELSE 'manana'
END;

UPDATE tutorias t
JOIN materias m ON m.id_materia=t.id_materia
SET t.lugar_o_enlace=m.aula;

-- 5) Índice para evitar dos espacios del mismo docente en el mismo turno/fecha.
SET @existe_idx := (
    SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA=DATABASE()
      AND TABLE_NAME='tutorias'
      AND INDEX_NAME='idx_tutorias_tutor_fecha_turno'
);
SET @sql_idx := IF(@existe_idx=0,
    'CREATE INDEX idx_tutorias_tutor_fecha_turno ON tutorias (id_tutor, fecha, turno_horario)',
    'SELECT 1');
PREPARE stmt_idx FROM @sql_idx;
EXECUTE stmt_idx;
DEALLOCATE PREPARE stmt_idx;

SELECT 'Migración de Tutorías v2 completada correctamente.' AS resultado;
