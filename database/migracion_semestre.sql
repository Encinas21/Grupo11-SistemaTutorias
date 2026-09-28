USE student_portal_db;

-- Ejecutar una sola vez en instalaciones existentes.
-- MySQL 8.0.16+ aplica CHECK constraints.
ALTER TABLE estudiantes
    ADD CONSTRAINT chk_estudiantes_semestre CHECK (semestre BETWEEN 1 AND 9);
