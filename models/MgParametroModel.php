<?php
declare(strict_types=1);

class MgParametroModel
{
    public function __construct(private PDO $pdo) {}

    public function listar(): array
    {
        return $this->pdo->query(
            'SELECT clave, valor, descripcion, fuente, estado_evidencia, actualizado_por, fecha_actualizacion
             FROM parametros_mg ORDER BY clave'
        )->fetchAll();
    }

    public function obtener(string $clave, ?string $defecto = null): ?string
    {
        $stmt = $this->pdo->prepare('SELECT valor FROM parametros_mg WHERE clave = ? LIMIT 1');
        $stmt->execute([$clave]);
        $valor = $stmt->fetchColumn();
        return ($valor === false || $valor === null || $valor === '') ? $defecto : (string) $valor;
    }

    public function actualizar(string $clave, ?string $valor, int $usuario): bool
    {
        $stmt = $this->pdo->prepare(
            'UPDATE parametros_mg SET valor = ?, actualizado_por = ?, fecha_actualizacion = CURRENT_TIMESTAMP WHERE clave = ?'
        );
        $stmt->execute([$valor, $usuario, $clave]);
        return true;
    }
}
