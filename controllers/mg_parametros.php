<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_once __DIR__ . '/../includes/permisos.php';
require_once __DIR__ . '/../models/MgParametroModel.php';
require_once __DIR__ . '/../models/MgBitacoraModel.php';

require_role(['administrador', 'coordinador_mg', 'auxiliar_mg']);
requerir_permiso('mg.parametros.ver');

$accion = $_GET['accion'] ?? 'listar';
$model = new MgParametroModel($pdo);
$bitacora = new MgBitacoraModel($pdo);

if ($accion === 'guardar' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requerir_permiso('mg.parametros.editar');
    validar_csrf();

    $clave = trim((string)($_POST['clave'] ?? ''));
    $valor = trim((string)($_POST['valor'] ?? ''));
    if ($clave === '' || !preg_match('/^[a-z0-9_]{1,60}$/', $clave)) {
        flash('error', 'La clave del parámetro no es válida.');
        redir('/controllers/mg_parametros.php?accion=listar');
    }

    $parametrosActuales = $model->listar();
    $parametroActual = null;
    foreach ($parametrosActuales as $item) {
        if ($item['clave'] === $clave) { $parametroActual = $item; break; }
    }
    if ($parametroActual === null) {
        flash('error', 'El parámetro solicitado no existe.');
        redir('/controllers/mg_parametros.php?accion=listar');
    }
    if ($valor !== '' && !is_numeric($valor)) {
        flash('error', 'El valor de este parámetro debe ser numérico o quedar vacío.');
        redir('/controllers/mg_parametros.php?accion=listar');
    }

    $antes = ['valor' => $parametroActual['valor']];
    if (!$model->actualizar($clave, $valor === '' ? null : $valor, (int)$_SESSION['id_usuario'])) {
        flash('error', 'No se pudo actualizar el parámetro.');
    } else {
        $despues = ['valor' => $model->obtener($clave)];
        $bitacora->registrar('editar_parametro', 'parametros_mg', null, $antes, $despues);
        flash('success', 'Parámetro actualizado correctamente.');
    }
    redir('/controllers/mg_parametros.php?accion=listar');
}

$parametros = $model->listar();
$tituloPagina = 'Parámetros de Modalidades de Grado';
require __DIR__ . '/../views/mg/parametros/index.php';
