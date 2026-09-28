<?php
require_once __DIR__ . '/../config/conexion.php';
require_once __DIR__ . '/../includes/seguridad.php';
require_login();
require_once __DIR__ . '/../models/PerfilModel.php';

$idUsuario = (int)$_SESSION['id_usuario'];
$model = new PerfilModel($pdo);
$formError = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    validar_csrf();
    if (user_role() !== 'administrador') {
        flash('error', 'El perfil es de solo lectura para estudiantes y docentes.');
        redir('/controllers/perfil.php');
    }

    try {
        $datos = [
            'nombre' => trim($_POST['nombre'] ?? ''),
            'apellido' => trim($_POST['apellido'] ?? ''),
            'correo' => trim($_POST['correo'] ?? ''),
            'usuario' => trim($_POST['usuario'] ?? ''),
            'telefono' => trim($_POST['telefono'] ?? ''),
            'clave' => $_POST['clave'] ?? '',
            'confirmar_clave' => $_POST['confirmar_clave'] ?? '',
        ];
        $error = validar_requeridos($datos, ['nombre'=>'Nombre','apellido'=>'Apellido','correo'=>'Correo','usuario'=>'Usuario']);
        if ($error) throw new RuntimeException($error);
        if (!validar_nombre_persona($datos['nombre']) || !validar_nombre_persona($datos['apellido'])) throw new RuntimeException('Nombre y apellido deben ser válidos y comenzar con mayúscula.');
        if (!validar_email_upds($datos['correo'])) throw new RuntimeException('El correo debe ser válido y terminar en @upds.net.com.');
        if ($datos['telefono'] !== '' && !validar_telefono_bolivia($datos['telefono'])) throw new RuntimeException('El teléfono debe tener exactamente 8 dígitos.');
        if ($datos['usuario'] !== 'admin') throw new RuntimeException('El usuario del administrador debe ser admin.');
        if (usuario_portal_existe($pdo, $datos['usuario'], $idUsuario)) throw new RuntimeException('El usuario admin ya existe. Utiliza el administrador existente.');
        if (correo_existe($pdo, $datos['correo'], $idUsuario)) throw new RuntimeException('Este correo ya está registrado. Debes ingresar otro correo @upds.net.com.');
        if ($datos['clave'] !== '' || $datos['confirmar_clave'] !== '') {
            if ($datos['clave'] !== $datos['confirmar_clave']) throw new RuntimeException('Las contraseñas no coinciden.');
        }
        $model->actualizarPerfilAdministrador($idUsuario, $datos);
        $_SESSION['nombre'] = $datos['nombre'];
        flash('success', 'Perfil actualizado correctamente.');
        redir('/controllers/perfil.php');
    } catch (Throwable $e) {
        $formError = $e instanceof RuntimeException ? $e->getMessage() : 'No se pudo actualizar el perfil.';
    }
}

$perfil = $model->obtenerPerfil($idUsuario);
if (!$perfil) { http_response_code(404); exit('No se encontró la información del perfil.'); }
$tituloPagina = 'Mi perfil';
require __DIR__ . '/../views/perfil/index.php';
