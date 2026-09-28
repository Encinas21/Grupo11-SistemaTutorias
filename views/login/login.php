<?php
require_once __DIR__.'/../../includes/seguridad.php';
if (!empty($_SESSION['id_usuario'])) { header('Location:/controllers/dashboard.php'); exit; }
$flash = mostrarFlash();
?><!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta http-equiv="Cache-Control" content="no-store">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<title>Iniciar sesión | Sistema de Tutorías</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="/assets/css/style.css">
</head>
<body class="login-page">
<div class="login-card">
    <div class="login-logo">ST</div>
    <div class="login-title">Sistema de Tutorías</div>
    <div class="login-sub">Accede a tu Sistema de Tutorías</div>
    <?php if ($flash): ?>
        <div class="alert alert-error" role="alert"><?= e($flash['mensaje']) ?></div>
    <?php endif; ?>
    <form method="post" action="/controllers/login_procesar.php">
        <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
        <div class="form-group">
            <label class="form-label" for="login">Usuario o correo</label>
            <input id="login" required name="login" autocomplete="username">
        </div>
        <div class="form-group">
            <label class="form-label" for="clave">Contraseña</label>
            <input id="clave" required type="password" name="clave" autocomplete="current-password">
        </div>
        <button class="btn btn-primary login-submit" type="submit"><i class="bi bi-box-arrow-in-right" aria-hidden="true"></i> Iniciar sesión</button>
    </form>
</div>
<script src="/assets/js/app.js?v=18"></script>
</body>
</html>