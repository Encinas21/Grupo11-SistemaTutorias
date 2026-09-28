<?php
declare(strict_types=1);

class MgBitacoraModel
{
    public function __construct(private PDO $pdo) {}

    public function registrar(string $accion, string $tabla, ?int $idRegistro, ?array $antes, ?array $despues): void
    {
        $stmt = $this->pdo->prepare(
            'INSERT INTO bitacora_mg (usuario, accion, tabla, id_registro, datos_antes, datos_despues, ip)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $_SESSION['id_usuario'] ?? null,
            $accion,
            $tabla,
            $idRegistro,
            $antes === null ? null : json_encode($antes, JSON_UNESCAPED_UNICODE),
            $despues === null ? null : json_encode($despues, JSON_UNESCAPED_UNICODE),
            $_SERVER['REMOTE_ADDR'] ?? null,
        ]);
    }
}
