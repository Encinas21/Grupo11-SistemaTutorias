<?php
require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_role(['administrador','docente','estudiante']);
require_once __DIR__ . '/../models/TutoriaModel.php';

$model = new TutoriaModel($pdo);
$inicio = substr($_GET['start'] ?? date('Y-m-01'), 0, 10);
$fin = substr($_GET['end'] ?? date('Y-m-t'), 0, 10);
$eventos = [];

try {
    $registros = $model->obtenerEventosCalendario($inicio, $fin, user_role(), (int)$_SESSION['id_usuario']);
    $colores = [
        'disponible' => '#018abd',
        'pendiente' => '#d99b00',
        'confirmada' => '#18824a',
        'realizada' => '#59636a',
        'rechazada' => '#bd3c49',
        'cancelada' => '#bd3c49',
    ];
    $horarios = TutoriaModel::horariosFijos();
    foreach ($registros as $r) {
        $turnoKey = $r['turno_horario'] ?? null;
        $turno = $turnoKey && isset($horarios[$turnoKey]) ? $horarios[$turnoKey] : null;
        $horario = $turno ? $turno['label'] : substr($r['hora_inicio'],0,5).'–'.substr($r['hora_fin'],0,5);
        $titulo = $r['nombre_materia'] . ' · ' . $horario;
        if (!empty(trim($r['estudiante'] ?? ''))) $titulo .= ' · ' . trim($r['estudiante']);
        $eventos[] = [
            'id' => (string)$r['id_tutoria'],
            'title' => $titulo,
            'start' => $r['fecha'].'T'.$r['hora_inicio'],
            'end' => $r['fecha'].'T'.$r['hora_fin'],
            'url' => '/controllers/tutorias.php?accion=detalle&id='.(int)$r['id_tutoria'],
            'backgroundColor' => $colores[$r['estado']] ?? '#018abd',
            'borderColor' => $colores[$r['estado']] ?? '#018abd',
            'extendedProps' => [
                'estado' => $r['estado'],
                'tutor' => $r['docente'],
                'estudiante' => trim($r['estudiante'] ?? '') ?: 'Sin estudiante',
                'materia' => $r['nombre_materia'],
                'aula' => $r['aula'],
                'horario' => $horario,
            ],
        ];
    }
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($eventos, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES);
} catch (Throwable $e) {
    http_response_code(500);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode(['error'=>'No se pudo cargar el calendario.'], JSON_UNESCAPED_UNICODE);
}
