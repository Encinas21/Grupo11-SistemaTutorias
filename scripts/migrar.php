<?php
declare(strict_types=1);

/**
 * Runner CLI de migraciones.
 *
 * Uso dentro del contenedor:
 *   php scripts/migrar.php
 *
 * Requiere las variables DB_HOST, DB_NAME, DB_USER y DB_PASS.
 * Los archivos SQL se aplican en orden lexicográfico y cada archivo se registra
 * en migraciones_aplicadas. Las migraciones deben ser idempotentes.
 */

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "Este script solo puede ejecutarse desde CLI.\n");
    exit(1);
}

$variables = ['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASS'];
foreach ($variables as $variable) {
    if (getenv($variable) === false || trim((string) getenv($variable)) === '') {
        fwrite(STDERR, "Falta la variable de entorno {$variable}.\n");
        exit(1);
    }
}

$dsn = sprintf(
    'mysql:host=%s;dbname=%s;charset=utf8mb4',
    getenv('DB_HOST'),
    getenv('DB_NAME')
);

try {
    $pdo = new PDO($dsn, getenv('DB_USER'), getenv('DB_PASS'), [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    $pdo->exec("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");
} catch (Throwable $e) {
    fwrite(STDERR, "No se pudo conectar con MySQL: {$e->getMessage()}\n");
    exit(1);
}

$pdo->exec(
    "CREATE TABLE IF NOT EXISTS migraciones_aplicadas (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        archivo VARCHAR(255) NOT NULL UNIQUE,
        fecha_aplicacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"
);

$directorio = dirname(__DIR__) . '/database/migrations';
$archivos = glob($directorio . '/*.sql') ?: [];
sort($archivos, SORT_STRING);

if ($archivos === []) {
    fwrite(STDOUT, "No hay migraciones pendientes.\n");
    exit(0);
}

$consulta = $pdo->query("SELECT archivo FROM migraciones_aplicadas");
$aplicadas = array_fill_keys($consulta->fetchAll(PDO::FETCH_COLUMN), true);

foreach ($archivos as $archivo) {
    $nombre = basename($archivo);

    if (isset($aplicadas[$nombre])) {
        fwrite(STDOUT, "[OMITIDA] {$nombre} ya fue aplicada.\n");
        continue;
    }

    $sql = trim((string) file_get_contents($archivo));
    if ($sql === '') {
        $pdo->prepare("INSERT INTO migraciones_aplicadas (archivo) VALUES (?)")->execute([$nombre]);
        fwrite(STDOUT, "[OK] {$nombre} estaba vacío y quedó registrado.\n");
        continue;
    }

    fwrite(STDOUT, "[APLICANDO] {$nombre}...\n");

    try {
        /*
         * Las migraciones pueden contener DDL de MySQL (CREATE TABLE, ALTER,
         * etc.). MySQL hace COMMIT implícito alrededor de DDL, por lo que no
         * es seguro envolver todo el archivo en una transacción PDO. Las
         * migraciones MG son idempotentes para permitir reintentar un archivo
         * que haya quedado parcialmente aplicado.
         */
        $pdo->exec($sql);
        $pdo->prepare("INSERT INTO migraciones_aplicadas (archivo) VALUES (?)")->execute([$nombre]);
        fwrite(STDOUT, "[OK] {$nombre}\n");
    } catch (Throwable $e) {
        fwrite(STDERR, "[ERROR] {$nombre}: {$e->getMessage()}\n");
        exit(1);
    }
}

fwrite(STDOUT, "Migraciones finalizadas correctamente.\n");
