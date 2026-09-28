<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_once __DIR__ . '/../includes/permisos.php';
require_once __DIR__ . '/../models/MgCalendarioModel.php';
require_once __DIR__ . '/../models/MgCohorteModel.php';
require_once __DIR__ . '/../models/MgBitacoraModel.php';

require_role(['administrador', 'coordinador_mg', 'auxiliar_mg', 'docente', 'estudiante']);
requerir_permiso('mg.calendario.ver');

$accion = $_GET['accion'] ?? 'listar';
$model = new MgCalendarioModel($pdo);
$cohorteModel = new MgCohorteModel($pdo);
$bitacora = new MgBitacoraModel($pdo);

if ($accion === 'guardar' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requerir_permiso('mg.calendario.editar');
    validar_csrf();
    $id = (int)($_POST['id_hito'] ?? 0);
    $avance = trim((string)($_POST['avance_esperado_pct'] ?? ''));
    $datos = [
        'id_cohorte' => (int)($_POST['id_cohorte'] ?? 0),
        'etapa' => (string)($_POST['etapa'] ?? ''),
        'tipo' => (string)($_POST['tipo'] ?? ''),
        'nombre' => trim((string)($_POST['nombre'] ?? '')),
        'orden' => max(1, (int)($_POST['orden'] ?? 1)),
        'fecha_limite' => trim((string)($_POST['fecha_limite'] ?? '')),
        'avance_esperado_pct' => $avance,
    ];
    $etapas = ['previa','mg1','mg2'];
    $tipos = ['taller','asignacion_tutor','asignacion_tribunal','informe','defensa','ingreso_mg2','otro'];
    if (!$cohorteModel->obtener($datos['id_cohorte']) || !in_array($datos['etapa'], $etapas, true) || !in_array($datos['tipo'], $tipos, true) || $datos['nombre'] === '') {
        flash('error', 'Los datos del hito no son válidos.');
        redir('/controllers/mg_calendario.php?accion=listar');
    }
    if ($avance !== '' && (!ctype_digit($avance) || (int)$avance > 100)) {
        flash('error', 'El avance esperado debe estar entre 0 y 100.');
        redir('/controllers/mg_calendario.php?accion=listar');
    }
    $antes = $id > 0 ? $model->obtener($id) : null;
    $model->guardar($datos, $id > 0 ? $id : null);
    $despues = $id > 0 ? $model->obtener($id) : null;
    $bitacora->registrar($id > 0 ? 'editar_hito' : 'crear_hito', 'calendario_mg', $id ?: null, $antes, $despues ?: $datos);
    flash('success', 'Hito de calendario guardado.');
    redir('/controllers/mg_calendario.php?accion=listar');
}

if ($accion === 'eliminar' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requerir_permiso('mg.calendario.editar');
    validar_csrf();
    $id = (int)($_POST['id_hito'] ?? 0);
    $antes = $model->obtener($id);
    if ($antes) {
        $model->eliminar($id);
        $bitacora->registrar('eliminar_hito', 'calendario_mg', $id, $antes, null);
        flash('success', 'Hito eliminado.');
    }
    redir('/controllers/mg_calendario.php?accion=listar');
}

$idCohorte = isset($_GET['id_cohorte']) && $_GET['id_cohorte'] !== '' ? (int)$_GET['id_cohorte'] : null;
$hitos = $model->listar($idCohorte);
$cohortes = $cohorteModel->listarActivas();
$puedeEditar = tiene_permiso('mg.calendario.editar');
$tituloPagina = 'Calendario de Modalidades de Grado';
require __DIR__ . '/../views/mg/calendario/index.php';
