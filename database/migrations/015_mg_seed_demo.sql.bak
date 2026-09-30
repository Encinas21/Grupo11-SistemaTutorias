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
