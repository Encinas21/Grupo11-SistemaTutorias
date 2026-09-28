CREATE DATABASE IF NOT EXISTS student_portal_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE student_portal_db;

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS
    notificaciones,
    evaluaciones_tutoria,
    tutorias,
    asistencia,
    calificaciones,
    inscripciones,
    tutor_materia,
    disponibilidad_tutor,
    cursos,
    materias,
    estudiantes,
    profesores,
    tutores,
    carreras,
    usuarios,
    roles,
    registro_accesos;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    telefono VARCHAR(8) NULL,
    CHECK (telefono IS NULL OR telefono REGEXP '^[0-9]{8}$'),
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE carreras (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    nombre_carrera VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    id_carrera INT NOT NULL,
    semestre TINYINT UNSIGNED NOT NULL,
    estado_academico ENUM('activo','egresado','titulado') NOT NULL DEFAULT 'activo',
    registro_universitario VARCHAR(30) UNIQUE,
    CHECK (semestre BETWEEN 1 AND 9),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera) ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE profesores (
    id_profesor INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    especialidad VARCHAR(150) NULL,
    biografia TEXT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tutores (
    id_tutor INT AUTO_INCREMENT PRIMARY KEY,
    id_profesor INT NOT NULL UNIQUE,
    especialidad VARCHAR(150) NULL,
    biografia TEXT NULL,
    FOREIGN KEY (id_profesor) REFERENCES profesores(id_profesor) ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nombre_curso VARCHAR(150) NOT NULL,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    id_carrera INT NULL,
    id_profesor INT NULL,
    semestre TINYINT UNSIGNED NULL,
    descripcion TEXT NULL,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (id_profesor) REFERENCES profesores(id_profesor) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE materias (
    id_materia INT AUTO_INCREMENT PRIMARY KEY,
    nombre_materia VARCHAR(150) NOT NULL,
    id_carrera INT NULL,
    id_curso INT NULL,
    aula VARCHAR(100) NOT NULL DEFAULT 'Aula 101',
    FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera) ON DELETE SET NULL,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso) ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE inscripciones (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_curso INT NOT NULL,
    fecha_inscripcion DATE NOT NULL,
    estado ENUM('activa', 'retirada', 'finalizada') NOT NULL DEFAULT 'activa',
    UNIQUE KEY uq_inscripcion (id_estudiante, id_curso),
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso) ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE calificaciones (
    id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_inscripcion INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    nota DECIMAL(5, 2) NOT NULL,
    observacion VARCHAR(255) NULL,
    fecha DATE NOT NULL,
    FOREIGN KEY (id_inscripcion) REFERENCES inscripciones(id_inscripcion) ON DELETE CASCADE,
    CHECK (nota >= 0 AND nota <= 100)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE asistencia (
    id_asistencia INT AUTO_INCREMENT PRIMARY KEY,
    id_inscripcion INT NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('presente', 'ausente', 'justificado', 'tarde') NOT NULL,
    observacion VARCHAR(255) NULL,
    UNIQUE KEY uq_asistencia (id_inscripcion, fecha),
    FOREIGN KEY (id_inscripcion) REFERENCES inscripciones(id_inscripcion) ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tutor_materia (
    id_tutor INT NOT NULL,
    id_materia INT NOT NULL,
    PRIMARY KEY (id_tutor, id_materia),
    FOREIGN KEY (id_tutor) REFERENCES tutores(id_tutor) ON DELETE CASCADE,
    FOREIGN KEY (id_materia) REFERENCES materias(id_materia) ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE disponibilidad_tutor (
    id_disponibilidad INT AUTO_INCREMENT PRIMARY KEY,
    id_tutor INT NOT NULL,
    dia_semana ENUM(
        'Lunes',
        'Martes',
        'Miercoles',
        'Jueves',
        'Viernes',
        'Sabado'
    ) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    FOREIGN KEY (id_tutor) REFERENCES tutores(id_tutor) ON DELETE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tutorias (
    id_tutoria INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NULL,
    id_tutor INT NOT NULL,
    id_materia INT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    modalidad ENUM('presencial', 'virtual') NOT NULL DEFAULT 'presencial',
    lugar_o_enlace VARCHAR(200) NULL,
    estado ENUM('disponible', 'pendiente', 'confirmada', 'rechazada', 'realizada', 'cancelada') NOT NULL DEFAULT 'disponible',
    turno_horario ENUM('manana', 'tarde', 'noche') NOT NULL DEFAULT 'manana',
    -- Plazo para que el docente registre la nota de la tutoría una vez marcada como "realizada".
    fecha_limite_notas DATE NULL,
    observaciones TEXT NULL,
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_tutor) REFERENCES tutores(id_tutor) ON DELETE CASCADE,
    FOREIGN KEY (id_materia) REFERENCES materias(id_materia) ON DELETE CASCADE,
    INDEX idx_tutorias_fecha (fecha),
    INDEX idx_tutorias_tutor_fecha (id_tutor, fecha),
    INDEX idx_tutorias_estudiante_fecha (id_estudiante, fecha),
    INDEX idx_tutorias_estado (estado)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

DELIMITER $$
CREATE TRIGGER trg_tutorias_no_domingo_insert
BEFORE INSERT ON tutorias
FOR EACH ROW
BEGIN
    IF DAYOFWEEK(NEW.fecha)=1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se pueden programar clases ni tutorías los domingos.';
    END IF;
END$$
CREATE TRIGGER trg_tutorias_no_domingo_update
BEFORE UPDATE ON tutorias
FOR EACH ROW
BEGIN
    IF DAYOFWEEK(NEW.fecha)=1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No se pueden programar clases ni tutorías los domingos.';
    END IF;
END$$
DELIMITER ;

CREATE TABLE evaluaciones_tutoria (
    id_evaluacion INT AUTO_INCREMENT PRIMARY KEY,
    id_tutoria INT NOT NULL UNIQUE,
    calificacion TINYINT NOT NULL,
    comentario TEXT NULL,
    fecha_evaluacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_tutoria) REFERENCES tutorias(id_tutoria) ON DELETE CASCADE,
    CHECK (calificacion BETWEEN 1 AND 5)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE notificaciones (
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

CREATE TABLE registro_accesos (
    id_acceso INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(45),
    resultado ENUM('exitoso', 'fallido') NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

INSERT INTO roles (id_rol, nombre_rol, descripcion) VALUES
    (1, 'administrador', 'Gestión completa del portal'),
    (2, 'docente', 'Gestión académica de sus cursos y tutorías asignadas'),
    (3, 'estudiante', 'Consulta y solicitud de tutorías propias');

INSERT INTO carreras (id_carrera, nombre_carrera) VALUES
    (1, 'Ingeniería de Sistemas'),
    (2, 'Administración de Empresas'),
    (3, 'Contaduría Pública'),
    (4, 'Derecho'),
    (5, 'Ingeniería Comercial'),
    (6, 'Arquitectura'),
    (7, 'Ingeniería Civil'),
    (8, 'Psicología'),
    (9, 'Marketing y Comunicación'),
    (10, 'Ingeniería Industrial');

INSERT INTO usuarios (
    id_usuario,
    id_rol,
    nombre,
    apellido,
    correo,
    usuario,
    contrasena_hash,
    telefono
) VALUES
    (
        1,
        1,
        'Admin',
        'Sistema',
        'admin@upds.net.com',
        'admin',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        '70000001'
    ),
    (
        2,
        2,
        'Carlos',
        'Fernández',
        'carlos.fernandez@upds.net.com',
        'docente1',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        '70000002'
    ),
    (
        3,
        3,
        'María',
        'Gómez',
        'maria.gomez@upds.net.com',
        'estudiante1',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        '70000003'
    ),
    (
        4,
        2,
        'Laura',
        'Rojas',
        'laura@upds.net.com',
        'docente2',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        '70000004'
    ),
    (
        5,
        3,
        'Juan',
        'Perez',
        'juan@upds.net.com',
        'estudiante2',
        '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
        '70000005'
    );

INSERT INTO profesores (
    id_profesor,
    id_usuario,
    especialidad,
    biografia
) VALUES
    (
        1,
        2,
        'Desarrollo Web y Bases de Datos',
        'Docente especializado en desarrollo backend y arquitecturas web.'
    ),
    (
        2,
        4,
        'Matemática Aplicada',
        'Docente de matemática y análisis cuantitativo.'
    );

INSERT INTO tutores (
    id_tutor,
    id_profesor,
    especialidad,
    biografia
) VALUES
    (
        1,
        1,
        'Desarrollo Web y Bases de Datos',
        'Tutor académico especializado en PHP, bases de datos y desarrollo web.'
    ),
    (
        2,
        2,
        'Matemática Aplicada',
        'Tutor académico para refuerzo de matemática y razonamiento cuantitativo.'
    );

INSERT INTO estudiantes (
    id_estudiante,
    id_usuario,
    id_carrera,
    semestre,
    registro_universitario
) VALUES
    (1, 3, 1, 4, 'RU-2026-98765'),
    (2, 5, 1, 2, 'RU-2026-12345');

INSERT INTO cursos (
    id_curso,
    nombre_curso,
    codigo,
    id_carrera,
    id_profesor,
    semestre,
    descripcion
) VALUES
    (
        1,
        'Base de Datos I',
        'BD-101',
        1,
        1,
        3,
        'Fundamentos de modelado, SQL y bases de datos.'
    ),
    (
        2,
        'Programación I',
        'PR-101',
        1,
        1,
        1,
        'Algoritmos y fundamentos de programación.'
    ),
    (
        3,
        'Tecnología Web I',
        'WEB-101',
        1,
        2,
        4,
        'Desarrollo web con PHP, HTML, CSS y JavaScript.'
    ),
    (
        4,
        'Matemática Discreta',
        'MAT-101',
        1,
        2,
        2,
        'Lógica, conjuntos, relaciones y estructuras discretas.'
    );

INSERT INTO materias (id_materia, nombre_materia, id_carrera, id_curso, aula) VALUES
    (1, 'Base de Datos I', 1, 1, 'Laboratorio 2'),
    (2, 'Programación I', 1, 2, 'Laboratorio 1'),
    (3, 'Tecnología Web I', 1, 3, 'Laboratorio 3'),
    (4, 'Matemática Discreta', 1, 4, 'Aula 204');

INSERT INTO tutor_materia (id_tutor, id_materia) VALUES
    (1, 1),
    (1, 3),
    (2, 4);

INSERT INTO disponibilidad_tutor (
    id_disponibilidad,
    id_tutor,
    dia_semana,
    hora_inicio,
    hora_fin
) VALUES
    (1, 1, 'Lunes', '14:00', '18:00'),
    (2, 1, 'Miercoles', '14:00', '18:00'),
    (3, 2, 'Martes', '09:00', '12:00');

INSERT INTO inscripciones (
    id_inscripcion,
    id_estudiante,
    id_curso,
    fecha_inscripcion,
    estado
) VALUES
    (1, 1, 1, '2026-02-02', 'activa'),
    (2, 1, 2, '2026-02-02', 'activa'),
    (3, 1, 3, '2026-02-02', 'activa'),
    (4, 2, 1, '2026-02-03', 'activa'),
    (5, 2, 4, '2026-02-03', 'activa');

INSERT INTO calificaciones (
    id_inscripcion,
    tipo,
    nota,
    observacion,
    fecha
) VALUES
    (1, 'Parcial 1', 86, 'Buen dominio de SQL', '2026-03-15'),
    (1, 'Trabajo práctico', 92, 'Excelente modelado', '2026-04-02'),
    (2, 'Parcial 1', 78, 'Debe reforzar ciclos', '2026-03-14'),
    (3, 'Proyecto', 95, 'Proyecto completo', '2026-04-20'),
    (4, 'Parcial 1', 73, 'Reforzar consultas', '2026-03-15'),
    (5, 'Parcial 1', 88, 'Buen desempeño', '2026-03-16');

INSERT INTO asistencia (
    id_inscripcion,
    fecha,
    estado,
    observacion
) VALUES
    (1, '2026-03-10', 'presente', NULL),
    (1, '2026-03-17', 'presente', NULL),
    (1, '2026-03-24', 'tarde', 'Llegó 10 minutos tarde'),
    (2, '2026-03-11', 'presente', NULL),
    (2, '2026-03-18', 'ausente', 'Sin justificativo'),
    (3, '2026-03-12', 'presente', NULL),
    (3, '2026-03-19', 'presente', NULL),
    (4, '2026-03-10', 'presente', NULL),
    (5, '2026-03-12', 'justificado', 'Certificación médica');

INSERT INTO tutorias (
    id_estudiante,
    id_tutor,
    id_materia,
    fecha,
    hora_inicio,
    hora_fin,
    modalidad,
    lugar_o_enlace,
    estado,
    observaciones
) VALUES
    (1, 1, 1, '2026-09-07', '14:00', '15:00', 'virtual', 'https://meet.google.com/portal-demo', 'realizada', 'Repaso de consultas JOIN.'),
    (2, 2, 4, '2026-09-08', '09:00', '10:00', 'presencial', 'Aula 204', 'realizada', 'Preparación para evaluación.'),
    (2, 1, 3, '2026-09-09', '14:00', '15:00', 'virtual', 'https://meet.google.com/web-demo', 'realizada', 'Revisión de formulario PHP.'),
    (1, 1, 3, '2026-09-14', '15:00', '16:00', 'presencial', 'Laboratorio 3', 'realizada', 'Repaso de MVC y sesiones.'),
    (1, 2, 4, '2026-09-15', '10:00', '11:00', 'presencial', 'Aula 204', 'cancelada', 'Se canceló por actividad institucional.'),
    (2, 1, 1, '2026-09-16', '16:00', '17:00', 'virtual', 'https://meet.google.com/bd-demo', 'realizada', 'Práctica de subconsultas.'),
    (2, 1, 1, '2026-09-21', '14:00', '15:00', 'presencial', 'Laboratorio 2', 'confirmada', 'Preparación para parcial.'),
    (1, 2, 4, '2026-09-22', '09:00', '10:00', 'virtual', 'https://meet.google.com/mat-demo', 'pendiente', 'Ejercicios de lógica proposicional.'),
    (1, 1, 3, '2026-09-23', '15:00', '16:00', 'virtual', 'https://meet.google.com/web-demo-2', 'confirmada', 'Revisión del proyecto web.'),
    (2, 1, 3, '2026-09-28', '16:00', '17:00', 'presencial', 'Laboratorio 3', 'pendiente', 'Práctica de JavaScript.'),
    (2, 2, 4, '2026-09-29', '10:00', '11:00', 'presencial', 'Aula 204', 'confirmada', 'Repaso de relaciones y conjuntos.'),
    (1, 1, 1, '2026-09-30', '14:00', '15:00', 'virtual', 'https://meet.google.com/sql-demo', 'pendiente', 'Preparación para consultas SQL.'),
    (2, 1, 1, '2026-10-05', '15:00', '16:00', 'presencial', 'Laboratorio 2', 'confirmada', 'Modelado relacional.'),
    (1, 2, 4, '2026-10-06', '11:00', '12:00', 'virtual', 'https://meet.google.com/mat-demo-2', 'pendiente', 'Ejercicios de matrices.'),
    (1, 1, 3, '2026-10-07', '16:00', '17:00', 'presencial', 'Laboratorio 3', 'confirmada', 'Revisión final del proyecto.');

UPDATE tutorias SET turno_horario = CASE
    WHEN hora_inicio >= '19:00:00' THEN 'noche'
    WHEN hora_inicio >= '13:00:00' THEN 'tarde'
    ELSE 'manana'
END;

UPDATE tutorias t
JOIN materias m ON m.id_materia=t.id_materia
SET t.lugar_o_enlace=m.aula;

INSERT INTO evaluaciones_tutoria (
    id_tutoria,
    calificacion,
    comentario
) VALUES
    (1, 5, 'Excelente explicación y seguimiento.'),
    (2, 4, 'Explicó los ejercicios con claridad.'),
    (3, 5, 'Me ayudó a resolver el problema y entender el código.'),
    (4, 4, 'Buena tutoría, especialmente en sesiones y MVC.'),
    (6, 5, 'La práctica de subconsultas fue muy útil.');

-- Datos de demostración v2: completa 15 docentes y 50 estudiantes.
-- Usuarios de prueba: contraseña "password".
USE student_portal_db;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET @hash_password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi';

-- Carreras adicionales (idempotente).
INSERT INTO carreras (id_carrera,nombre_carrera) VALUES
(3,'Contaduría Pública'),(4,'Derecho'),(5,'Ingeniería Comercial'),(6,'Arquitectura'),
(7,'Ingeniería Civil'),(8,'Psicología'),(9,'Marketing y Comunicación'),(10,'Ingeniería Industrial')
ON DUPLICATE KEY UPDATE nombre_carrera=VALUES(nombre_carrera);

-- 13 docentes adicionales: junto a docente1/docente2 = 15 docentes.
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Sofía','Mendoza','sofia.mendoza@upds.net.com','docente3',@hash_password,'70000006' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente3');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Diego','Navarro','diego.navarro@upds.net.com','docente4',@hash_password,'70000007' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente4');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Valeria','Castro','valeria.castro@upds.net.com','docente5',@hash_password,'70000008' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente5');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Andrés','Vargas','andres.vargas@upds.net.com','docente6',@hash_password,'70000009' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente6');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Camila','Herrera','camila.herrera@upds.net.com','docente7',@hash_password,'70000010' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente7');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Mateo','Paredes','mateo.paredes@upds.net.com','docente8',@hash_password,'70000011' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente8');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Gabriela','Ríos','gabriela.rios@upds.net.com','docente9',@hash_password,'70000012' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente9');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Ricardo','Salvatierra','ricardo.salvatierra@upds.net.com','docente10',@hash_password,'70000013' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente10');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Natalia','Pérez','natalia.perez@upds.net.com','docente11',@hash_password,'70000014' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente11');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Jorge','Céspedes','jorge.cespedes@upds.net.com','docente12',@hash_password,'70000015' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente12');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'María','Fernández','maria.fernandez@upds.net.com','docente13',@hash_password,'70000016' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente13');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Álvaro','Quinteros','alvaro.quinteros@upds.net.com','docente14',@hash_password,'70000017' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente14');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Paola','Cárdenas','paola.cardenas@upds.net.com','docente15',@hash_password,'70000018' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente15');

INSERT INTO profesores(id_usuario,especialidad,biografia)
SELECT u.id_usuario, CASE u.usuario
WHEN 'docente3' THEN 'Desarrollo de Software' WHEN 'docente4' THEN 'Bases de Datos' WHEN 'docente5' THEN 'Matemática Aplicada'
WHEN 'docente6' THEN 'Redes y Sistemas' WHEN 'docente7' THEN 'Ingeniería de Software' WHEN 'docente8' THEN 'Tecnología Web'
WHEN 'docente9' THEN 'Contabilidad' WHEN 'docente10' THEN 'Derecho Empresarial' WHEN 'docente11' THEN 'Marketing'
WHEN 'docente12' THEN 'Arquitectura' WHEN 'docente13' THEN 'Ingeniería Civil' WHEN 'docente14' THEN 'Psicología'
ELSE 'Ingeniería Industrial' END,
'Profesional académico incorporado al Sistema de Tutorías.'
FROM usuarios u WHERE u.usuario REGEXP '^docente(3|4|5|6|7|8|9|1[0-5])$'
AND NOT EXISTS(SELECT 1 FROM profesores p WHERE p.id_usuario=u.id_usuario);

INSERT INTO tutores(id_profesor,especialidad,biografia)
SELECT p.id_profesor,p.especialidad,p.biografia FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario
WHERE u.usuario REGEXP '^docente(3|4|5|6|7|8|9|1[0-5])$'
AND NOT EXISTS(SELECT 1 FROM tutores t WHERE t.id_profesor=p.id_profesor);

-- Estudiantes 3..50: junto a estudiante1/estudiante2 = 50.
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) VALUES
(3,'Lucía','Ramírez','lucia.ramirez@upds.net.com','estudiante3',@hash_password,'70000019'),
(3,'Gabriel','Morales','gabriel.morales@upds.net.com','estudiante4',@hash_password,'70000020'),
(3,'Daniela','Flores','daniela.flores@upds.net.com','estudiante5',@hash_password,'70000021'),
(3,'Nicolás','Suárez','nicolas.suarez@upds.net.com','estudiante6',@hash_password,'70000022'),
(3,'Paula','Ríos','paula.rios@upds.net.com','estudiante7',@hash_password,'70000023'),
(3,'Sebastián','Torres','sebastian.torres@upds.net.com','estudiante8',@hash_password,'70000024'),
(3,'Mariana','Vega','mariana.vega@upds.net.com','estudiante9',@hash_password,'70000025'),
(3,'Alejandro','Cárdenas','alejandro.cardenas@upds.net.com','estudiante10',@hash_password,'70000026'),
(3,'Carolina','Molina','carolina.molina@upds.net.com','estudiante11',@hash_password,'70000027'),
(3,'Tomás','Gutiérrez','tomas.gutierrez@upds.net.com','estudiante12',@hash_password,'70000028'),
(3,'Fernanda','Ponce','fernanda.ponce@upds.net.com','estudiante13',@hash_password,'70000029'),
(3,'Javier','Salazar','javier.salazar@upds.net.com','estudiante14',@hash_password,'70000030'),
(3,'Renata','Quispe','renata.quispe@upds.net.com','estudiante15',@hash_password,'70000031'),
(3,'Martín','Choque','martin.choque@upds.net.com','estudiante16',@hash_password,'70000032'),
(3,'Valentina','Arce','valentina.arce@upds.net.com','estudiante17',@hash_password,'70000033'),
(3,'Rodrigo','Mamani','rodrigo.mamani@upds.net.com','estudiante18',@hash_password,'70000034'),
(3,'Elena','Peña','elena.pena@upds.net.com','estudiante19',@hash_password,'70000035'),
(3,'Mauricio','Cabrera','mauricio.cabrera@upds.net.com','estudiante20',@hash_password,'70000036'),
(3,'Isabela','Mendoza','isabela.mendoza@upds.net.com','estudiante21',@hash_password,'70000037'),
(3,'Cristóbal','Villarroel','cristobal.villarroel@upds.net.com','estudiante22',@hash_password,'70000038'),
(3,'Andrea','Salinas','andrea.salinas@upds.net.com','estudiante23',@hash_password,'70000039'),
(3,'Bruno','Aguilar','bruno.aguilar@upds.net.com','estudiante24',@hash_password,'70000040'),
(3,'Cecilia','Moreno','cecilia.moreno@upds.net.com','estudiante25',@hash_password,'70000041'),
(3,'Diego','Paz','diego.paz@upds.net.com','estudiante26',@hash_password,'70000042'),
(3,'Elisa','Méndez','elisa.mendez@upds.net.com','estudiante27',@hash_password,'70000043'),
(3,'Fernando','López','fernando.lopez@upds.net.com','estudiante28',@hash_password,'70000044'),
(3,'Gloria','Vargas','gloria.vargas@upds.net.com','estudiante29',@hash_password,'70000045'),
(3,'Hugo','Rivera','hugo.rivera@upds.net.com','estudiante30',@hash_password,'70000046'),
(3,'Irene','Soto','irene.soto@upds.net.com','estudiante31',@hash_password,'70000047'),
(3,'José','Mendoza','jose.mendoza@upds.net.com','estudiante32',@hash_password,'70000048'),
(3,'Karen','Villar','karen.villar@upds.net.com','estudiante33',@hash_password,'70000049'),
(3,'Luis','Pacheco','luis.pacheco@upds.net.com','estudiante34',@hash_password,'70000050'),
(3,'Mónica','Rojas','monica.rojas@upds.net.com','estudiante35',@hash_password,'70000051'),
(3,'Nelson','Ortega','nelson.ortega@upds.net.com','estudiante36',@hash_password,'70000052'),
(3,'Olivia','Cruz','olivia.cruz@upds.net.com','estudiante37',@hash_password,'70000053'),
(3,'Pablo','Fuentes','pablo.fuentes@upds.net.com','estudiante38',@hash_password,'70000054'),
(3,'Raquel','Luna','raquel.luna@upds.net.com','estudiante39',@hash_password,'70000055'),
(3,'Sergio','Arias','sergio.arias@upds.net.com','estudiante40',@hash_password,'70000056'),
(3,'Tamara','Villarreal','tamara.villarreal@upds.net.com','estudiante41',@hash_password,'70000057'),
(3,'Ulises','Mamani','ulises.mamani@upds.net.com','estudiante42',@hash_password,'70000058'),
(3,'Verónica','Flores','veronica.flores@upds.net.com','estudiante43',@hash_password,'70000059'),
(3,'Walter','Cortez','walter.cortez@upds.net.com','estudiante44',@hash_password,'70000060'),
(3,'Ximena','Paredes','ximena.paredes@upds.net.com','estudiante45',@hash_password,'70000061'),
(3,'Yamila','Molina','yamila.molina@upds.net.com','estudiante46',@hash_password,'70000062'),
(3,'Zoe','Vega','zoe.vega@upds.net.com','estudiante47',@hash_password,'70000063'),
(3,'Adrián','Condori','adrian.condori@upds.net.com','estudiante48',@hash_password,'70000064'),
(3,'Beatriz','López','beatriz.lopez@upds.net.com','estudiante49',@hash_password,'70000065'),
(3,'Carlos','Quisbert','carlos.quisbert@upds.net.com','estudiante50',@hash_password,'70000066')
ON DUPLICATE KEY UPDATE telefono=VALUES(telefono);

INSERT INTO estudiantes(id_usuario,id_carrera,semestre,registro_universitario)
SELECT u.id_usuario, ((u.id_usuario-3) MOD 10)+1, ((u.id_usuario-3) MOD 9)+1, CONCAT('RU-2026-',LPAD(u.id_usuario,5,'0'))
FROM usuarios u WHERE u.usuario REGEXP '^estudiante([3-9]|[1-4][0-9]|50)$'
AND NOT EXISTS(SELECT 1 FROM estudiantes e WHERE e.id_usuario=u.id_usuario);

-- Cursos/materias adicionales para las nuevas carreras.
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Contabilidad Financiera','CON-101',3,p.id_profesor,1,'Fundamentos de contabilidad financiera.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente9' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='CON-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Derecho Empresarial','DER-101',4,p.id_profesor,1,'Principios jurídicos para organizaciones.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente10' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='DER-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Marketing Digital','MKT-101',9,p.id_profesor,1,'Estrategias de marketing digital.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente11' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='MKT-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Diseño Arquitectónico','ARQ-101',6,p.id_profesor,1,'Bases del diseño arquitectónico.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente12' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='ARQ-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Resistencia de Materiales','CIV-101',7,p.id_profesor,2,'Principios de resistencia de materiales.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente13' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='CIV-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Psicología General','PSI-101',8,p.id_profesor,1,'Conceptos introductorios de psicología.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente14' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='PSI-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Procesos Industriales','IND-101',10,p.id_profesor,1,'Introducción a procesos y producción.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente15' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='IND-101');

-- Cursos adicionales para que los docentes 3..8 también tengan alumnos asignados.
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Desarrollo de Software','SW-101',1,p.id_profesor,2,'Fundamentos de desarrollo de software.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente3' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='SW-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Bases de Datos II','BD-201',1,p.id_profesor,4,'Diseño avanzado y optimización de bases de datos.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente4' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='BD-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Matemática Aplicada','MAT-201',1,p.id_profesor,3,'Aplicaciones de matemática en ingeniería.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente5' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='MAT-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Redes de Computadoras','RED-101',1,p.id_profesor,5,'Fundamentos de redes y comunicaciones.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente6' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='RED-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Ingeniería de Software','ING-101',1,p.id_profesor,5,'Procesos y buenas prácticas de ingeniería de software.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente7' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='ING-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Tecnología Web II','WEB-201',1,p.id_profesor,5,'Aplicaciones web modernas y APIs.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente8' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='WEB-201');

INSERT INTO materias(nombre_materia,id_carrera,id_curso,aula)
SELECT c.nombre_curso,c.id_carrera,c.id_curso,CASE c.codigo WHEN 'CON-101' THEN 'Aula 305' WHEN 'DER-101' THEN 'Aula 306' WHEN 'MKT-101' THEN 'Laboratorio 4' WHEN 'ARQ-101' THEN 'Taller 1' WHEN 'CIV-101' THEN 'Laboratorio Civil' WHEN 'PSI-101' THEN 'Aula 307' WHEN 'SW-101' THEN 'Laboratorio 5' WHEN 'BD-201' THEN 'Laboratorio 6' WHEN 'MAT-201' THEN 'Aula 205' WHEN 'RED-101' THEN 'Laboratorio Redes' WHEN 'ING-101' THEN 'Aula 308' WHEN 'WEB-201' THEN 'Laboratorio Web' ELSE 'Laboratorio Industrial' END
FROM cursos c WHERE c.codigo IN('CON-101','DER-101','MKT-101','ARQ-101','CIV-101','PSI-101','IND-101','SW-101','BD-201','MAT-201','RED-101','ING-101','WEB-201')
AND NOT EXISTS(SELECT 1 FROM materias m WHERE m.id_curso=c.id_curso);

INSERT IGNORE INTO tutor_materia(id_tutor,id_materia)
SELECT t.id_tutor,m.id_materia FROM tutores t JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios u ON u.id_usuario=p.id_usuario JOIN materias m ON m.id_curso IN(SELECT c.id_curso FROM cursos c WHERE c.id_profesor=p.id_profesor);

-- Inscripciones demo para que el listado académico tenga alumnos distribuidos.
INSERT IGNORE INTO inscripciones(id_estudiante,id_curso,fecha_inscripcion,estado)
SELECT e.id_estudiante,c.id_curso,'2026-02-02','activa'
FROM estudiantes e CROSS JOIN cursos c
WHERE e.id_estudiante >= 1 AND c.id_curso <= 17
  AND MOD(e.id_estudiante + c.id_curso,7)=0;

-- Notas demo: cada estudiante inscrito tiene tres evaluaciones.
INSERT INTO calificaciones (id_inscripcion,tipo,nota,observacion,fecha)
SELECT i.id_inscripcion,v.tipo,
       CASE v.orden WHEN 1 THEN 65+MOD(i.id_inscripcion*7,31) WHEN 2 THEN 62+MOD(i.id_inscripcion*11,34) ELSE 68+MOD(i.id_inscripcion*13,28) END,
       CASE v.orden WHEN 1 THEN 'Evaluación inicial del curso.' WHEN 2 THEN 'Trabajo práctico y seguimiento académico.' ELSE 'Evaluación de cierre del periodo.' END,
       CASE v.orden WHEN 1 THEN '2026-03-15' WHEN 2 THEN '2026-04-15' ELSE '2026-05-15' END
FROM inscripciones i
CROSS JOIN (SELECT 1 orden,'Parcial 1' tipo UNION ALL SELECT 2,'Trabajo práctico' UNION ALL SELECT 3,'Parcial 2') v
WHERE NOT EXISTS (SELECT 1 FROM calificaciones c WHERE c.id_inscripcion=i.id_inscripcion AND c.tipo=v.tipo);

-- Agenda demostrativa: crea espacios disponibles para el resto de septiembre de 2026
-- en los tres turnos para los docentes 3..8, evitando duplicados.
SELECT NULL,t.id_tutor,m.id_materia,d.fecha,
       CASE h.turno WHEN 'manana' THEN '09:00' WHEN 'tarde' THEN '15:00' ELSE '19:00' END,
       CASE h.turno WHEN 'manana' THEN '11:00' WHEN 'tarde' THEN '18:00' ELSE '22:00' END,
       'presencial',m.aula,'disponible',NULL,h.turno
FROM tutores t
JOIN profesores p ON p.id_profesor=t.id_profesor
JOIN usuarios u ON u.id_usuario=p.id_usuario
JOIN materias m ON m.id_materia=(SELECT MIN(tm2.id_materia) FROM tutor_materia tm2 WHERE tm2.id_tutor=t.id_tutor)
JOIN (SELECT '2026-09-28' fecha UNION ALL SELECT '2026-09-29' UNION ALL SELECT '2026-09-30') d
JOIN (SELECT 'manana' turno UNION ALL SELECT 'tarde' UNION ALL SELECT 'noche') h
WHERE u.usuario IN ('docente3','docente4','docente5','docente6','docente7','docente8')
AND NOT EXISTS (
  SELECT 1 FROM tutorias tx WHERE tx.id_tutor=t.id_tutor AND tx.fecha=d.fecha AND tx.turno_horario=h.turno
);

SELECT
 (SELECT COUNT(*) FROM profesores) AS total_profesores,
 (SELECT COUNT(*) FROM estudiantes) AS total_estudiantes,
 (SELECT COUNT(*) FROM carreras) AS total_carreras;


-- Ampliación demo V3: 100 estudiantes con registros académicos completos.
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) VALUES
(3,'Ariana','Sánchez','ariana.sanchez@upds.net.com','estudiante51',@hash_password,'70000069'),
(3,'Benjamín','Castro','benjamin.castro@upds.net.com','estudiante52',@hash_password,'70000070'),
(3,'Claudia','Rojas','claudia.rojas@upds.net.com','estudiante53',@hash_password,'70000071'),
(3,'Damián','Vega','damian.vega@upds.net.com','estudiante54',@hash_password,'70000072'),
(3,'Estefanía','Paredes','estefania.paredes@upds.net.com','estudiante55',@hash_password,'70000073'),
(3,'Fabián','Salinas','fabian.salinas@upds.net.com','estudiante56',@hash_password,'70000074'),
(3,'Génesis','Mora','genesis.mora@upds.net.com','estudiante57',@hash_password,'70000075'),
(3,'Héctor','Cruz','hector.cruz@upds.net.com','estudiante58',@hash_password,'70000076'),
(3,'Ivana','Mamani','ivana.mamani@upds.net.com','estudiante59',@hash_password,'70000077'),
(3,'Joel','Flores','joel.flores@upds.net.com','estudiante60',@hash_password,'70000078'),
(3,'Karla','Vargas','karla.vargas@upds.net.com','estudiante61',@hash_password,'70000079'),
(3,'Leonardo','Quispe','leonardo.quispe@upds.net.com','estudiante62',@hash_password,'70000080'),
(3,'Melissa','Torrez','melissa.torrez@upds.net.com','estudiante63',@hash_password,'70000081'),
(3,'Noé','Condori','noe.condori@upds.net.com','estudiante64',@hash_password,'70000082'),
(3,'Patricia','Arias','patricia.arias@upds.net.com','estudiante65',@hash_password,'70000083'),
(3,'Rafael','Céspedes','rafael.cespedes@upds.net.com','estudiante66',@hash_password,'70000084'),
(3,'Sandra','Mendoza','sandra.mendoza@upds.net.com','estudiante67',@hash_password,'70000085'),
(3,'Thiago','Aguilar','thiago.aguilar@upds.net.com','estudiante68',@hash_password,'70000086'),
(3,'Valeria','López','valeria.lopez@upds.net.com','estudiante69',@hash_password,'70000087'),
(3,'William','Paz','william.paz@upds.net.com','estudiante70',@hash_password,'70000088'),
(3,'Xavier','Romero','xavier.romero@upds.net.com','estudiante71',@hash_password,'70000089'),
(3,'Yessenia','Ortega','yessenia.ortega@upds.net.com','estudiante72',@hash_password,'70000090'),
(3,'Zaira','Fuentes','zaira.fuentes@upds.net.com','estudiante73',@hash_password,'70000091'),
(3,'Abel','Villarroel','abel.villarroel@upds.net.com','estudiante74',@hash_password,'70000092'),
(3,'Bianca','Soria','bianca.soria@upds.net.com','estudiante75',@hash_password,'70000093'),
(3,'César','Nina','cesar.nina@upds.net.com','estudiante76',@hash_password,'70000094'),
(3,'Diana','Cabrera','diana.cabrera@upds.net.com','estudiante77',@hash_password,'70000095'),
(3,'Emilio','Salazar','emilio.salazar@upds.net.com','estudiante78',@hash_password,'70000096'),
(3,'Fátima','Choque','fatima.choque@upds.net.com','estudiante79',@hash_password,'70000097'),
(3,'Gonzalo','Arce','gonzalo.arce@upds.net.com','estudiante80',@hash_password,'70000098'),
(3,'Helena','Ponce','helena.ponce@upds.net.com','estudiante81',@hash_password,'70000099'),
(3,'Isaac','Rivera','isaac.rivera@upds.net.com','estudiante82',@hash_password,'70000100'),
(3,'Jimena','Morales','jimena.morales@upds.net.com','estudiante83',@hash_password,'70000101'),
(3,'Kevin','Luna','kevin.luna@upds.net.com','estudiante84',@hash_password,'70000102'),
(3,'Laura','Méndez','laura.mendez@upds.net.com','estudiante85',@hash_password,'70000103'),
(3,'Marco','Navarro','marco.navarro@upds.net.com','estudiante86',@hash_password,'70000104'),
(3,'Nadia','Herrera','nadia.herrera@upds.net.com','estudiante87',@hash_password,'70000105'),
(3,'Óscar','Cárdenas','oscar.cardenas@upds.net.com','estudiante88',@hash_password,'70000106'),
(3,'Pilar','Molina','pilar.molina@upds.net.com','estudiante89',@hash_password,'70000107'),
(3,'Raúl','Villar','raul.villar@upds.net.com','estudiante90',@hash_password,'70000108'),
(3,'Sara','Gutiérrez','sara.gutierrez@upds.net.com','estudiante91',@hash_password,'70000109'),
(3,'Tobías','Ríos','tobias.rios@upds.net.com','estudiante92',@hash_password,'70000110'),
(3,'Úrsula','Peña','ursula.pena@upds.net.com','estudiante93',@hash_password,'70000111'),
(3,'Víctor','Fuentes','victor.fuentes@upds.net.com','estudiante94',@hash_password,'70000112'),
(3,'Wendy','Cortez','wendy.cortez@upds.net.com','estudiante95',@hash_password,'70000113'),
(3,'Yuri','Mamani','yuri.mamani@upds.net.com','estudiante96',@hash_password,'70000114'),
(3,'Zulema','Salvatierra','zulema.salvatierra@upds.net.com','estudiante97',@hash_password,'70000115'),
(3,'Adela','Quinteros','adela.quinteros@upds.net.com','estudiante98',@hash_password,'70000116'),
(3,'Braulio','Cárdenas','braulio.cardenas@upds.net.com','estudiante99',@hash_password,'70000117'),
(3,'Carla','Fernández','carla.fernandez@upds.net.com','estudiante100',@hash_password,'70000118')
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre), apellido=VALUES(apellido), telefono=VALUES(telefono);

INSERT INTO estudiantes(id_usuario,id_carrera,semestre,registro_universitario)
SELECT u.id_usuario, MOD(CAST(SUBSTRING(u.usuario,11) AS UNSIGNED)-1,10)+1,
       MOD(CAST(SUBSTRING(u.usuario,11) AS UNSIGNED)-1,9)+1,
       CONCAT('RU-2026-',LPAD(u.id_usuario,5,'0'))
FROM usuarios u
WHERE u.usuario REGEXP '^estudiante(5[1-9]|[6-9][0-9]|100)$'
AND NOT EXISTS (SELECT 1 FROM estudiantes e WHERE e.id_usuario=u.id_usuario);

-- Cédulas de Identidad finales para los 100 estudiantes demo.
UPDATE estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
SET e.registro_universitario = LPAD(MOD(CAST(SUBSTRING(u.usuario,11) AS UNSIGNED) * 73129 + 1241203, 9000000) + 1000000, 7, '0')
WHERE u.usuario REGEXP '^estudiante[0-9]+$';

-- Dos cursos por estudiante para que el sistema tenga información visible desde el inicio.
INSERT IGNORE INTO inscripciones(id_estudiante,id_curso,fecha_inscripcion,estado)
SELECT e.id_estudiante,c.id_curso,'2026-02-02','activa'
FROM estudiantes e
JOIN cursos c ON c.id_curso IN (
  MOD(e.id_estudiante-1,(SELECT MAX(id_curso) FROM cursos))+1,
  MOD(e.id_estudiante+4,(SELECT MAX(id_curso) FROM cursos))+1
)
WHERE e.id_estudiante BETWEEN 1 AND 100;

-- Tres notas por inscripción.
INSERT INTO calificaciones (id_inscripcion,tipo,nota,observacion,fecha)
SELECT i.id_inscripcion,v.tipo,
       CASE v.orden WHEN 1 THEN 65+MOD(i.id_inscripcion*7,31)
                    WHEN 2 THEN 62+MOD(i.id_inscripcion*11,34)
                    ELSE 68+MOD(i.id_inscripcion*13,28) END,
       CASE v.orden WHEN 1 THEN 'Evaluación inicial del curso.'
                    WHEN 2 THEN 'Trabajo práctico y seguimiento académico.'
                    ELSE 'Evaluación de cierre del periodo.' END,
       CASE v.orden WHEN 1 THEN '2026-03-15' WHEN 2 THEN '2026-04-15' ELSE '2026-05-15' END
FROM inscripciones i
CROSS JOIN (SELECT 1 orden,'Parcial 1' tipo UNION ALL SELECT 2,'Trabajo práctico' UNION ALL SELECT 3,'Parcial 2') v
WHERE NOT EXISTS (SELECT 1 FROM calificaciones c WHERE c.id_inscripcion=i.id_inscripcion AND c.tipo=v.tipo);

-- Asistencia demo: cinco registros por inscripción.
INSERT IGNORE INTO asistencia(id_inscripcion,fecha,estado,observacion)
SELECT i.id_inscripcion,d.fecha,
       CASE MOD(i.id_inscripcion + d.orden,10) WHEN 0 THEN 'tarde' WHEN 1 THEN 'ausente' ELSE 'presente' END,
       CASE MOD(i.id_inscripcion + d.orden,10) WHEN 0 THEN 'Ingreso posterior al horario.' WHEN 1 THEN 'Inasistencia registrada.' ELSE 'Asistencia registrada.' END
FROM inscripciones i
CROSS JOIN (
 SELECT 1 orden,'2026-03-09' fecha UNION ALL SELECT 2,'2026-03-16' UNION ALL SELECT 3,'2026-03-23' UNION ALL SELECT 4,'2026-03-30' UNION ALL SELECT 5,'2026-04-06'
) d
WHERE NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_inscripcion=i.id_inscripcion AND a.fecha=d.fecha);

-- Tutorías demo V8: agenda equilibrada durante todo el periodo de demostración.
-- Se distribuyen dos espacios por día, de lunes a sábado, rotando docentes y turnos.
-- Los domingos quedan excluidos y el calendario mantiene una carga visual moderada.
INSERT INTO tutorias(id_estudiante,id_tutor,id_materia,fecha,hora_inicio,hora_fin,modalidad,lugar_o_enlace,estado,observaciones,turno_horario)
WITH RECURSIVE fechas AS (
    SELECT DATE('2026-09-28') AS fecha
    UNION ALL
    SELECT fecha + INTERVAL 1 DAY FROM fechas WHERE fecha < DATE('2026-10-31')
), docentes_demo AS (
    SELECT u.id_usuario,
           ROW_NUMBER() OVER (ORDER BY CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)) AS n
    FROM usuarios u
    WHERE u.usuario REGEXP '^docente[0-9]+$' AND u.estado='activo'
), espacios AS (
    SELECT f.fecha,
           d.n,
           ROW_NUMBER() OVER (PARTITION BY f.fecha ORDER BY d.n) AS puesto
    FROM fechas f CROSS JOIN docentes_demo d
    WHERE DAYOFWEEK(f.fecha) <> 1
), seleccion AS (
    SELECT fecha,n,puesto,
           CASE MOD(DATEDIFF(fecha,'2026-09-28') + n,3) WHEN 0 THEN 'manana' WHEN 1 THEN 'tarde' ELSE 'noche' END AS turno
    FROM espacios
    WHERE puesto <= 2
)
SELECT NULL,t.id_tutor,m.id_materia,s.fecha,
       CASE s.turno WHEN 'manana' THEN '09:00' WHEN 'tarde' THEN '15:00' ELSE '19:00' END,
       CASE s.turno WHEN 'manana' THEN '11:00' WHEN 'tarde' THEN '18:00' ELSE '22:00' END,
       'presencial',m.aula,'disponible','Espacio académico disponible para estudiantes.',s.turno
FROM seleccion s
JOIN docentes_demo d ON d.n=s.n
JOIN profesores p ON p.id_usuario=d.id_usuario
JOIN tutores t ON t.id_profesor=p.id_profesor
JOIN tutor_materia tm ON tm.id_tutor=t.id_tutor
JOIN materias m ON m.id_materia=tm.id_materia
WHERE tm.id_materia=(SELECT MIN(tm2.id_materia) FROM tutor_materia tm2 WHERE tm2.id_tutor=t.id_tutor)
AND NOT EXISTS (SELECT 1 FROM tutorias tx WHERE tx.id_tutor=t.id_tutor AND tx.fecha=s.fecha);

-- Garantiza que los listados de usuarios de prueba estén completos.


-- V11: ampliación de datos de demostración a 1.000 estudiantes y 50 docentes.
-- Contraseña para todas las cuentas demo: password.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET SESSION cte_max_recursion_depth = 2000;
UPDATE usuarios SET apellido='Fernández', correo='carlos.fernandez@upds.net.com' WHERE usuario='docente1';

-- Docentes adicionales 16..50, cada uno con nombre, apellido y correo propios.
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
WITH RECURSIVE nums AS (SELECT 16 AS n UNION ALL SELECT n+1 FROM nums WHERE n < 50)
SELECT 2,
 CASE MOD(n-16,35)
  WHEN 0 THEN 'Adriana' WHEN 1 THEN 'Bernardo' WHEN 2 THEN 'Claudia' WHEN 3 THEN 'Damián' WHEN 4 THEN 'Estefanía'
  WHEN 5 THEN 'Federico' WHEN 6 THEN 'Graciela' WHEN 7 THEN 'Hernán' WHEN 8 THEN 'Inés' WHEN 9 THEN 'Joaquín'
  WHEN 10 THEN 'Karina' WHEN 11 THEN 'Leonardo' WHEN 12 THEN 'Milagros' WHEN 13 THEN 'Néstor' WHEN 14 THEN 'Ofelia'
  WHEN 15 THEN 'Patricio' WHEN 16 THEN 'Queralt' WHEN 17 THEN 'Ramiro' WHEN 18 THEN 'Silvia' WHEN 19 THEN 'Teodoro'
  WHEN 20 THEN 'Ubaldo' WHEN 21 THEN 'Viviana' WHEN 22 THEN 'Wilfredo' WHEN 23 THEN 'Ximena' WHEN 24 THEN 'Yolanda'
  WHEN 25 THEN 'Zacarías' WHEN 26 THEN 'Alicia' WHEN 27 THEN 'Benjamín' WHEN 28 THEN 'Daniela' WHEN 29 THEN 'Esteban'
  WHEN 30 THEN 'Florencia' WHEN 31 THEN 'Germán' WHEN 32 THEN 'Helena' WHEN 33 THEN 'Ignacio' ELSE 'Julieta' END,
 CASE MOD(n-16,35)
  WHEN 0 THEN 'Aguilar' WHEN 1 THEN 'Benítez' WHEN 2 THEN 'Cárdenas' WHEN 3 THEN 'Delgado' WHEN 4 THEN 'Escobar'
  WHEN 5 THEN 'Fernández' WHEN 6 THEN 'Guzmán' WHEN 7 THEN 'Heredia' WHEN 8 THEN 'Ibarra' WHEN 9 THEN 'Jiménez'
  WHEN 10 THEN 'Keller' WHEN 11 THEN 'López' WHEN 12 THEN 'Maldonado' WHEN 13 THEN 'Núñez' WHEN 14 THEN 'Ocampo'
  WHEN 15 THEN 'Pacheco' WHEN 16 THEN 'Quiroga' WHEN 17 THEN 'Rojas' WHEN 18 THEN 'Sánchez' WHEN 19 THEN 'Tapia'
  WHEN 20 THEN 'Ugarte' WHEN 21 THEN 'Vargas' WHEN 22 THEN 'Wagner' WHEN 23 THEN 'Ximénez' WHEN 24 THEN 'Yáñez'
  WHEN 25 THEN 'Zeballos' WHEN 26 THEN 'Alarcón' WHEN 27 THEN 'Bustamante' WHEN 28 THEN 'Cabrera' WHEN 29 THEN 'Domínguez'
  WHEN 30 THEN 'Espinoza' WHEN 31 THEN 'Flores' WHEN 32 THEN 'Gutiérrez' WHEN 33 THEN 'Herrera' ELSE 'Ibáñez' END,
 CONCAT('docente',n,'@upds.net.com'), CONCAT('docente',n), @hash_password, LPAD(60000000+n,8,'0')
FROM nums
WHERE NOT EXISTS (SELECT 1 FROM usuarios u WHERE u.usuario=CONCAT('docente',n));

INSERT INTO profesores (id_usuario,especialidad,biografia)
SELECT u.id_usuario, CONCAT('Docencia en ', c.nombre_carrera), CONCAT('Docente responsable de asignaturas y tutorías de ', c.nombre_carrera, ', con acompañamiento y evaluación continua.')
FROM usuarios u
JOIN carreras c ON c.id_carrera = MOD(CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)-16,10)+1
WHERE u.usuario REGEXP '^docente(1[6-9]|[2-4][0-9]|50)$'
AND NOT EXISTS (SELECT 1 FROM profesores p WHERE p.id_usuario=u.id_usuario);

INSERT INTO tutores (id_profesor,especialidad,biografia)
SELECT p.id_profesor,p.especialidad,p.biografia FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario
WHERE u.usuario REGEXP '^docente[0-9]+$'
AND NOT EXISTS (SELECT 1 FROM tutores t WHERE t.id_profesor=p.id_profesor);

-- Cursos avanzados y materias para que los 50 docentes tengan asignaciones académicas.
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Administración de Bases de Datos','BD-301',1,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Administración de Bases de Datos.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente16' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='BD-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Gestión Administrativa II','ADM-201',2,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Gestión Administrativa II.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente17' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='ADM-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Contabilidad de Costos','CON-201',3,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Contabilidad de Costos.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente18' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='CON-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Derecho Laboral','DER-201',4,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Derecho Laboral.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente19' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='DER-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Investigación de Mercados','COM-201',5,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Investigación de Mercados.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente20' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='COM-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Urbanismo I','ARQ-201',6,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Urbanismo I.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente21' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='ARQ-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Hidráulica Aplicada','CIV-201',7,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Hidráulica Aplicada.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente22' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='CIV-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Psicología Educativa','PSI-201',8,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Psicología Educativa.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente23' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='PSI-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Marketing Estratégico','MKT-201',9,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Marketing Estratégico.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente24' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='MKT-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Logística Industrial','IND-201',10,p.id_profesor,2,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Logística Industrial.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente25' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='IND-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Optimización de Bases de Datos','BD-401',1,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Optimización de Bases de Datos.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente26' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='BD-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Planificación Estratégica','ADM-301',2,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Planificación Estratégica.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente27' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='ADM-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Auditoría Financiera','CON-301',3,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Auditoría Financiera.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente28' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='CON-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Derecho Tributario','DER-301',4,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Derecho Tributario.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente29' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='DER-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Estrategia Comercial','COM-301',5,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Estrategia Comercial.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente30' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='COM-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Diseño Arquitectónico II','ARQ-301',6,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Diseño Arquitectónico II.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente31' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='ARQ-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Estructuras de Hormigón','CIV-301',7,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Estructuras de Hormigón.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente32' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='CIV-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Psicología Social','PSI-301',8,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Psicología Social.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente33' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='PSI-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Comercio Electrónico','MKT-301',9,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Comercio Electrónico.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente34' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='MKT-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Control de Calidad','IND-301',10,p.id_profesor,3,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Control de Calidad.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente35' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='IND-301');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Seguridad de Bases de Datos','BD-501',1,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Seguridad de Bases de Datos.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente36' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='BD-501');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Gestión de Recursos Humanos','ADM-401',2,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Gestión de Recursos Humanos.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente37' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='ADM-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Presupuestos Empresariales','CON-401',3,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Presupuestos Empresariales.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente38' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='CON-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Legislación Comercial','DER-401',4,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Legislación Comercial.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente39' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='DER-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Comercio Internacional','COM-401',5,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Comercio Internacional.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente40' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='COM-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Construcción Sustentable','ARQ-401',6,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Construcción Sustentable.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente41' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='ARQ-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Geotecnia Aplicada','CIV-401',7,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Geotecnia Aplicada.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente42' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='CIV-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Evaluación Psicológica','PSI-401',8,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Evaluación Psicológica.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente43' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='PSI-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Comunicación Digital','MKT-401',9,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Comunicación Digital.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente44' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='MKT-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Gestión de Producción','IND-401',10,p.id_profesor,4,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Gestión de Producción.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente45' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='IND-401');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Programación II','PR-201',1,p.id_profesor,5,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Programación II.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente46' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='PR-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Administración de Proyectos','ADM-501',2,p.id_profesor,5,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Administración de Proyectos.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente47' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='ADM-501');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Tributación Aplicada','CON-501',3,p.id_profesor,5,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Tributación Aplicada.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente48' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='CON-501');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Derecho Corporativo','DER-501',4,p.id_profesor,5,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Derecho Corporativo.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente49' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='DER-501');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado) SELECT 'Gestión de Ventas','COM-501',5,p.id_profesor,5,'Asignatura orientada al desarrollo de competencias académicas y profesionales en Gestión de Ventas.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente50' AND NOT EXISTS (SELECT 1 FROM cursos WHERE codigo='COM-501');

-- Cada curso tiene su materia y cada docente tiene asignada al menos una materia de tutoría.
INSERT INTO materias(nombre_materia,id_carrera,id_curso,aula)
SELECT c.nombre_curso,c.id_carrera,c.id_curso,CONCAT('Aula ',LPAD(c.id_curso,3,'0'))
FROM cursos c WHERE NOT EXISTS (SELECT 1 FROM materias m WHERE m.id_curso=c.id_curso);

INSERT IGNORE INTO tutor_materia(id_tutor,id_materia)
SELECT t.id_tutor,m.id_materia FROM tutores t
JOIN profesores p ON p.id_profesor=t.id_profesor
JOIN materias m ON m.id_curso=(SELECT MIN(c2.id_curso) FROM cursos c2 WHERE c2.id_profesor=p.id_profesor);

-- Disponibilidad de tutoría de lunes a sábado para todos los docentes, sin domingos.
INSERT INTO disponibilidad_tutor(id_tutor,dia_semana,hora_inicio,hora_fin)
SELECT t.id_tutor,d.dia,'09:00','18:00'
FROM tutores t
CROSS JOIN (SELECT 'Lunes' dia UNION ALL SELECT 'Martes' UNION ALL SELECT 'Miercoles' UNION ALL SELECT 'Jueves' UNION ALL SELECT 'Viernes' UNION ALL SELECT 'Sabado') d
WHERE NOT EXISTS (SELECT 1 FROM disponibilidad_tutor x WHERE x.id_tutor=t.id_tutor AND x.dia_semana=d.dia AND x.hora_inicio='09:00' AND x.hora_fin='18:00');

-- Estudiantes 101..1000 con datos completos, correos UPDS y C.I. numérica única.
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
WITH RECURSIVE nums AS (SELECT 101 AS n UNION ALL SELECT n+1 FROM nums WHERE n < 1000)
SELECT 3,
 CASE MOD(n-101,30) WHEN 0 THEN 'Abril' WHEN 1 THEN 'Agustín' WHEN 2 THEN 'Aitana' WHEN 3 THEN 'Alejandra' WHEN 4 THEN 'Amparo'
 WHEN 5 THEN 'Andrés' WHEN 6 THEN 'Ángela' WHEN 7 THEN 'Antonella' WHEN 8 THEN 'Ariana' WHEN 9 THEN 'Benicio'
 WHEN 10 THEN 'Brenda' WHEN 11 THEN 'Camilo' WHEN 12 THEN 'Candela' WHEN 13 THEN 'Dario' WHEN 14 THEN 'Emilia'
 WHEN 15 THEN 'Facundo' WHEN 16 THEN 'Fiorella' WHEN 17 THEN 'Francisco' WHEN 18 THEN 'Gala' WHEN 19 THEN 'Iván'
 WHEN 20 THEN 'Juliana' WHEN 21 THEN 'Lautaro' WHEN 22 THEN 'Luciana' WHEN 23 THEN 'Marcos' WHEN 24 THEN 'Martina'
 WHEN 25 THEN 'Nahuel' WHEN 26 THEN 'Noelia' WHEN 27 THEN 'Renzo' WHEN 28 THEN 'Romina' ELSE 'Thiago' END,
 CASE FLOOR((n-101)/30)
 WHEN 0 THEN 'Alarcón' WHEN 1 THEN 'Barrera' WHEN 2 THEN 'Cabrera' WHEN 3 THEN 'Duarte' WHEN 4 THEN 'Espinoza'
 WHEN 5 THEN 'Figueroa' WHEN 6 THEN 'Gallardo' WHEN 7 THEN 'Hidalgo' WHEN 8 THEN 'Iriarte' WHEN 9 THEN 'Jaramillo'
 WHEN 10 THEN 'Ledesma' WHEN 11 THEN 'Márquez' WHEN 12 THEN 'Navia' WHEN 13 THEN 'Olivera' WHEN 14 THEN 'Peralta'
 WHEN 15 THEN 'Quintana' WHEN 16 THEN 'Roldán' WHEN 17 THEN 'Serrano' WHEN 18 THEN 'Torrico' WHEN 19 THEN 'Urquidi'
 WHEN 20 THEN 'Valencia' WHEN 21 THEN 'Wálter' WHEN 22 THEN 'Yucra' WHEN 23 THEN 'Zambrana' WHEN 24 THEN 'Aguilera'
 WHEN 25 THEN 'Beltrán' WHEN 26 THEN 'Céspedes' WHEN 27 THEN 'Del Carpio' WHEN 28 THEN 'Escalante' ELSE 'Fernández' END,
 CONCAT('estudiante',n,'@upds.net.com'), CONCAT('estudiante',n), @hash_password, LPAD(60000000+n,8,'0')
FROM nums
WHERE NOT EXISTS (SELECT 1 FROM usuarios u WHERE u.usuario=CONCAT('estudiante',n));

INSERT INTO estudiantes(id_usuario,id_carrera,semestre,registro_universitario)
SELECT u.id_usuario, MOD(CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)-1,10)+1,
       MOD(CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)-1,9)+1,
       LPAD(MOD(CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)*73129+1241203,9000000)+1000000,7,'0')
FROM usuarios u WHERE u.usuario REGEXP '^estudiante[0-9]+$'
AND NOT EXISTS (SELECT 1 FROM estudiantes e WHERE e.id_usuario=u.id_usuario);

-- Normaliza las C.I. numéricas para los 1.000 estudiantes y corrige el apellido de Carlos docente.
UPDATE estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
SET e.registro_universitario=LPAD(MOD(CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)*73129+1241203,9000000)+1000000,7,'0')
WHERE u.usuario REGEXP '^estudiante[0-9]+$';
UPDATE usuarios SET apellido='Fernández',correo='carlos.fernandez@upds.net.com' WHERE usuario='docente1';

-- Cada estudiante queda inscrito en tres cursos diferentes.
INSERT IGNORE INTO inscripciones(id_estudiante,id_curso,fecha_inscripcion,estado)
SELECT e.id_estudiante,c.id_curso,DATE_ADD('2026-02-02',INTERVAL MOD(CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED),45) DAY),'activa'
FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
JOIN cursos c ON c.id_curso IN (
 MOD(CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)-1,(SELECT COUNT(*) FROM cursos))+1,
 MOD(CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)+6,(SELECT COUNT(*) FROM cursos))+1,
 MOD(CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)+12,(SELECT COUNT(*) FROM cursos))+1
)
WHERE u.usuario REGEXP '^estudiante[0-9]+$';

-- Tres calificaciones para cada inscripción.
INSERT INTO calificaciones(id_inscripcion,tipo,nota,observacion,fecha)
SELECT i.id_inscripcion,v.tipo,
 CASE v.orden WHEN 1 THEN 65+MOD(i.id_inscripcion*7,31) WHEN 2 THEN 62+MOD(i.id_inscripcion*11,34) ELSE 68+MOD(i.id_inscripcion*13,28) END,
 CASE v.orden WHEN 1 THEN 'Evaluación inicial del curso.' WHEN 2 THEN 'Trabajo práctico y seguimiento académico.' ELSE 'Evaluación de cierre del periodo.' END,
 CASE v.orden WHEN 1 THEN '2026-03-15' WHEN 2 THEN '2026-04-15' ELSE '2026-05-15' END
FROM inscripciones i CROSS JOIN (SELECT 1 orden,'Parcial 1' tipo UNION ALL SELECT 2,'Trabajo práctico' UNION ALL SELECT 3,'Parcial 2') v
WHERE NOT EXISTS (SELECT 1 FROM calificaciones x WHERE x.id_inscripcion=i.id_inscripcion AND x.tipo=v.tipo);

-- Cinco registros de asistencia por inscripción.
INSERT IGNORE INTO asistencia(id_inscripcion,fecha,estado,observacion)
SELECT i.id_inscripcion,d.fecha,
 CASE MOD(i.id_inscripcion+d.orden,10) WHEN 0 THEN 'tarde' WHEN 1 THEN 'ausente' WHEN 2 THEN 'justificado' ELSE 'presente' END,
 CASE MOD(i.id_inscripcion+d.orden,10) WHEN 0 THEN 'Ingreso posterior al horario.' WHEN 1 THEN 'Inasistencia registrada.' WHEN 2 THEN 'Inasistencia justificada.' ELSE 'Asistencia registrada.' END
FROM inscripciones i CROSS JOIN (
 SELECT 1 orden,'2026-03-09' fecha UNION ALL SELECT 2,'2026-03-16' UNION ALL SELECT 3,'2026-03-23' UNION ALL SELECT 4,'2026-03-30' UNION ALL SELECT 5,'2026-04-06'
) d
WHERE NOT EXISTS (SELECT 1 FROM asistencia a WHERE a.id_inscripcion=i.id_inscripcion AND a.fecha=d.fecha);

-- Tutorías individuales para los estudiantes, seis por día de lunes a sábado, entre noviembre de 2026 y mayo de 2027.
-- Cada docente recibe sesiones rotativas y no se programan tutorías los domingos.
INSERT INTO tutorias(id_estudiante,id_tutor,id_materia,fecha,hora_inicio,hora_fin,modalidad,lugar_o_enlace,estado,observaciones,turno_horario)
WITH RECURSIVE fechas AS (
 SELECT DATE('2026-11-02') AS fecha
 UNION ALL SELECT fecha + INTERVAL 1 DAY FROM fechas WHERE fecha < DATE('2027-06-30')
), dias AS (
 SELECT fecha, ROW_NUMBER() OVER (ORDER BY fecha) AS dia_num FROM fechas WHERE DAYOFWEEK(fecha) <> 1
), estudiantes_n AS (
 SELECT e.id_estudiante,CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED) AS n
 FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.usuario REGEXP '^estudiante[0-9]+$'
), asignaciones AS (
 SELECT en.id_estudiante,en.n,d.fecha,MOD(en.n-1,50)+1 AS docente_num,MOD(en.n-1,3) AS turno_num
 FROM estudiantes_n en JOIN dias d ON d.dia_num=FLOOR((en.n-1)/6)+1
)
SELECT a.id_estudiante,t.id_tutor,m.id_materia,a.fecha,
 CASE a.turno_num WHEN 0 THEN '09:00' WHEN 1 THEN '14:00' ELSE '17:00' END,
 CASE a.turno_num WHEN 0 THEN '10:00' WHEN 1 THEN '15:00' ELSE '18:00' END,
 'presencial',m.aula,'confirmada','Tutoría individual de seguimiento académico y refuerzo de contenidos.',
 CASE a.turno_num WHEN 0 THEN 'manana' WHEN 1 THEN 'tarde' ELSE 'noche' END
FROM asignaciones a
JOIN usuarios u ON u.usuario=CONCAT('docente',a.docente_num)
JOIN profesores p ON p.id_usuario=u.id_usuario
JOIN tutores t ON t.id_profesor=p.id_profesor
JOIN materias m ON m.id_curso=(SELECT MIN(c.id_curso) FROM cursos c WHERE c.id_profesor=p.id_profesor)
WHERE NOT EXISTS (SELECT 1 FROM tutorias tx WHERE tx.id_estudiante=a.id_estudiante);

-- Normalización V17 de los datos de demostración: semestres por cohortes y notas variadas.
UPDATE estudiantes e
JOIN usuarios u ON u.id_usuario=e.id_usuario
SET e.semestre = MOD(FLOOR((CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)-1)/10),9)+1
WHERE u.usuario REGEXP '^estudiante[0-9]+$';

UPDATE calificaciones cal
JOIN inscripciones i ON i.id_inscripcion=cal.id_inscripcion
JOIN estudiantes e ON e.id_estudiante=i.id_estudiante
JOIN usuarios u ON u.id_usuario=e.id_usuario
SET cal.nota = LEAST(100,42+(e.semestre*4)+MOD(
 CAST(REGEXP_SUBSTR(u.usuario,'[0-9]+$') AS UNSIGNED)*17+i.id_curso*11+
 CASE cal.tipo WHEN 'Parcial 1' THEN 3 WHEN 'Trabajo práctico' THEN 13 WHEN 'Parcial 2' THEN 23 ELSE 31 END,47))
WHERE u.usuario REGEXP '^estudiante[0-9]+$';

-- Resumen de carga de datos demo (debería mostrar 1 administrador, 50 docentes y 1.000 estudiantes).
SELECT (SELECT COUNT(*) FROM usuarios WHERE usuario='admin') AS administradores,
       (SELECT COUNT(*) FROM profesores) AS docentes,
       (SELECT COUNT(*) FROM estudiantes) AS estudiantes,
       (SELECT COUNT(*) FROM cursos) AS cursos,
       (SELECT COUNT(*) FROM inscripciones) AS inscripciones,
       (SELECT COUNT(*) FROM calificaciones) AS calificaciones,
       (SELECT COUNT(*) FROM asistencia) AS registros_asistencia,
       (SELECT COUNT(*) FROM tutorias) AS tutorias;
-- 009_mg_base.sql
-- [CONFIRMADO]/[PENDIENTE]/[PROPUESTA] según docs del módulo MG.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS parametros_mg (
    clave VARCHAR(60) PRIMARY KEY,
    valor VARCHAR(100) NULL,
    descripcion VARCHAR(255) NOT NULL,
    fuente VARCHAR(60) NULL,
    estado_evidencia ENUM('confirmado','pendiente','propuesta') NOT NULL DEFAULT 'pendiente',
    actualizado_por INT NULL,
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_parametros_mg_usuario
        FOREIGN KEY (actualizado_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS modalidades_grado (
    id_modalidad INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL UNIQUE,
    requiere_tutor TINYINT(1) NOT NULL DEFAULT 0,
    flujo ENUM('perfil_mg','examen_areas','excelencia') NOT NULL,
    activa TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cohortes_mg (
    id_cohorte INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(40) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,
    activa TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS calendario_mg (
    id_hito INT AUTO_INCREMENT PRIMARY KEY,
    id_cohorte INT NOT NULL,
    etapa ENUM('previa','mg1','mg2') NOT NULL,
    tipo ENUM('taller','asignacion_tutor','asignacion_tribunal','informe','defensa','ingreso_mg2','otro') NOT NULL,
    nombre VARCHAR(180) NOT NULL,
    orden INT NOT NULL DEFAULT 1,
    fecha_limite DATE NULL,
    avance_esperado_pct TINYINT UNSIGNED NULL,
    CONSTRAINT fk_calendario_mg_cohorte
        FOREIGN KEY (id_cohorte) REFERENCES cohortes_mg(id_cohorte) ON DELETE CASCADE,
    CONSTRAINT chk_calendario_mg_avance CHECK (avance_esperado_pct IS NULL OR avance_esperado_pct BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bitacora_mg (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    usuario INT NULL,
    accion VARCHAR(80) NOT NULL,
    tabla VARCHAR(80) NOT NULL,
    id_registro BIGINT NULL,
    datos_antes JSON NULL,
    datos_despues JSON NULL,
    ip VARCHAR(45) NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_bitacora_mg_fecha (fecha),
    INDEX idx_bitacora_mg_tabla (tabla),
    CONSTRAINT fk_bitacora_mg_usuario
        FOREIGN KEY (usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Roles nuevos: inserción idempotente por nombre.
INSERT INTO roles (nombre_rol, descripcion)
SELECT 'coordinador_mg', 'Gestión operativa de Modalidades de Grado'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE nombre_rol = 'coordinador_mg');

INSERT INTO roles (nombre_rol, descripcion)
SELECT 'auxiliar_mg', 'Logística y registro de Modalidades de Grado'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE nombre_rol = 'auxiliar_mg');

INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'reuniones_min_semana_perfil', '2', 'Reuniones mínimas de referencia por semana durante MG1.', 'ENT-03', 'confirmado'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'reuniones_min_semana_perfil');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'dias_alerta_sin_reunion', '10', 'Días sin reunión para una alerta de seguimiento.', 'Diseño', 'propuesta'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'dias_alerta_sin_reunion');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'tutor_carga_recomendada', '3', 'Carga recomendada de estudiantes por Tutor; no bloquea.', 'ENT-03', 'confirmado'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'tutor_carga_recomendada');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'tutor_max_estudiantes', '', 'Máximo institucional pendiente; no bloquear mientras no exista validación.', 'C-01', 'pendiente'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'tutor_max_estudiantes');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'dias_anticipacion_tribunal', '14', 'Anticipación aproximada para asignar tribunales.', 'ENT-03', 'confirmado'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'dias_anticipacion_tribunal');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'tribunales_por_defensa_mg1', '2', 'Cantidad de tribunales para defensa MG1.', 'ENT-03', 'confirmado'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'tribunales_por_defensa_mg1');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'tribunales_por_defensa_mg2', '2', 'Cantidad de tribunales para defensa MG2.', 'ENT-03', 'pendiente'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'tribunales_por_defensa_mg2');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'min_interesados_examen', '12', 'Referencia pendiente de normativa para Examen de Grado; P3.', 'ENT-03', 'pendiente'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'min_interesados_examen');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'promedio_excelencia', '90', 'Referencia pendiente de normativa para Graduación por Excelencia; P3.', 'ENT-03', 'pendiente'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'promedio_excelencia');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'duracion_mg1_meses', '2', 'Duración aproximada de MG1.', 'ENT-03', 'confirmado'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'duracion_mg1_meses');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'duracion_mg2_meses', '4', 'Duración aproximada de MG2.', 'ENT-03', 'confirmado'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'duracion_mg2_meses');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'plazo_registro_reunion_dias', '7', 'Días hacia atrás permitidos para registrar una reunión; propuesta.', 'Diseño', 'propuesta'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'plazo_registro_reunion_dias');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'nota_minima', '0', 'Límite inferior provisional de nota.', 'Pendiente normativa', 'pendiente'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'nota_minima');
INSERT INTO parametros_mg (clave, valor, descripcion, fuente, estado_evidencia)
SELECT 'nota_maxima', '100', 'Límite superior provisional de nota.', 'Pendiente normativa', 'pendiente'
WHERE NOT EXISTS (SELECT 1 FROM parametros_mg WHERE clave = 'nota_maxima');

INSERT INTO modalidades_grado (codigo, nombre, requiere_tutor, flujo)
SELECT 'PG', 'Proyecto de Grado', 1, 'perfil_mg'
WHERE NOT EXISTS (SELECT 1 FROM modalidades_grado WHERE codigo = 'PG');
INSERT INTO modalidades_grado (codigo, nombre, requiere_tutor, flujo)
SELECT 'TESIS', 'Tesis', 1, 'perfil_mg'
WHERE NOT EXISTS (SELECT 1 FROM modalidades_grado WHERE codigo = 'TESIS');
INSERT INTO modalidades_grado (codigo, nombre, requiere_tutor, flujo)
SELECT 'TD', 'Trabajo Dirigido', 1, 'perfil_mg'
WHERE NOT EXISTS (SELECT 1 FROM modalidades_grado WHERE codigo = 'TD');
INSERT INTO modalidades_grado (codigo, nombre, requiere_tutor, flujo)
SELECT 'EG', 'Examen de Grado', 0, 'examen_areas'
WHERE NOT EXISTS (SELECT 1 FROM modalidades_grado WHERE codigo = 'EG');
INSERT INTO modalidades_grado (codigo, nombre, requiere_tutor, flujo)
SELECT 'GE', 'Graduación por Excelencia', 0, 'excelencia'
WHERE NOT EXISTS (SELECT 1 FROM modalidades_grado WHERE codigo = 'GE');
-- HU-023/HU-024 [CONFIRMADO]/[PROPUESTA]
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS expedientes_mg (
    id_expediente INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_modalidad INT NOT NULL,
    id_cohorte INT NOT NULL,
    etapa_actual ENUM('previa','mg1','mg2','finalizado') NOT NULL DEFAULT 'previa',
    estado ENUM('activo','aprobado','reprobado','abandono','retirado') NOT NULL DEFAULT 'activo',
    titulo_trabajo VARCHAR(255) NULL,
    fecha_inicio DATE NOT NULL,
    fecha_cierre DATE NULL,
    observaciones TEXT NULL,
    UNIQUE KEY uq_expediente_mg_estudiante_modalidad_cohorte (id_estudiante,id_modalidad,id_cohorte),
    CONSTRAINT fk_expedientes_mg_estudiante FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE RESTRICT,
    CONSTRAINT fk_expedientes_mg_modalidad FOREIGN KEY (id_modalidad) REFERENCES modalidades_grado(id_modalidad) ON DELETE RESTRICT,
    CONSTRAINT fk_expedientes_mg_cohorte FOREIGN KEY (id_cohorte) REFERENCES cohortes_mg(id_cohorte) ON DELETE RESTRICT,
    INDEX idx_expedientes_mg_filtros (id_cohorte,id_modalidad,etapa_actual,estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS expediente_etapas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_expediente INT NOT NULL,
    etapa ENUM('previa','mg1','mg2','finalizado') NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,
    resultado VARCHAR(100) NULL,
    registrado_por INT NULL,
    CONSTRAINT fk_expediente_etapas_expediente FOREIGN KEY (id_expediente) REFERENCES expedientes_mg(id_expediente) ON DELETE CASCADE,
    CONSTRAINT fk_expediente_etapas_usuario FOREIGN KEY (registrado_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    INDEX idx_expediente_etapas_expediente (id_expediente,fecha_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS importaciones_mg (
    id_importacion INT AUTO_INCREMENT PRIMARY KEY,
    archivo VARCHAR(255) NOT NULL,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario INT NULL,
    total_filas INT NOT NULL DEFAULT 0,
    total_ok INT NOT NULL DEFAULT 0,
    total_advertencias INT NOT NULL DEFAULT 0,
    total_errores INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_importaciones_mg_usuario FOREIGN KEY (usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS importaciones_mg_detalle (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_importacion INT NOT NULL,
    numero_fila INT NOT NULL,
    registro_universitario VARCHAR(30) NULL,
    nombres VARCHAR(150) NULL,
    apellidos VARCHAR(150) NULL,
    resultado ENUM('ok','advertencia','error','pendiente_cuenta','omitido') NOT NULL,
    mensaje VARCHAR(500) NULL,
    datos JSON NULL,
    id_expediente INT NULL,
    CONSTRAINT fk_importaciones_mg_detalle_importacion FOREIGN KEY (id_importacion) REFERENCES importaciones_mg(id_importacion) ON DELETE CASCADE,
    CONSTRAINT fk_importaciones_mg_detalle_expediente FOREIGN KEY (id_expediente) REFERENCES expedientes_mg(id_expediente) ON DELETE SET NULL,
    INDEX idx_importaciones_mg_detalle_importacion (id_importacion,numero_fila)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
-- HU-025/HU-026/HU-027 [CONFIRMADO]/[PROPUESTA]
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS asignaciones_tutor (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_expediente INT NOT NULL,
    id_tutor INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_fin DATE NULL,
    estado ENUM('vigente','finalizada','reemplazada') NOT NULL DEFAULT 'vigente',
    motivo_fin VARCHAR(500) NULL,
    referencia_decanatura VARCHAR(100) NULL,
    disponibilidad_consultada TINYINT(1) NOT NULL DEFAULT 0,
    numero_carta VARCHAR(30) NULL,
    observaciones TEXT NULL,
    registrado_por INT NULL,
    CONSTRAINT fk_asignaciones_mg_expediente FOREIGN KEY (id_expediente) REFERENCES expedientes_mg(id_expediente) ON DELETE CASCADE,
    CONSTRAINT fk_asignaciones_mg_tutor FOREIGN KEY (id_tutor) REFERENCES tutores(id_tutor) ON DELETE RESTRICT,
    CONSTRAINT fk_asignaciones_mg_usuario FOREIGN KEY (registrado_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    INDEX idx_asignaciones_mg_expediente (id_expediente,estado),
    INDEX idx_asignaciones_mg_tutor (id_tutor,estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS plantillas_documento (
    id_plantilla INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(80) NOT NULL UNIQUE,
    nombre VARCHAR(180) NOT NULL,
    cuerpo_html LONGTEXT NOT NULL,
    version INT NOT NULL DEFAULT 1,
    activa TINYINT(1) NOT NULL DEFAULT 1,
    actualizado_por INT NULL,
    CONSTRAINT fk_plantillas_documento_usuario FOREIGN KEY (actualizado_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS documentos_generados (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_plantilla INT NULL,
    tipo VARCHAR(80) NOT NULL,
    id_expediente INT NULL,
    destinatario VARCHAR(180) NULL,
    numero_correlativo VARCHAR(30) NOT NULL,
    contenido_snapshot LONGTEXT NOT NULL,
    generado_por INT NULL,
    fecha_generacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_documentos_generados_plantilla FOREIGN KEY (id_plantilla) REFERENCES plantillas_documento(id_plantilla) ON DELETE SET NULL,
    CONSTRAINT fk_documentos_generados_expediente FOREIGN KEY (id_expediente) REFERENCES expedientes_mg(id_expediente) ON DELETE SET NULL,
    CONSTRAINT fk_documentos_generados_usuario FOREIGN KEY (generado_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    INDEX idx_documentos_generados_expediente (id_expediente,fecha_generacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contadores_documento (
    tipo VARCHAR(80) NOT NULL,
    anio SMALLINT UNSIGNED NOT NULL,
    ultimo_numero INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (tipo,anio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO plantillas_documento (codigo,nombre,cuerpo_html,version,activa)
SELECT 'CARTA_ASIGNACION_TUTOR','Carta de asignación de Tutor',
'<div style="font-family:Arial,sans-serif;line-height:1.5"><p><strong>[PLANTILLA PROVISIONAL]</strong></p><p>Por medio de la presente se registra la asignación del Tutor para el expediente de <strong>{{estudiante_nombre}}</strong>, registro universitario {{registro_universitario}}.</p><p>Modalidad: {{modalidad}}<br>Carrera: {{carrera}}<br>Cohorte: {{cohorte}}<br>Tema: {{tema}}<br>Tutor: {{tutor_nombre}}</p><p>Número: {{numero_carta}}<br>Fecha: {{fecha_larga}}</p><p>Documento provisional pendiente de sustitución por el formato oficial de UPDS.</p></div>',1,1
WHERE NOT EXISTS (SELECT 1 FROM plantillas_documento WHERE codigo='CARTA_ASIGNACION_TUTOR');
-- Seed MG de desarrollo [PROPUESTA]. Reutiliza usuarios, estudiantes y tutores del seed oficial.
-- No contiene archivos subidos ni secretos; contraseña de desarrollo de usuarios existentes: password.
INSERT INTO cohortes_mg(codigo,nombre,fecha_inicio,fecha_fin,activa)
SELECT 'G1-2026-03','Grupo 1 - Marzo 2026','2026-03-01',NULL,1 WHERE NOT EXISTS(SELECT 1 FROM cohortes_mg WHERE codigo='G1-2026-03');
INSERT INTO cohortes_mg(codigo,nombre,fecha_inicio,fecha_fin,activa)
SELECT 'G2-2026-09','Grupo 2 - Septiembre 2026','2026-09-01',NULL,1 WHERE NOT EXISTS(SELECT 1 FROM cohortes_mg WHERE codigo='G2-2026-09');
INSERT INTO expedientes_mg(id_estudiante,id_modalidad,id_cohorte,etapa_actual,estado,titulo_trabajo,fecha_inicio)
SELECT e.id_estudiante,m.id_modalidad,c.id_cohorte,CASE WHEN u.usuario IN('estudiante1','estudiante2','estudiante3') THEN 'mg1' ELSE 'previa' END,'activo',CONCAT('Tema de demostración - ',u.nombre,' ',u.apellido),'2026-09-01'
FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario CROSS JOIN (SELECT id_modalidad FROM modalidades_grado WHERE codigo='PG') m CROSS JOIN (SELECT id_cohorte FROM cohortes_mg WHERE codigo='G2-2026-09') c
WHERE u.usuario IN('estudiante1','estudiante2','estudiante3','estudiante4','estudiante5','estudiante6')
AND NOT EXISTS(SELECT 1 FROM expedientes_mg x WHERE x.id_estudiante=e.id_estudiante AND x.id_modalidad=m.id_modalidad AND x.id_cohorte=c.id_cohorte);
INSERT INTO expediente_etapas(id_expediente,etapa,fecha_inicio,fecha_fin,resultado)
SELECT x.id_expediente,'previa',x.fecha_inicio,CASE WHEN x.etapa_actual='mg1' THEN '2026-09-14' ELSE NULL END,CASE WHEN x.etapa_actual='mg1' THEN 'Aprobada' ELSE NULL END FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.usuario IN('estudiante1','estudiante2','estudiante3','estudiante4','estudiante5','estudiante6') AND NOT EXISTS(SELECT 1 FROM expediente_etapas ee WHERE ee.id_expediente=x.id_expediente);
INSERT INTO expediente_etapas(id_expediente,etapa,fecha_inicio,registrado_por)
SELECT x.id_expediente,'mg1','2026-09-14',NULL FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.usuario IN('estudiante1','estudiante2','estudiante3') AND NOT EXISTS(SELECT 1 FROM expediente_etapas ee WHERE ee.id_expediente=x.id_expediente AND ee.etapa='mg1');
INSERT INTO asignaciones_tutor(id_expediente,id_tutor,fecha_asignacion,estado,referencia_decanatura,disponibilidad_consultada)
SELECT x.id_expediente,t.id_tutor,'2026-09-10','vigente','DEM-MG-2026-09',1
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario JOIN tutores t ON t.id_tutor IN(1,2,3)
WHERE eu.usuario IN('estudiante1','estudiante2','estudiante3') AND t.id_tutor=CASE eu.usuario WHEN 'estudiante1' THEN 1 WHEN 'estudiante2' THEN 2 ELSE 3 END
AND NOT EXISTS(SELECT 1 FROM asignaciones_tutor a WHERE a.id_expediente=x.id_expediente AND a.estado='vigente');


-- HU-028..031 MG
-- HU-028 a HU-031 [CONFIRMADO]/[PENDIENTE]/[PROPUESTA]
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS tribunales_defensa (
 id INT AUTO_INCREMENT PRIMARY KEY,
 id_expediente INT NOT NULL,
 etapa ENUM('mg1','mg2') NOT NULL,
 id_tutor INT NOT NULL,
 orden TINYINT UNSIGNED NOT NULL,
 fecha_asignacion DATE NOT NULL,
 estado ENUM('vigente','reemplazado') NOT NULL DEFAULT 'vigente',
 registrado_por INT NULL,
 CONSTRAINT fk_tribunal_exp FOREIGN KEY (id_expediente) REFERENCES expedientes_mg(id_expediente) ON DELETE CASCADE,
 CONSTRAINT fk_tribunal_tutor FOREIGN KEY (id_tutor) REFERENCES tutores(id_tutor) ON DELETE RESTRICT,
 CONSTRAINT fk_tribunal_usuario FOREIGN KEY (registrado_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
 INDEX idx_tribunal_exp (id_expediente,etapa,estado), INDEX idx_tribunal_tutor (id_tutor,estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS defensas_mg (
 id_defensa INT AUTO_INCREMENT PRIMARY KEY,
 id_expediente INT NOT NULL,
 etapa ENUM('mg1','mg2') NOT NULL,
 fecha DATE NOT NULL,
 hora_inicio TIME NOT NULL,
 hora_fin TIME NOT NULL,
 ambiente VARCHAR(100) NOT NULL,
 estado ENUM('programada','realizada','reprogramada','cancelada') NOT NULL DEFAULT 'programada',
 obs_fondo TEXT NULL, obs_forma TEXT NULL,
 autorizado_por VARCHAR(150) NULL, referencia_autorizacion VARCHAR(100) NULL,
 CONSTRAINT fk_defensa_exp FOREIGN KEY (id_expediente) REFERENCES expedientes_mg(id_expediente) ON DELETE CASCADE,
 CHECK (hora_fin > hora_inicio), INDEX idx_defensa_fecha (fecha,hora_inicio,hora_fin,estado), INDEX idx_defensa_exp (id_expediente,etapa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS calificaciones_mg (
 id INT AUTO_INCREMENT PRIMARY KEY,
 id_defensa INT NOT NULL UNIQUE,
 nota DECIMAL(5,2) NOT NULL,
 observaciones VARCHAR(1000) NULL,
 publicada TINYINT(1) NOT NULL DEFAULT 0,
 registrada_por INT NULL,
 fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_calif_defensa FOREIGN KEY (id_defensa) REFERENCES defensas_mg(id_defensa) ON DELETE CASCADE,
 CONSTRAINT fk_calif_usuario FOREIGN KEY (registrada_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
 CHECK (nota >= 0 AND nota <= 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- HU-034..038: seguimiento, informes y alertas MG. Idempotente.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS reuniones_mg (
 id_reunion INT AUTO_INCREMENT PRIMARY KEY,
 id_asignacion INT NOT NULL,
 fecha DATE NOT NULL,
 hora_inicio TIME NOT NULL,
 hora_fin TIME NOT NULL,
 modalidad ENUM('presencial','virtual') NOT NULL,
 lugar_o_enlace VARCHAR(500) NULL,
 temas TEXT NOT NULL,
 avance_sesion TINYINT UNSIGNED NULL,
 observaciones TEXT NULL,
 asistio_estudiante ENUM('si','no') NOT NULL,
 asistio_tutor ENUM('si','no') NOT NULL,
 estado_validacion ENUM('registrada','validada','observada') NOT NULL DEFAULT 'registrada',
 registrada_por INT NULL,
 validada_por INT NULL,
 fecha_validacion DATETIME NULL,
 CONSTRAINT fk_reunion_asignacion FOREIGN KEY (id_asignacion) REFERENCES asignaciones_tutor(id_asignacion) ON DELETE CASCADE,
 CONSTRAINT fk_reunion_registro FOREIGN KEY (registrada_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
 CONSTRAINT fk_reunion_validada FOREIGN KEY (validada_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
 CHECK (hora_fin > hora_inicio),
 CHECK (avance_sesion IS NULL OR avance_sesion BETWEEN 0 AND 100),
 INDEX idx_reunion_fecha (fecha,hora_inicio,hora_fin),
 INDEX idx_reunion_asignacion (id_asignacion,fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS informes_avance (
 id_informe INT AUTO_INCREMENT PRIMARY KEY,
 id_expediente INT NOT NULL,
 id_hito INT NOT NULL,
 porcentaje_avance TINYINT UNSIGNED NOT NULL,
 fecha_presentacion DATE NOT NULL,
 formato ENUM('digital','fisico') NOT NULL,
 respaldo_fisico TINYINT(1) NOT NULL DEFAULT 0,
 presentado_por INT NULL,
 observaciones VARCHAR(1000) NULL,
 registrado_por INT NULL,
 CONSTRAINT fk_informe_expediente FOREIGN KEY (id_expediente) REFERENCES expedientes_mg(id_expediente) ON DELETE CASCADE,
 CONSTRAINT fk_informe_hito FOREIGN KEY (id_hito) REFERENCES calendario_mg(id_hito) ON DELETE RESTRICT,
 CONSTRAINT fk_informe_presentado FOREIGN KEY (presentado_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
 CONSTRAINT fk_informe_registrado FOREIGN KEY (registrado_por) REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
 CONSTRAINT uq_informe_expediente_hito UNIQUE (id_expediente,id_hito),
 CHECK (porcentaje_avance BETWEEN 0 AND 100),
 INDEX idx_informe_expediente (id_expediente),
 INDEX idx_informe_hito (id_hito)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS alertas_atendidas (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 tipo_alerta VARCHAR(10) NOT NULL,
 id_referencia INT NOT NULL,
 atendida_por INT NOT NULL,
 nota VARCHAR(1000) NOT NULL,
 fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_alerta_atendida_usuario FOREIGN KEY (atendida_por) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,
 INDEX idx_alerta_atendida_ref (tipo_alerta,id_referencia),
 INDEX idx_alerta_atendida_fecha (fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Hitos de demostración: no fijan una cantidad institucional; la cantidad de tipo informe sigue siendo configurable por cohorte.
INSERT INTO calendario_mg(id_cohorte,etapa,tipo,nombre,orden,fecha_limite,avance_esperado_pct)
SELECT c.id_cohorte,'mg1','taller','Taller de metodología',1,DATE_ADD(c.fecha_inicio,INTERVAL 14 DAY),NULL
FROM cohortes_mg c WHERE NOT EXISTS(SELECT 1 FROM calendario_mg k WHERE k.id_cohorte=c.id_cohorte AND k.tipo='taller');
INSERT INTO calendario_mg(id_cohorte,etapa,tipo,nombre,orden,fecha_limite,avance_esperado_pct)
SELECT c.id_cohorte,'mg1','asignacion_tribunal','Asignación de tribunales MG1',2,DATE_ADD(c.fecha_inicio,INTERVAL 30 DAY),NULL
FROM cohortes_mg c WHERE NOT EXISTS(SELECT 1 FROM calendario_mg k WHERE k.id_cohorte=c.id_cohorte AND k.tipo='asignacion_tribunal');
INSERT INTO calendario_mg(id_cohorte,etapa,tipo,nombre,orden,fecha_limite,avance_esperado_pct)
SELECT c.id_cohorte,'mg2','informe','Informe de avance 1',3,DATE_ADD(c.fecha_inicio,INTERVAL 90 DAY),50
FROM cohortes_mg c WHERE NOT EXISTS(SELECT 1 FROM calendario_mg k WHERE k.id_cohorte=c.id_cohorte AND k.tipo='informe');
INSERT INTO calendario_mg(id_cohorte,etapa,tipo,nombre,orden,fecha_limite,avance_esperado_pct)
SELECT c.id_cohorte,'mg2','informe','Informe de avance 2',4,DATE_ADD(c.fecha_inicio,INTERVAL 120 DAY),70
FROM cohortes_mg c WHERE (SELECT COUNT(*) FROM calendario_mg k WHERE k.id_cohorte=c.id_cohorte AND k.tipo='informe') < 2;
INSERT INTO calendario_mg(id_cohorte,etapa,tipo,nombre,orden,fecha_limite,avance_esperado_pct)
SELECT c.id_cohorte,'mg2','informe','Informe de avance 3',5,DATE_ADD(c.fecha_inicio,INTERVAL 150 DAY),85
FROM cohortes_mg c WHERE (SELECT COUNT(*) FROM calendario_mg k WHERE k.id_cohorte=c.id_cohorte AND k.tipo='informe') < 3;
-- HU-040: bitácora. La tabla ya se crea en 009 para que toda la Fase 0 tenga auditoría.
CREATE TABLE IF NOT EXISTS bitacora_mg (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 usuario INT NULL,
 accion VARCHAR(80) NOT NULL,
 tabla VARCHAR(80) NOT NULL,
 id_registro BIGINT NULL,
 datos_antes JSON NULL,
 datos_despues JSON NULL,
 ip VARCHAR(45) NULL,
 fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_bitacora_mg_fecha (fecha), INDEX idx_bitacora_mg_tabla (tabla),
 CONSTRAINT fk_bitacora_mg_usuario FOREIGN KEY (usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================

-- DEMO FINAL MG (015_mg_seed_demo.sql)
-- HU-019..040 / DEMO-FINAL: datos de demostración MG completos e idempotentes.
-- No representa reglas institucionales adicionales; solo facilita la demo local.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Cohortes y catálogos ya existen desde 009; se refuerzan por si la base fue creada sin el seed completo.
INSERT INTO cohortes_mg(codigo,nombre,fecha_inicio,fecha_fin,activa)
SELECT 'G1-2026-03','Grupo 1 - Marzo 2026','2026-03-01',NULL,1
WHERE NOT EXISTS (SELECT 1 FROM cohortes_mg WHERE codigo='G1-2026-03');
INSERT INTO cohortes_mg(codigo,nombre,fecha_inicio,fecha_fin,activa)
SELECT 'G2-2026-09','Grupo 2 - Septiembre 2026','2026-09-01',NULL,1
WHERE NOT EXISTS (SELECT 1 FROM cohortes_mg WHERE codigo='G2-2026-09');

-- Seis estudiantes demo distribuidos entre las dos cohortes y las cinco modalidades.
INSERT INTO expedientes_mg(id_estudiante,id_modalidad,id_cohorte,etapa_actual,estado,titulo_trabajo,fecha_inicio,observaciones)
SELECT e.id_estudiante,m.id_modalidad,c.id_cohorte,'mg2','activo','[DEMO MG FINAL] Sistema de seguimiento académico', '2026-03-10','Caso demo para seguimiento e informes.'
FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
JOIN modalidades_grado m ON m.codigo='TESIS' JOIN cohortes_mg c ON c.codigo='G1-2026-03'
WHERE u.usuario='estudiante1'
AND NOT EXISTS (SELECT 1 FROM expedientes_mg x WHERE x.id_estudiante=e.id_estudiante AND x.id_modalidad=m.id_modalidad AND x.id_cohorte=c.id_cohorte);
INSERT INTO expedientes_mg(id_estudiante,id_modalidad,id_cohorte,etapa_actual,estado,titulo_trabajo,fecha_inicio,observaciones)
SELECT e.id_estudiante,m.id_modalidad,c.id_cohorte,'mg1','activo','[DEMO MG FINAL] Plataforma de apoyo a decisiones', '2026-03-12','Caso demo para defensa y cruce de agenda.'
FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
JOIN modalidades_grado m ON m.codigo='TD' JOIN cohortes_mg c ON c.codigo='G1-2026-03'
WHERE u.usuario='estudiante2'
AND NOT EXISTS (SELECT 1 FROM expedientes_mg x WHERE x.id_estudiante=e.id_estudiante AND x.id_modalidad=m.id_modalidad AND x.id_cohorte=c.id_cohorte);
INSERT INTO expedientes_mg(id_estudiante,id_modalidad,id_cohorte,etapa_actual,estado,titulo_trabajo,fecha_inicio,fecha_cierre,observaciones)
SELECT e.id_estudiante,m.id_modalidad,c.id_cohorte,'finalizado','aprobado','[DEMO MG FINAL] Examen integrador de áreas', '2026-03-15','2026-08-15','Caso demo finalizado.'
FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
JOIN modalidades_grado m ON m.codigo='EG' JOIN cohortes_mg c ON c.codigo='G1-2026-03'
WHERE u.usuario='estudiante3'
AND NOT EXISTS (SELECT 1 FROM expedientes_mg x WHERE x.id_estudiante=e.id_estudiante AND x.id_modalidad=m.id_modalidad AND x.id_cohorte=c.id_cohorte);
INSERT INTO expedientes_mg(id_estudiante,id_modalidad,id_cohorte,etapa_actual,estado,titulo_trabajo,fecha_inicio,fecha_cierre,observaciones)
SELECT e.id_estudiante,m.id_modalidad,c.id_cohorte,'finalizado','aprobado','[DEMO MG FINAL] Trayectoria académica de excelencia', '2026-03-18','2026-08-20','Caso demo de excelencia; fórmula institucional sigue pendiente.'
FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
JOIN modalidades_grado m ON m.codigo='GE' JOIN cohortes_mg c ON c.codigo='G1-2026-03'
WHERE u.usuario='estudiante4'
AND NOT EXISTS (SELECT 1 FROM expedientes_mg x WHERE x.id_estudiante=e.id_estudiante AND x.id_modalidad=m.id_modalidad AND x.id_cohorte=c.id_cohorte);
INSERT INTO expedientes_mg(id_estudiante,id_modalidad,id_cohorte,etapa_actual,estado,titulo_trabajo,fecha_inicio,observaciones)
SELECT e.id_estudiante,m.id_modalidad,c.id_cohorte,'mg2','activo','[DEMO MG FINAL] Proyecto de grado de ingeniería', '2026-09-03','Caso demo con informes y defensa.'
FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
JOIN modalidades_grado m ON m.codigo='PG' JOIN cohortes_mg c ON c.codigo='G1-2026-03'
WHERE u.usuario='estudiante5'
AND NOT EXISTS (SELECT 1 FROM expedientes_mg x WHERE x.id_estudiante=e.id_estudiante AND x.id_modalidad=m.id_modalidad AND x.id_cohorte=c.id_cohorte AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%');
INSERT INTO expedientes_mg(id_estudiante,id_modalidad,id_cohorte,etapa_actual,estado,titulo_trabajo,fecha_inicio,observaciones)
SELECT e.id_estudiante,m.id_modalidad,c.id_cohorte,'mg1','activo','[DEMO MG FINAL] Caso sin Tutor para alerta A1', '2026-09-05','Caso demo deliberadamente sin Tutor vigente.'
FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
JOIN modalidades_grado m ON m.codigo='PG' JOIN cohortes_mg c ON c.codigo='G2-2026-09'
WHERE u.usuario='estudiante6'
AND NOT EXISTS (SELECT 1 FROM expedientes_mg x WHERE x.id_estudiante=e.id_estudiante AND x.id_modalidad=m.id_modalidad AND x.id_cohorte=c.id_cohorte AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%');


-- Hitos adicionales para que la línea de tiempo muestre ingreso a MG2 y defensa.
INSERT INTO calendario_mg(id_cohorte,etapa,tipo,nombre,orden,fecha_limite,avance_esperado_pct)
SELECT c.id_cohorte,'mg2','ingreso_mg2','Ingreso a MG2',6,DATE_ADD(c.fecha_inicio,INTERVAL 75 DAY),NULL
FROM cohortes_mg c WHERE NOT EXISTS (SELECT 1 FROM calendario_mg k WHERE k.id_cohorte=c.id_cohorte AND k.tipo='ingreso_mg2');
INSERT INTO calendario_mg(id_cohorte,etapa,tipo,nombre,orden,fecha_limite,avance_esperado_pct)
SELECT c.id_cohorte,'mg1','defensa','Defensa MG1 - demo',7,DATE_ADD(CURDATE(),INTERVAL 5 DAY),NULL
FROM cohortes_mg c WHERE NOT EXISTS (SELECT 1 FROM calendario_mg k WHERE k.id_cohorte=c.id_cohorte AND k.tipo='defensa');

-- Etapas de los casos demo.
INSERT INTO expediente_etapas(id_expediente,etapa,fecha_inicio,fecha_fin,resultado)
SELECT x.id_expediente,'previa',x.fecha_inicio,DATE_ADD(x.fecha_inicio,INTERVAL 14 DAY),'Aprobada'
FROM expedientes_mg x WHERE x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM expediente_etapas ee WHERE ee.id_expediente=x.id_expediente AND ee.etapa='previa');
INSERT INTO expediente_etapas(id_expediente,etapa,fecha_inicio,fecha_fin,resultado)
SELECT x.id_expediente,'mg1',DATE_ADD(x.fecha_inicio,INTERVAL 15 DAY),CASE WHEN x.etapa_actual IN('mg2','finalizado') THEN DATE_ADD(x.fecha_inicio,INTERVAL 70 DAY) ELSE NULL END,CASE WHEN x.etapa_actual IN('mg2','finalizado') THEN 'Aprobada' ELSE NULL END
FROM expedientes_mg x WHERE x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM expediente_etapas ee WHERE ee.id_expediente=x.id_expediente AND ee.etapa='mg1');
INSERT INTO expediente_etapas(id_expediente,etapa,fecha_inicio,fecha_fin,resultado)
SELECT x.id_expediente,'mg2',DATE_ADD(x.fecha_inicio,INTERVAL 71 DAY),CASE WHEN x.etapa_actual='finalizado' THEN x.fecha_cierre ELSE NULL END,CASE WHEN x.etapa_actual='finalizado' THEN 'Aprobada' ELSE NULL END
FROM expedientes_mg x WHERE x.titulo_trabajo LIKE '[DEMO MG FINAL]%' AND x.etapa_actual IN('mg2','finalizado')
AND NOT EXISTS (SELECT 1 FROM expediente_etapas ee WHERE ee.id_expediente=x.id_expediente AND ee.etapa='mg2');

-- Tres Tutores demo identificados por usuario, nunca por ID fijo.
-- Tutor 1 recibe carga superior a la recomendada para demostrar A8.
INSERT INTO asignaciones_tutor(id_expediente,id_tutor,fecha_asignacion,estado,referencia_decanatura,disponibilidad_consultada,observaciones)
SELECT x.id_expediente,t.id_tutor,'2026-03-20','reemplazada','DEM-FINAL-001',1,'Asignación histórica de demostración.'
FROM expedientes_mg x
JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN tutores t ON 1=1 JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario
WHERE x.titulo_trabajo LIKE '[DEMO MG FINAL]%' AND eu.usuario='estudiante1' AND tu.usuario='docente3'
AND NOT EXISTS (SELECT 1 FROM asignaciones_tutor a WHERE a.id_expediente=x.id_expediente AND a.id_tutor=t.id_tutor AND a.estado='reemplazada');
INSERT INTO asignaciones_tutor(id_expediente,id_tutor,fecha_asignacion,estado,referencia_decanatura,disponibilidad_consultada,observaciones)
SELECT x.id_expediente,t.id_tutor,'2026-04-01','vigente','DEM-FINAL-002',1,'Cambio de Tutor de demostración.'
FROM expedientes_mg x
JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN tutores t ON 1=1 JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario
WHERE x.titulo_trabajo LIKE '[DEMO MG FINAL]%' AND eu.usuario='estudiante1' AND tu.usuario='docente4'
AND NOT EXISTS (SELECT 1 FROM asignaciones_tutor a WHERE a.id_expediente=x.id_expediente AND a.id_tutor=t.id_tutor AND a.estado='vigente');

INSERT INTO asignaciones_tutor(id_expediente,id_tutor,fecha_asignacion,estado,referencia_decanatura,disponibilidad_consultada,observaciones)
SELECT x.id_expediente,t.id_tutor,'2026-03-21','vigente','DEM-FINAL-003',1,'Tutor demo.'
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN tutores t ON 1=1 JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario
WHERE x.titulo_trabajo LIKE '[DEMO MG FINAL]%' AND eu.usuario='estudiante2' AND tu.usuario='docente4'
AND NOT EXISTS (SELECT 1 FROM asignaciones_tutor a WHERE a.id_expediente=x.id_expediente AND a.estado='vigente');
INSERT INTO asignaciones_tutor(id_expediente,id_tutor,fecha_asignacion,estado,referencia_decanatura,disponibilidad_consultada,observaciones)
SELECT x.id_expediente,t.id_tutor,'2026-03-22','vigente','DEM-FINAL-004',1,'Tutor demo.'
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN tutores t ON 1=1 JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario
WHERE x.titulo_trabajo LIKE '[DEMO MG FINAL]%' AND eu.usuario='estudiante3' AND tu.usuario='docente5'
AND NOT EXISTS (SELECT 1 FROM asignaciones_tutor a WHERE a.id_expediente=x.id_expediente AND a.estado='vigente');
INSERT INTO asignaciones_tutor(id_expediente,id_tutor,fecha_asignacion,estado,referencia_decanatura,disponibilidad_consultada,observaciones)
SELECT x.id_expediente,t.id_tutor,'2026-03-23','vigente','DEM-FINAL-005',1,'Tutor demo.'
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN tutores t ON 1=1 JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario
WHERE x.titulo_trabajo LIKE '[DEMO MG FINAL]%' AND eu.usuario='estudiante4' AND tu.usuario='docente3'
AND NOT EXISTS (SELECT 1 FROM asignaciones_tutor a WHERE a.id_expediente=x.id_expediente AND a.estado='vigente');
INSERT INTO asignaciones_tutor(id_expediente,id_tutor,fecha_asignacion,estado,referencia_decanatura,disponibilidad_consultada,observaciones)
SELECT x.id_expediente,t.id_tutor,'2026-09-10','vigente','DEM-FINAL-006',1,'Tutor demo.'
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN tutores t ON 1=1 JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario
WHERE x.titulo_trabajo LIKE '[DEMO MG FINAL]%' AND eu.usuario='estudiante5' AND tu.usuario='docente3'
AND NOT EXISTS (SELECT 1 FROM asignaciones_tutor a WHERE a.id_expediente=x.id_expediente AND a.estado='vigente');


-- Carga adicional sobre el expediente PG de estudiante6 en G2 para demostrar A8 sin quitar el caso A1 del expediente demo G1.
INSERT INTO asignaciones_tutor(id_expediente,id_tutor,fecha_asignacion,estado,referencia_decanatura,disponibilidad_consultada,observaciones)
SELECT x.id_expediente,t.id_tutor,'2026-09-12','vigente','DEM-FINAL-007',1,'Carga adicional de demostración.'
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN modalidades_grado m ON m.id_modalidad=x.id_modalidad JOIN cohortes_mg c ON c.id_cohorte=x.id_cohorte
JOIN tutores t ON 1=1 JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario
WHERE eu.usuario='estudiante6' AND m.codigo='PG' AND c.codigo='G2-2026-09' AND tu.usuario='docente3'
AND NOT EXISTS (SELECT 1 FROM asignaciones_tutor a WHERE a.id_expediente=x.id_expediente AND a.estado='vigente');

-- Reuniones: una validada reciente, una antigua y una de esta semana.
INSERT INTO reuniones_mg(id_asignacion,fecha,hora_inicio,hora_fin,modalidad,lugar_o_enlace,temas,avance_sesion,observaciones,asistio_estudiante,asistio_tutor,estado_validacion,registrada_por,validada_por,fecha_validacion)
SELECT a.id_asignacion,DATE_SUB(CURDATE(),INTERVAL 3 DAY),'10:00:00','11:00:00','virtual','https://teams.microsoft.com/l/meetup-join/demo-001','Revisión de metodología y avances.',42,'Reunión validada de demostración.','si','si','validada',u1.id_usuario,u2.id_usuario,NOW()
FROM asignaciones_tutor a JOIN expedientes_mg x ON x.id_expediente=a.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario JOIN usuarios u1 ON u1.usuario='docente4' JOIN usuarios u2 ON u2.usuario='coord_mg'
WHERE eu.usuario='estudiante1' AND a.estado='vigente' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM reuniones_mg r WHERE r.id_asignacion=a.id_asignacion AND r.temas='Revisión de metodología y avances.');
INSERT INTO reuniones_mg(id_asignacion,fecha,hora_inicio,hora_fin,modalidad,lugar_o_enlace,temas,avance_sesion,observaciones,asistio_estudiante,asistio_tutor,estado_validacion,registrada_por)
SELECT a.id_asignacion,DATE_SUB(CURDATE(),INTERVAL 12 DAY),'15:00:00','16:00:00','presencial','Sala MG 2','Seguimiento de avance y riesgos.',25,'Reunión antigua para demostrar alerta A2.','si','si','registrada',u1.id_usuario
FROM asignaciones_tutor a JOIN expedientes_mg x ON x.id_expediente=a.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario JOIN usuarios u1 ON u1.usuario='docente4'
WHERE eu.usuario='estudiante2' AND a.estado='vigente' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM reuniones_mg r WHERE r.id_asignacion=a.id_asignacion AND r.temas='Seguimiento de avance y riesgos.');
INSERT INTO reuniones_mg(id_asignacion,fecha,hora_inicio,hora_fin,modalidad,lugar_o_enlace,temas,avance_sesion,observaciones,asistio_estudiante,asistio_tutor,estado_validacion,registrada_por)
SELECT a.id_asignacion,CURDATE(),'09:00:00','10:00:00','presencial','Sala MG 1','Revisión de cronograma.',35,NULL,'si','si','registrada',u1.id_usuario
FROM asignaciones_tutor a JOIN expedientes_mg x ON x.id_expediente=a.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario JOIN usuarios u1 ON u1.usuario='docente5'
WHERE eu.usuario='estudiante3' AND a.estado='vigente' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM reuniones_mg r WHERE r.id_asignacion=a.id_asignacion AND r.temas='Revisión de cronograma.');

-- Informes: uno tardío con bajo avance y dos faltantes para demostrar A4/A5/A6.
INSERT INTO informes_avance(id_expediente,id_hito,porcentaje_avance,fecha_presentacion,formato,respaldo_fisico,presentado_por,observaciones,registrado_por)
SELECT x.id_expediente,k.id_hito,30,DATE_ADD(k.fecha_limite,INTERVAL 8 DAY),'digital',0,u.id_usuario,'Informe demo presentado tarde y con avance inferior al esperado.',u.id_usuario
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN calendario_mg k ON k.id_cohorte=x.id_cohorte AND k.tipo='informe' AND k.orden=3 JOIN usuarios u ON u.usuario='coord_mg'
WHERE eu.usuario='estudiante1' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM informes_avance i WHERE i.id_expediente=x.id_expediente AND i.id_hito=k.id_hito);

-- Defensas: una próxima sin tribunales, otra con tribunales y una con cruce de ambiente para probar validación.
INSERT INTO defensas_mg(id_expediente,etapa,fecha,hora_inicio,hora_fin,ambiente,estado,obs_fondo,obs_forma)
SELECT x.id_expediente,'mg1',DATE_ADD(CURDATE(),INTERVAL 5 DAY),'10:00:00','11:30:00','Sala Defensa A','programada','Caso demo para alerta A7/A9.','Pendiente de citaciones.'
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario
WHERE u.usuario='estudiante2' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM defensas_mg d WHERE d.id_expediente=x.id_expediente AND d.etapa='mg1' AND d.ambiente='Sala Defensa A');
INSERT INTO defensas_mg(id_expediente,etapa,fecha,hora_inicio,hora_fin,ambiente,estado,obs_fondo,obs_forma)
SELECT x.id_expediente,'mg2',DATE_ADD(CURDATE(),INTERVAL 7 DAY),'14:00:00','15:30:00','Sala Defensa B','programada','Defensa demo con tribunal completo.','Citación parcial para demostración.'
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario
WHERE u.usuario='estudiante1' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM defensas_mg d WHERE d.id_expediente=x.id_expediente AND d.etapa='mg2' AND d.ambiente='Sala Defensa B');
INSERT INTO defensas_mg(id_expediente,etapa,fecha,hora_inicio,hora_fin,ambiente,estado,obs_fondo,obs_forma)
SELECT x.id_expediente,'mg1',DATE_ADD(CURDATE(),INTERVAL 5 DAY),'10:30:00','12:00:00','Sala Defensa A','programada','Caso demo deliberadamente conflictivo.','Debe detectarse el cruce de ambiente.'
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario
WHERE u.usuario='estudiante6' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM defensas_mg d WHERE d.id_expediente=x.id_expediente AND d.etapa='mg1' AND d.ambiente='Sala Defensa A');

-- Tribunales para la defensa MG2 de estudiante1: dos vigentes.
INSERT INTO tribunales_defensa(id_expediente,etapa,id_tutor,orden,fecha_asignacion,estado,registrado_por)
SELECT x.id_expediente,'mg2',t.id_tutor,1,CURDATE(),'vigente',u.id_usuario
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN tutores t ON 1=1 JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario JOIN usuarios u ON u.usuario='coord_mg'
WHERE eu.usuario='estudiante1' AND tu.usuario='docente3' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM tribunales_defensa td WHERE td.id_expediente=x.id_expediente AND td.etapa='mg2' AND td.id_tutor=t.id_tutor AND td.estado='vigente');
INSERT INTO tribunales_defensa(id_expediente,etapa,id_tutor,orden,fecha_asignacion,estado,registrado_por)
SELECT x.id_expediente,'mg2',t.id_tutor,2,CURDATE(),'vigente',u.id_usuario
FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
JOIN tutores t ON 1=1 JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario JOIN usuarios u ON u.usuario='coord_mg'
WHERE eu.usuario='estudiante1' AND tu.usuario='docente5' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM tribunales_defensa td WHERE td.id_expediente=x.id_expediente AND td.etapa='mg2' AND td.id_tutor=t.id_tutor AND td.estado='vigente');

-- Una calificación publicada para demostrar consulta del estudiante.
INSERT INTO calificaciones_mg(id_defensa,nota,observaciones,publicada,registrada_por)
SELECT d.id_defensa,87.50,'Calificación demo publicada.',1,u.id_usuario
FROM defensas_mg d JOIN expedientes_mg x ON x.id_expediente=d.id_expediente JOIN usuarios eu ON eu.id_usuario=(SELECT e.id_usuario FROM estudiantes e WHERE e.id_estudiante=x.id_estudiante) JOIN usuarios u ON u.usuario='coord_mg'
WHERE eu.usuario='estudiante1' AND d.etapa='mg2' AND x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
AND NOT EXISTS (SELECT 1 FROM calificaciones_mg c WHERE c.id_defensa=d.id_defensa);

-- Carta y citación demo; se dejan otras defensas sin citación para que A9 sea visible.
INSERT INTO documentos_generados(id_plantilla,tipo,id_expediente,destinatario,numero_correlativo,contenido_snapshot,generado_por)
SELECT p.id_plantilla,'CARTA_ASIGNACION_TUTOR',x.id_expediente,CONCAT(eu.nombre,' ',eu.apellido),'DEMO-CARTA-2026-001','<p>[DEMO MG FINAL] Carta de asignación de Tutor.</p>',u.id_usuario
FROM plantillas_documento p JOIN expedientes_mg x ON x.titulo_trabajo LIKE '[DEMO MG FINAL]%' JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario JOIN usuarios u ON u.usuario='coord_mg'
WHERE p.codigo='CARTA_ASIGNACION_TUTOR' AND eu.usuario='estudiante1'
AND NOT EXISTS (SELECT 1 FROM documentos_generados d WHERE d.id_expediente=x.id_expediente AND d.tipo='CARTA_ASIGNACION_TUTOR' AND d.numero_correlativo='DEMO-CARTA-2026-001');
INSERT INTO documentos_generados(id_plantilla,tipo,id_expediente,destinatario,numero_correlativo,contenido_snapshot,generado_por)
SELECT p.id_plantilla,'CITACION_ESTUDIANTE',x.id_expediente,CONCAT(eu.nombre,' ',eu.apellido),'DEMO-CIT-2026-001','<p>[DEMO MG FINAL] Citación provisional de estudiante.</p>',u.id_usuario
FROM plantillas_documento p JOIN expedientes_mg x ON x.titulo_trabajo LIKE '[DEMO MG FINAL]%' JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario JOIN usuarios u ON u.usuario='coord_mg'
WHERE p.codigo='CARTA_ASIGNACION_TUTOR' AND eu.usuario='estudiante1'
AND NOT EXISTS (SELECT 1 FROM documentos_generados d WHERE d.id_expediente=x.id_expediente AND d.tipo='CITACION_ESTUDIANTE' AND d.numero_correlativo='DEMO-CIT-2026-001');

-- Bitácora visible en la pantalla HU-040.
INSERT INTO bitacora_mg(usuario,accion,tabla,id_registro,datos_antes,datos_despues,ip)
SELECT u.id_usuario,'demo_seed','expedientes_mg',x.id_expediente,NULL,JSON_OBJECT('origen','DEMO MG FINAL','titulo',x.titulo_trabajo),'127.0.0.1'
FROM usuarios u JOIN expedientes_mg x ON x.titulo_trabajo LIKE '[DEMO MG FINAL]%'
WHERE u.usuario='coord_mg'
AND NOT EXISTS (SELECT 1 FROM bitacora_mg b WHERE b.accion='demo_seed' AND b.tabla='expedientes_mg' AND b.id_registro=x.id_expediente);
