<?php
declare(strict_types=1);

class MgCalendarioModel
{
    public function __construct(private PDO $pdo) {}

    public function listar(?int $idCohorte = null): array
    {
        $sql = 'SELECT k.*, c.nombre AS cohorte_nombre FROM calendario_mg k JOIN cohortes_mg c ON c.id_cohorte = k.id_cohorte';
        $params = [];
        if ($idCohorte !== null) { $sql .= ' WHERE k.id_cohorte = ?'; $params[] = $idCohorte; }
        $sql .= ' ORDER BY c.fecha_inicio DESC, k.etapa, k.orden, k.fecha_limite, k.id_hito';
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public function obtener(int $id): ?array
    {
        $stmt = $this->pdo->prepare('SELECT * FROM calendario_mg WHERE id_hito = ?');
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }

    public function guardar(array $d, ?int $id = null): void
    {
        if ($id === null) {
            $stmt = $this->pdo->prepare(
                'INSERT INTO calendario_mg (id_cohorte, etapa, tipo, nombre, orden, fecha_limite, avance_esperado_pct) VALUES (?, ?, ?, ?, ?, ?, ?)'
            );
            $stmt->execute([$d['id_cohorte'], $d['etapa'], $d['tipo'], $d['nombre'], (int)$d['orden'], $d['fecha_limite'] ?: null, $d['avance_esperado_pct'] === '' ? null : $d['avance_esperado_pct']]);
        } else {
            $stmt = $this->pdo->prepare(
                'UPDATE calendario_mg SET id_cohorte = ?, etapa = ?, tipo = ?, nombre = ?, orden = ?, fecha_limite = ?, avance_esperado_pct = ? WHERE id_hito = ?'
            );
            $stmt->execute([$d['id_cohorte'], $d['etapa'], $d['tipo'], $d['nombre'], (int)$d['orden'], $d['fecha_limite'] ?: null, $d['avance_esperado_pct'] === '' ? null : $d['avance_esperado_pct'], $id]);
        }
    }

    public function eliminar(int $id): bool
    {
        $stmt = $this->pdo->prepare('DELETE FROM calendario_mg WHERE id_hito = ?');
        $stmt->execute([$id]);
        return $stmt->rowCount() > 0;
    }
}
