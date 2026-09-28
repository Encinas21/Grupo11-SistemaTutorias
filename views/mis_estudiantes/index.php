<?php include __DIR__.'/../layouts/header.php'; ?>
<div class="toolbar"><div><h1 class="page-title">Mis estudiantes</h1><p class="subtitle">Consulta los alumnos inscritos en tus cursos y revisa sus notas.</p></div></div>
<?php if(!$cursos): ?>
<div class="card"><div class="card-body empty"><i class="bi bi-people" style="font-size:2rem"></i><h3>No tienes cursos asignados</h3><p>Cuando el administrador te asigne un curso podrás ver aquí a sus estudiantes.</p></div></div>
<?php else: ?>
<div class="grid grid-3" style="margin-bottom:20px">
<?php foreach($cursos as $curso): ?><a class="card" style="text-decoration:none" href="?id_curso=<?= (int)$curso['id_curso'] ?>"><div class="card-body"><div class="profile-card-title"><h2><?= e($curso['codigo']) ?></h2><i class="bi bi-journal-text"></i></div><strong><?= e($curso['nombre_curso']) ?></strong><div class="profile-stats" style="margin-top:14px"><div><strong><?= (int)$curso['total_estudiantes'] ?></strong><small>Inscritos</small></div><div><strong><?= number_format((float)$curso['promedio_curso'],1) ?></strong><small>Promedio</small></div></div></div></a><?php endforeach; ?>
</div>
<?php if($cursoSeleccionado): ?>
<div class="card"><div class="card-body"><div class="section-heading"><div><h2><?= e($cursoSeleccionado['nombre_curso']) ?> <span class="badge badge-primary"><?= e($cursoSeleccionado['codigo']) ?></span></h2><p>Estudiantes inscritos y registro de calificaciones.</p></div><div class="badge badge-light"><?= count($estudiantes) ?> estudiantes</div></div>
<input class="search" data-search="#tabla-estudiantes" placeholder="Buscar por nombre, usuario o correo...">
<div class="table-wrap"><table class="table" id="tabla-estudiantes"><thead><tr><th>Estudiante</th><th>Cédula de Identidad</th><th>Semestre</th><th>Promedio</th><th>Notas registradas</th></tr></thead><tbody>
<?php foreach($estudiantes as $estudiante): ?><tr><td><strong><?= e($estudiante['nombre'].' '.$estudiante['apellido']) ?></strong><br><small><?= e($estudiante['usuario']) ?> · <?= e($estudiante['correo']) ?></small></td><td><?= e($estudiante['registro_universitario']?:'—') ?></td><td><?= e($estudiante['semestre']) ?></td><td><span class="badge <?= (float)$estudiante['promedio']>=60?'badge-success':'badge-danger' ?>"><?= number_format((float)$estudiante['promedio'],1) ?></span></td><td><?= e($estudiante['notas']?:'Sin notas registradas') ?></td></tr><?php endforeach; ?>
</tbody></table></div><?php if(!$estudiantes): ?><div class="empty">Este curso todavía no tiene estudiantes inscritos.</div><?php endif; ?></div></div>
<?php endif; ?>
<?php endif; ?>
<?php include __DIR__.'/../layouts/footer.php'; ?>
