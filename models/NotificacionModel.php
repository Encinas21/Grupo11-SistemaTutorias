<?php
class NotificacionModel
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    /**
     * Crea una notificación para un usuario. Se usa desde otros
     * controladores/modelos cuando ocurre un evento relevante
     * (tutoría creada, aceptada, rechazada, confirmada, etc.).
     */
    public function crear(int $idUsuario, string $mensaje, string $tipo = 'general', ?string $url = null): void
    {
        if ($idUsuario <= 0) {
            return;
        }

        $stmt = $this->pdo->prepare("
            INSERT INTO notificaciones (id_usuario, tipo, mensaje, url)
            VALUES (?, ?, ?, ?)
        ");
        $stmt->execute([$idUsuario, $tipo, $mensaje, $url]);
    }

    public function obtenerRecientes(int $idUsuario, int $limite = 8): array
    {
        $limite = max(1, min(30, $limite));

        $stmt = $this->pdo->prepare("
            SELECT *
            FROM notificaciones
            WHERE id_usuario = ?
            ORDER BY fecha_creacion DESC
            LIMIT {$limite}
        ");
        $stmt->execute([$idUsuario]);

        return $stmt->fetchAll();
    }

    public function contarNoLeidas(int $idUsuario): int
    {
        $stmt = $this->pdo->prepare('
            SELECT COUNT(*) FROM notificaciones WHERE id_usuario = ? AND leida = 0
        ');
        $stmt->execute([$idUsuario]);

        return (int) $stmt->fetchColumn();
    }

    public function marcarLeida(int $idNotificacion, int $idUsuario): bool
    {
        $stmt = $this->pdo->prepare('
            UPDATE notificaciones SET leida = 1
            WHERE id_notificacion = ? AND id_usuario = ?
        ');

        return $stmt->execute([$idNotificacion, $idUsuario]);
    }

    public function marcarTodasLeidas(int $idUsuario): bool
    {
        $stmt = $this->pdo->prepare('
            UPDATE notificaciones SET leida = 1 WHERE id_usuario = ?
        ');

        return $stmt->execute([$idUsuario]);
    }
}
