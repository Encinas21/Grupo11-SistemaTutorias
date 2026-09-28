<?php
require_once __DIR__.'/../config/conexion.php';
require_once __DIR__.'/../includes/seguridad.php';
require_once __DIR__.'/../includes/paginacion.php';
require_role(['administrador']);
require_once __DIR__.'/../models/UsuarioModel.php';
require_once __DIR__.'/../models/RolModel.php';

$m = new UsuarioModel($pdo);
$id = (int)($_GET['id'] ?? 0);
$accion = $_GET['accion'] ?? 'listar';
$formError = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validar_csrf();
    $accionPost = $_POST['accion'] ?? '';
    try {
        if ($accionPost === 'eliminar') {
            $m->eliminar((int)($_POST['id'] ?? 0));
            flash('success', 'Usuario eliminado.');
            redir('/controllers/usuarios.php');
        }
        if ($accionPost !== 'guardar') throw new RuntimeException('Acción no reconocida.');
        $id = (int)($_POST['id'] ?? $id);
        $error = validar_requeridos($_POST, [
            'nombre'=>'Nombre','apellido'=>'Apellido','correo'=>'Correo','usuario'=>'Usuario','id_rol'=>'Rol'
        ]);
        if ($error) throw new RuntimeException($error);
        foreach (['nombre'=>'Nombre','apellido'=>'Apellido'] as $campo=>$etiqueta) {
            if (!validar_nombre_persona((string)$_POST[$campo], strtolower($etiqueta))) throw new RuntimeException("{$etiqueta} debe ser un nombre válido, con la primera letra en mayúscula.");
        }
        if (!validar_email_upds((string)$_POST['correo'])) throw new RuntimeException('El correo debe ser válido y terminar en @upds.net.com.');
        $rolSeleccionado = (int)$_POST['id_rol'];
        $prefijo = $rolSeleccionado === 1 ? 'admin' : ($rolSeleccionado === 2 ? 'docente' : 'estudiante');
        if ($rolSeleccionado === 1) { if (trim((string)$_POST['usuario']) !== 'admin') throw new RuntimeException('El usuario administrador debe ser admin.'); }
        $usuarioActual = $id ? $id : 0;
        if (usuario_portal_existe($pdo, trim((string)$_POST['usuario']), $usuarioActual)) {
            if ($rolSeleccionado === 1 && trim((string)$_POST['usuario']) === 'admin') {
                throw new RuntimeException('El usuario admin ya existe. La cuenta administradora ya está creada; edita esa cuenta en lugar de crear otra.');
            }
            $sugerido = siguiente_usuario_portal($pdo, $prefijo);
            throw new RuntimeException('El usuario ' . trim((string)$_POST['usuario']) . ' ya existe. El siguiente usuario disponible es ' . $sugerido . '.');
        }
        if (correo_existe($pdo, trim((string)$_POST['correo']), $usuarioActual)) throw new RuntimeException('Este correo ya está registrado. Debes ingresar otro correo @upds.net.com.');
        elseif (!validar_usuario_portal((string)$_POST['usuario'], $prefijo)) throw new RuntimeException('El usuario debe tener el formato ' . $prefijo . ' seguido de números.');
        if (trim((string)($_POST['telefono'] ?? '')) !== '' && !validar_telefono_bolivia((string)$_POST['telefono'])) throw new RuntimeException('El teléfono debe tener exactamente 8 dígitos numéricos.');
        if ($id === 0) {
            $error = validar_requeridos($_POST, ['clave'=>'Contraseña','confirmar_clave'=>'Confirmar contraseña']);
            if ($error) throw new RuntimeException($error);
            if ($_POST['clave'] !== $_POST['confirmar_clave']) throw new RuntimeException('Las contraseñas no coinciden.');
        } elseif (!empty($_POST['clave']) || !empty($_POST['confirmar_clave'])) {
            if (($_POST['clave'] ?? '') !== ($_POST['confirmar_clave'] ?? '')) throw new RuntimeException('Las contraseñas no coinciden.');
        }
        if ($id) $m->actualizar($id, $_POST); else $m->crear($_POST);
        flash('success', $id ? 'Usuario actualizado.' : 'Usuario creado.');
        redir('/controllers/usuarios.php');
    } catch (Throwable $e) {
        $formError = $e instanceof RuntimeException ? $e->getMessage() : 'No se pudo guardar el usuario. Puede existir un correo o usuario repetido.';
        $accion = $id > 0 ? 'editar' : 'crear';
    }
}

$registro = $id ? $m->obtenerPorId($id) : [];
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $formError) $registro = array_merge($registro ?? [], $_POST);
$busqueda = trim((string)($_GET['buscar'] ?? ''));
$todosLosRegistros = filtrar_registros($m->obtenerTodas(), $busqueda);
$paginacion = paginar_registros($todosLosRegistros, (int)($_GET['pagina'] ?? 1), 10);
$registros = $paginacion['registros'];
$roles = (new RolModel($pdo))->obtenerTodas();
$siguienteDocente = siguiente_usuario_portal($pdo, 'docente');
$siguienteEstudiante = siguiente_usuario_portal($pdo, 'estudiante');
$tituloPagina = 'Usuarios';
require __DIR__.'/../views/usuarios/index.php';
