-- OBSOLETO: conservar por historial. No ejecutar directamente. El esquema/seed oficial se gestiona en database/00_init_complete.sql y database/seeds/00_seed_unico.sql.
USE student_portal_db;

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Contraseña de prueba para los nuevos usuarios: password
-- El mismo hash bcrypt de 'password' utilizado en database/init.sql.
SET @hash_password = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi';

INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 2,'Sofía','Mendoza','sofia.mendoza@upds.net.com','docente3',@hash_password,'70000006'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='docente3');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 2,'Diego','Navarro','diego.navarro@upds.net.com','docente4',@hash_password,'70000007'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='docente4');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 2,'Valeria','Castro','valeria.castro@upds.net.com','docente5',@hash_password,'70000008'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='docente5');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 2,'Andrés','Vargas','andres.vargas@upds.net.com','docente6',@hash_password,'70000009'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='docente6');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 2,'Camila','Herrera','camila.herrera@upds.net.com','docente7',@hash_password,'70000010'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='docente7');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 2,'Mateo','Paredes','mateo.paredes@upds.net.com','docente8',@hash_password,'70000011'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='docente8');

INSERT INTO profesores (id_usuario,especialidad,biografia)
SELECT u.id_usuario,'Desarrollo de Software','Docente orientado a desarrollo de software y proyectos web.' FROM usuarios u WHERE u.usuario='docente3' AND NOT EXISTS (SELECT 1 FROM profesores p WHERE p.id_usuario=u.id_usuario);
INSERT INTO profesores (id_usuario,especialidad,biografia)
SELECT u.id_usuario,'Bases de Datos','Docente especializado en modelado y administración de bases de datos.' FROM usuarios u WHERE u.usuario='docente4' AND NOT EXISTS (SELECT 1 FROM profesores p WHERE p.id_usuario=u.id_usuario);
INSERT INTO profesores (id_usuario,especialidad,biografia)
SELECT u.id_usuario,'Matemática Aplicada','Docente dedicado al razonamiento lógico y matemático.' FROM usuarios u WHERE u.usuario='docente5' AND NOT EXISTS (SELECT 1 FROM profesores p WHERE p.id_usuario=u.id_usuario);
INSERT INTO profesores (id_usuario,especialidad,biografia)
SELECT u.id_usuario,'Redes y Sistemas','Docente especializado en redes, infraestructura y sistemas.' FROM usuarios u WHERE u.usuario='docente6' AND NOT EXISTS (SELECT 1 FROM profesores p WHERE p.id_usuario=u.id_usuario);
INSERT INTO profesores (id_usuario,especialidad,biografia)
SELECT u.id_usuario,'Ingeniería de Software','Docente orientado a análisis, diseño y calidad de software.' FROM usuarios u WHERE u.usuario='docente7' AND NOT EXISTS (SELECT 1 FROM profesores p WHERE p.id_usuario=u.id_usuario);
INSERT INTO profesores (id_usuario,especialidad,biografia)
SELECT u.id_usuario,'Tecnología Web','Docente especializado en tecnologías web y aplicaciones dinámicas.' FROM usuarios u WHERE u.usuario='docente8' AND NOT EXISTS (SELECT 1 FROM profesores p WHERE p.id_usuario=u.id_usuario);

INSERT INTO tutores (id_profesor,especialidad,biografia)
SELECT p.id_profesor,p.especialidad,p.biografia FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente3' AND NOT EXISTS (SELECT 1 FROM tutores t WHERE t.id_profesor=p.id_profesor);
INSERT INTO tutores (id_profesor,especialidad,biografia)
SELECT p.id_profesor,p.especialidad,p.biografia FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente4' AND NOT EXISTS (SELECT 1 FROM tutores t WHERE t.id_profesor=p.id_profesor);
INSERT INTO tutores (id_profesor,especialidad,biografia)
SELECT p.id_profesor,p.especialidad,p.biografia FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente5' AND NOT EXISTS (SELECT 1 FROM tutores t WHERE t.id_profesor=p.id_profesor);
INSERT INTO tutores (id_profesor,especialidad,biografia)
SELECT p.id_profesor,p.especialidad,p.biografia FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente6' AND NOT EXISTS (SELECT 1 FROM tutores t WHERE t.id_profesor=p.id_profesor);
INSERT INTO tutores (id_profesor,especialidad,biografia)
SELECT p.id_profesor,p.especialidad,p.biografia FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente7' AND NOT EXISTS (SELECT 1 FROM tutores t WHERE t.id_profesor=p.id_profesor);
INSERT INTO tutores (id_profesor,especialidad,biografia)
SELECT p.id_profesor,p.especialidad,p.biografia FROM profesores p JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE u.usuario='docente8' AND NOT EXISTS (SELECT 1 FROM tutores t WHERE t.id_profesor=p.id_profesor);

INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Lucía','Ramírez','lucia.ramirez@upds.net.com','estudiante3',@hash_password,'70000012' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante3');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Gabriel','Morales','gabriel.morales@upds.net.com','estudiante4',@hash_password,'70000013' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante4');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Daniela','Flores','daniela.flores@upds.net.com','estudiante5',@hash_password,'70000014' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante5');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Nicolás','Suárez','nicolas.suarez@upds.net.com','estudiante6',@hash_password,'70000015' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante6');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Paula','Ríos','paula.rios@upds.net.com','estudiante7',@hash_password,'70000016' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante7');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Sebastián','Torres','sebastian.torres@upds.net.com','estudiante8',@hash_password,'70000017' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante8');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Mariana','Vega','mariana.vega@upds.net.com','estudiante9',@hash_password,'70000018' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante9');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Alejandro','Cárdenas','alejandro.cardenas@upds.net.com','estudiante10',@hash_password,'70000019' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante10');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Carolina','Molina','carolina.molina@upds.net.com','estudiante11',@hash_password,'70000020' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante11');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Tomás','Gutiérrez','tomas.gutierrez@upds.net.com','estudiante12',@hash_password,'70000021' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante12');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Fernanda','Ponce','fernanda.ponce@upds.net.com','estudiante13',@hash_password,'70000022' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante13');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Javier','Salazar','javier.salazar@upds.net.com','estudiante14',@hash_password,'70000023' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante14');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Renata','Quispe','renata.quispe@upds.net.com','estudiante15',@hash_password,'70000024' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante15');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Martín','Choque','martin.choque@upds.net.com','estudiante16',@hash_password,'70000025' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante16');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Valentina','Arce','valentina.arce@upds.net.com','estudiante17',@hash_password,'70000026' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante17');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Rodrigo','Mamani','rodrigo.mamani@upds.net.com','estudiante18',@hash_password,'70000027' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante18');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Elena','Peña','elena.pena@upds.net.com','estudiante19',@hash_password,'70000028' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante19');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Mauricio','Cabrera','mauricio.cabrera@upds.net.com','estudiante20',@hash_password,'70000029' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante20');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Isabela','Mendoza','isabela.mendoza@upds.net.com','estudiante21',@hash_password,'70000030' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante21');
INSERT INTO usuarios (id_rol,nombre,apellido,correo,usuario,contrasena_hash,telefono)
SELECT 3,'Cristóbal','Villarroel','cristobal.villarroel@upds.net.com','estudiante22',@hash_password,'70000031' WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE usuario='estudiante22');

INSERT INTO estudiantes (id_usuario,id_carrera,semestre,registro_universitario)
SELECT u.id_usuario,CASE WHEN MOD(u.id_usuario,2)=0 THEN c1.id_carrera ELSE c2.id_carrera END,MOD(u.id_usuario,9)+1,CONCAT('RU-2026-',LPAD(u.id_usuario,5,'0'))
FROM usuarios u
JOIN carreras c1 ON c1.nombre_carrera='Ingeniería de Sistemas'
JOIN carreras c2 ON c2.nombre_carrera='Administración de Empresas'
WHERE u.usuario LIKE 'estudiante%' AND u.usuario REGEXP '^estudiante([3-9]|1[0-9]|2[0-2])$'
  AND NOT EXISTS (SELECT 1 FROM estudiantes e WHERE e.id_usuario=u.id_usuario);
