<?php
require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_role(['administrador', 'docente', 'estudiante']);

require_once __DIR__ . '/../models/TutoriaModel.php';

$autoload = __DIR__ . '/../vendor/autoload.php';

if (!is_file($autoload)) {
    http_response_code(500);
    exit('La dependencia de PDF no está instalada. Reconstruye el contenedor con Docker.');
}

require_once $autoload;

use Dompdf\Dompdf;
use Dompdf\Options;

$model = new TutoriaModel($pdo);
$rol = user_role();
$idUsuario = (int) $_SESSION['id_usuario'];
$tipo = $_GET['tipo'] ?? 'lista';

function pdfEsc($valor): string
{
    return htmlspecialchars((string) $valor, ENT_QUOTES, 'UTF-8');
}

function estadoClasePdf(string $estado): string
{
    return match ($estado) {
        'confirmada' => 'confirmada',
        'realizada' => 'realizada',
        'cancelada' => 'cancelada',
        default => 'pendiente',
    };
}

$html = '
<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<style>
    @page { margin: 35px 36px 45px; }
    body {
        font-family: DejaVu Sans, sans-serif;
        color: #16303b;
        font-size: 10px;
    }
    .header {
        border-bottom: 3px solid #018abd;
        padding-bottom: 12px;
        margin-bottom: 14px;
    }
    .brand-row { display: table; width: 100%; }
    .brand-mark { display: table-cell; width: 34px; vertical-align: middle; }
    .brand-mark span { display: inline-block; width: 28px; height: 28px; line-height: 28px; text-align: center; background: #018abd; color: #ffffff; border-radius: 8px; font-size: 12px; font-weight: bold; }
    .brand-copy { display: table-cell; vertical-align: middle; }
    .summary { display: table; width: 100%; margin: 0 0 18px; border-spacing: 6px 0; }
    .summary-item { display: table-cell; width: 33.33%; padding: 9px 10px; background: #f0f8fb; border: 1px solid #d5e9ef; }
    .summary-label { color: #6c7a80; font-size: 7px; text-transform: uppercase; }
    .summary-value { color: #16303b; font-size: 10px; font-weight: bold; margin-top: 2px; }
    .divider { border-top: 1px solid #dfeaf0; margin: 6px 0 14px; }
    .title {
        color: #018abd;
        font-size: 19px;
        font-weight: bold;
        margin: 0 0 4px;
    }
    .subtitle {
        color: #6c7a80;
        font-size: 9px;
    }
    .meta {
        margin: 0 0 15px;
        padding: 10px;
        background: #f0f8fb;
        border: 1px solid #d5e9ef;
    }
    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 12px;
    }
    th {
        background: #018abd;
        color: #ffffff;
        text-align: left;
        padding: 7px;
        font-size: 8px;
    }
    td {
        border-bottom: 1px solid #dfeaf0;
        padding: 7px;
        vertical-align: top;
    }
    .badge {
        display: inline-block;
        padding: 3px 6px;
        border-radius: 8px;
        font-weight: bold;
    }
    .pendiente { background: #fff4cf; color: #7a5a00; }
    .confirmada { background: #e8f7fc; color: #01698f; }
    .realizada { background: #eaf8f0; color: #176f40; }
    .cancelada { background: #ffecee; color: #a92d3b; }
    .box {
        border: 1px solid #dfeaf0;
        padding: 12px;
        margin: 10px 0;
    }
    .label {
        color: #6c7a80;
        font-size: 8px;
        text-transform: uppercase;
    }
    .value {
        font-size: 11px;
        margin: 2px 0 8px;
    }
    </style>
</head>
<body>
<div class="header">
    <div class="brand-row">
        <div class="brand-mark"><span>ST</span></div>
        <div class="brand-copy">
            <div class="title">Sistema Web de Apoyo Académico para Tutorías</div>
            <div class="subtitle">Grupo11 · Constancia y reportes de tutorías</div>
        </div>
    </div>
</div>

';

if ($tipo === 'detalle') {
    $id = (int) ($_GET['id'] ?? 0);
    $detalle = $model->obtenerDetalle($id);

    if (!$detalle || !$model->puedeVer($id, $rol, $idUsuario)) {
        http_response_code(403);
        exit('No tienes permiso para generar este documento.');
    }

    $html .= '
        <h2>Constancia de tutoría #' . $id . '</h2>
        <div class="box">
            <div class="label">Estudiante</div>
            <div class="value">' . pdfEsc($detalle['estudiante']) . '</div>
            <div class="label">Tutor</div>
            <div class="value">' . pdfEsc($detalle['docente']) . '</div>
            <div class="label">Materia</div>
            <div class="value">' . pdfEsc($detalle['nombre_materia']) . '</div>
            <div class="label">Fecha y horario</div>
            <div class="value">' . pdfEsc($detalle['fecha']) . ' · ' .
                pdfEsc(substr($detalle['hora_inicio'], 0, 5)) . ' - ' .
                pdfEsc(substr($detalle['hora_fin'], 0, 5)) . '</div>
            <div class="label">Aula</div>
            <div class="value">' . pdfEsc($detalle['aula'] ?: '—') . '</div>
            <div class="label">Estado</div>
            <div class="value">
                <span class="badge ' . estadoClasePdf($detalle['estado']) . '">' .
                pdfEsc(ucfirst($detalle['estado'])) . '</span>
            </div>

        </div>
    ';
} else {
    $filtros = [
        'q' => trim($_GET['q'] ?? ''),
        'estado' => $_GET['estado'] ?? '',
        'id_tutor' => (int) ($_GET['id_tutor'] ?? 0),
        'id_materia' => (int) ($_GET['id_materia'] ?? 0),
        'turno_horario' => $_GET['turno_horario'] ?? '',
        'fecha_desde' => $_GET['fecha_desde'] ?? '',
        'fecha_hasta' => $_GET['fecha_hasta'] ?? '',
    ];

    $resultado = $model->obtenerListado(
        $filtros,
        1,
        5000,
        $rol,
        $idUsuario
    );

    $html .= '
        <h2>Listado de tutorías</h2>
        <div class="summary">
            <div class="summary-item"><div class="summary-label">Resultados</div><div class="summary-value">' . (int) $resultado['total'] . '</div></div>
            <div class="summary-item"><div class="summary-label">Filtros</div><div class="summary-value">' . ($filtros['q'] !== '' || $filtros['estado'] !== '' || $filtros['id_tutor'] || $filtros['id_materia'] || $filtros['turno_horario'] || $filtros['fecha_desde'] || $filtros['fecha_hasta'] ? 'Aplicados' : 'Sin filtros') . '</div></div>
            <div class="summary-item"><div class="summary-label">Generado</div><div class="summary-value">' . pdfEsc(date('d/m/Y H:i')) . '</div></div>
        </div>
        <div class="divider"></div>
        ';

    if (!$resultado['items']) {
        $html .= '<div class="box">No se encontraron tutorías con los filtros aplicados.</div>';
    } else {
        $html .= '<table><thead><tr><th>Fecha</th><th>Estudiante</th><th>Tutor</th><th>Materia</th><th>Aula</th><th>Estado</th></tr></thead><tbody>';
    }

    foreach ($resultado['items'] as $item) {
        $html .= '
            <tr>
                <td>' . pdfEsc($item['fecha']) . '<br>' .
                    pdfEsc(substr($item['hora_inicio'], 0, 5)) . ' - ' .
                    pdfEsc(substr($item['hora_fin'], 0, 5)) . '</td>
                <td>' . pdfEsc($item['estudiante']) . '</td>
                <td>' . pdfEsc($item['docente']) . '</td>
                <td>' . pdfEsc($item['nombre_materia']) . '</td>
                <td>' . pdfEsc($item['aula']) . '</td>
                <td><span class="badge ' . estadoClasePdf($item['estado']) . '">' .
                    pdfEsc(ucfirst($item['estado'])) . '</span></td>
            </tr>
        ';
    }

    if ($resultado['items']) {
        $html .= '</tbody></table>';
    }
}

$html .= '</body></html>';


$options = new Options();
$options->set('isRemoteEnabled', false);
$options->set('defaultFont', 'DejaVu Sans');

$dompdf = new Dompdf($options);
$dompdf->loadHtml($html, 'UTF-8');
$dompdf->setPaper('A4', 'portrait');
$dompdf->render();
$canvas = $dompdf->getCanvas();
$canvas->page_text(36, 815, 'Sistema Web de Apoyo Académico para Tutorías · Grupo11 © ' . date('Y'), null, 8, [0.54, 0.60, 0.63]);
$canvas->page_text(535, 815, 'Página {PAGE_NUM} de {PAGE_COUNT}', null, 8, [0.54, 0.60, 0.63]);

$nombreArchivo = $tipo === 'detalle'
    ? 'constancia-tutoria-' . (int) ($_GET['id'] ?? 0) . '.pdf'
    : 'listado-tutorias-' . date('Ymd-His') . '.pdf';

$dompdf->stream($nombreArchivo, [
    'Attachment' => true,
]);
