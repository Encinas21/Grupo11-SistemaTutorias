<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_once __DIR__ . '/../includes/permisos.php';
require_once __DIR__ . '/../models/MgModalidadModel.php';
require_once __DIR__ . '/../models/MgBitacoraModel.php';

require_role(['administrador', 'coordinador_mg', 'auxiliar_mg', 'docente', 'estudiante']);
requerir_permiso('mg.modalidades.ver');

$accion = $_GET['accion'] ?? 'listar';
$model = new MgModalidadModel($pdo);
$bitacora = new MgBitacoraModel($pdo);

if ($accion === 'estado' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requerir_permiso('mg.modalidades.editar');
    validar_csrf();
    $id = (int)($_POST['id_modalidad'] ?? 0);
    $registro = $model->obtener($id);
    if (!$registro) {
        flash('error', 'La modalidad no existe.');
    } else {
        $activo = (int)($_POST['activa'] ?? 0) === 1 ? 1 : 0;
        $model->cambiarEstado($id, $activo);
        $bitacora->registrar('cambiar_estado_modalidad', 'modalidades_grado', $id, $registro, $model->obtener($id));
        flash('success', 'Estado de modalidad actualizado.');
    }
    redir('/controllers/mg_modalidades.php?accion=listar');
}

$modalidades = $model->listar();
$estadisticasModalidades = [];
foreach ($modalidades as $modalidad) {
    $st = $pdo->prepare("SELECT COUNT(*) FROM expedientes_mg WHERE id_modalidad=?");
    $st->execute([(int)$modalidad['id_modalidad']]);
    $expedientes = (int)$st->fetchColumn();
    $st = $pdo->prepare("SELECT COUNT(DISTINCT id_estudiante) FROM expedientes_mg WHERE id_modalidad=? AND estado='activo'");
    $st->execute([(int)$modalidad['id_modalidad']]);
    $activos = (int)$st->fetchColumn();
    $estadisticasModalidades[(int)$modalidad['id_modalidad']] = ['expedientes'=>$expedientes,'activos'=>$activos];
}
$tituloPagina = 'Modalidades de Grado';
require __DIR__ . '/../views/mg/modalidades/index.php';
