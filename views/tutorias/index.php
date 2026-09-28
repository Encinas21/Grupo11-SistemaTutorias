<?php
include __DIR__ . '/../layouts/header.php';

$estadoClase = static function (string $estado): string {
    return match ($estado) {
        'confirmada', 'realizada' => 'badge-success',
        'rechazada', 'cancelada' => 'badge-danger',
        'pendiente' => 'badge-warning',
        default => 'badge-primary',
    };
};

$estadoTexto = $estados;
$horarioLabel = static function (?string $turno) use ($horarios): string {
    return $horarios[$turno]['label'] ?? 'Horario';
};
$detalleUrl = static fn(int $id) => '/controllers/tutorias.php?accion=detalle&id=' . $id;
$urlPagina = static function (int $numero) use ($filtros): string {
    $params = array_filter(array_merge($filtros, ['pagina' => $numero]), static fn($v) => $v !== '' && $v !== 0 && $v !== null);
    return '/controllers/tutorias.php?' . http_build_query($params);
};
?>

<?php if ($accion === 'listar'): ?>
    <div class="toolbar">
        <div>
            <h1 class="page-title">Tutorías</h1>
            <p class="subtitle">Horarios disponibles durante todo el mes con tres turnos fijos.</p>
        </div>
        <?php if ($rol === 'docente'): ?>
            <div class="actions"><a class="btn btn-light" href="#generar-mes">Generar mes completo</a><a class="btn btn-primary" href="?accion=crear">+ Publicar horario</a></div>
        <?php endif; ?>
    </div>

    <div class="tutoria-schedule-info">
        <div><i class="bi bi-sunrise"></i><strong>Mañana</strong><span>09:00 – 11:00</span></div>
        <div><i class="bi bi-sun"></i><strong>Tarde</strong><span>15:00 – 18:00</span></div>
        <div><i class="bi bi-moon-stars"></i><strong>Noche</strong><span>19:00 – 22:00</span></div>
    </div>

    <div class="card calendar-card">
        <div class="card-body">
            <div class="section-heading">
                <div><h2>Calendario mensual</h2><p>Los espacios libres aparecen como disponibles. El aula se toma automáticamente de la materia.</p></div>
                <div class="calendar-legend">
                    <?php foreach ($estadoTexto as $estado => $texto): ?>
                        <span><i class="legend-dot legend-<?= e($estado) ?>"></i><?= e($texto) ?></span>
                    <?php endforeach; ?>
                </div>
            </div>
            <div id="calendar" data-calendar-url="/controllers/tutorias_api.php" data-can-create="<?= $rol === 'docente' ? '1' : '0' ?>"></div>
        </div>
    </div>

    <div class="card filter-card">
        <div class="card-body">
            <div class="section-heading"><div><h2>Buscar horarios</h2><p>Filtra por docente, materia, turno o estado.</p></div><strong class="result-count"><?= number_format($resultado['total']) ?> resultado<?= $resultado['total'] === 1 ? '' : 's' ?></strong></div>
            <form method="get" class="filter-form">
                <div class="filter-grid">
                    <div class="form-group"><label class="form-label">Buscar</label><input name="q" value="<?= e($filtros['q']) ?>" placeholder="Materia, docente o aula..."></div>
                    <div class="form-group"><label class="form-label">Estado</label><select name="estado"><option value="">Todos</option><?php foreach ($estadoTexto as $v=>$txt): ?><option value="<?= e($v) ?>" <?= $filtros['estado']===$v?'selected':'' ?>><?= e($txt) ?></option><?php endforeach; ?></select></div>
                    <div class="form-group"><label class="form-label">Docente</label><select name="id_tutor"><option value="">Todos</option><?php foreach($tutores as $t): ?><option value="<?= (int)$t['id_tutor'] ?>" <?= (int)$filtros['id_tutor']===(int)$t['id_tutor']?'selected':'' ?>><?= e($t['nombre_completo']) ?></option><?php endforeach; ?></select></div>
                    <div class="form-group"><label class="form-label">Materia</label><select name="id_materia"><option value="">Todas</option><?php foreach($materias as $m): ?><option value="<?= (int)$m['id_materia'] ?>" <?= (int)$filtros['id_materia']===(int)$m['id_materia']?'selected':'' ?>><?= e($m['nombre_materia']) ?></option><?php endforeach; ?></select></div>
                    <div class="form-group"><label class="form-label">Turno</label><select name="turno_horario"><option value="">Todos</option><?php foreach($horarios as $v=>$h): ?><option value="<?= e($v) ?>" <?= $filtros['turno_horario']===$v?'selected':'' ?>><?= e($h['label'].' · '.$h['inicio'].'–'.$h['fin']) ?></option><?php endforeach; ?></select></div>
                    <div class="form-group"><label class="form-label">Desde</label><input type="date" name="fecha_desde" value="<?= e($filtros['fecha_desde']) ?>"></div>
                    <div class="form-group"><label class="form-label">Hasta</label><input type="date" name="fecha_hasta" value="<?= e($filtros['fecha_hasta']) ?>"></div>
                    <div class="filter-actions"><button class="btn btn-primary">Aplicar</button><a class="btn btn-light" href="/controllers/tutorias.php">Limpiar</a></div>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="table-wrap">
                <table class="table" id="tabla-tutorias">
                    <thead><tr><th>Fecha</th><th>Horario</th><th>Materia</th><th>Aula</th><th>Docente</th><th>Estudiante</th><th>Estado</th><th>Acciones</th></tr></thead>
                    <tbody>
                    <?php if (!$resultado['items']): ?><tr><td colspan="8"><div class="empty">No hay tutorías para los filtros seleccionados.</div></td></tr><?php endif; ?>
                    <?php foreach($resultado['items'] as $item): ?>
                        <tr>
                            <td><strong><?= e($item['fecha']) ?></strong></td>
                            <?php
                            $turnoItem = $item['turno_horario'] ?? null;
                            $horarioItem = $turnoItem && isset($horarios[$turnoItem])
                                ? $horarios[$turnoItem]
                                : ['label' => 'Horario', 'inicio' => substr((string)($item['hora_inicio'] ?? ''), 0, 5), 'fin' => substr((string)($item['hora_fin'] ?? ''), 0, 5)];
                            ?>
                            <td><span class="badge badge-light"><?= e($horarioItem['label']) ?><br><?= e($horarioItem['inicio']) ?>–<?= e($horarioItem['fin']) ?></span></td>
                            <td><?= e($item['nombre_materia']) ?></td>
                            <td><?= e($item['aula']) ?></td>
                            <td><a class="link-primary" href="/controllers/tutor_perfil.php?id=<?= (int)$item['id_tutor'] ?>"><?= e($item['docente']) ?></a></td>
                            <td><?= $item['estudiante'] ? e(trim($item['estudiante'])) : '<span class="muted-text">Sin estudiante</span>' ?></td>
                            <td><span class="badge <?= e($estadoClase($item['estado'])) ?>"><?= e($estadoTexto[$item['estado']] ?? ucfirst($item['estado'])) ?></span></td>
                            <td><div class="actions">
                                <a class="btn btn-light btn-sm" href="<?= e($detalleUrl((int)$item['id_tutoria'])) ?>">Ver</a>
                                <?php if ($rol === 'estudiante' && $item['estado'] === 'disponible'): ?>
                                    <form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="solicitar_unirse"><input type="hidden" name="id" value="<?= (int)$item['id_tutoria'] ?>"><button class="btn btn-primary btn-sm">Solicitar</button></form>
                                <?php elseif ($rol === 'estudiante' && $item['estado'] === 'pendiente' && (int)($item['estudiante_usuario'] ?? 0) === (int)$_SESSION['id_usuario']): ?>
                                    <form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="cancelar_solicitud"><input type="hidden" name="id" value="<?= (int)$item['id_tutoria'] ?>"><button class="btn btn-danger btn-sm" data-confirm="¿Cancelar tu solicitud?">Cancelar</button></form>
                                <?php elseif ($rol === 'administrador' && $item['estado'] === 'pendiente'): ?>
                                    <form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="cambiar_estado"><input type="hidden" name="nuevo_estado" value="confirmada"><input type="hidden" name="id" value="<?= (int)$item['id_tutoria'] ?>"><button class="btn btn-success btn-sm">Aceptar</button></form>
                                    <form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="cambiar_estado"><input type="hidden" name="nuevo_estado" value="rechazada"><input type="hidden" name="id" value="<?= (int)$item['id_tutoria'] ?>"><button class="btn btn-danger btn-sm" data-confirm="¿Rechazar esta solicitud?">Rechazar</button></form>
                                <?php elseif ($rol === 'docente' && (int)$item['profesor_usuario'] === (int)$_SESSION['id_usuario'] && $item['estado'] === 'disponible'): ?>
                                    <a class="btn btn-light btn-sm" href="/controllers/tutorias.php?accion=editar&id=<?= (int)$item['id_tutoria'] ?>">Editar</a>
                                    <form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="eliminar_disponibilidad"><input type="hidden" name="id" value="<?= (int)$item['id_tutoria'] ?>"><button class="btn btn-danger btn-sm" data-confirm="¿Eliminar este horario disponible?">Eliminar</button></form>
                                <?php elseif ($rol === 'docente' && (int)$item['profesor_usuario'] === (int)$_SESSION['id_usuario'] && $item['estado'] === 'confirmada'): ?>
                                    <form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="cambiar_estado"><input type="hidden" name="nuevo_estado" value="realizada"><input type="hidden" name="id" value="<?= (int)$item['id_tutoria'] ?>"><button class="btn btn-success btn-sm">Realizada</button></form>
                                    <form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="cambiar_estado"><input type="hidden" name="nuevo_estado" value="cancelada"><input type="hidden" name="id" value="<?= (int)$item['id_tutoria'] ?>"><button class="btn btn-danger btn-sm" data-confirm="¿Cancelar esta tutoría?">Cancelar</button></form>
                                <?php endif; ?>
                            </div></td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
            <?php if ($resultado['paginas'] > 1): ?><nav class="pagination" aria-label="Paginación"><?php if($resultado['pagina']>1): ?><a class="btn btn-light btn-sm" href="<?= e($urlPagina($resultado['pagina']-1)) ?>">← Anterior</a><?php endif; ?><?php for($n=max(1,$resultado['pagina']-2);$n<=min($resultado['paginas'],$resultado['pagina']+2);$n++): ?><a class="btn <?= $n===$resultado['pagina']?'btn-primary':'btn-light' ?> btn-sm" href="<?= e($urlPagina($n)) ?>"><?= $n ?></a><?php endfor; ?><?php if($resultado['pagina']<$resultado['paginas']): ?><a class="btn btn-light btn-sm" href="<?= e($urlPagina($resultado['pagina']+1)) ?>">Siguiente →</a><?php endif; ?></nav><?php endif; ?>
        </div>
    </div>

<?php elseif ($accion === 'detalle' && $registro): ?>
    <div class="toolbar"><div><a class="back-link" href="/controllers/tutorias.php">← Volver</a><h1 class="page-title">Detalle de tutoría</h1><p class="subtitle">Información de la sesión y su estado de aprobación.</p></div></div>
    <div class="detail-grid">
        <div class="card"><div class="card-body">
            <?php $turnoDetalle = $registro['turno_horario'] ?? null; ?>
             <div class="detail-status"><span class="badge <?= e($estadoClase($registro['estado'])) ?>"><?= e($estadoTexto[$registro['estado']] ?? ucfirst($registro['estado'])) ?></span><span class="muted-text"><?= e($horarioLabel($turnoDetalle)) ?></span></div>
            <h2 class="detail-title"><?= e($registro['nombre_materia']) ?></h2>
            <div class="detail-list">
                <div><span>Docente</span><strong><a class="link-primary" href="/controllers/tutor_perfil.php?id=<?= (int)$registro['id_tutor'] ?>"><?= e($registro['docente']) ?></a></strong></div>
                <div><span>Estudiante</span><strong><?= $registro['estudiante'] ? e(trim($registro['estudiante'])) : 'Espacio disponible' ?></strong></div>
                <div><span>Fecha</span><strong><?= e($registro['fecha']) ?></strong></div>
                <div><span>Horario</span><strong><?= e($horarios[$registro['turno_horario']]['inicio'] ?? substr($registro['hora_inicio'],0,5)) ?> – <?= e($horarios[$registro['turno_horario']]['fin'] ?? substr($registro['hora_fin'],0,5)) ?></strong></div>
                <div><span>Aula</span><strong><?= e($registro['aula']) ?></strong></div>
            </div>
            <div class="actions" style="margin-top:20px">
                <?php if ($rol === 'estudiante' && $registro['estado'] === 'disponible'): ?><form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="solicitar_unirse"><input type="hidden" name="id" value="<?= (int)$registro['id_tutoria'] ?>"><button class="btn btn-primary">Solicitar unirse</button></form><?php endif; ?>
                <?php if ($rol === 'estudiante' && $registro['estado'] === 'pendiente' && (int)($registro['estudiante_usuario'] ?? 0)===$idUsuario): ?><form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="cancelar_solicitud"><input type="hidden" name="id" value="<?= (int)$registro['id_tutoria'] ?>"><button class="btn btn-danger" data-confirm="¿Cancelar tu solicitud?">Cancelar solicitud</button></form><?php endif; ?>
                <?php if ($rol === 'administrador' && $registro['estado'] === 'pendiente'): ?><form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="cambiar_estado"><input type="hidden" name="nuevo_estado" value="confirmada"><input type="hidden" name="id" value="<?= (int)$registro['id_tutoria'] ?>"><button class="btn btn-success">Aceptar solicitud</button></form><form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="cambiar_estado"><input type="hidden" name="nuevo_estado" value="rechazada"><input type="hidden" name="id" value="<?= (int)$registro['id_tutoria'] ?>"><button class="btn btn-danger" data-confirm="¿Rechazar esta solicitud?">Rechazar</button></form><?php endif; ?>
                <?php if ($rol === 'docente' && (int)$registro['profesor_usuario']===$idUsuario && $registro['estado']==='disponible'): ?><a class="btn btn-light" href="/controllers/tutorias.php?accion=editar&id=<?= (int)$registro['id_tutoria'] ?>">Editar horario</a><form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="eliminar_disponibilidad"><input type="hidden" name="id" value="<?= (int)$registro['id_tutoria'] ?>"><button class="btn btn-danger" data-confirm="¿Eliminar este horario?">Eliminar</button></form><?php endif; ?>
                <?php if ($rol === 'docente' && (int)$registro['profesor_usuario']===$idUsuario && $registro['estado']==='confirmada'): ?><form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="cambiar_estado"><input type="hidden" name="nuevo_estado" value="realizada"><input type="hidden" name="id" value="<?= (int)$registro['id_tutoria'] ?>"><button class="btn btn-success">Marcar realizada</button></form><?php endif; ?>
            </div>
        </div></div>
        <div class="card"><div class="card-body"><h2>Reglas de la tutoría</h2><div class="info-list"><div><i class="bi bi-clock"></i><span>Los horarios son fijos y no se editan manualmente.</span></div><div><i class="bi bi-building"></i><span>El aula pertenece a la materia y no puede cambiarse desde la tutoría.</span></div><div><i class="bi bi-person-check"></i><span>El estudiante solicita unirse y el administrador aprueba o rechaza.</span></div></div></div></div>
    </div>

    <?php if ($registro['estado'] === 'realizada'): ?>
        <div class="card"><div class="card-body"><h2>Evaluación</h2>
            <?php if ($registro['evaluacion_calificacion']): ?><div class="review-card"><div class="stars-readonly large"><?= str_repeat('★',(int)$registro['evaluacion_calificacion']) ?></div><p><?= nl2br(e($registro['evaluacion_comentario'] ?: 'Sin comentario.')) ?></p></div>
            <?php elseif ($rol==='estudiante' && (int)($registro['estudiante_usuario']??0)===$idUsuario): ?><form method="post" action="/controllers/evaluacion_tutoria.php" class="review-form"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="guardar"><input type="hidden" name="id_tutoria" value="<?= (int)$registro['id_tutoria'] ?>"><label class="form-label">Tu calificación</label><div class="star-input" data-star-input><?php for($s=5;$s>=1;$s--): ?><input id="star-<?= $s ?>" type="radio" name="calificacion" value="<?= $s ?>" required><label for="star-<?= $s ?>">★</label><?php endfor; ?></div><div class="form-group"><label class="form-label">Comentario</label><textarea name="comentario" placeholder="Cuéntanos cómo fue la tutoría..."></textarea></div><button class="btn btn-primary">Guardar reseña</button></form>
            <?php else: ?><div class="empty compact">Esta tutoría todavía no tiene una reseña.</div><?php endif; ?>
        </div></div>
    <?php endif; ?>

<?php elseif (in_array($accion, ['crear','editar'], true)): ?>
    <?php $esEdicion=$accion==='editar' && $registro; $idFormulario=$esEdicion?(int)$registro['id_tutoria']:0; $materiaSeleccionada=(int)($formData['id_materia']??0); ?>
    <div class="modal is-open" data-close-url="/controllers/tutorias.php" role="dialog" aria-modal="true"><div class="modal-dialog"><div class="modal-header"><div><h2><?= $esEdicion?'Editar horario':'Publicar horario de tutoría' ?></h2><small>Selecciona fecha, materia y uno de los tres turnos.</small></div><a class="modal-close" href="/controllers/tutorias.php" data-modal-close>×</a></div><div class="modal-body">
        <?php if($formError): ?><div class="alert alert-error"><?= e($formError) ?></div><?php endif; ?>
        <form method="post"><input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="accion" value="<?= $esEdicion?'editar_disponibilidad':'crear_disponibilidad' ?>"><input type="hidden" name="id" value="<?= $idFormulario ?>">
            <div class="form-group"><label class="form-label">Docente</label><input value="<?= e(($tutorActual['nombre']??'').' '.($tutorActual['apellido']??'')) ?>" readonly></div>
            <div class="grid grid-2">
                <div class="form-group"><label class="form-label">Materia</label><select required name="id_materia"><option value="">Selecciona una materia</option><?php foreach($materiasTutor as $m): ?><option value="<?= (int)$m['id_materia'] ?>" <?= $materiaSeleccionada===(int)$m['id_materia']?'selected':'' ?>><?= e($m['nombre_materia'].' · '.$m['aula']) ?></option><?php endforeach; ?></select></div>
                <div class="form-group"><label class="form-label">Fecha</label><input required type="date" name="fecha" data-no-sunday min="<?= e(date('Y-m-d')) ?>" value="<?= e($formData['fecha']??date('Y-m-d')) ?>"></div>
                <div class="form-group"><label class="form-label">Horario fijo</label><select required name="turno_horario"><?php foreach($horarios as $v=>$h): ?><option value="<?= e($v) ?>" <?= ($formData['turno_horario']??'manana')===$v?'selected':'' ?>><?= e($h['label'].' · '.$h['inicio'].' – '.$h['fin']) ?></option><?php endforeach; ?></select></div>
                <div class="form-group"><label class="form-label">Aula</label><input value="Se asigna automáticamente según la materia" readonly></div>
            </div>
            <div class="form-note"><strong>Importante:</strong> no debes ingresar hora de inicio, hora de fin, observaciones ni lugar/enlace. El sistema usa automáticamente los tres horarios y el aula definida en la materia.</div>
            <div class="actions"><button class="btn btn-primary"><?= $esEdicion?'Guardar cambios':'Publicar horario' ?></button><a class="btn btn-light" href="/controllers/tutorias.php">Cancelar</a></div>
        </form>
    </div></div></div>
<?php endif; ?>

<?php if ($accion === 'listar' && $rol === 'docente'): ?>
<div class="modal" id="generar-mes" role="dialog" aria-modal="true" data-close-url="/controllers/tutorias.php">
    <div class="modal-dialog">
        <div class="modal-header"><div><h2>Generar agenda mensual</h2><small>Distribuye espacios durante todo el mes, de lunes a sábado, alternando los turnos para evitar acumulaciones.</small></div><a class="modal-close" href="/controllers/tutorias.php" data-modal-close>×</a></div>
        <div class="modal-body">
            <form method="post">
                <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
                <input type="hidden" name="accion" value="generar_mes">
                <div class="form-group"><label class="form-label">Materia</label><select required name="id_materia"><option value="">Selecciona una materia</option><?php foreach($materiasTutor as $m): ?><option value="<?= (int)$m['id_materia'] ?>"><?= e($m['nombre_materia'].' · '.$m['aula']) ?></option><?php endforeach; ?></select></div>
                <div class="form-group"><label class="form-label">Mes</label><input required type="month" name="mes" value="<?= e(date('Y-m')) ?>"></div>
                <div class="form-note"><strong>Distribución equilibrada:</strong> se publicará un espacio por día hábil de lunes a sábado, alternando mañana, tarde y noche. Los domingos quedan bloqueados.</div>
                <div class="actions"><button class="btn btn-primary">Generar agenda</button><a class="btn btn-light" href="/controllers/tutorias.php">Cancelar</a></div>
            </form>
        </div>
    </div>
</div>
<?php endif; ?>

<?php if ($accion === 'listar'): ?>
<script>document.addEventListener('click',function(e){const a=e.target.closest('a[href="#generar-mes"]');if(!a)return;e.preventDefault();const m=document.getElementById('generar-mes');if(m){m.classList.add('is-open');document.body.classList.add('modal-open');}});</script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.18/index.global.min.css">
<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.18/index.global.min.js"></script>
<?php endif; ?>
<?php include __DIR__ . '/../layouts/footer.php'; ?>
