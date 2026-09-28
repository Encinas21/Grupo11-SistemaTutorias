<?php
require_once __DIR__.'/../config/conexion.php'; require_once __DIR__.'/../includes/seguridad.php'; require_role(['administrador']); require_once __DIR__.'/../models/RolModel.php';
$m=new RolModel($pdo); $id=(int)($_GET['id']??0); $accion=$_GET['accion']??'listar'; $formError=null;
if($_SERVER['REQUEST_METHOD']==='POST'){
    validar_csrf();
    try{
        if(($_POST['accion']??'')==='eliminar'){ $m->eliminar((int)($_POST['id']??0)); flash('success','Registro eliminado correctamente.'); redir('/controllers/roles.php'); }
        if(($_POST['accion']??'')!=='guardar') throw new RuntimeException('Acción no reconocida.');
        $id=(int)($_POST['id']??$id);
        $error=validar_requeridos($_POST,['nombre_rol'=>'Nombre del rol']); if($error) throw new RuntimeException($error);
        
        $rolNombre = strtolower(trim((string)$_POST['nombre_rol']));
        $rolesPermitidos = ['administrador','docente','estudiante'];
        if(!in_array($rolNombre,$rolesPermitidos,true)) throw new RuntimeException('El rol debe ser uno de los perfiles del sistema: administrador, docente o estudiante.');
        if (!validar_descripcion_coherente((string)($_POST['descripcion'] ?? ''), 20)) throw new RuntimeException('La descripción debe explicar la función del rol con una frase de al menos 4 palabras.');
        $_POST['nombre_rol'] = $rolNombre;
        $stmtRol=$pdo->prepare('SELECT COUNT(*) FROM roles WHERE LOWER(nombre_rol)=LOWER(?) AND id_rol<>?'); $stmtRol->execute([$rolNombre,$id]);
        if((int)$stmtRol->fetchColumn()>0) throw new RuntimeException('El rol ' . $rolNombre . ' ya existe. No se puede duplicar.');
        if($id)$m->editar($id,$_POST);else$m->crear($_POST);
        flash('success',$id?'Registro actualizado correctamente.':'Registro creado correctamente.'); redir('/controllers/roles.php');
    }catch(Throwable $e){$formError=$e->getMessage();$accion=$id>0?'editar':'crear';}
}
$registro=$id?$m->obtenerPorId($id):null; if($_SERVER['REQUEST_METHOD']==='POST'&&$formError)$registro=array_merge($registro??[],$_POST);
$registros=$m->obtenerTodas();$tituloPagina='Roles de usuario';require __DIR__.'/../views/roles/index.php';
