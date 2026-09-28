<?php

require_once __DIR__ . '/../../includes/seguridad.php';

$tituloPagina = $tituloPagina ?? 'Sistema de Tutorías';

$flash = mostrarFlash();

$rol = user_role();

$rolVisible = nombre_rol_visible($rol);

$path = $_SERVER['REQUEST_URI'] ?? '';

function activo(string $needle): string
{
    global $path;

    return str_contains($path, $needle) ? 'active' : '';
}

$nombreUsuario = $_SESSION['nombre'] ?? 'Usuario';

$inicialUsuario = strtoupper(substr($nombreUsuario, 0, 1));

// Un estudiante solo accede al módulo de Modalidad de Grado cuando ya culminó
// su plan académico. Se mantiene un fallback para instalaciones antiguas.
$estudianteEgresado = false;
if ($rol === 'estudiante') {
    try {
        $stmtEgreso = $pdo->prepare("SELECT estado_academico FROM estudiantes WHERE id_usuario=? LIMIT 1");
        $stmtEgreso->execute([(int)($_SESSION['id_usuario'] ?? 0)]);
        $estadoAcademico = (string)$stmtEgreso->fetchColumn();
        $estudianteEgresado = in_array($estadoAcademico, ['egresado'], true);
    } catch (Throwable $e) {
        $stmtEgreso = $pdo->prepare("SELECT e.semestre, SUM(i.estado='activa') activos FROM estudiantes e LEFT JOIN inscripciones i ON i.id_estudiante=e.id_estudiante WHERE e.id_usuario=? GROUP BY e.id_estudiante,e.semestre");
        $stmtEgreso->execute([(int)($_SESSION['id_usuario'] ?? 0)]);
        $academicoFallback = $stmtEgreso->fetch() ?: [];
        $estudianteEgresado = ((int)($academicoFallback['semestre'] ?? 0) >= 9 && (int)($academicoFallback['activos'] ?? 0) === 0);
    }
}

require_once __DIR__ . '/../../models/NotificacionModel.php';

$notifModel = new NotificacionModel($pdo);

$notifNoLeidas = $rol
    ? $notifModel->contarNoLeidas((int) ($_SESSION['id_usuario'] ?? 0))
    : 0;

$notifRecientes = $rol
    ? $notifModel->obtenerRecientes((int) ($_SESSION['id_usuario'] ?? 0))
    : [];

?>

<!doctype html>

<html lang="es">

<head>

    <meta charset="utf-8">

    <meta name="viewport" content="width=device-width, initial-scale=1">

    <meta
        name="description"
        content="Sistema Web de Apoyo Académico para Tutorías"
    >

    <title>
        <?= e($tituloPagina) ?> | Sistema de Tutorías
    </title>

    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
    >

    <link
        rel="stylesheet"
        href="/assets/css/style.css"
    >

</head>

<body>

<div class="app">

    <aside
        class="sidebar"
        aria-label="Navegación principal"
    >

        <div class="brand">

            <span
                class="brand-mark"
                aria-hidden="true"
            >
                ST
            </span>

            <span>
                Sistema de Tutorías
            </span>

        </div>


        <div class="nav-title">
            Principal
        </div>


        <a
            class="nav-link <?= e(activo('/dashboard')) ?>"
            href="/controllers/dashboard.php"
        >

            <i
                class="bi bi-grid-1x2-fill"
                aria-hidden="true"
            ></i>

            <span>
                Dashboard
            </span>

        </a>


        <?php if ($rol === 'administrador'): ?>

            <div class="nav-title">
                Académico
            </div>


            <a
                class="nav-link <?= e(activo('/estudiantes')) ?>"
                href="/controllers/estudiantes.php"
            >

                <i
                    class="bi bi-mortarboard-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Estudiantes
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/profesores')) ?>"
                href="/controllers/profesores.php"
            >

                <i
                    class="bi bi-person-workspace"
                    aria-hidden="true"
                ></i>

                <span>
                    Docentes
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/cursos')) ?>"
                href="/controllers/cursos.php"
            >

                <i
                    class="bi bi-journal-bookmark-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Cursos
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/inscripciones')) ?>"
                href="/controllers/inscripciones.php"
            >

                <i
                    class="bi bi-pencil-square"
                    aria-hidden="true"
                ></i>

                <span>
                    Inscripciones
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/calificaciones')) ?>"
                href="/controllers/calificaciones.php"
            >

                <i
                    class="bi bi-star-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Calificaciones
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/asistencia')) ?>"
                href="/controllers/asistencia.php"
            >

                <i
                    class="bi bi-calendar-check-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Asistencia
                </span>

            </a>


            <div class="nav-title">
                Administración
            </div>


            <a
                class="nav-link <?= e(activo('/usuarios')) ?>"
                href="/controllers/usuarios.php"
            >

                <i
                    class="bi bi-people-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Usuarios
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/roles')) ?>"
                href="/controllers/roles.php"
            >

                <i
                    class="bi bi-shield-lock-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Roles
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/carreras')) ?>"
                href="/controllers/carreras.php"
            >

                <i
                    class="bi bi-bank"
                    aria-hidden="true"
                ></i>

                <span>
                    Carreras
                </span>

            </a>


            <div class="nav-title">
                Tutorías
            </div>


            <a
                class="nav-link <?= e(activo('/tutorias')) ?>"
                href="/controllers/tutorias.php"
            >

                <i
                    class="bi bi-calendar3"
                    aria-hidden="true"
                ></i>

                <span>
                    Tutorías
                </span>

            </a>


            <div class="nav-title">
                Modalidades de Grado
            </div>

            <a class="nav-link <?= e(activo('/mg_cohortes')) ?>" href="/controllers/mg_cohortes.php?accion=listar">
                <i class="bi bi-people-fill" aria-hidden="true"></i><span>Cohortes MG</span>
            </a>
            <a class="nav-link <?= e(activo('/mg_expedientes')) ?>" href="/controllers/mg_expedientes.php?accion=listar"><i class="bi bi-folder2-open" aria-hidden="true"></i><span>Expedientes MG</span></a>
            <a class="nav-link <?= e(activo('/mg_defensas')) ?>" href="/controllers/mg_defensas.php?accion=agenda"><i class="bi bi-calendar-event" aria-hidden="true"></i><span>Defensas MG</span></a>
            <a class="nav-link <?= e(activo('/mg_reportes')) ?>" href="/controllers/mg_reportes.php"><i class="bi bi-bar-chart" aria-hidden="true"></i><span>Reportes MG</span></a>
            <a class="nav-link <?= e(activo('/mg_calendario')) ?>" href="/controllers/mg_calendario.php?accion=listar">
                <i class="bi bi-calendar3" aria-hidden="true"></i><span>Calendario MG</span>
            </a>
            <a class="nav-link <?= e(activo('/mg_calendario_hitos')) ?>" href="/controllers/mg_calendario_hitos.php"><i class="bi bi-signpost-split" aria-hidden="true"></i><span>Hitos MG</span></a>
            <a class="nav-link <?= e(activo('/mg_modalidades')) ?>" href="/controllers/mg_modalidades.php?accion=listar">
                <i class="bi bi-list-check" aria-hidden="true"></i><span>Modalidades</span>
            </a>
            <a class="nav-link <?= e(activo('/mg_parametros')) ?>" href="/controllers/mg_parametros.php?accion=listar">
                <i class="bi bi-sliders" aria-hidden="true"></i><span>Parámetros MG</span>
            </a>
            <a class="nav-link <?= e(activo('/mg_plantillas')) ?>" href="/controllers/mg_plantillas.php?accion=listar"><i class="bi bi-file-earmark-text" aria-hidden="true"></i><span>Plantillas MG</span></a>
            <a class="nav-link <?= e(activo('/mg_reuniones')) ?>" href="/controllers/mg_reuniones.php"><i class="bi bi-people" aria-hidden="true"></i><span>Reuniones MG</span></a>
            <a class="nav-link <?= e(activo('/mg_informes')) ?>" href="/controllers/mg_informes.php"><i class="bi bi-file-earmark-bar-graph" aria-hidden="true"></i><span>Informes MG</span></a>
            <a class="nav-link <?= e(activo('/mg_alertas')) ?>" href="/controllers/mg_alertas.php"><i class="bi bi-exclamation-triangle" aria-hidden="true"></i><span>Alertas MG</span></a>
            <a class="nav-link <?= e(activo('/mg_dashboard')) ?>" href="/controllers/mg_dashboard.php"><i class="bi bi-speedometer2" aria-hidden="true"></i><span>Dashboard MG</span></a>
            <a class="nav-link <?= e(activo('/mg_bitacora')) ?>" href="/controllers/mg_bitacora.php"><i class="bi bi-journal-text" aria-hidden="true"></i><span>Bitácora MG</span></a>

        <?php elseif (in_array($rol, ['coordinador_mg', 'auxiliar_mg'], true)): ?>

            <div class="nav-title">
                Modalidades de Grado
            </div>

            <a class="nav-link <?= e(activo('/mg_cohortes')) ?>" href="/controllers/mg_cohortes.php?accion=listar">
                <i class="bi bi-people-fill" aria-hidden="true"></i><span>Cohortes MG</span>
            </a>
            <a class="nav-link <?= e(activo('/mg_expedientes')) ?>" href="/controllers/mg_expedientes.php?accion=listar"><i class="bi bi-folder2-open" aria-hidden="true"></i><span>Expedientes MG</span></a>
            <a class="nav-link <?= e(activo('/mg_calendario')) ?>" href="/controllers/mg_calendario.php?accion=listar">
                <i class="bi bi-calendar3" aria-hidden="true"></i><span>Calendario MG</span>
            </a>
            <a class="nav-link <?= e(activo('/mg_modalidades')) ?>" href="/controllers/mg_modalidades.php?accion=listar">
                <i class="bi bi-list-check" aria-hidden="true"></i><span>Modalidades</span>
            </a>
            <?php if ($rol !== 'auxiliar_mg'): ?>
            <a class="nav-link <?= e(activo('/mg_parametros')) ?>" href="/controllers/mg_parametros.php?accion=listar">
                <i class="bi bi-sliders" aria-hidden="true"></i><span>Parámetros MG</span>
            </a>
            <?php endif; ?>
            <a class="nav-link <?= e(activo('/mg_reuniones')) ?>" href="/controllers/mg_reuniones.php"><i class="bi bi-people" aria-hidden="true"></i><span>Reuniones MG</span></a>
            <a class="nav-link <?= e(activo('/mg_informes')) ?>" href="/controllers/mg_informes.php"><i class="bi bi-file-earmark-bar-graph" aria-hidden="true"></i><span>Informes MG</span></a>
            <a class="nav-link <?= e(activo('/mg_alertas')) ?>" href="/controllers/mg_alertas.php"><i class="bi bi-exclamation-triangle" aria-hidden="true"></i><span>Alertas MG</span></a>
            <a class="nav-link <?= e(activo('/mg_dashboard')) ?>" href="/controllers/mg_dashboard.php"><i class="bi bi-speedometer2" aria-hidden="true"></i><span>Dashboard MG</span></a>

        <?php elseif ($rol === 'docente'): ?>

            <div class="nav-title">
                Mi gestión
            </div>


            <a
                class="nav-link <?= e(activo('/cursos')) ?>"
                href="/controllers/cursos.php"
            >

                <i
                    class="bi bi-journal-bookmark-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Mis cursos
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/calificaciones')) ?>"
                href="/controllers/calificaciones.php"
            >

                <i
                    class="bi bi-star-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Calificaciones
                </span>

            </a>



            <a
                class="nav-link <?= e(activo('/mis_estudiantes')) ?>"
                href="/controllers/mis_estudiantes.php"
            >
                <i class="bi bi-people-fill" aria-hidden="true"></i>
                <span>Mis estudiantes</span>
            </a>

            <a
                class="nav-link <?= e(activo('/asistencia')) ?>"
                href="/controllers/asistencia.php"
            >

                <i
                    class="bi bi-calendar-check-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Asistencia
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/tutorias')) ?>"
                href="/controllers/tutorias.php"
            >

                <i
                    class="bi bi-calendar3"
                    aria-hidden="true"
                ></i>

                <span>
                    Tutorías
                </span>

            </a>

            <div class="nav-title">
                Modalidad de Grado
            </div>
            <a class="nav-link <?= e(activo('/mg_expedientes')) ?>" href="/controllers/mg_expedientes.php?accion=listar">
                <i class="bi bi-folder2-open" aria-hidden="true"></i><span>Expedientes MG</span>
            </a>
            <a class="nav-link <?= e(activo('/mg_defensas')) ?>" href="/controllers/mg_defensas.php?accion=agenda">
                <i class="bi bi-calendar-event" aria-hidden="true"></i><span>Defensas MG</span>
            </a>
            <a class="nav-link <?= e(activo('/mg_reuniones')) ?>" href="/controllers/mg_reuniones.php"><i class="bi bi-people" aria-hidden="true"></i><span>Reuniones MG</span></a>
            <a class="nav-link <?= e(activo('/mg_informes')) ?>" href="/controllers/mg_informes.php"><i class="bi bi-file-earmark-bar-graph" aria-hidden="true"></i><span>Informes MG</span></a>

        <?php else: ?>

            <div class="nav-title">
                Mi portal
            </div>


            <a
                class="nav-link <?= e(activo('/calificaciones')) ?>"
                href="/controllers/calificaciones.php"
            >

                <i
                    class="bi bi-star-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Mis notas
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/asistencia')) ?>"
                href="/controllers/asistencia.php"
            >

                <i
                    class="bi bi-calendar-check-fill"
                    aria-hidden="true"
                ></i>

                <span>
                    Mi asistencia
                </span>

            </a>


            <a
                class="nav-link <?= e(activo('/tutorias')) ?>"
                href="/controllers/tutorias.php"
            >

                <i
                    class="bi bi-calendar3"
                    aria-hidden="true"
                ></i>

                <span>
                    Mis tutorías
                </span>

            </a>

            <?php if ($estudianteEgresado): ?>
                <div class="nav-title">
                    Modalidad de Grado
                </div>
                <a class="nav-link <?= e(activo('/mg_expedientes')) ?>" href="/controllers/mg_expedientes.php?accion=listar">
                    <i class="bi bi-folder2-open" aria-hidden="true"></i><span>Mi expediente MG</span>
                </a>
                <a class="nav-link <?= e(activo('/mg_defensas')) ?>" href="/controllers/mg_defensas.php?accion=agenda">
                    <i class="bi bi-calendar-event" aria-hidden="true"></i><span>Mis defensas MG</span>
                </a>
                <a class="nav-link <?= e(activo('/mg_calificaciones')) ?>" href="/controllers/mg_expedientes.php?accion=listar">
                    <i class="bi bi-award" aria-hidden="true"></i><span>Mi proceso de grado</span>
                </a>
            <?php endif; ?>

        <?php endif; ?>


        <div class="sidebar-logout">

            <a
                class="nav-link"
                href="/controllers/logout.php"
            >

                <i
                    class="bi bi-box-arrow-right"
                    aria-hidden="true"
                ></i>

                <span>
                    Cerrar sesión
                </span>

            </a>

        </div>

    </aside>


    <div
        class="sidebar-overlay"
        data-sidebar-overlay
    ></div>


    <main class="main">

        <header class="topbar">

            <div class="topbar-left">

                <button
                    class="mobile-toggle"
                    type="button"
                    data-menu-toggle
                    aria-label="Abrir menú"
                    aria-controls="sidebar"
                >

                    <i class="bi bi-list"></i>

                </button>


                <div>

                    <strong>
                        <?= e($tituloPagina) ?>
                    </strong>

                    <div class="topbar-subtitle">
                        Sistema Web de Apoyo Académico para Tutorías
                    </div>

                </div>

            </div>


            <!-- NOTIFICACIONES -->

            <details class="notif-dropdown">

                <summary
                    class="notif-bell"
                    aria-label="Notificaciones"
                >

                    <i
                        class="bi bi-bell-fill"
                        aria-hidden="true"
                    ></i>


                    <?php if ($notifNoLeidas > 0): ?>

                        <span class="notif-count">

                            <?= $notifNoLeidas > 9
                                ? '9+'
                                : (int) $notifNoLeidas ?>

                        </span>

                    <?php endif; ?>

                </summary>


                <div class="notif-panel">

                    <div class="notif-panel-header">

                        <strong>
                            Notificaciones
                        </strong>


                        <?php if ($notifNoLeidas > 0): ?>

                            <form
                                method="post"
                                action="/controllers/notificaciones.php"
                            >

                                <input
                                    type="hidden"
                                    name="csrf"
                                    value="<?= e(csrf_token()) ?>"
                                >

                                <input
                                    type="hidden"
                                    name="accion"
                                    value="marcar_todas"
                                >

                                <input
                                    type="hidden"
                                    name="volver"
                                    value="<?= e($path) ?>"
                                >

                                <button
                                    class="link-button"
                                    type="submit"
                                >
                                    Marcar todas como leídas
                                </button>

                            </form>

                        <?php endif; ?>

                    </div>


                    <?php if (!$notifRecientes): ?>

                        <p class="muted-text notif-empty">
                            No tienes notificaciones todavía.
                        </p>

                    <?php endif; ?>


                    <?php foreach ($notifRecientes as $notif): ?>

                        <div
                            class="notif-item <?= $notif['leida'] ? '' : 'is-unread' ?>"
                        >

                            <a
                                href="<?= e($notif['url'] ?: '#') ?>"
                                class="notif-item-msg"
                            >

                                <?= e($notif['mensaje']) ?>

                                <small>
                                    <?= e($notif['fecha_creacion']) ?>
                                </small>

                            </a>


                            <?php if (!$notif['leida']): ?>

                                <form
                                    method="post"
                                    action="/controllers/notificaciones.php"
                                >

                                    <input
                                        type="hidden"
                                        name="csrf"
                                        value="<?= e(csrf_token()) ?>"
                                    >

                                    <input
                                        type="hidden"
                                        name="accion"
                                        value="marcar_leida"
                                    >

                                    <input
                                        type="hidden"
                                        name="id"
                                        value="<?= (int) $notif['id_notificacion'] ?>"
                                    >

                                    <input
                                        type="hidden"
                                        name="volver"
                                        value="<?= e($path) ?>"
                                    >

                                    <button
                                        class="link-button"
                                        type="submit"
                                        title="Marcar como leída"
                                    >
                                        ✓
                                    </button>

                                </form>

                            <?php endif; ?>

                        </div>

                    <?php endforeach; ?>

                </div>

            </details>


            <!-- PERFIL DEL USUARIO -->

            <a
                href="/controllers/perfil.php"
                class="user-chip"
                title="Ver mi perfil"
                style="
                    text-decoration: none;
                    color: inherit;
                    cursor: pointer;
                "
            >

                <div class="user-info">

                    <strong>
                        <?= e($nombreUsuario) ?>
                    </strong>

                    <div class="user-role">
                        <?= e($rolVisible) ?>
                    </div>

                </div>


                <div
                    class="avatar"
                    aria-hidden="true"
                >
                    <?= e($inicialUsuario) ?>
                </div>

            </a>
        </header>


        <section class="content">

            <?php if ($flash): ?>

                <div
                    class="alert alert-<?= e(
                        $flash['tipo'] === 'success'
                            ? 'success'
                            : 'error'
                    ) ?>"
                    data-toast="1"
                    role="alert"
                >

                    <?= e($flash['mensaje']) ?>

                </div>

            <?php endif; ?>