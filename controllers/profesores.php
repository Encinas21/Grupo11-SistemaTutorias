<?php
require_once __DIR__.'/../config/conexion.php';
require_once __DIR__.'/../includes/seguridad.php';
require_once __DIR__.'/../includes/paginacion.php';
require_role(['administrador']);
require_once __DIR__.'/../models/ProfesorModel.php';

$m = new ProfesorModel($pdo);
$id = (int)($_GET['id'] ?? 0);
$accion = $_GET['accion'] ?? 'listar';
$formError = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validar_csrf();
    $accionPost = $_POST['accion'] ?? '';
    try {
        if ($accionPost === 'eliminar') {
            $m->eliminar((int)($_POST['id'] ?? 0));
            flash('success', 'Registro eliminado correctamente.');
            redir('/controllers/profesores.php');
        }
        if ($accionPost !== 'guardar') throw new RuntimeException('Acción no reconocida.');
        $id = (int)($_POST['id'] ?? $id);
        $error = validar_requeridos($_POST, [
            'nombre'=>'Nombre','apellido'=>'Apellido','correo'=>'Correo','usuario'=>'Usuario'
        ]);
        if ($error) throw new RuntimeException($error);
        foreach (['nombre'=>'Nombre','apellido'=>'Apellido'] as $campo=>$etiqueta) {
            if (!validar_nombre_persona((string)$_POST[$campo], strtolower($etiqueta))) throw new RuntimeException("{$etiqueta} debe ser un nombre válido, con la primera letra en mayúscula.");
        }
        if (!especialidad_docente_valida((string)($_POST['especialidad'] ?? ''))) throw new RuntimeException('Selecciona una especialidad académica válida del catálogo.');
        if (!validar_descripcion_coherente((string)($_POST['biografia'] ?? ''), 24)) throw new RuntimeException('La biografía debe describir la experiencia o el área académica con una frase de al menos 4 palabras.');
        if (!validar_email_upds((string)$_POST['correo'])) throw new RuntimeException('El correo debe ser válido y terminar en @upds.net.com.');
        if (!validar_usuario_portal((string)$_POST['usuario'], 'docente')) throw new RuntimeException('El usuario debe tener el formato docente seguido de números.');
        $usuarioActual = $id ? (int)($m->obtenerPorId($id)['id_usuario'] ?? 0) : 0;
        if (usuario_portal_existe($pdo, trim((string)$_POST['usuario']), $usuarioActual)) throw new RuntimeException('El usuario ' . trim((string)$_POST['usuario']) . ' ya existe. Utiliza ' . siguiente_usuario_portal($pdo, 'docente') . '.');
        if (correo_existe($pdo, trim((string)$_POST['correo']), $usuarioActual)) throw new RuntimeException('Este correo ya está registrado. Debes ingresar otro correo @upds.net.com.');
        if (trim((string)($_POST['telefono'] ?? '')) !== '' && !validar_telefono_bolivia((string)$_POST['telefono'])) throw new RuntimeException('El teléfono debe tener exactamente 8 dígitos numéricos.');
        if ($id === 0) {
            $error = validar_requeridos($_POST, ['clave'=>'Contraseña','confirmar_clave'=>'Confirmar contraseña']);
            if ($error) throw new RuntimeException($error);
            if ($_POST['clave'] !== $_POST['confirmar_clave']) throw new RuntimeException('Las contraseñas no coinciden.');
        }
        if ($id) $m->editar($id, $_POST); else $m->crear($_POST);
        flash('success', $id ? 'Registro actualizado correctamente.' : 'Registro creado correctamente.');
        redir('/controllers/profesores.php');
    } catch (Throwable $e) {
        $formError = $e instanceof RuntimeException ? $e->getMessage() : 'No se pudo completar la operación. Verifica los datos ingresados.';
        $accion = $id > 0 ? 'editar' : 'crear';
    }
}

$registro = $id ? $m->obtenerPorId($id) : [];
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $formError) $registro = array_merge($registro ?? [], $_POST);
$busqueda = trim((string)($_GET['buscar'] ?? ''));
$todosLosRegistros = filtrar_registros($m->obtenerTodas(), $busqueda);
$paginacion = paginar_registros($todosLosRegistros, (int)($_GET['pagina'] ?? 1), 10);
$registros = $paginacion['registros'];
$siguienteDocente = siguiente_usuario_portal($pdo, 'docente');
$tituloPagina = 'Docentes';
require __DIR__.'/../views/profesores/index.php';
