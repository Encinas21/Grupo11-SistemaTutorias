<?php require __DIR__ . '/../../layouts/header.php'; ?>
<div class="toolbar">
  <div>
    <h1 class="page-title">Plantillas de documentos MG</h1>
    <p class="subtitle">Administra las plantillas desde ventanas emergentes. Las variables se reemplazan al generar el documento.</p>
  </div>
  <div class="badge badge-light"><?= count($plantillas) ?> plantilla(s)</div>
</div>

<div class="card" style="margin-bottom:18px">
  <div class="card-body">
    <div class="section-heading" style="margin-bottom:8px">
      <div>
        <h2>Variables disponibles</h2>
        <p>Úsalas exactamente como aparecen dentro del HTML de la plantilla.</p>
      </div>
    </div>
    <div class="mg-template-variables" aria-label="Variables disponibles">
      <code>{{estudiante_nombre}}</code>
      <code>{{registro_universitario}}</code>
      <code>{{carrera}}</code>
      <code>{{modalidad}}</code>
      <code>{{tema}}</code>
      <code>{{tutor_nombre}}</code>
      <code>{{numero_carta}}</code>
      <code>{{fecha_larga}}</code>
      <code>{{cohorte}}</code>
    </div>
  </div>
</div>

<div class="mg-template-list">
<?php foreach ($plantillas as $p): $modalId = 'editar-plantilla-' . (int)$p['id_plantilla']; ?>
  <article class="mg-template-card">
    <div class="mg-template-meta">
      <code><?= e($p['codigo']) ?></code>
      <strong><?= e($p['nombre']) ?></strong>
      <span class="subtitle">Versión <?= e($p['version']) ?> · Los documentos ya generados conservan su snapshot.</span>
    </div>
    <div class="mg-template-actions">
      <button type="button" class="btn btn-primary" data-open-modal="#<?= e($modalId) ?>">
        <i class="bi bi-pencil-square" aria-hidden="true"></i> Editar plantilla
      </button>
    </div>
  </article>

  <div class="modal mg-modal-wide" id="<?= e($modalId) ?>" role="dialog" aria-modal="true" aria-labelledby="titulo-<?= e($modalId) ?>">
    <div class="modal-dialog">
      <div class="modal-header">
        <div>
          <h2 id="titulo-<?= e($modalId) ?>">Editar plantilla</h2>
          <div style="opacity:.82;font-size:.78rem"><?= e($p['codigo']) ?> · versión <?= e($p['version']) ?></div>
        </div>
        <button type="button" class="modal-close" data-modal-close aria-label="Cerrar">×</button>
      </div>
      <div class="modal-body">
        <form method="post" action="/controllers/mg_plantillas.php?accion=guardar" class="mg-modal-form" data-no-ajax="1">
          <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
          <input type="hidden" name="id_plantilla" value="<?= (int)$p['id_plantilla'] ?>">
          <div class="grid grid-2">
            <div class="form-group">
              <label class="form-label">Código</label>
              <input value="<?= e($p['codigo']) ?>" disabled>
            </div>
            <div class="form-group">
              <label class="form-label">Nombre</label>
              <input name="nombre" value="<?= e($p['nombre']) ?>" required>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">Editor HTML</label>
            <textarea name="cuerpo_html" rows="13" style="width:100%;font-family:ui-monospace,SFMono-Regular,Consolas,monospace" required data-template-editor data-template-preview="#preview-<?= (int)$p['id_plantilla'] ?>"><?= e($p['cuerpo_html']) ?></textarea>
            <p class="mg-modal-help">Puedes usar las variables disponibles. La vista previa elimina scripts y atributos de eventos por seguridad.</p>
          </div>
          <div class="form-group">
            <label class="form-label">Vista previa</label>
            <div id="preview-<?= (int)$p['id_plantilla'] ?>" class="mg-template-preview"></div>
          </div>
          <div class="mg-modal-actions">
            <button type="button" class="btn btn-light" data-modal-close>Cancelar</button>
            <button class="btn btn-primary" type="submit"><i class="bi bi-check2-circle" aria-hidden="true"></i> Guardar plantilla</button>
          </div>
        </form>
      </div>
    </div>
  </div>
<?php endforeach; ?>
</div>
<?php require __DIR__ . '/../../layouts/footer.php'; ?>
