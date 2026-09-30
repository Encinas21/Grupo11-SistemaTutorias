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
<div class="login-shell">
    <section class="login-visual" aria-hidden="true">
        <div class="login-orbit orbit-one"></div>
        <div class="login-orbit orbit-two"></div>
        <div class="login-grid"></div>
        <div class="login-brand-lockup">
            <div class="login-brand-mark"><span>ST</span><i class="bi bi-stars"></i></div>
            <div><strong>Sistema de Tutorías</strong><small>Apoyo académico inteligente</small></div>
        </div>
        <div class="login-visual-copy">
            <h1>Tu progreso,<br><em>en un solo lugar.</em></h1>
            <p>Conecta con tus tutorías, cursos y seguimiento académico desde una experiencia simple y moderna.</p>
            <div class="login-mini-cards">
                <div><i class="bi bi-calendar2-check"></i><span>Agenda de tutorías</span><b>Organizada</b></div>
                <div><i class="bi bi-graph-up-arrow"></i><span>Seguimiento</span><b>En tiempo real</b></div>
            </div>
        </div>
    </section>

    <section class="login-panel">
        <div class="login-panel-inner">
            <div class="login-mobile-brand"><span class="login-logo">ST</span><span>Sistema de Tutorías</span></div>
            <div class="login-heading">
                <span class="login-kicker">BIENVENIDO DE NUEVO</span>
                <h2>Hola, qué bueno verte.</h2>
                <p>Ingresa tus datos para continuar con tu jornada académica.</p>
            </div>
            <?php if ($flash): ?>
                <div class="alert alert-error login-alert" role="alert"><i class="bi bi-exclamation-circle"></i><?= e($flash['mensaje']) ?></div>
            <?php endif; ?>
            <form method="post" action="/controllers/login_procesar.php" class="login-form">
                <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
                <div class="form-group login-field">
                    <label class="form-label" for="login">Usuario o correo</label>
                    <div class="login-input-wrap"><i class="bi bi-person"></i><input id="login" required name="login" autocomplete="username" placeholder="Ej. estudiante01@correo.com"></div>
                </div>
                <div class="form-group login-field">
                    <div class="login-label-row"><label class="form-label" for="clave">Contraseña</label><span>Acceso seguro</span></div>
                    <div class="login-input-wrap"><i class="bi bi-lock"></i><input id="clave" required type="password" name="clave" autocomplete="current-password" placeholder="Ingresa tu contraseña"><button type="button" class="password-toggle" data-password-toggle="clave" aria-label="Mostrar contraseña"><i class="bi bi-eye"></i></button></div>
                </div>
                <button class="btn btn-primary login-submit" type="submit"><span>Entrar al portal</span><i class="bi bi-arrow-right"></i></button>
            </form>
            <div class="login-security"><i class="bi bi-shield-lock-fill"></i><div><strong>Acceso protegido</strong><span>Tu sesión y tus datos académicos están protegidos.</span></div></div>
            <div class="login-footer"><span>UPDS · Tecnología Web</span><span><i class="bi bi-circle-fill"></i> Plataforma activa</span></div>
        </div>
    </section>
</div>
<script src="/assets/js/app.js"></script>
<script>
document.addEventListener('click', function(e){
    const btn=e.target.closest('[data-password-toggle]'); if(!btn) return;
    const input=document.getElementById(btn.dataset.passwordToggle); if(!input) return;
    input.type=input.type==='password'?'text':'password';
    btn.innerHTML=input.type==='password'?'<i class="bi bi-eye"></i>':'<i class="bi bi-eye-slash"></i>';
});
</script>
</body>
</html>
