<?php
declare(strict_types=1);

class MgModalidadModel
{
    public function __construct(private PDO $pdo) {}

    public function listar(bool $soloActivas = false): array
    {
        $sql = 'SELECT * FROM modalidades_grado';
        if ($soloActivas) $sql .= ' WHERE activa = 1';
        return $this->pdo->query($sql . ' ORDER BY nombre')->fetchAll();
    }

    public function cambiarEstado(int $id, int $activo): bool
    {
        $stmt = $this->pdo->prepare('UPDATE modalidades_grado SET activa = ? WHERE id_modalidad = ?');
        $stmt->execute([$activo, $id]);
        return $stmt->rowCount() > 0;
    }

    public function obtener(int $id): ?array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM modalidades_grado WHERE id_modalidad = ?');
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }
}
