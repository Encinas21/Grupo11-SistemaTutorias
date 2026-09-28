<?php
require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_role(['administrador', 'docente', 'estudiante']);
require_once __DIR__ . '/../models/TutoriaModel.php';
require_once __DIR__ . '/../models/NotificacionModel.php';

$model = new TutoriaModel($pdo);
$notificaciones = new NotificacionModel($pdo);
$rol = user_role();
$idUsuario = (int)$_SESSION['id_usuario'];
$id = (int)($_GET['id'] ?? $_POST['id'] ?? 0);
$accion = $_GET['accion'] ?? 'listar';
$formData = [];
$formError = null;

$estudianteActual = $rol === 'estudiante' ? $model->obtenerEstudiantePorUsuario($idUsuario) : null;
$tutorActual = $rol === 'docente' ? $model->obtenerTutorPorUsuario($idUsuario) : null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validar_csrf();
    $accionPost = $_POST['accion'] ?? '';

    try {
        if ($accionPost === 'generar_mes') {
            if ($rol !== 'docente' || !$tutorActual) throw new TutoriaValidationException('Solo un docente puede generar su agenda mensual.');
            $materiaId = (int)($_POST['id_materia'] ?? 0);
            $mes = trim($_POST['mes'] ?? '');
            $cantidad = $model->generarMes((int)$tutorActual['id_tutor'], $materiaId, $mes);
            flash('success', $cantidad > 0 ? "Se publicaron {$cantidad} espacios para el mes seleccionado." : 'No se agregaron espacios porque ya existen horarios publicados para ese mes.');
            redir('/controllers/tutorias.php');
        }

        if ($accionPost === 'crear_disponibilidad') {
            if ($rol !== 'docente' || !$tutorActual) throw new TutoriaValidationException('Solo un docente puede publicar horarios de tutoría.');
            $formData = $_POST;
            $materiaId = (int)($_POST['id_materia'] ?? 0);
            $materiasTutor = $model->obtenerMateriasPorTutor((int)$tutorActual['id_tutor']);
            $materia = null;
            foreach ($materiasTutor as $m) if ((int)$m['id_materia'] === $materiaId) { $materia = $m; break; }
            if (!$materia) throw new TutoriaValidationException('Selecciona una materia que tengas asignada.');
            $nuevoId = $model->crear([
                'id_tutor' => (int)$tutorActual['id_tutor'],
                'id_materia' => $materiaId,
                'fecha' => trim($_POST['fecha'] ?? ''),
                'turno_horario' => $_POST['turno_horario'] ?? '',
                'aula' => $materia['aula'],
            ]);
            flash('success', 'Horario de tutoría publicado. El estudiante podrá solicitar unirse.');
            redir('/controllers/tutorias.php?accion=detalle&id=' . $nuevoId);
        }

        if ($accionPost === 'editar_disponibilidad') {
            if ($rol !== 'docente' || !$tutorActual) throw new TutoriaValidationException('No tienes permiso para editar este horario.');
            $idPost = (int)($_POST['id'] ?? 0);
            $registro = $model->obtenerDetalle($idPost);
            if (!$registro || (int)$registro['profesor_usuario'] !== $idUsuario) throw new TutoriaValidationException('Solo puedes editar tus propios horarios.');
            $materiasTutor = $model->obtenerMateriasPorTutor((int)$tutorActual['id_tutor']);
            $materia = null;
            foreach ($materiasTutor as $m) if ((int)$m['id_materia'] === (int)($_POST['id_materia'] ?? 0)) { $materia = $m; break; }
            if (!$materia) throw new TutoriaValidationException('Selecciona una materia válida.');
            $model->editarDisponibilidad($idPost, [
                'id_materia' => (int)$_POST['id_materia'],
                'fecha' => trim($_POST['fecha'] ?? ''),
                'turno_horario' => $_POST['turno_horario'] ?? '',
                'aula' => $materia['aula'],
            ]);
            flash('success', 'Horario actualizado correctamente.');
            redir('/controllers/tutorias.php');
        }

        if ($accionPost === 'solicitar_unirse') {
            if ($rol !== 'estudiante' || !$estudianteActual) throw new TutoriaValidationException('Solo los estudiantes pueden solicitar unirse a una tutoría.');
            $idPost = (int)($_POST['id'] ?? 0);
            $detalle = $model->obtenerDetalle($idPost);
            if (!$detalle || $detalle['estado'] !== 'disponible') throw new TutoriaValidationException('Esta tutoría ya no está disponible.');
            $registro = $model->solicitarUnirse($idPost, (int)$estudianteActual['id_estudiante']);
            $mensaje = sprintf('%s %s solicitó unirse a la tutoría de %s del %s (%s).',
                $estudianteActual['nombre'], $estudianteActual['apellido'], $registro['nombre_materia'], $registro['fecha'], TutoriaModel::horariosFijos()[$registro['turno_horario']]['label'] ?? $registro['turno_horario']);
            $admins = $pdo->query("SELECT id_usuario FROM usuarios WHERE id_rol=(SELECT id_rol FROM roles WHERE nombre_rol='administrador' LIMIT 1) AND estado='activo'")->fetchAll();
            foreach ($admins as $admin) $notificaciones->crear((int)$admin['id_usuario'], $mensaje, 'tutoria_solicitud', '/controllers/tutorias.php?accion=detalle&id=' . $idPost);
            $notificaciones->crear((int)$registro['profesor_usuario'], $mensaje, 'tutoria_solicitud', '/controllers/tutorias.php?accion=detalle&id=' . $idPost);
            flash('success', 'Tu solicitud fue enviada. El administrador debe aprobarla.');
            redir('/controllers/tutorias.php?accion=detalle&id=' . $idPost);
        }

        if ($accionPost === 'cancelar_solicitud') {
            if ($rol !== 'estudiante') throw new TutoriaValidationException('No tienes permiso para cancelar esta solicitud.');
            $idPost = (int)($_POST['id'] ?? 0);
            if (!$model->cancelarSolicitud($idPost, $idUsuario)) throw new TutoriaValidationException('No se pudo cancelar la solicitud.');
            flash('success', 'Solicitud cancelada. El horario volvió a quedar disponible.');
            redir('/controllers/tutorias.php');
        }

        if ($accionPost === 'eliminar_disponibilidad') {
            if ($rol !== 'docente') throw new TutoriaValidationException('No tienes permiso para eliminar este horario.');
            $registro = $model->obtenerDetalle((int)($_POST['id'] ?? 0));
            if (!$registro || (int)$registro['profesor_usuario'] !== $idUsuario || $registro['estado'] !== 'disponible') throw new TutoriaValidationException('Solo puedes eliminar horarios disponibles propios.');
            if (!$model->eliminarSiPertenece((int)$_POST['id'], $rol, $idUsuario)) throw new TutoriaValidationException('No se pudo eliminar el horario.');
            flash('success', 'Horario eliminado.');
            redir('/controllers/tutorias.php');
        }

        if ($accionPost === 'cambiar_estado') {
            $idCambio = (int)($_POST['id'] ?? 0);
            $nuevoEstado = $_POST['nuevo_estado'] ?? '';
            $anterior = $model->cambiarEstado($idCambio, $nuevoEstado, $rol, $idUsuario);
            $horario = TutoriaModel::horariosFijos()[$anterior['turno_horario']]['label'] ?? $anterior['turno_horario'];

            if ($rol === 'administrador') {
                $texto = $nuevoEstado === 'confirmada' ? 'aceptada' : 'rechazada';
                if (!empty($anterior['estudiante_usuario'])) {
                    $notificaciones->crear((int)$anterior['estudiante_usuario'], "Tu solicitud de tutoría de {$anterior['nombre_materia']} del {$anterior['fecha']} ({$horario}) fue {$texto} por el administrador.", 'tutoria', '/controllers/tutorias.php?accion=detalle&id=' . $idCambio);
                }
                $notificaciones->crear((int)$anterior['profesor_usuario'], "El administrador {$texto} la solicitud de {$anterior['nombre_materia']} del {$anterior['fecha']} ({$horario}).", 'tutoria', '/controllers/tutorias.php?accion=detalle&id=' . $idCambio);
                flash('success', $nuevoEstado === 'confirmada' ? 'Solicitud aceptada. La tutoría quedó confirmada.' : 'Solicitud rechazada.');
            } else {
                if ($nuevoEstado === 'realizada') {
                    $model->asegurarNotaTutoria($idCambio);
                    if (!empty($anterior['estudiante_usuario'])) $notificaciones->crear((int)$anterior['estudiante_usuario'], "La tutoría de {$anterior['nombre_materia']} fue marcada como realizada.", 'tutoria', '/controllers/tutorias.php?accion=detalle&id=' . $idCambio);
                    flash('success', 'Tutoría marcada como realizada.');
                } else {
                    flash('success', 'Tutoría cancelada.');
                }
            }
            redir('/controllers/tutorias.php');
        }

        throw new TutoriaValidationException('Acción no reconocida.');
    } catch (TutoriaValidationException $e) {
        $formError = $e->getMessage();
        $accion = $accionPost === 'crear_disponibilidad' ? 'crear' : ($accionPost === 'editar_disponibilidad' ? 'editar' : 'detalle');
        if (in_array($accionPost, ['solicitar_unirse','cancelar_solicitud','eliminar_disponibilidad','cambiar_estado'], true)) {
            flash('error', $formError);
            redir('/controllers/tutorias.php');
        }
    } catch (Throwable $e) {
        $formError = 'No se pudo completar la operación. Revisa los datos e inténtalo nuevamente.';
        if (in_array($accionPost, ['solicitar_unirse','cancelar_solicitud','eliminar_disponibilidad','cambiar_estado'], true)) {
            flash('error', $formError);
            redir('/controllers/tutorias.php');
        }
    }
}

$perPagina = 12;
$pagina = max(1, (int)($_GET['pagina'] ?? 1));
$filtros = [
    'q' => trim($_GET['q'] ?? ''),
    'estado' => $_GET['estado'] ?? '',
    'id_tutor' => (int)($_GET['id_tutor'] ?? 0),
    'id_materia' => (int)($_GET['id_materia'] ?? 0),
    'turno_horario' => $_GET['turno_horario'] ?? '',
    'fecha_desde' => $_GET['fecha_desde'] ?? '',
    'fecha_hasta' => $_GET['fecha_hasta'] ?? '',
];
$permitidosEstado=['disponible','pendiente','confirmada','rechazada','realizada','cancelada'];
if(!in_array($filtros['estado'],$permitidosEstado,true)) $filtros['estado']='';
if(!isset(TutoriaModel::horariosFijos()[$filtros['turno_horario']])) $filtros['turno_horario']='';

$resultado=$model->obtenerListado($filtros,$pagina,$perPagina,$rol,$idUsuario);
$registro=null;
if(in_array($accion,['detalle','editar'],true)) {
    if($id<=0) { flash('error','No se indicó una tutoría válida.'); redir('/controllers/tutorias.php'); }
    $registro=$model->obtenerDetalle($id);
    if(!$registro || !$model->puedeVer($id,$rol,$idUsuario)) { flash('error','No tienes permiso para consultar esta tutoría.'); redir('/controllers/tutorias.php'); }
    if($accion==='editar' && (!$model->puedeEditar($id,$rol,$idUsuario) || $registro['estado']!=='disponible')) { flash('error','Solo puedes editar horarios que todavía están disponibles.'); redir('/controllers/tutorias.php'); }
    if($formError && !$formData) $formData=$registro;
}

if($accion==='crear' && $rol!=='docente') { flash('error','Solo los docentes pueden publicar horarios.'); redir('/controllers/tutorias.php'); }
if(!$formData) $formData=[
    'id_materia'=>(int)($_GET['id_materia']??0),
    'fecha'=>$_GET['fecha']??date('Y-m-d'),
    'turno_horario'=>$_GET['turno_horario']??'manana'
];

$tutores=$model->obtenerTutores();
$materias=$model->obtenerMaterias();
$materiasTutor=$tutorActual ? $model->obtenerMateriasPorTutor((int)$tutorActual['id_tutor']) : [];
$horarios=TutoriaModel::horariosFijos();
$estados=[
    'disponible'=>'Disponible','pendiente'=>'Pendiente de aprobación','confirmada'=>'Confirmada','rechazada'=>'Rechazada','realizada'=>'Realizada','cancelada'=>'Cancelada'
];
$tituloPagina='Tutorías académicas';
require __DIR__ . '/../views/tutorias/index.php';
