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
