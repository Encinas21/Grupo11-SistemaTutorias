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
