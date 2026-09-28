<?php
require_once __DIR__.'/../config/conexion.php';require_once __DIR__.'/../includes/seguridad.php';
require_once __DIR__.'/../includes/paginacion.php';require_role(['administrador']);require_once __DIR__.'/../models/InscripcionModel.php';
require_once __DIR__.'/../models/EstudianteModel.php';
require_once __DIR__.'/../models/CursoModel.php';
$m=new InscripcionModel($pdo);$id=(int)($_GET['id']??0);$accion=$_GET['accion']??'listar';$formError=null;
if($_SERVER['REQUEST_METHOD']==='POST'){
    validar_csrf();
    try{
        if(($_POST['accion']??'')==='eliminar'){ $m->eliminar((int)($_POST['id']??0));flash('success','Registro eliminado correctamente.');redir('/controllers/inscripciones.php'); }
        if(($_POST['accion']??'')!=='guardar')throw new RuntimeException('Acción no reconocida.');
        $id=(int)($_POST['id']??$id);$error=validar_requeridos($_POST,['id_estudiante'=>'Estudiante','id_curso'=>'Curso','fecha_inscripcion'=>'Fecha']);if($error)throw new RuntimeException($error);
        if((int)($_POST['id_estudiante']??0)<=0 || (int)($_POST['id_curso']??0)<=0)throw new RuntimeException('Selecciona un estudiante y un curso válidos.');
        $fechaHoy=date('Y-m-d');
        $fechaEnviada=(string)($_POST['fecha_inscripcion']??'');
        if($id){
            $inscripcionActual=$m->obtenerPorId($id);
            if(!$inscripcionActual)throw new RuntimeException('La inscripción que intentas editar no existe.');
            if($fechaEnviada!==($inscripcionActual['fecha_inscripcion']??''))throw new RuntimeException('La fecha original de la inscripción no se puede modificar.');
        }elseif($fechaEnviada!==$fechaHoy){
            throw new RuntimeException('La fecha de inscripción debe ser la fecha de hoy: '.date('d/m/Y').'. No se permiten fechas anteriores ni futuras.');
        }
        if($id)$m->editar($id,$_POST);else$m->crear($_POST);flash('success',$id?'Registro actualizado correctamente.':'Registro creado correctamente.');redir('/controllers/inscripciones.php');
    }catch(Throwable $e){$formError=$e->getMessage();$accion=$id>0?'editar':'crear';}
}
$registro=$id?$m->obtenerPorId($id):null;if($_SERVER['REQUEST_METHOD']==='POST'&&$formError)$registro=array_merge($registro??[],$_POST);
$estudiantesDisponibles=(new EstudianteModel($pdo))->obtenerTodas();
$cursosDisponibles=(new CursoModel($pdo))->obtenerTodas();
$busqueda=trim((string)($_GET['buscar']??''));$todosLosRegistros=filtrar_registros($m->obtenerTodas(),$busqueda);$paginacion=paginar_registros($todosLosRegistros,(int)($_GET['pagina']??1),10);$registros=$paginacion['registros'];$tituloPagina='Inscripciones';require __DIR__.'/../views/inscripciones/index.php';
