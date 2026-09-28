<?php include __DIR__ . '/../layouts/header.php'; ?>

<div class="toolbar">
    <div>
        <h1 class="page-title">Asistencia</h1>
        <p class="subtitle">Control de presencia, ausencias y tardanzas.</p>
    </div>
    <?php if ($rol === 'docente'): ?>
        <a class="btn btn-primary" href="?accion=crear">+ Registrar asistencia</a>
    <?php endif; ?>
</div>

<?php if ($rol === 'docente'): ?>
    <div class="card">
        <div class="card-body">
            <h2 style="margin-top:0">Tomar asistencia por curso</h2>
            <p class="subtitle">
                Elige uno de tus cursos y una fecha para ver a TODOS los estudiantes
                inscritos (aunque todavía no tengan asistencia registrada) y marcarlos
                de una sola vez.
            </p>

            <form method="get" class="grid grid-2" style="align-items:end">
                <input type="hidden" name="accion" value="tomar">
                <div class="form-group">
                    <label class="form-label" for="id_curso">Curso / Materias</label>
                    <select id="id_curso" name="id_curso" required onchange="this.form.submit()">
                        <option value="">Selecciona un curso</option>
                        <?php foreach ($cursosProfesor as $c): ?>
                            <option
                                value="<?= (int) $c['id_curso'] ?>"
                                <?= $cursoRosterId === (int) $c['id_curso'] ? 'selected' : '' ?>
                            >
                                <?= e($c['codigo'] . ' · ' . $c['nombre_curso']) ?>
                                <?= $c['materias'] ? ' (' . e($c['materias']) . ')' : '' ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label" for="fecha_roster">Fecha</label>
                    <input
                        id="fecha_roster"
                        type="date"
                        name="fecha_roster"
                        max="<?= e(date('Y-m-d')) ?>"
                        value="<?= e($fechaRoster) ?>"
                        onchange="this.form.submit()"
                    >
                </div>
            </form>

            <?php if ($cursoRosterId > 0): ?>
                <?php if (!$rosterCurso): ?>
                    <p class="muted-text">Este curso todavía no tiene estudiantes inscritos.</p>
                <?php else: ?>
                    <form method="post">
                        <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
                        <input type="hidden" name="accion" value="guardar_masivo">
                        <input type="hidden" name="id_curso" value="<?= $cursoRosterId ?>">
                        <input type="hidden" name="fecha" value="<?= e($fechaRoster) ?>">

                        <div class="table-wrap">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Estudiante</th>
                                        <th>Estado</th>
                                        <th>Observación</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($rosterCurso as $i => $fila): ?>
                                        <tr>
                                            <td>
                                                <?= e($fila['estudiante']) ?>
                                                <?php if (!$fila['id_asistencia']): ?>
                                                    <span class="badge badge-warning">Sin registrar</span>
                                                <?php endif; ?>
                                            </td>
                                            <td>
                                                <input type="hidden" name="filas[<?= $i ?>][id_inscripcion]" value="<?= (int) $fila['id_inscripcion'] ?>">
                                                <select name="filas[<?= $i ?>][estado]">
                                                    <option value="">Sin marcar</option>
                                                    <?php foreach (['presente' => 'Presente', 'ausente' => 'Ausente', 'justificado' => 'Justificado', 'tarde' => 'Tarde'] as $valorEstado => $etiquetaEstado): ?>
                                                        <option
                                                            value="<?= $valorEstado ?>"
                                                            <?= ($fila['estado'] ?? '') === $valorEstado ? 'selected' : '' ?>
                                                        >
                                                            <?= $etiquetaEstado ?>
                                                        </option>
                                                    <?php endforeach; ?>
                                                </select>
                                            </td>
                                            <td>
                                                <input
                                                    name="filas[<?= $i ?>][observacion]"
                                                    value="<?= e($fila['observacion'] ?? '') ?>"
                                                    placeholder="Opcional"
                                                >
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>

                        <div class="actions">
                            <button class="btn btn-primary" type="submit">Guardar asistencia del curso</button>
                        </div>
                    </form>
                <?php endif; ?>
            <?php endif; ?>
        </div>
    </div>
<?php endif; ?>

<div class="card">
    <div class="card-body">
        <h2 style="margin-top:0">Historial de asistencia</h2>
        <form method="get" class="search-form" style="display:flex;gap:8px;align-items:center;margin-bottom:16px;flex-wrap:wrap"><input class="search" type="search" name="buscar" value="<?=e($busqueda ?? '')?>" placeholder="Buscar estudiante o curso..." style="flex:1;min-width:220px"><button class="btn btn-primary btn-sm" type="submit">Buscar en todos</button><?php if (!empty($busqueda)): ?><a class="btn btn-light btn-sm" href="/controllers/asistencia.php">Limpiar</a><?php endif; ?></form>
        <div class="table-wrap">
            <table class="table" id="tabla">
                <thead>
                    <tr>
                        <th>Estudiante</th>
                        <th>Curso</th>
                        <th>Fecha</th>
                        <th>Estado</th>
                        <th>Observación</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($registros as $r): ?>
                        <tr>
                            <td><?= e($r['estudiante']) ?></td>
                            <td><?= e($r['codigo']) ?></td>
                            <td><?= e($r['fecha']) ?></td>
                            <td>
                                <span class="badge <?= in_array($r['estado'], ['presente', 'justificado']) ? 'badge-success' : ($r['estado'] === 'tarde' ? 'badge-warning' : 'badge-danger') ?>">
                                    <?= e($r['estado']) ?>
                                </span>
                            </td>
                            <td><?= e($r['observacion']) ?></td>
                            <td>
                                <div class="actions">
                                    <?php if ($rol === 'docente'): ?>
                                        <a class="btn btn-light btn-sm" href="?accion=editar&id=<?= $r['id_asistencia'] ?>">Editar</a>
                                        <form method="post">
                                            <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
                                            <input type="hidden" name="accion" value="eliminar">
                                            <input type="hidden" name="id" value="<?= $r['id_asistencia'] ?>">
                                            <button class="btn btn-danger btn-sm" data-confirm="¿Eliminar registro de asistencia?">Eliminar</button>
                                        </form>
                                    <?php endif; ?>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php include __DIR__ . '/../layouts/paginacion.php'; ?>
    </div>
</div>

<?php if ($rol === 'docente' && $accion !== 'listar' && $accion !== 'tomar'): ?>
    <div class="modal is-open" data-close-url="/controllers/asistencia.php" role="dialog" aria-modal="true">
        <div class="modal-dialog">
            <div class="modal-header">
                <h2 style="margin-top:0"><?= $id ? 'Editar' : 'Registrar' ?> asistencia</h2>
                <a class="modal-close" href="/controllers/asistencia.php" data-modal-close aria-label="Cerrar">×</a>
            </div>
            <div class="modal-body">
                <?php if ($formError ?? null): ?>
                    <div class="alert alert-error" role="alert"><?= e($formError) ?></div>
                <?php endif; ?>
                <form method="post">
                    <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
                    <input type="hidden" name="accion" value="guardar">
                    <div class="grid grid-2">
                        <div class="form-group">
                            <label class="form-label">Inscripción</label>
                            <select required name="id_inscripcion">
                                <?php foreach ($ins as $i): ?>
                                    <option
                                        value="<?= $i['id_inscripcion'] ?>"
                                        <?= ($registro['id_inscripcion'] ?? '') == $i['id_inscripcion'] ? 'selected' : '' ?>
                                    >
                                        <?= e($i['estudiante'] . ' · ' . $i['codigo'] . ' · ' . $i['nombre_curso']) ?>
                                    </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Fecha</label>
                            <input
                                required
                                type="date"
                                name="fecha"
                                value="<?= e($registro['fecha'] ?? date('Y-m-d')) ?>"
                                min="<?= e(date('Y-m-d')) ?>"
                                max="<?= e(date('Y-m-d')) ?>"
                                <?= $id ? 'readonly' : '' ?>
                            >
                        </div>
                        <div class="form-group">
                            <label class="form-label">Estado</label>
                            <select name="estado">
                                <option value="presente">Presente</option>
                                <option value="ausente">Ausente</option>
                                <option value="justificado">Justificado</option>
                                <option value="tarde">Tarde</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Observación</label>
                            <input name="observacion" value="<?= e($registro['observacion'] ?? '') ?>">
                        </div>
                    </div>
                    <div class="actions">
                        <button class="btn btn-primary">Guardar</button>
                        <a class="btn btn-light" href="/controllers/asistencia.php">Cancelar</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
<?php endif; ?>

<?php include __DIR__ . '/../layouts/footer.php'; ?>
