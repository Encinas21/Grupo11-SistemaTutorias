-- 020_mg_citaciones.sql: relación por defensa y plantillas provisionales.
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET @db := DATABASE();
SET @col := (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=@db AND table_name='documentos_generados' AND column_name='id_defensa');
SET @sql := IF(@col=0,'ALTER TABLE documentos_generados ADD COLUMN id_defensa INT NULL AFTER id_expediente','SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @fk := (SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_schema=@db AND table_name='documentos_generados' AND constraint_name='fk_documentos_generados_defensa');
SET @sql := IF(@fk=0,'ALTER TABLE documentos_generados ADD CONSTRAINT fk_documentos_generados_defensa FOREIGN KEY (id_defensa) REFERENCES defensas_mg(id_defensa) ON DELETE SET NULL','SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @idx := (SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema=@db AND table_name='documentos_generados' AND index_name='idx_documentos_generados_defensa');
SET @sql := IF(@idx=0,'CREATE INDEX idx_documentos_generados_defensa ON documentos_generados(id_defensa)','SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
INSERT INTO plantillas_documento(codigo,nombre,cuerpo_html,version,activa)
SELECT 'CITACION_TRIBUNAL','Citacion provisional a tribunal','<div><p><strong>[PLANTILLA PROVISIONAL]</strong></p><h2>Citación a tribunal</h2><p>Se cita a {{tribunal_nombre}} para la defensa de {{estudiante_nombre}}.</p><p>Modalidad: {{modalidad}} · Tema: {{tema}} · Cohorte: {{cohorte}}</p><p>Fecha: {{fecha_defensa}} ({{fecha_larga}}), horario {{hora_inicio}} a {{hora_fin}}, ambiente {{ambiente}}.</p><p>Número: {{numero_carta}}</p></div>',1,1
WHERE NOT EXISTS(SELECT 1 FROM plantillas_documento WHERE codigo='CITACION_TRIBUNAL');
INSERT INTO plantillas_documento(codigo,nombre,cuerpo_html,version,activa)
SELECT 'CITACION_ESTUDIANTE','Citacion provisional al estudiante','<div><p><strong>[PLANTILLA PROVISIONAL]</strong></p><h2>Citación a defensa</h2><p>Se cita al estudiante {{estudiante_nombre}} para la defensa de {{tema}}.</p><p>Modalidad: {{modalidad}} · Cohorte: {{cohorte}}</p><p>Fecha: {{fecha_defensa}} ({{fecha_larga}}), horario {{hora_inicio}} a {{hora_fin}}, ambiente {{ambiente}}.</p><p>Número: {{numero_carta}}</p></div>',1,1
WHERE NOT EXISTS(SELECT 1 FROM plantillas_documento WHERE codigo='CITACION_ESTUDIANTE');
