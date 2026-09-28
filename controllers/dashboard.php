<?php
require_once __DIR__.'/../config/conexion.php';require_once __DIR__.'/../includes/seguridad.php';require_login();require_once __DIR__.'/../models/DashboardModel.php';require_once __DIR__.'/../models/EstudianteModel.php';require_once __DIR__.'/../models/ProfesorModel.php';
$m=new DashboardModel($pdo);$stats=['estudiantes'=>$m->contar('estudiantes'),'profesores'=>$m->contar('profesores'),'cursos'=>$m->contar('cursos'),'promedio'=>$m->promedioNotas(),'asistencia'=>$m->porcentajeAsistencia(),'tutorias'=>$m->contar('tutorias')];$grafico=$m->notasPorCurso();
$misDatos=null;if(user_role()==='estudiante'){$em=new EstudianteModel($pdo);$misDatos=$em->obtenerPorUsuario($_SESSION['id_usuario']);}elseif(user_role()==='docente'){$pm=new ProfesorModel($pdo);$misDatos=$pm->obtenerPorUsuario($_SESSION['id_usuario']);}
$titulo='Dashboard';require __DIR__.'/../views/dashboard/index.php';
