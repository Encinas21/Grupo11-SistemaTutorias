<?php
require_once __DIR__.'/../config/conexion.php'; require_once __DIR__.'/../includes/seguridad.php'; require_role(['administrador']); require_once __DIR__.'/../models/CarreraModel.php';
$m=new CarreraModel($pdo);$id=(int)($_GET['id']??0);$accion=$_GET['accion']??'listar';$formError=null;
if($_SERVER['REQUEST_METHOD']==='POST'){
    validar_csrf();
    try{
        if(($_POST['accion']??'')==='eliminar'){ $m->eliminar((int)($_POST['id']??0));flash('success','Registro eliminado correctamente.');redir('/controllers/carreras.php'); }
        if(($_POST['accion']??'')!=='guardar')throw new RuntimeException('Acción no reconocida.');
        $id=(int)($_POST['id']??$id);$error=validar_requeridos($_POST,['nombre_carrera'=>'Nombre']);if($error)throw new RuntimeException($error);
        if(!carrera_catalogo_valida((string)$_POST['nombre_carrera']))throw new RuntimeException('Selecciona una carrera válida del catálogo académico. No se permiten nombres inventados.');
        $stmtCarrera=$pdo->prepare('SELECT COUNT(*) FROM carreras WHERE LOWER(nombre_carrera)=LOWER(?) AND id_carrera<>?');$stmtCarrera->execute([trim((string)$_POST['nombre_carrera']),$id]);if((int)$stmtCarrera->fetchColumn()>0)throw new RuntimeException('Esta carrera ya está registrada.');
        if($id)$m->editar($id,$_POST);else$m->crear($_POST);flash('success',$id?'Registro actualizado correctamente.':'Registro creado correctamente.');redir('/controllers/carreras.php');
    }catch(Throwable $e){$formError=$e->getMessage();$accion=$id>0?'editar':'crear';}
}
$registro=$id?$m->obtenerPorId($id):null;if($_SERVER['REQUEST_METHOD']==='POST'&&$formError)$registro=array_merge($registro??[],$_POST);$registros=$m->obtenerTodas();$tituloPagina='Carreras';require __DIR__.'/../views/carreras/index.php';
