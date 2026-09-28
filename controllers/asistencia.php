<?php
require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_once __DIR__ . '/../includes/paginacion.php';
require_role(['administrador', 'docente', 'estudiante']);
require_once __DIR__ . '/../models/AsistenciaModel.php';
require_once __DIR__ . '/../models/InscripcionModel.php';
require_once __DIR__ . '/../models/CursoModel.php';

$m = new AsistenciaModel($pdo);
$insModel = new InscripcionModel($pdo);
$cursoModel = new CursoModel($pdo);
$rol = user_role();
$idUsuario = (int) $_SESSION['id_usuario'];
$id = (int) ($_GET['id'] ?? 0);
$accion = $_GET['accion'] ?? 'listar';
$formError = null;

$registros = $rol === 'docente' ? $m->obtenerTodas($idUsuario) : $m->obtenerTodas();

if ($rol === 'estudiante') {
    $q = $pdo->prepare("
        SELECT a.*, CONCAT(u.nombre, ' ', u.apellido) estudiante, c.nombre_curso, c.codigo
        FROM asistencia a
        JOIN inscripciones i ON i.id_inscripcion = a.id_inscripcion
        JOIN estudiantes e ON e.id_estudiante = i.id_estudiante
        JOIN usuarios u ON u.id_usuario = e.id_usuario
        JOIN cursos c ON c.id_curso = i.id_curso
        WHERE e.id_usuario = ?
        ORDER BY a.fecha DESC
    ");
    $q->execute([$idUsuario]);
    $registros = $q->fetchAll();
    $accion = 'listar';
    $id = 0;
}

// Cursos (con sus materias) a cargo del profesor, para la vista de roster.
$cursosProfesor = $rol === 'docente' ? $cursoModel->obtenerPorProfesor($idUsuario) : [];
$cursoRosterId = (int) ($_GET['id_curso'] ?? 0);
$fechaRoster = $_GET['fecha_roster'] ?? date('Y-m-d');
$rosterCurso = [];

if ($rol === 'docente' && $cursoRosterId > 0) {
    // Verifica que el curso elegido sea del profesor antes de mostrar el roster.
    $esSuyo = false;
    foreach ($cursosProfesor as $c) {
        if ((int) $c['id_curso'] === $cursoRosterId) {
            $esSuyo = true;
            break;
        }
    }

    if ($esSuyo) {
        $rosterCurso = $m->obtenerRosterPorCurso($cursoRosterId, $fechaRoster);
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    require_role(['docente']);
    validar_csrf();

    try {
        $accionPost = $_POST['accion'] ?? '';

        if ($accionPost === 'guardar_masivo') {
            $idCursoPost = (int) ($_POST['id_curso'] ?? 0);
            $fechaPost = $_POST['fecha'] ?? '';

            if ($idCursoPost <= 0 || $fechaPost === '') {
                throw new RuntimeException('Selecciona un curso y una fecha válidos.');
            }

            if ($fechaPost > date('Y-m-d')) {
                throw new RuntimeException('No puedes registrar asistencia de una fecha futura.');
            }

            $permit = $pdo->prepare('
                SELECT COUNT(*) FROM cursos c
                JOIN profesores p ON p.id_profesor = c.id_profesor
                WHERE c.id_curso = ? AND p.id_usuario = ?
            ');
            $permit->execute([$idCursoPost, $idUsuario]);

            if ((int) $permit->fetchColumn() === 0) {
                throw new RuntimeException('Ese curso no está a tu cargo.');
            }

            $m->guardarMasivo($fechaPost, $_POST['filas'] ?? []);
            flash('success', 'Asistencia del curso guardada correctamente.');
            redir('/controllers/asistencia.php?accion=tomar&id_curso=' . $idCursoPost . '&fecha_roster=' . $fechaPost);
        }

        if ($accionPost === 'eliminar') {
            $registro = $m->obtenerPorId((int) ($_POST['id'] ?? 0));

            if (!$registro) {
                throw new RuntimeException('El registro de asistencia no existe.');
            }

            // El profesor solo puede eliminar registros de sus propios cursos.
            $permit = $pdo->prepare('
                SELECT COUNT(*) FROM asistencia a
                JOIN inscripciones i ON i.id_inscripcion = a.id_inscripcion
                JOIN cursos c ON c.id_curso = i.id_curso
                JOIN profesores p ON p.id_profesor = c.id_profesor
                WHERE a.id_asistencia = ? AND p.id_usuario = ?
            ');
            $permit->execute([(int) $_POST['id'], $idUsuario]);

            if ((int) $permit->fetchColumn() === 0) {
                throw new RuntimeException('No tienes permiso para eliminar esta asistencia.');
            }

            $m->eliminar((int) $_POST['id']);
            flash('success', 'Registro de asistencia eliminado.');
            redir('/controllers/asistencia.php');
        }

        if ($accionPost !== 'guardar') {
            throw new RuntimeException('Acción no reconocida.');
        }

        $id = (int) ($_POST['id'] ?? $id);
        $error = validar_requeridos($_POST, ['id_inscripcion' => 'Inscripción', 'estado' => 'Estado']);

        if ($error) {
            throw new RuntimeException($error);
        }

        if ((int) ($_POST['id_inscripcion'] ?? 0) <= 0) {
            throw new RuntimeException('Selecciona una inscripción válida.');
        }

        $permit = $pdo->prepare('
            SELECT COUNT(*) FROM inscripciones i
            JOIN cursos c ON c.id_curso = i.id_curso
            JOIN profesores p ON p.id_profesor = c.id_profesor
            WHERE i.id_inscripcion = ? AND p.id_usuario = ?
        ');
        $permit->execute([(int) $_POST['id_inscripcion'], $idUsuario]);

        if ((int) $permit->fetchColumn() === 0) {
            throw new RuntimeException('Solo puedes registrar asistencia de estudiantes inscritos en tus cursos.');
        }

        if (!in_array($_POST['estado'], ['presente', 'ausente', 'justificado', 'tarde'], true)) {
            throw new RuntimeException('El estado de asistencia no es válido.');
        }

        if ($id) {
            $actual = $m->obtenerPorId($id);

            if (!$actual) {
                throw new RuntimeException('El registro de asistencia no existe.');
            }

            $permit = $pdo->prepare('
                SELECT COUNT(*) FROM asistencia a
                JOIN inscripciones i ON i.id_inscripcion = a.id_inscripcion
                JOIN cursos c ON c.id_curso = i.id_curso
                JOIN profesores p ON p.id_profesor = c.id_profesor
                WHERE a.id_asistencia = ? AND p.id_usuario = ?
            ');
            $permit->execute([$id, $idUsuario]);

            if ((int) $permit->fetchColumn() === 0) {
                throw new RuntimeException('No tienes permiso para editar esta asistencia.');
            }

            $_POST['fecha'] = $actual['fecha'];
            $m->editar($id, $_POST);
        } else {
            $_POST['fecha'] = date('Y-m-d');
            $m->crear($_POST);
        }

        flash('success', $id ? 'Asistencia actualizada.' : 'Asistencia registrada.');
        redir('/controllers/asistencia.php');
    } catch (Throwable $e) {
        $formError = $e->getMessage();
        $accion = $id > 0 ? 'editar' : 'crear';
    }
}

$registro = $id ? $m->obtenerPorId($id) : null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $formError) {
    $registro = array_merge($registro ?? [], $_POST);
}

$ins = $rol === 'docente' ? $insModel->obtenerParaProfesor($idUsuario) : $insModel->obtenerTodas();
$busqueda = trim((string)($_GET['buscar'] ?? ''));
$todosLosRegistros = filtrar_registros($registros, $busqueda);
$paginacion = paginar_registros($todosLosRegistros, (int)($_GET['pagina'] ?? 1), 10);
$registros = $paginacion['registros'];
$tituloPagina = 'Asistencia';
require __DIR__ . '/../views/asistencia/index.php';
