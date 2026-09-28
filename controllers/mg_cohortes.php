<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_once __DIR__ . '/../includes/permisos.php';
require_once __DIR__ . '/../models/MgCohorteModel.php';
require_once __DIR__ . '/../models/MgBitacoraModel.php';

require_role(['administrador', 'coordinador_mg', 'auxiliar_mg', 'docente', 'estudiante']);
requerir_permiso('mg.cohortes.ver');

$accion = $_GET['accion'] ?? 'listar';
$model = new MgCohorteModel($pdo);
$bitacora = new MgBitacoraModel($pdo);

if ($accion === 'guardar' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requerir_permiso('mg.cohortes.editar');
    validar_csrf();

    $id = (int)($_POST['id_cohorte'] ?? 0);
    $datos = [
        'codigo' => trim((string)($_POST['codigo'] ?? '')),
        'nombre' => trim((string)($_POST['nombre'] ?? '')),
        'fecha_inicio' => trim((string)($_POST['fecha_inicio'] ?? '')),
        'fecha_fin' => trim((string)($_POST['fecha_fin'] ?? '')),
        'activa' => isset($_POST['activa']) ? 1 : 0,
    ];
    if ($datos['codigo'] === '' || $datos['nombre'] === '' || $datos['fecha_inicio'] === '') {
        flash('error', 'Código, nombre y fecha de inicio son obligatorios.');
        redir('/controllers/mg_cohortes.php?accion=listar');
    }
    if ($datos['fecha_fin'] !== '' && $datos['fecha_fin'] < $datos['fecha_inicio']) {
        flash('error', 'La fecha de fin no puede ser anterior a la fecha de inicio.');
        redir('/controllers/mg_cohortes.php?accion=listar');
    }

    try {
        $antes = $id > 0 ? $model->obtener($id) : null;
        $model->guardar($datos, $id > 0 ? $id : null);
        $registro = $id > 0 ? $model->obtener($id) : null;
        $bitacora->registrar($id > 0 ? 'editar_cohorte' : 'crear_cohorte', 'cohortes_mg', $id ?: null, $antes, $registro ?: $datos);
        flash('success', 'Cohorte guardada correctamente.');
    } catch (PDOException $e) {
        flash('error', 'No se pudo guardar la cohorte. Verifica que el código no esté repetido.');
    }
    redir('/controllers/mg_cohortes.php?accion=listar');
}

if ($accion === 'desactivar' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requerir_permiso('mg.cohortes.editar');
    validar_csrf();
    $id = (int)($_POST['id_cohorte'] ?? 0);
    $antes = $model->obtener($id);
    if (!$antes) {
        flash('error', 'La cohorte no existe.');
    } else {
        $model->desactivar($id);
        $despues = $model->obtener($id);
        $bitacora->registrar('desactivar_cohorte', 'cohortes_mg', $id, $antes, $despues);
        flash('success', 'Cohorte desactivada.');
    }
    redir('/controllers/mg_cohortes.php?accion=listar');
}

$cohortes = $model->listar();
$puedeEditar = tiene_permiso('mg.cohortes.editar');
$tituloPagina = 'Cohortes de Modalidades de Grado';
require __DIR__ . '/../views/mg/cohortes/index.php';
