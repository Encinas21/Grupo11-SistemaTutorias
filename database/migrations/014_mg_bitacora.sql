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
