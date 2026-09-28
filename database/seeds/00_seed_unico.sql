-- Seed oficial de desarrollo. Idempotente. Contraseña de desarrollo: password.
-- OBSOLETO: conservar por historial. No ejecutar directamente. El esquema/seed oficial se gestiona en database/00_init_complete.sql y database/seeds/00_seed_unico.sql.
-- Datos de demostración v2: completa 15 docentes y 50 estudiantes.
-- Usuarios de prueba: contraseña "password".
USE student_portal_db;
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET @hash_password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi';

-- Carreras adicionales (idempotente).
INSERT INTO carreras (id_carrera,nombre_carrera) VALUES
(3,'Contaduría Pública'),(4,'Derecho'),(5,'Ingeniería Comercial'),(6,'Arquitectura'),
(7,'Ingeniería Civil'),(8,'Psicología'),(9,'Marketing y Comunicación'),(10,'Ingeniería Industrial')
ON DUPLICATE KEY UPDATE nombre_carrera=VALUES(nombre_carrera);

-- 13 docentes adicionales: junto a docente1/docente2 = 15 docentes.
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Sofía','Mendoza','sofia.mendoza@upds.net.com','docente3',@hash_password,'70000006' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente3');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Diego','Navarro','diego.navarro@upds.net.com','docente4',@hash_password,'70000007' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente4');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Valeria','Castro','valeria.castro@upds.net.com','docente5',@hash_password,'70000008' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente5');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Andrés','Vargas','andres.vargas@upds.net.com','docente6',@hash_password,'70000009' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente6');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Camila','Herrera','camila.herrera@upds.net.com','docente7',@hash_password,'70000010' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente7');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Mateo','Paredes','mateo.paredes@upds.net.com','docente8',@hash_password,'70000011' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente8');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Gabriela','Ríos','gabriela.rios@upds.net.com','docente9',@hash_password,'70000012' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente9');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Ricardo','Salvatierra','ricardo.salvatierra@upds.net.com','docente10',@hash_password,'70000013' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente10');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Natalia','Pérez','natalia.perez@upds.net.com','docente11',@hash_password,'70000014' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente11');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Jorge','Céspedes','jorge.cespedes@upds.net.com','docente12',@hash_password,'70000015' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente12');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'María','Fernández','maria.fernandez@upds.net.com','docente13',@hash_password,'70000016' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente13');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Álvaro','Quinteros','alvaro.quinteros@upds.net.com','docente14',@hash_password,'70000017' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente14');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) SELECT 2,'Paola','Cárdenas','paola.cardenas@upds.net.com','docente15',@hash_password,'70000018' WHERE NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario='docente15');

INSERT INTO profesores(id_usuario,especialidad,biografia)
SELECT u.id_usuario, CASE u.usuario
WHEN 'docente3' THEN 'Desarrollo de Software' WHEN 'docente4' THEN 'Bases de Datos' WHEN 'docente5' THEN 'Matemática Aplicada'
WHEN 'docente6' THEN 'Redes y Sistemas' WHEN 'docente7' THEN 'Ingeniería de Software' WHEN 'docente8' THEN 'Tecnología Web'
WHEN 'docente9' THEN 'Contabilidad' WHEN 'docente10' THEN 'Derecho Empresarial' WHEN 'docente11' THEN 'Marketing'
WHEN 'docente12' THEN 'Arquitectura' WHEN 'docente13' THEN 'Ingeniería Civil' WHEN 'docente14' THEN 'Psicología'
ELSE 'Ingeniería Industrial' END,
'Profesional académico incorporado al Sistema de Tutorías.'
FROM usuarios u WHERE u.usuario REGEXP '^docente(3|4|5|6|7|8|9|1[0-5])$'
AND NOT EXISTS(SELECT 1 FROM profesores p WHERE p.id_usuario=u.id_usuario);

INSERT INTO tutores(id_profesor,especialidad,biografia)
SELECT p.id_profesor,p.especialidad,p.biografia FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario
WHERE u.usuario REGEXP '^docente(3|4|5|6|7|8|9|1[0-5])$'
AND NOT EXISTS(SELECT 1 FROM tutores t WHERE t.id_profesor=p.id_profesor);

-- Estudiantes 3..50: junto a estudiante1/estudiante2 = 50.
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono) VALUES
(3,'Lucía','Ramírez','lucia.ramirez@upds.net.com','estudiante3',@hash_password,'70000019'),
(3,'Gabriel','Morales','gabriel.morales@upds.net.com','estudiante4',@hash_password,'70000020'),
(3,'Daniela','Flores','daniela.flores@upds.net.com','estudiante5',@hash_password,'70000021'),
(3,'Nicolás','Suárez','nicolas.suarez@upds.net.com','estudiante6',@hash_password,'70000022'),
(3,'Paula','Ríos','paula.rios@upds.net.com','estudiante7',@hash_password,'70000023'),
(3,'Sebastián','Torres','sebastian.torres@upds.net.com','estudiante8',@hash_password,'70000024'),
(3,'Mariana','Vega','mariana.vega@upds.net.com','estudiante9',@hash_password,'70000025'),
(3,'Alejandro','Cárdenas','alejandro.cardenas@upds.net.com','estudiante10',@hash_password,'70000026'),
(3,'Carolina','Molina','carolina.molina@upds.net.com','estudiante11',@hash_password,'70000027'),
(3,'Tomás','Gutiérrez','tomas.gutierrez@upds.net.com','estudiante12',@hash_password,'70000028'),
(3,'Fernanda','Ponce','fernanda.ponce@upds.net.com','estudiante13',@hash_password,'70000029'),
(3,'Javier','Salazar','javier.salazar@upds.net.com','estudiante14',@hash_password,'70000030'),
(3,'Renata','Quispe','renata.quispe@upds.net.com','estudiante15',@hash_password,'70000031'),
(3,'Martín','Choque','martin.choque@upds.net.com','estudiante16',@hash_password,'70000032'),
(3,'Valentina','Arce','valentina.arce@upds.net.com','estudiante17',@hash_password,'70000033'),
(3,'Rodrigo','Mamani','rodrigo.mamani@upds.net.com','estudiante18',@hash_password,'70000034'),
(3,'Elena','Peña','elena.pena@upds.net.com','estudiante19',@hash_password,'70000035'),
(3,'Mauricio','Cabrera','mauricio.cabrera@upds.net.com','estudiante20',@hash_password,'70000036'),
(3,'Isabela','Mendoza','isabela.mendoza@upds.net.com','estudiante21',@hash_password,'70000037'),
(3,'Cristóbal','Villarroel','cristobal.villarroel@upds.net.com','estudiante22',@hash_password,'70000038'),
(3,'Andrea','Salinas','andrea.salinas@upds.net.com','estudiante23',@hash_password,'70000039'),
(3,'Bruno','Aguilar','bruno.aguilar@upds.net.com','estudiante24',@hash_password,'70000040'),
(3,'Cecilia','Moreno','cecilia.moreno@upds.net.com','estudiante25',@hash_password,'70000041'),
(3,'Diego','Paz','diego.paz@upds.net.com','estudiante26',@hash_password,'70000042'),
(3,'Elisa','Méndez','elisa.mendez@upds.net.com','estudiante27',@hash_password,'70000043'),
(3,'Fernando','López','fernando.lopez@upds.net.com','estudiante28',@hash_password,'70000044'),
(3,'Gloria','Vargas','gloria.vargas@upds.net.com','estudiante29',@hash_password,'70000045'),
(3,'Hugo','Rivera','hugo.rivera@upds.net.com','estudiante30',@hash_password,'70000046'),
(3,'Irene','Soto','irene.soto@upds.net.com','estudiante31',@hash_password,'70000047'),
(3,'José','Mendoza','jose.mendoza@upds.net.com','estudiante32',@hash_password,'70000048'),
(3,'Karen','Villar','karen.villar@upds.net.com','estudiante33',@hash_password,'70000049'),
(3,'Luis','Pacheco','luis.pacheco@upds.net.com','estudiante34',@hash_password,'70000050'),
(3,'Mónica','Rojas','monica.rojas@upds.net.com','estudiante35',@hash_password,'70000051'),
(3,'Nelson','Ortega','nelson.ortega@upds.net.com','estudiante36',@hash_password,'70000052'),
(3,'Olivia','Cruz','olivia.cruz@upds.net.com','estudiante37',@hash_password,'70000053'),
(3,'Pablo','Fuentes','pablo.fuentes@upds.net.com','estudiante38',@hash_password,'70000054'),
(3,'Raquel','Luna','raquel.luna@upds.net.com','estudiante39',@hash_password,'70000055'),
(3,'Sergio','Arias','sergio.arias@upds.net.com','estudiante40',@hash_password,'70000056'),
(3,'Tamara','Villarreal','tamara.villarreal@upds.net.com','estudiante41',@hash_password,'70000057'),
(3,'Ulises','Mamani','ulises.mamani@upds.net.com','estudiante42',@hash_password,'70000058'),
(3,'Verónica','Flores','veronica.flores@upds.net.com','estudiante43',@hash_password,'70000059'),
(3,'Walter','Cortez','walter.cortez@upds.net.com','estudiante44',@hash_password,'70000060'),
(3,'Ximena','Paredes','ximena.paredes@upds.net.com','estudiante45',@hash_password,'70000061'),
(3,'Yamila','Molina','yamila.molina@upds.net.com','estudiante46',@hash_password,'70000062'),
(3,'Zoe','Vega','zoe.vega@upds.net.com','estudiante47',@hash_password,'70000063'),
(3,'Adrián','Condori','adrian.condori@upds.net.com','estudiante48',@hash_password,'70000064'),
(3,'Beatriz','López','beatriz.lopez@upds.net.com','estudiante49',@hash_password,'70000065'),
(3,'Carlos','Quisbert','carlos.quisbert@upds.net.com','estudiante50',@hash_password,'70000066')
ON DUPLICATE KEY UPDATE telefono=VALUES(telefono);

INSERT INTO estudiantes(id_usuario,id_carrera,semestre,registro_universitario)
SELECT u.id_usuario, ((u.id_usuario-3) MOD 10)+1, ((u.id_usuario-3) MOD 9)+1, CONCAT('RU-2026-',LPAD(u.id_usuario,5,'0'))
FROM usuarios u WHERE u.usuario REGEXP '^estudiante([3-9]|[1-4][0-9]|50)$'
AND NOT EXISTS(SELECT 1 FROM estudiantes e WHERE e.id_usuario=u.id_usuario);

-- Cédula de Identidad numérica para cada estudiante demo.
UPDATE estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
SET e.registro_universitario = LPAD(MOD(CAST(SUBSTRING(u.usuario,11) AS UNSIGNED) * 73129 + 1241203, 9000000) + 1000000, 7, '0')
WHERE u.usuario REGEXP '^estudiante[0-9]+$';

-- Cursos/materias adicionales para las nuevas carreras.
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Contabilidad Financiera','CON-101',3,p.id_profesor,1,'Fundamentos de contabilidad financiera.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente9' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='CON-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Derecho Empresarial','DER-101',4,p.id_profesor,1,'Principios jurídicos para organizaciones.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente10' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='DER-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Marketing Digital','MKT-101',9,p.id_profesor,1,'Estrategias de marketing digital.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente11' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='MKT-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Diseño Arquitectónico','ARQ-101',6,p.id_profesor,1,'Bases del diseño arquitectónico.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente12' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='ARQ-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Resistencia de Materiales','CIV-101',7,p.id_profesor,2,'Principios de resistencia de materiales.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente13' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='CIV-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Psicología General','PSI-101',8,p.id_profesor,1,'Conceptos introductorios de psicología.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente14' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='PSI-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Procesos Industriales','IND-101',10,p.id_profesor,1,'Introducción a procesos y producción.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente15' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='IND-101');

-- Cursos adicionales para que los docentes 3..8 también tengan alumnos asignados.
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Desarrollo de Software','SW-101',1,p.id_profesor,2,'Fundamentos de desarrollo de software.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente3' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='SW-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Bases de Datos II','BD-201',1,p.id_profesor,4,'Diseño avanzado y optimización de bases de datos.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente4' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='BD-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Matemática Aplicada','MAT-201',1,p.id_profesor,3,'Aplicaciones de matemática en ingeniería.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente5' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='MAT-201');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Redes de Computadoras','RED-101',1,p.id_profesor,5,'Fundamentos de redes y comunicaciones.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente6' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='RED-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Ingeniería de Software','ING-101',1,p.id_profesor,5,'Procesos y buenas prácticas de ingeniería de software.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente7' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='ING-101');
INSERT INTO cursos(nombre_curso,codigo,id_carrera,id_profesor,semestre,descripcion,estado)
SELECT 'Tecnología Web II','WEB-201',1,p.id_profesor,5,'Aplicaciones web modernas y APIs.','activo' FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente8' AND NOT EXISTS(SELECT 1 FROM cursos WHERE codigo='WEB-201');

INSERT INTO materias(nombre_materia,id_carrera,id_curso,aula)
SELECT c.nombre_curso,c.id_carrera,c.id_curso,CASE c.codigo WHEN 'CON-101' THEN 'Aula 305' WHEN 'DER-101' THEN 'Aula 306' WHEN 'MKT-101' THEN 'Laboratorio 4' WHEN 'ARQ-101' THEN 'Taller 1' WHEN 'CIV-101' THEN 'Laboratorio Civil' WHEN 'PSI-101' THEN 'Aula 307' WHEN 'SW-101' THEN 'Laboratorio 5' WHEN 'BD-201' THEN 'Laboratorio 6' WHEN 'MAT-201' THEN 'Aula 205' WHEN 'RED-101' THEN 'Laboratorio Redes' WHEN 'ING-101' THEN 'Aula 308' WHEN 'WEB-201' THEN 'Laboratorio Web' ELSE 'Laboratorio Industrial' END
FROM cursos c WHERE c.codigo IN('CON-101','DER-101','MKT-101','ARQ-101','CIV-101','PSI-101','IND-101','SW-101','BD-201','MAT-201','RED-101','ING-101','WEB-201')
AND NOT EXISTS(SELECT 1 FROM materias m WHERE m.id_curso=c.id_curso);

INSERT IGNORE INTO tutor_materia(id_tutor,id_materia)
SELECT t.id_tutor,m.id_materia FROM tutores t JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios u ON u.id_usuario=p.id_usuario JOIN materias m ON m.id_curso IN(SELECT c.id_curso FROM cursos c WHERE c.id_profesor=p.id_profesor);

-- Inscripciones demo para que el listado académico tenga alumnos distribuidos.
INSERT IGNORE INTO inscripciones(id_estudiante,id_curso,fecha_inscripcion,estado)
SELECT e.id_estudiante,c.id_curso,'2026-02-02','activa'
FROM estudiantes e CROSS JOIN cursos c
WHERE e.id_estudiante >= 1 AND c.id_curso <= 17
  AND MOD(e.id_estudiante + c.id_curso,7)=0;

-- Notas demo: cada estudiante inscrito tiene tres evaluaciones.
INSERT INTO calificaciones (id_inscripcion,tipo,nota,observacion,fecha)
SELECT i.id_inscripcion,v.tipo,
       CASE v.orden WHEN 1 THEN 65+MOD(i.id_inscripcion*7,31) WHEN 2 THEN 62+MOD(i.id_inscripcion*11,34) ELSE 68+MOD(i.id_inscripcion*13,28) END,
       CASE v.orden WHEN 1 THEN 'Evaluación inicial del curso.' WHEN 2 THEN 'Trabajo práctico y seguimiento académico.' ELSE 'Evaluación de cierre del periodo.' END,
       CASE v.orden WHEN 1 THEN '2026-03-15' WHEN 2 THEN '2026-04-15' ELSE '2026-05-15' END
FROM inscripciones i
CROSS JOIN (SELECT 1 orden,'Parcial 1' tipo UNION ALL SELECT 2,'Trabajo práctico' UNION ALL SELECT 3,'Parcial 2') v
WHERE NOT EXISTS (SELECT 1 FROM calificaciones c WHERE c.id_inscripcion=i.id_inscripcion AND c.tipo=v.tipo);

-- Agenda demostrativa: crea espacios disponibles para el resto de septiembre de 2026
-- en los tres turnos para los docentes 3..8, evitando duplicados.
INSERT INTO tutorias(id_estudiante,id_tutor,id_materia,fecha,hora_inicio,hora_fin,modalidad,lugar_o_enlace,estado,observaciones,turno_horario)
SELECT NULL,t.id_tutor,m.id_materia,d.fecha,
       CASE h.turno WHEN 'manana' THEN '09:00' WHEN 'tarde' THEN '15:00' ELSE '19:00' END,
       CASE h.turno WHEN 'manana' THEN '11:00' WHEN 'tarde' THEN '18:00' ELSE '22:00' END,
       'presencial',m.aula,'disponible',NULL,h.turno
FROM tutores t
JOIN profesores p ON p.id_profesor=t.id_profesor
JOIN usuarios u ON u.id_usuario=p.id_usuario
JOIN materias m ON m.id_materia=(SELECT MIN(tm2.id_materia) FROM tutor_materia tm2 WHERE tm2.id_tutor=t.id_tutor)
JOIN (SELECT '2026-09-28' fecha UNION ALL SELECT '2026-09-29' UNION ALL SELECT '2026-09-30') d
JOIN (SELECT 'manana' turno UNION ALL SELECT 'tarde' UNION ALL SELECT 'noche') h
WHERE u.usuario IN ('docente3','docente4','docente5','docente6','docente7','docente8')
AND NOT EXISTS (
  SELECT 1 FROM tutorias tx WHERE tx.id_tutor=t.id_tutor AND tx.fecha=d.fecha AND tx.turno_horario=h.turno
);

SELECT
 (SELECT COUNT(*) FROM profesores) AS total_profesores,
 (SELECT COUNT(*) FROM estudiantes) AS total_estudiantes,
 (SELECT COUNT(*) FROM carreras) AS total_carreras;

-- Roles y usuarios de desarrollo de Modalidades de Grado [PROPUESTA].
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT r.id_rol,'Coordinador','MG','coordinador.mg@upds.net.com','coord_mg',@hash_password,'70000991'
FROM roles r
WHERE r.nombre_rol='coordinador_mg'
  AND NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='coord_mg');

INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT r.id_rol,'Auxiliar','MG','auxiliar.mg@upds.net.com','auxiliar_mg',@hash_password,'70000992'
FROM roles r
WHERE r.nombre_rol='auxiliar_mg'
  AND NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='auxiliar_mg');

-- Datos mínimos de catálogo MG. Las cifras institucionales permanecen configurables.
INSERT INTO cohortes_mg (codigo,nombre,fecha_inicio,fecha_fin,activa)
SELECT 'G1-2026-03','Grupo 1 - Marzo 2026','2026-03-01',NULL,1
WHERE NOT EXISTS (SELECT 1 FROM cohortes_mg WHERE codigo='G1-2026-03');
INSERT INTO cohortes_mg (codigo,nombre,fecha_inicio,fecha_fin,activa)
SELECT 'G2-2026-09','Grupo 2 - Septiembre 2026','2026-09-01',NULL,1
WHERE NOT EXISTS (SELECT 1 FROM cohortes_mg WHERE codigo='G2-2026-09');

-- ============================================================

-- DEMO FINAL MG: mismo bloque que 015_mg_seed_demo.sql
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
