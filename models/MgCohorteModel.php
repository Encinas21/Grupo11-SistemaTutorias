<?php
declare(strict_types=1);

class MgCohorteModel
{
    public function __construct(private PDO $pdo) {}

    public function listar(): array
    {
        return $this->pdo->query(
            'SELECT c.*, 0 AS expedientes
             FROM cohortes_mg c
             ORDER BY c.fecha_inicio DESC, c.id_cohorte DESC'
        )->fetchAll();
    }

    public function listarActivas(): array
    {
        return $this->pdo->query('SELECT * FROM cohortes_mg WHERE activa = 1 ORDER BY fecha_inicio DESC')->fetchAll();
    }

    public function obtener(int $id): ?array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM cohortes_mg WHERE id_cohorte = ?');
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }

    public function guardar(array $datos, ?int $id = null): void
    {
        if ($id === null) {
            $stmt = $this->pdo->prepare(
                'INSERT INTO cohortes_mg (codigo, nombre, fecha_inicio, fecha_fin, activa) VALUES (?, ?, ?, ?, ?)'
            );
            $stmt->execute([$datos['codigo'], $datos['nombre'], $datos['fecha_inicio'], $datos['fecha_fin'] ?: null, (int)$datos['activa']]);
        } else {
            $stmt = $this->pdo->prepare(
                'UPDATE cohortes_mg SET codigo = ?, nombre = ?, fecha_inicio = ?, fecha_fin = ?, activa = ? WHERE id_cohorte = ?'
            );
            $stmt->execute([$datos['codigo'], $datos['nombre'], $datos['fecha_inicio'], $datos['fecha_fin'] ?: null, (int)$datos['activa'], $id]);
        }
    }

    public function desactivar(int $id): bool
    {
        $stmt = $this->pdo->prepare('UPDATE cohortes_mg SET activa = 0 WHERE id_cohorte = ?');
        $stmt->execute([$id]);
        return $stmt->rowCount() > 0;
    }
}
