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
