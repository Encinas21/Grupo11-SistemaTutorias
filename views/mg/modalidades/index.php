<?php require __DIR__ . '/../../layouts/header.php'; ?>
<div class="toolbar"><div><h1 class="page-title">Modalidades de Grado</h1><p class="subtitle">Catálogo MVP de las cinco modalidades.</p></div></div>
<div class="card"><div class="card-body"><div class="form-grid" style="margin-bottom:18px"><div><strong>Modalidades activas</strong><div style="font-size:28px;font-weight:700"><?= count(array_filter($modalidades, fn($m) => (int)$m['activa'] === 1)) ?></div></div><div><strong>Expedientes MG</strong><div style="font-size:28px;font-weight:700"><?= array_sum(array_column($estadisticasModalidades, 'expedientes')) ?></div></div><div><strong>Estudiantes en proceso</strong><div style="font-size:28px;font-weight:700"><?= array_sum(array_column($estadisticasModalidades, 'activos')) ?></div></div></div><table class="table">
<thead><tr><th>Código</th><th>Modalidad</th><th>Tutor</th><th>Flujo</th><th>Estado</th><th>Expedientes</th><th>En proceso</th><th></th></tr></thead>
<tbody>
<?php foreach ($modalidades as $m): ?>
<tr>
<td><?= e($m['codigo']) ?></td><td><?= e($m['nombre']) ?></td>
<td><?= $m['requiere_tutor'] ? 'Sí' : 'No' ?></td><td><?= e($m['flujo']) ?></td>
<td><?= $m['activa'] ? 'Activa' : 'Inactiva' ?></td>
<td><?= (int)($estadisticasModalidades[(int)$m['id_modalidad']]['expedientes'] ?? 0) ?></td>
<td><?= (int)($estadisticasModalidades[(int)$m['id_modalidad']]['activos'] ?? 0) ?></td>
<td>
<?php if (tiene_permiso('mg.modalidades.editar')): ?>
<form method="post" action="/controllers/mg_modalidades.php?accion=estado" class="inline-form">
<input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
<input type="hidden" name="id_modalidad" value="<?= (int)$m['id_modalidad'] ?>">
<input type="hidden" name="activa" value="<?= $m['activa'] ? 0 : 1 ?>">
<button class="btn btn-light" type="submit" data-confirm="¿Deseas <?= $m['activa'] ? 'desactivar' : 'activar' ?> la modalidad <?= e($m['nombre']) ?>?"> <?= $m['activa'] ? 'Desactivar' : 'Activar' ?> </button>
</form>
<?php endif; ?>
</td></tr>
<?php endforeach; ?>
</tbody></table></div></div>
<?php require __DIR__ . '/../../layouts/footer.php'; ?>
