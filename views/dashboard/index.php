<?php $tituloPagina='Dashboard'; include __DIR__.'/../layouts/header.php'; ?>

<div class="dashboard-page">
    <section class="dashboard-hero">
        <div class="dashboard-hero-pattern"></div>
        <div class="dashboard-hero-copy">
            <span class="hero-kicker"><i class="bi bi-grid-1x2-fill"></i> <?= e(ucfirst($rol)) ?> · Panel principal</span>
            <h1>Hola, <?= e($_SESSION['nombre']) ?> <span>✦</span></h1>
            <p><?= $rol==='administrador' ? 'Todo el sistema académico, resumido en una vista clara para tomar decisiones rápidamente.' : ($rol==='docente' ? 'Consulta tus herramientas académicas y mantén tus tutorías organizadas desde un solo lugar.' : 'Consulta tu información académica y mantén tus tutorías al día desde un solo lugar.') ?></p>
        </div>
        <div class="dashboard-hero-side">
            <div class="hero-date"><i class="bi bi-calendar3"></i><span>Panel académico</span><strong>Gestión &amp; seguimiento</strong></div>
            <a class="hero-action" href="/controllers/tutorias.php"><i class="bi bi-arrow-up-right"></i></a>
        </div>
        <div class="hero-glow hero-glow-one"></div><div class="hero-glow hero-glow-two"></div>
    </section>

    <?php if($rol==='administrador'): ?>
        <section class="dashboard-stat-grid">
            <div class="dashboard-stat stat-blue"><div class="stat-top"><span>Estudiantes</span><i class="bi bi-mortarboard-fill"></i></div><strong><?= number_format($stats['estudiantes']) ?></strong><small>Registrados en el sistema</small><div class="stat-accent"></div></div>
            <div class="dashboard-stat stat-cyan"><div class="stat-top"><span>Docentes</span><i class="bi bi-person-workspace"></i></div><strong><?= number_format($stats['profesores']) ?></strong><small>Equipo académico</small><div class="stat-accent"></div></div>
            <div class="dashboard-stat stat-navy"><div class="stat-top"><span>Cursos</span><i class="bi bi-journal-bookmark-fill"></i></div><strong><?= number_format($stats['cursos']) ?></strong><small>Materias activas</small><div class="stat-accent"></div></div>
            <div class="dashboard-stat stat-green"><div class="stat-top"><span>Promedio</span><i class="bi bi-stars"></i></div><strong><?= number_format($stats['promedio'],1) ?></strong><small>Promedio general</small><div class="stat-accent"></div></div>
            <div class="dashboard-stat stat-orange"><div class="stat-top"><span>Asistencia</span><i class="bi bi-calendar2-check-fill"></i></div><strong><?= number_format($stats['asistencia'],1) ?>%</strong><small>Registro general</small><div class="stat-accent"></div></div>
        </section>

        <?php $maxPromedio=0; foreach($grafico as $item){$maxPromedio=max($maxPromedio,(float)$item['promedio']);} $maxPromedio=max($maxPromedio,100); ?>
        <div class="dashboard-main-grid">
            <section class="dashboard-panel dashboard-chart-panel">
                <div class="panel-heading"><div><span class="panel-kicker">ANÁLISIS ACADÉMICO</span><h2>Promedio por curso</h2><p>Una lectura rápida del rendimiento registrado.</p></div><span class="panel-icon"><i class="bi bi-bar-chart-line-fill"></i></span></div>
                <div class="course-average-list" aria-label="Promedio por curso">
                    <?php foreach($grafico as $item): $valor=(float)$item['promedio']; $ancho=$maxPromedio>0?min(100,($valor/$maxPromedio)*100):0; ?>
                        <div class="course-average-row"><div class="course-average-label"><strong><?= e($item['codigo']) ?></strong><span><?= e($item['nombre_curso']) ?></span></div><div class="course-average-track"><div class="course-average-bar" style="width:<?= number_format($ancho,2,'.','') ?>%"></div></div><div class="course-average-value"><?= number_format($valor,1) ?></div></div>
                    <?php endforeach; ?>
                </div>
                <div class="chart-footnote"><span><i class="bi bi-info-circle"></i> Escala sobre 100 puntos</span><strong><?= count($grafico) ?> cursos</strong></div>
            </section>
            <section class="dashboard-panel module-panel">
                <div class="panel-heading"><div><span class="panel-kicker">CENTRO DE CONTROL</span><h2>Acciones rápidas</h2><p>Accede directamente a las áreas más utilizadas.</p></div><span class="panel-icon navy"><i class="bi bi-command"></i></span></div>
                <div class="quick-actions">
                    <a href="/controllers/estudiantes.php"><span class="quick-icon blue"><i class="bi bi-people-fill"></i></span><span><strong>Estudiantes</strong><small>Consultar registros</small></span><i class="bi bi-chevron-right"></i></a>
                    <a href="/controllers/calificaciones.php"><span class="quick-icon green"><i class="bi bi-graph-up-arrow"></i></span><span><strong>Calificaciones</strong><small>Revisar rendimiento</small></span><i class="bi bi-chevron-right"></i></a>
                    <a href="/controllers/tutorias.php"><span class="quick-icon orange"><i class="bi bi-calendar-heart"></i></span><span><strong>Tutorías</strong><small>Gestionar agenda</small></span><i class="bi bi-chevron-right"></i></a>
                    <a href="/controllers/asistencia.php"><span class="quick-icon red"><i class="bi bi-check2-circle"></i></span><span><strong>Asistencia</strong><small>Seguimiento académico</small></span><i class="bi bi-chevron-right"></i></a>
                </div>
            </section>
        </div>

        <section class="dashboard-bottom-grid">
            <div class="dashboard-panel insight-panel"><div class="insight-symbol"><i class="bi bi-lightbulb-fill"></i></div><div><span class="panel-kicker">VISIÓN GENERAL</span><h3>Un panel pensado para decidir rápido.</h3><p>La información principal queda agrupada por rendimiento, asistencia y gestión para que las tareas frecuentes estén a pocos clics.</p></div></div>
            <div class="dashboard-panel mini-metric"><span>Sesiones de tutoría</span><strong><?= number_format($stats['tutorias']) ?></strong><small>registradas en el sistema</small><a href="/controllers/tutorias.php">Ver agenda <i class="bi bi-arrow-right"></i></a></div>
        </section>

    <?php elseif($rol==='docente'): ?>
        <div class="role-dashboard-grid">
            <section class="dashboard-panel role-profile-card">
                <div class="role-card-head"><div class="role-avatar teacher"><i class="bi bi-person-workspace"></i></div><div><span class="panel-kicker">MI PERFIL DOCENTE</span><h2><?= e($_SESSION['nombre']) ?></h2><p>Gestiona tus cursos, estudiantes y tutorías.</p></div></div>
                <div class="teacher-focus"><div><i class="bi bi-journal-text"></i><span>Mis cursos</span><strong>Consulta desde el menú</strong></div><div><i class="bi bi-people"></i><span>Mis estudiantes</span><strong>Seguimiento directo</strong></div><div><i class="bi bi-calendar-heart"></i><span>Tutorías</span><strong>Agenda disponible</strong></div></div>
                <div class="actions"><a class="btn btn-primary" href="/controllers/calificaciones.php"><i class="bi bi-pencil-square"></i> Registrar notas</a><a class="btn btn-light" href="/controllers/tutorias.php"><i class="bi bi-calendar3"></i> Ver tutorías</a></div>
            </section>
            <section class="dashboard-panel role-side-card navy-card"><span class="panel-kicker">TU ESPACIO DE TRABAJO</span><div class="big-icon"><i class="bi bi-mortarboard-fill"></i></div><h2>Todo lo necesario para acompañar a tus estudiantes.</h2><p>Usa las herramientas del panel para registrar asistencia, calificaciones y gestionar tus horarios de tutoría.</p><a href="/controllers/mis_estudiantes.php" class="text-action">Ver mis estudiantes <i class="bi bi-arrow-up-right"></i></a></section>
        </div>
    <?php else: ?>
        <div class="role-dashboard-grid student-grid">
            <section class="dashboard-panel role-profile-card">
                <div class="role-card-head"><div class="role-avatar student"><i class="bi bi-mortarboard-fill"></i></div><div><span class="panel-kicker">MI INFORMACIÓN ACADÉMICA</span><h2><?= e($_SESSION['nombre']) ?></h2><p>Tu información principal siempre a mano.</p></div></div>
                <div class="student-data-grid"><div><span>Carrera</span><strong><?= e($misDatos['nombre_carrera']??'Sin carrera asignada') ?></strong></div><div><span>Semestre</span><strong><?= e($misDatos['semestre']??'No registrado') ?></strong></div><div><span>Registro universitario</span><strong><?= e($misDatos['registro_universitario']??'No registrado') ?></strong></div></div>
                <div class="actions"><a class="btn btn-primary" href="/controllers/tutorias.php"><i class="bi bi-calendar-heart"></i> Mis tutorías</a><a class="btn btn-light" href="/controllers/calificaciones.php"><i class="bi bi-stars"></i> Mis notas</a></div>
            </section>
            <section class="dashboard-panel role-side-card student-side"><span class="panel-kicker">MI PORTAL</span><div class="big-icon"><i class="bi bi-compass-fill"></i></div><h2>Explora, consulta y mantén tu avance organizado.</h2><p>Encuentra tus notas, asistencia y horarios de tutoría desde el menú lateral.</p><div class="student-shortcuts"><a href="/controllers/calificaciones.php"><i class="bi bi-stars"></i> Notas</a><a href="/controllers/asistencia.php"><i class="bi bi-calendar2-check"></i> Asistencia</a></div></section>
        </div>
    <?php endif; ?>
</div>
<?php include __DIR__.'/../layouts/footer.php'; ?>
