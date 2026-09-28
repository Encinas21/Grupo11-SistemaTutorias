<?php
$esModal = (($_GET['modal'] ?? '') === '1');
if (!$esModal) { require __DIR__.'/../../layouts/header.php'; }
?>
<?php if ($esModal): ?>
<div class="modal is-open" data-dynamic="1" role="dialog" aria-modal="true" aria-labelledby="titulo-asignacion-tutor">
  <div class="modal-dialog mg-modal-wide">
    <div class="modal-header"><div><h2 id="titulo-asignacion-tutor"><?=$actual?'Cambiar Tutor':'Asignar Tutor'?></h2><div style="opacity:.82;font-size:.78rem">Expediente #<?=$x['id_expediente']?> · <?=e($x['apellido'].', '.$x['nombre'])?></div></div><button type="button" class="modal-close" data-modal-close aria-label="Cerrar">×</button></div>
    <div class="modal-body">
      <form method="post" action="/controllers/mg_asignaciones.php?accion=guardar" class="mg-modal-form" data-no-ajax="1">
        <input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><input type="hidden" name="id_expediente" value="<?=$x['id_expediente']?>"><input type="hidden" name="id_anterior" value="<?=$actual['id_asignacion']??''?>">
        <div class="grid grid-2">
          <div class="form-group"><label class="form-label">Tutor</label><select name="id_tutor" required><?php foreach($tutores as $t): ?><option value="<?=$t['id_tutor']?>"><?=e($t['apellido'].', '.$t['nombre'])?> · <?=e($t['especialidad']??'Sin especialidad')?> · carga <?=$t['carga']?><?=(($cargaRecomendada>0 && $t['carga']>=$cargaRecomendada)?' · ADVERTENCIA':'')?> · disponibilidad <?=$t['disponibilidad']?'registrada':'sin registro'?></option><?php endforeach;?></select></div>
          <div class="form-group"><label class="form-label">Fecha de asignación</label><input type="date" name="fecha" value="<?=date('Y-m-d')?>" required></div>
          <div class="form-group"><label><input type="checkbox" name="disponibilidad_consultada" value="1" required> Disponibilidad consultada</label></div>
          <div class="form-group"><label class="form-label">Referencia de Decanatura</label><input name="referencia_decanatura" required value=""></div>
          <?php if($actual): ?><div class="form-group span-2"><label class="form-label">Motivo de cambio/renuncia</label><textarea name="motivo_fin" required></textarea></div><?php endif; ?>
          <div class="form-group span-2"><label class="form-label">Observaciones</label><textarea name="observaciones"></textarea></div>
        </div>
        <div class="mg-modal-actions"><button type="button" class="btn btn-light" data-modal-close>Cancelar</button><button class="btn btn-primary" type="submit"><?=$actual?'Registrar cambio':'Asignar Tutor'?></button></div>
      </form>
    </div>
  </div>
</div>
<?php else: ?>
<div class="toolbar"><div><h1 class="page-title"><?=$actual?'Cambiar Tutor':'Asignar Tutor'?></h1><p class="subtitle">Expediente #<?=$x['id_expediente']?> · <?=e($x['apellido'].', '.$x['nombre'])?></p></div></div>
<div class="card"><div class="card-body"><form method="post" action="/controllers/mg_asignaciones.php?accion=guardar" class="form-grid"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><input type="hidden" name="id_expediente" value="<?=$x['id_expediente']?>"><input type="hidden" name="id_anterior" value="<?=$actual['id_asignacion']??''?>"><div><label class="form-label">Tutor</label><select name="id_tutor" required><?php foreach($tutores as $t): ?><option value="<?=$t['id_tutor']?>"><?=e($t['apellido'].', '.$t['nombre'])?> · <?=e($t['especialidad']??'Sin especialidad')?> · carga <?=$t['carga']?><?=(($cargaRecomendada>0 && $t['carga']>=$cargaRecomendada)?' · ADVERTENCIA':'')?> · disponibilidad <?=$t['disponibilidad']?'registrada':'sin registro'?></option><?php endforeach;?></select></div><div><label class="form-label">Fecha de asignación</label><input type="date" name="fecha" value="<?=date('Y-m-d')?>" required></div><div><label><input type="checkbox" name="disponibilidad_consultada" value="1" required> Disponibilidad consultada</label></div><div><label class="form-label">Referencia de Decanatura</label><input name="referencia_decanatura" required value=""></div><?php if($actual): ?><div><label class="form-label">Motivo de cambio/renuncia</label><textarea name="motivo_fin" required></textarea></div><?php endif; ?><div><label class="form-label">Observaciones</label><textarea name="observaciones"></textarea></div><div><button class="btn btn-primary" type="submit"><?=$actual?'Registrar cambio':'Asignar Tutor'?></button><a class="btn btn-light" href="/controllers/mg_expedientes.php?accion=ficha&id=<?=$x['id_expediente']?>">Cancelar</a></div></form></div></div>
<div class="card"><div class="card-body"><h2>Línea de tiempo de Tutor</h2><table class="table"><thead><tr><th>Tutor</th><th>Desde</th><th>Hasta</th><th>Estado</th><th>Referencia</th></tr></thead><tbody><?php foreach($historial as $h): ?><tr><td><?=e($h['apellido'].', '.$h['nombre'])?></td><td><?=e($h['fecha_asignacion'])?></td><td><?=e($h['fecha_fin']??'')?></td><td><?=e($h['estado'])?></td><td><?=e($h['referencia_decanatura']??'')?></td></tr><?php endforeach;?></tbody></table></div></div>
<?php require __DIR__.'/../../layouts/footer.php'; ?>
<?php endif; ?>
