<?php
include __DIR__ . '/../layouts/header.php';
$esAdmin = $rol === 'administrador';
$nombreCompleto = trim(($perfil['nombre'] ?? '') . ' ' . ($perfil['apellido'] ?? ''));
$iniciales = strtoupper(substr($perfil['nombre'] ?? 'U', 0, 1) . substr($perfil['apellido'] ?? '', 0, 1));
$rolTexto = nombre_rol_visible($perfil['nombre_rol'] ?? $rol);
?>

<div class="toolbar">
    <div>
        <h1 class="page-title">Mi perfil</h1>
        <p class="subtitle">Información personal y académica de tu cuenta.</p>
    </div>
    <?php if ($esAdmin): ?><a class="btn btn-primary" href="#editar-perfil" data-open-modal="#editar-perfil"><i class="bi bi-pencil-square"></i> Editar perfil</a><?php endif; ?>
</div>

<div class="profile-hero card">
    <div class="card-body profile-hero-body">
        <div class="profile-avatar"><?= e($iniciales) ?></div>
        <div class="profile-main">
            <span class="badge badge-primary"><?= e($rolTexto) ?></span>
            <h2><?= e($nombreCompleto) ?></h2>
            <p class="profile-specialty"><?= e($perfil['usuario']) ?></p>
            <p class="profile-bio"><?= e($perfil['correo']) ?></p>
        </div>
        <div class="profile-stats">
            <div><strong><?= e($perfil['estado'] === 'activo' ? 'Activo' : 'Inactivo') ?></strong><small>Estado de cuenta</small></div>
            <div><strong><?= e(date('d/m/Y', strtotime($perfil['fecha_registro']))) ?></strong><small>Registro</small></div>
        </div>
    </div>
</div>


<div class="profile-grid profile-grid-three">
    <div class="card profile-info-card">
        <div class="card-body">
            <div class="profile-card-title"><h2>Información personal</h2><i class="bi bi-person-vcard"></i></div>
            <div class="profile-detail"><span>Nombre completo</span><strong><?= e($nombreCompleto) ?></strong></div>
            <div class="profile-detail"><span>Usuario</span><strong><?= e($perfil['usuario']) ?></strong></div>
            <div class="profile-detail"><span>Correo</span><strong><?= e($perfil['correo']) ?></strong></div>
            <div class="profile-detail"><span>Teléfono</span><strong><?= e($perfil['telefono'] ?: 'No registrado') ?></strong></div>
        </div>
    </div>

    <?php if ($rol === 'estudiante'): ?>
    <div class="card profile-info-card">
        <div class="card-body">
            <div class="profile-card-title"><h2>Información académica</h2><i class="bi bi-mortarboard"></i></div>
            <div class="profile-detail"><span>Carrera</span><strong><?= e($perfil['nombre_carrera'] ?: 'No registrada') ?></strong></div>
            <div class="profile-detail"><span>Semestre</span><strong><?= e($perfil['semestre'] ?? '—') ?></strong></div>
            <div class="profile-detail"><span>Cédula de Identidad</span><strong><?= e($perfil['registro_universitario'] ?: 'No registrado') ?></strong></div>
        </div>
    </div>
    <?php elseif ($rol === 'docente'): ?>
    <div class="card profile-info-card">
        <div class="card-body">
            <div class="profile-card-title"><h2>Información docente</h2><i class="bi bi-person-workspace"></i></div>
            <div class="profile-detail"><span>Especialidad</span><strong><?= e($perfil['especialidad'] ?: 'No registrada') ?></strong></div>
            <div class="profile-detail"><span>Rol</span><strong>Docente / Tutor</strong></div>
            <div class="profile-detail profile-detail-column"><span>Descripción</span><strong><?= e($perfil['biografia'] ?: 'Sin descripción registrada.') ?></strong></div>
        </div>
    </div>
    <?php else: ?>
    <div class="card profile-info-card">
        <div class="card-body">
            <div class="profile-card-title"><h2>Acceso administrativo</h2><i class="bi bi-shield-check"></i></div>
            <div class="profile-detail"><span>Rol</span><strong>Administrador</strong></div>
            <div class="profile-detail"><span>Permisos</span><strong>Gestión general del sistema</strong></div>
            <div class="profile-detail"><span>Edición de perfiles</span><strong>Habilitada</strong></div>
        </div>
    </div>
    <?php endif; ?>

    <div class="card profile-info-card">
        <div class="card-body">
            <div class="profile-card-title"><h2>Seguridad y cuenta</h2><i class="bi bi-shield-lock"></i></div>
            <div class="profile-detail"><span>Estado</span><strong><?= e(ucfirst($perfil['estado'])) ?></strong></div>
            <div class="profile-detail"><span>Contraseña</span><strong>••••••••</strong></div>
            <?php if (!$esAdmin): ?><div class="profile-readonly-note"><i class="bi bi-lock-fill"></i> Los datos del perfil solo pueden ser modificados por el administrador.</div><?php endif; ?>
        </div>
    </div>
</div>

<?php if ($esAdmin): ?>
<div class="modal <?= $formError ? 'is-open' : '' ?>" id="editar-perfil" role="dialog" aria-modal="true" aria-labelledby="titulo-editar-perfil">
    <div class="modal-dialog">
        <div class="modal-header">
            <div><h2 id="titulo-editar-perfil">Editar perfil administrativo</h2><small>Actualiza tus datos personales y de acceso.</small></div>
            <a class="modal-close" href="#" data-modal-close aria-label="Cerrar">×</a>
        </div>
        <div class="modal-body">
            <?php if ($formError): ?><div class="alert alert-error"><?= e($formError) ?></div><?php endif; ?>
            <form method="post">
                <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
                <div class="grid grid-2">
                    <div class="form-group"><label class="form-label">Nombre</label><input required name="nombre" data-only-letters value="<?= e($perfil['nombre']) ?>"></div>
                    <div class="form-group"><label class="form-label">Apellido</label><input required name="apellido" data-only-letters value="<?= e($perfil['apellido']) ?>"></div>
                    <div class="form-group"><label class="form-label">Correo</label><input required type="email" name="correo" value="<?= e($perfil['correo']) ?>"></div>
                    <div class="form-group"><label class="form-label">Usuario</label><input required name="usuario" value="<?= e($perfil['usuario']) ?>"></div>
                    <div class="form-group"><label class="form-label">Teléfono</label><input name="telefono" inputmode="numeric" maxlength="8" pattern="[0-9]{8}" data-phone-bolivia value="<?= e($perfil['telefono'] ?? '') ?>" placeholder="8 dígitos"></div>
                    <div class="form-group"><label class="form-label">Nueva contraseña <span class="muted-text">(opcional)</span></label><input type="password" name="clave"></div>
                    <div class="form-group"><label class="form-label">Confirmar contraseña</label><input type="password" name="confirmar_clave"></div>
                </div>
                <div class="actions"><button class="btn btn-primary"><i class="bi bi-check2-circle"></i> Guardar cambios</button><a class="btn btn-light" href="#" data-modal-close>Cancelar</a></div>
            </form>
        </div>
    </div>
</div>
<?php endif; ?>

<?php include __DIR__ . '/../layouts/footer.php'; ?>
