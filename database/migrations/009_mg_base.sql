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
