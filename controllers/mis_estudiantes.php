<?php
require_once __DIR__.'/../config/conexion.php';
require_once __DIR__.'/../includes/seguridad.php';
require_role(['docente']);
require_once __DIR__.'/../models/MisEstudiantesModel.php';
$model=new MisEstudiantesModel($pdo);
$idUsuario=(int)$_SESSION['id_usuario'];
$idCurso=(int)($_GET['id_curso']??0);
$cursos=$model->obtenerCursos($idUsuario);
$cursoSeleccionado=null;$estudiantes=[];
foreach($cursos as $curso){if((int)$curso['id_curso']===$idCurso){$cursoSeleccionado=$curso;break;}}
if(!$cursoSeleccionado && $cursos){$cursoSeleccionado=$cursos[0];$idCurso=(int)$cursoSeleccionado['id_curso'];}
if($cursoSeleccionado)$estudiantes=$model->obtenerEstudiantesPorCurso($idCurso,$idUsuario);
$tituloPagina='Mis estudiantes';
require __DIR__.'/../views/mis_estudiantes/index.php';
