USE student_portal_db;

CREATE TABLE IF NOT EXISTS solicitudes_perfil (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,

    id_usuario INT NOT NULL,

    campo VARCHAR(50) NOT NULL,

    valor_actual TEXT NULL,

    valor_nuevo TEXT NOT NULL,

    estado ENUM('pendiente', 'aprobada', 'rechazada')
        NOT NULL DEFAULT 'pendiente',

    fecha_solicitud DATETIME
        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    fecha_respuesta DATETIME NULL,

    id_administrador INT NULL,

    observacion_admin VARCHAR(500) NULL,

    FOREIGN KEY (id_usuario)
        REFERENCES usuarios(id_usuario)
        ON DELETE CASCADE,

    FOREIGN KEY (id_administrador)
        REFERENCES usuarios(id_usuario)
        ON DELETE SET NULL,

    INDEX idx_solicitud_usuario (id_usuario),

    INDEX idx_solicitud_estado (estado),

    INDEX idx_solicitud_fecha (fecha_solicitud)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;