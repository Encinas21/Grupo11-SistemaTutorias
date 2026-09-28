<?php
require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_role(['administrador', 'docente', 'estudiante']);

require_once __DIR__ . '/../models/NotificacionModel.php';

$model = new NotificacionModel($pdo);
$idUsuario = (int) $_SESSION['id_usuario'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validar_csrf();

    $accion = $_POST['accion'] ?? '';

    if ($accion === 'marcar_leida') {
        $model->marcarLeida((int) ($_POST['id'] ?? 0), $idUsuario);
    } elseif ($accion === 'marcar_todas') {
        $model->marcarTodasLeidas($idUsuario);
    }
}

$destino = $_POST['volver'] ?? $_SERVER['HTTP_REFERER'] ?? '/controllers/dashboard.php';
redir($destino);
