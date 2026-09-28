<?php
date_default_timezone_set('America/La_Paz');

$host = getenv('DB_HOST');
$db = getenv('DB_NAME');
$user = getenv('DB_USER');
$pass = getenv('DB_PASS');
$charset = 'utf8mb4';

$faltantes = [];
foreach (['DB_HOST' => $host, 'DB_NAME' => $db, 'DB_USER' => $user, 'DB_PASS' => $pass] as $nombre => $valor) {
    if ($valor === false || $valor === null || trim((string) $valor) === '') {
        $faltantes[] = $nombre;
    }
}

if ($faltantes !== []) {
    http_response_code(500);
    exit('Configuración incompleta: faltan las variables de entorno ' . implode(', ', $faltantes) . '. Revisa el archivo .env.');
}

$dsn = "mysql:host={$host};dbname={$db};charset={$charset}";

$options = [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
];

try {
    $pdo = new PDO($dsn, $user, $pass, $options);
    $pdo->exec("SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci");
    $pdo->exec("SET time_zone = '-04:00'");
} catch (PDOException $e) {
    http_response_code(500);
    exit('No se pudo conectar con MySQL. Verifica las variables DB_* y que los servicios estén levantados.');
}
