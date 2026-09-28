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
