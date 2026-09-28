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
