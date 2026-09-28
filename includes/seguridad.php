<?php
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_set_cookie_params([
        'httponly' => true,
        'samesite' => 'Lax',
        'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    ]);
    session_start();
}

function e($v): string { return htmlspecialchars((string) $v, ENT_QUOTES, 'UTF-8'); }
function redir(string $url): never { header('Location: ' . $url); exit; }
function flash(string $tipo, string $mensaje): void { $_SESSION['flash'] = ['tipo' => $tipo, 'mensaje' => $mensaje]; }
function mostrarFlash(): ?array { $f = $_SESSION['flash'] ?? null; unset($_SESSION['flash']); return $f; }
function csrf_token(): string { if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32)); return $_SESSION['csrf']; }
function validar_csrf(): void { if (!hash_equals($_SESSION['csrf'] ?? '', $_POST['csrf'] ?? '')) { http_response_code(419); exit('Token CSRF inválido. Recarga la página e inténtalo nuevamente.'); } }
function require_login(): void { if (empty($_SESSION['id_usuario'])) redir('/views/login/login.php'); }
function require_role(array $roles): void { require_login(); if (!in_array($_SESSION['rol'] ?? '', $roles, true)) redir('/views/errores/acceso_denegado.php'); }
function user_role(): string { return $_SESSION['rol'] ?? ''; }
function home_by_role(): string { return '/controllers/dashboard.php'; }

/** Solo letras Unicode y un único espacio entre palabras. */
function validar_solo_letras(string $valor): bool
{
    $valor = trim($valor);
    return $valor !== '' && preg_match('/^\p{L}+(?: \p{L}+)*$/u', $valor) === 1;
}

/** Devuelve el primer campo obligatorio que esté vacío. */
function validar_requeridos(array $datos, array $campos): ?string
{
    foreach ($campos as $campo => $etiqueta) {
        $valor = $datos[$campo] ?? '';
        if (is_string($valor)) {
            $valor = trim($valor);
        }
        if ($valor === '' || $valor === null) {
            return "El campo {$etiqueta} es obligatorio.";
        }
    }
    return null;
}

function validar_email(string $correo): bool
{
    return filter_var(trim($correo), FILTER_VALIDATE_EMAIL) !== false;
}

/** Teléfono celular/convencional para Bolivia: exactamente 8 dígitos. */
function validar_telefono_bolivia(string $telefono): bool
{
    return preg_match('/^\d{8}$/', trim($telefono)) === 1;
}

/** Cédula de Identidad del demo: solo 7 u 8 dígitos. */
function validar_ci(string $ci): bool
{
    return preg_match('/^[0-9]{7,8}$/', trim($ci)) === 1;
}

/** Usuario del portal: prefijo + números. */
function validar_usuario_portal(string $usuario, string $prefijo): bool
{
    return preg_match('/^' . preg_quote($prefijo, '/') . '[0-9]+$/', trim($usuario)) === 1;
}

/** Código académico: sigla + número de tres dígitos. */
function validar_codigo_curso(string $codigo): bool
{
    return preg_match('/^[A-Z]{2,4}-[0-9]{3}$/', trim($codigo)) === 1;
}



/** Nombres y apellidos comunes permitidos para evitar datos evidentemente ficticios. */
function validar_nombre_real(string $valor): bool
{
    $valor = trim($valor);
    if (!preg_match('/^[A-ZÁÉÍÓÚÜÑ][a-záéíóúüñ]+(?: [A-ZÁÉÍÓÚÜÑ][a-záéíóúüñ]+)*$/u', $valor)) return false;
    $nombres = ['Abel','Adela','Admin','Adrián','Alejandro','Andrea','Ariana','Beatriz','Benjamín','Bianca','Braulio','Bruno','Carla','Carlos','Carolina','Cecilia','Claudia','Cristóbal','César','Damián','Daniela','Diana','Diego','Docente','Elena','Elisa','Erick','Emilio','Estefanía','Fabián','Fernanda','Fernando','Fátima','Gabriel','Gabriela','Gloria','Gonzalo','Génesis','Helena','Hugo','Héctor','Irene','Isaac','Isabela','Ivana','Javier','Jimena','Joel','José','Karen','Karla','Kevin','Laura','Leonardo','Lucía','Luis','Marco','Mariana','Martín','Mauricio','Melissa','Mónica','Nadia','Nelson','Nicolás','Noé','Olivia','Pablo','Paola','Patricia','Paula','Pilar','Rafael','Raquel','Raúl','Renata','Ricardo','Rodrigo','Sandra','Sara','Sebastián','Sergio','Sistema','Sofía','Tamara','Thiago','Tobías','Tomás','Ulises','Valentina','Valeria','Verónica','Víctor','Walter','Wendy','William','Xavier','Ximena','Yamila','Yessenia','Yuri','Zaira','Zoe','Zulema','Óscar','Úrsula'];
    $apellidos = ['Aguilar','Arce','Arias','Cabrera','Castro','Choque','Condori','Cortez','Cruz','Cárdenas','Céspedes','Encinas','Fernández','Flores','Fuentes','García','González','Gutiérrez','Gómez','Hernández','Herrera','Jiménez','Luna','López','Mamani','Martínez','Mendoza','Molina','Mora','Morales','Moreno','Méndez','Navarro','Nina','Ortega','Pacheco','Paredes','Paz','Peña','Ponce','Pérez','Quinteros','Quisbert','Quispe','Ramírez','Rivera','Rojas','Romero','Ríos','Salazar','Salinas','Salvatierra','Silva','Soria','Soto','Suárez','Sánchez','Torres','Torrez','Vargas','Vega','Villar','Villarreal','Villarroel','Vásquez','Zambrana','Docente','Sistema'];
    $primera = explode(' ', $valor)[0];
    return in_array($primera, $nombres, true) || in_array($valor, $apellidos, true);
}

function validar_nombre_persona(string $valor, string $tipo = 'nombre'): bool
{
    $valor = trim($valor);
    if (!validar_solo_letras($valor)) return false;
    if (!preg_match('/^[A-ZÁÉÍÓÚÜÑ]/u', $valor)) return false;
    return validar_nombre_real($valor);
}

function validar_email_upds(string $correo): bool
{
    $correo = trim($correo);
    return filter_var($correo, FILTER_VALIDATE_EMAIL) !== false
        && (bool)preg_match('/@upds\.net\.com$/i', $correo);
}

function siguiente_usuario_portal(PDO $pdo, string $prefijo): string
{
    // Calcula el siguiente número revisando todos los usuarios existentes, sin
    // depender de que los números sean consecutivos ni de funciones REGEXP SQL.
    $stmt = $pdo->prepare('SELECT usuario FROM usuarios WHERE usuario LIKE ?');
    $stmt->execute([$prefijo . '%']);
    $max = 0;
    $patron = '/^' . preg_quote($prefijo, '/') . '([0-9]+)$/i';
    foreach ($stmt->fetchAll(PDO::FETCH_COLUMN) as $usuarioExistente) {
        if (preg_match($patron, (string)$usuarioExistente, $coincidencia)) {
            $max = max($max, (int)$coincidencia[1]);
        }
    }
    return $prefijo . ($max + 1);
}

function usuario_portal_existe(PDO $pdo, string $usuario, int $excluirId = 0): bool
{
    $sql = 'SELECT COUNT(*) FROM usuarios WHERE usuario=?' . ($excluirId ? ' AND id_usuario<>?' : '');
    $stmt = $pdo->prepare($sql);
    $excluirId ? $stmt->execute([$usuario, $excluirId]) : $stmt->execute([$usuario]);
    return (int)$stmt->fetchColumn() > 0;
}

function correo_existe(PDO $pdo, string $correo, int $excluirId = 0): bool
{
    $sql = 'SELECT COUNT(*) FROM usuarios WHERE LOWER(correo)=LOWER(?)' . ($excluirId ? ' AND id_usuario<>?' : '');
    $stmt = $pdo->prepare($sql);
    $excluirId ? $stmt->execute([$correo, $excluirId]) : $stmt->execute([$correo]);
    return (int)$stmt->fetchColumn() > 0;
}

function ci_existe(PDO $pdo, string $ci, int $excluirEstudiante = 0): bool
{
    $sql = 'SELECT COUNT(*) FROM estudiantes WHERE registro_universitario=?' . ($excluirEstudiante ? ' AND id_estudiante<>?' : '');
    $stmt = $pdo->prepare($sql);
    $excluirEstudiante ? $stmt->execute([$ci, $excluirEstudiante]) : $stmt->execute([$ci]);
    return (int)$stmt->fetchColumn() > 0;
}

function nombre_rol_visible(string $rol): string
{
    return match ($rol) {
        'docente' => 'Docente',
        'coordinador_mg' => 'Coordinador MG',
        'auxiliar_mg' => 'Auxiliar MG',
        'administrador' => 'Administrador',
        'estudiante' => 'Estudiante',
        default => ucfirst($rol),
    };
}

/** Rechaza descripciones de prueba como "asdasd": exige una frase útil con varias palabras. */
function validar_descripcion_coherente(string $valor, int $minCaracteres = 20): bool
{
    $valor = trim(preg_replace('/\s+/u', ' ', $valor) ?? $valor);
    if ($valor === '') return true; // campo opcional
    preg_match_all('/./us', $valor, $caracteres);
    if (count($caracteres[0] ?? []) < $minCaracteres) return false;
    $palabras = preg_split('/\s+/u', $valor, -1, PREG_SPLIT_NO_EMPTY) ?: [];
    if (count($palabras) < 4) return false;
    if (preg_match('/^(.)\1{3,}$/iu', str_replace(' ', '', $valor))) return false;
    $letras = preg_replace('/[^\p{L}]/u', '', $valor) ?? '';
    preg_match_all('/\p{L}/u', $letras, $soloLetras);
    if (count($soloLetras[0] ?? []) < 12) return false;
    return true;
}

function carrera_catalogo_valida(string $nombre): bool
{
    $catalogo = [
        'Ingeniería de Sistemas', 'Administración de Empresas', 'Contaduría Pública',
        'Derecho', 'Ingeniería Comercial', 'Arquitectura', 'Ingeniería Civil',
        'Psicología', 'Marketing y Comunicación', 'Ingeniería Industrial'
    ];
    return in_array(trim($nombre), $catalogo, true);
}

function especialidad_docente_valida(string $especialidad): bool
{
    $catalogo = [
        'Desarrollo Web y Bases de Datos','Matemática Aplicada','Desarrollo de Software',
        'Bases de Datos','Redes y Sistemas','Ingeniería de Software','Tecnología Web',
        'Contabilidad','Derecho Empresarial','Marketing','Arquitectura','Ingeniería Civil',
        'Psicología','Ingeniería Industrial','Administración de Empresas','Programación',
        'Diseño Arquitectónico','Resistencia de Materiales','Contabilidad Financiera',
        'Derecho','Marketing Digital','Procesos Industriales'
    ];
    return in_array(trim($especialidad), $catalogo, true);
}
