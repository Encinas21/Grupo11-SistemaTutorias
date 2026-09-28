<?php require __DIR__ . '/../../layouts/header.php'; ?>
<div class="toolbar">
  <div><h1 class="page-title">Cohortes MG</h1><p class="subtitle">Agrupación por cohorte de inicio. Una cohorte con expedientes no se elimina: se desactiva.</p></div>
  <?php if ($puedeEditar): ?><button type="button" class="btn btn-primary" data-open-modal="#modal-nueva-cohorte"><i class="bi bi-plus-circle" aria-hidden="true"></i> Nueva cohorte</button><?php endif; ?>
</div>
<div class="card"><div class="card-body"><div class="table-wrap"><table class="table">
<thead><tr><th>Código</th><th>Nombre</th><th>Inicio</th><th>Fin</th><th>Estado</th><th>Acciones</th></tr></thead>
<tbody>
<?php foreach ($cohortes as $c): $modalId='modal-cohorte-'.(int)$c['id_cohorte']; ?>
<tr>
<td><code><?= e($c['codigo']) ?></code></td><td><?= e($c['nombre']) ?></td><td><?= e($c['fecha_inicio']) ?></td><td><?= e($c['fecha_fin'] ?? '') ?></td>
<td><span class="badge <?= $c['activa'] ? 'badge-success' : 'badge-light' ?>"><?= $c['activa'] ? 'Activa' : 'Inactiva' ?></span></td>
<td><div class="actions">
  <?php if ($puedeEditar): ?><button type="button" class="btn btn-light btn-sm" data-open-modal="#<?= e($modalId) ?>">Editar</button><?php endif; ?>
  <a class="btn btn-light btn-sm" href="/controllers/mg_calendario.php?accion=listar&id_cohorte=<?= (int)$c['id_cohorte'] ?>">Calendario</a>
</div></td>
</tr>
<?php endforeach; if (!$cohortes): ?><tr><td colspan="6" class="empty compact">No hay cohortes registradas.</td></tr><?php endif; ?>
</tbody></table></div></div></div>

<?php if ($puedeEditar): ?>
<div class="modal" id="modal-nueva-cohorte" role="dialog" aria-modal="true" aria-labelledby="titulo-nueva-cohorte">
  <div class="modal-dialog"><div class="modal-header"><h2 id="titulo-nueva-cohorte">Nueva cohorte</h2><button type="button" class="modal-close" data-modal-close aria-label="Cerrar">×</button></div>
  <div class="modal-body"><form method="post" action="/controllers/mg_cohortes.php?accion=guardar" class="mg-modal-form" data-no-ajax="1">
    <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
    <div class="grid grid-2">
      <div class="form-group"><label class="form-label">Código</label><input name="codigo" required placeholder="G1-2026-03"></div>
      <div class="form-group"><label class="form-label">Nombre</label><input name="nombre" required placeholder="Grupo 1 - Marzo 2026"></div>
      <div class="form-group"><label class="form-label">Fecha de inicio</label><input type="date" name="fecha_inicio" required></div>
      <div class="form-group"><label class="form-label">Fecha de fin</label><input type="date" name="fecha_fin"></div>
      <div class="form-group"><label><input type="checkbox" name="activa" value="1" checked> Activa</label></div>
    </div>
    <div class="mg-modal-actions"><button type="button" class="btn btn-light" data-modal-close>Cancelar</button><button class="btn btn-primary" type="submit">Guardar</button></div>
  </form></div></div>
</div>
<?php foreach ($cohortes as $c): $modalId='modal-cohorte-'.(int)$c['id_cohorte']; ?>
<div class="modal" id="<?= e($modalId) ?>" role="dialog" aria-modal="true" aria-labelledby="titulo-<?= e($modalId) ?>">
  <div class="modal-dialog"><div class="modal-header"><h2 id="titulo-<?= e($modalId) ?>">Editar cohorte</h2><button type="button" class="modal-close" data-modal-close aria-label="Cerrar">×</button></div>
  <div class="modal-body"><form method="post" action="/controllers/mg_cohortes.php?accion=guardar" class="mg-modal-form" data-no-ajax="1">
    <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="id_cohorte" value="<?= (int)$c['id_cohorte'] ?>">
    <div class="grid grid-2">
      <div class="form-group"><label class="form-label">Código</label><input name="codigo" value="<?= e($c['codigo']) ?>" required></div>
      <div class="form-group"><label class="form-label">Nombre</label><input name="nombre" value="<?= e($c['nombre']) ?>" required></div>
      <div class="form-group"><label class="form-label">Inicio</label><input type="date" name="fecha_inicio" value="<?= e($c['fecha_inicio']) ?>" required></div>
      <div class="form-group"><label class="form-label">Fin</label><input type="date" name="fecha_fin" value="<?= e($c['fecha_fin'] ?? '') ?>"></div>
      <div class="form-group"><label><input type="checkbox" name="activa" value="1" <?= $c['activa'] ? 'checked' : '' ?>> Activa</label></div>
    </div>
    <div class="mg-modal-actions"><button type="button" class="btn btn-light" data-modal-close>Cancelar</button><button class="btn btn-primary" type="submit">Guardar cambios</button></div>
  </form></div></div>
</div>
<?php endforeach; endif; ?>
<?php require __DIR__ . '/../../layouts/footer.php'; ?>
