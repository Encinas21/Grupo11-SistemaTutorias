<?php

class PerfilModel
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    /**
     * Obtiene toda la información del perfil del usuario.
     *
     * Incluye información general de usuarios
     * y datos específicos de estudiantes o profesores.
     */
    public function obtenerPerfil(int $idUsuario): ?array
    {
        $sql = "
            SELECT
                u.id_usuario,
                u.id_rol,
                u.nombre,
                u.apellido,
                u.correo,
                u.usuario,
                u.telefono,
                u.estado,
                u.fecha_registro,

                r.nombre_rol,

                e.id_estudiante,
                e.id_carrera,
                e.semestre,
                e.registro_universitario,

                c.nombre_carrera,

                p.id_profesor,
                p.especialidad,
                p.biografia

            FROM usuarios u

            INNER JOIN roles r
                ON r.id_rol = u.id_rol

            LEFT JOIN estudiantes e
                ON e.id_usuario = u.id_usuario

            LEFT JOIN carreras c
                ON c.id_carrera = e.id_carrera

            LEFT JOIN profesores p
                ON p.id_usuario = u.id_usuario

            WHERE u.id_usuario = ?

            LIMIT 1
        ";

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$idUsuario]);

        $perfil = $stmt->fetch();

        return $perfil ?: null;
    }

    /**
     * Obtiene las solicitudes pendientes de un usuario.
     */
    public function obtenerSolicitudesUsuario(int $idUsuario): array
    {
        $stmt = $this->pdo->prepare("
            SELECT
                s.*,
                CONCAT(u.nombre, ' ', u.apellido) AS nombre_usuario
            FROM solicitudes_perfil s
            INNER JOIN usuarios u
                ON u.id_usuario = s.id_usuario
            WHERE s.id_usuario = ?
            ORDER BY s.fecha_solicitud DESC
        ");

        $stmt->execute([$idUsuario]);

        return $stmt->fetchAll();
    }

    /**
     * Comprueba si ya existe una solicitud pendiente
     * para el mismo usuario y campo.
     */
    public function existeSolicitudPendiente(
        int $idUsuario,
        string $campo
    ): bool {
        $stmt = $this->pdo->prepare("
            SELECT COUNT(*)
            FROM solicitudes_perfil
            WHERE id_usuario = ?
              AND campo = ?
              AND estado = 'pendiente'
        ");

        $stmt->execute([
            $idUsuario,
            $campo
        ]);

        return (int) $stmt->fetchColumn() > 0;
    }

    /**
     * Crea una solicitud de cambio.
     */
    public function crearSolicitud(
        int $idUsuario,
        string $campo,
        ?string $valorActual,
        string $valorNuevo
    ): bool {
        $stmt = $this->pdo->prepare("
            INSERT INTO solicitudes_perfil
            (
                id_usuario,
                campo,
                valor_actual,
                valor_nuevo
            )
            VALUES
            (
                :id_usuario,
                :campo,
                :valor_actual,
                :valor_nuevo
            )
        ");

        return $stmt->execute([
            'id_usuario' => $idUsuario,
            'campo' => $campo,
            'valor_actual' => $valorActual,
            'valor_nuevo' => $valorNuevo
        ]);
    }

    /**
     * Obtiene todas las solicitudes pendientes.
     * Solamente debe ser utilizado por el administrador.
     */
    public function obtenerSolicitudesPendientes(): array
    {
        $stmt = $this->pdo->query("
            SELECT
                s.*,

                u.nombre,
                u.apellido,
                u.usuario,
                u.correo,

                r.nombre_rol,

                CONCAT(
                    u.nombre,
                    ' ',
                    u.apellido
                ) AS nombre_completo

            FROM solicitudes_perfil s

            INNER JOIN usuarios u
                ON u.id_usuario = s.id_usuario

            INNER JOIN roles r
                ON r.id_rol = u.id_rol

            WHERE s.estado = 'pendiente'

            ORDER BY s.fecha_solicitud ASC
        ");

        return $stmt->fetchAll();
    }

    /**
     * Obtiene una solicitud por su ID.
     */
    public function obtenerSolicitudPorId(int $idSolicitud): ?array
    {
        $stmt = $this->pdo->prepare("
            SELECT
                s.*,
                u.nombre,
                u.apellido,
                u.usuario,
                u.correo,
                r.nombre_rol
            FROM solicitudes_perfil s
            INNER JOIN usuarios u
                ON u.id_usuario = s.id_usuario
            INNER JOIN roles r
                ON r.id_rol = u.id_rol
            WHERE s.id_solicitud = ?
            LIMIT 1
        ");

        $stmt->execute([$idSolicitud]);

        $solicitud = $stmt->fetch();

        return $solicitud ?: null;
    }

    /**
     * Actualiza el estado de una solicitud.
     */
    public function responderSolicitud(
        int $idSolicitud,
        string $estado,
        int $idAdministrador,
        ?string $observacion = null
    ): bool {
        $stmt = $this->pdo->prepare("
            UPDATE solicitudes_perfil

            SET
                estado = ?,
                fecha_respuesta = NOW(),
                id_administrador = ?,
                observacion_admin = ?

            WHERE id_solicitud = ?
              AND estado = 'pendiente'
        ");

        return $stmt->execute([
            $estado,
            $idAdministrador,
            $observacion,
            $idSolicitud
        ]);
    }

    /**
     * Actualiza un dato permitido del usuario.
     *
     * El correo NO se actualiza mediante este método.
     */
    public function actualizarDatoUsuario(
        int $idUsuario,
        string $campo,
        string $valor
    ): bool {
        $camposPermitidos = [
            'nombre',
            'apellido',
            'usuario',
            'telefono'
        ];

        if (!in_array($campo, $camposPermitidos, true)) {
            return false;
        }

        $sql = "
            UPDATE usuarios
            SET {$campo} = ?
            WHERE id_usuario = ?
        ";

        $stmt = $this->pdo->prepare($sql);

        return $stmt->execute([
            $valor,
            $idUsuario
        ]);
    }
    public function actualizarPerfilAdministrador(int $idUsuario, array $datos): bool
    {
        $this->pdo->beginTransaction();
        try {
            $sql = "UPDATE usuarios SET nombre=?, apellido=?, correo=?, usuario=?, telefono=?";
            $params = [$datos['nombre'], $datos['apellido'], $datos['correo'], $datos['usuario'], $datos['telefono'] !== '' ? $datos['telefono'] : null];
            if (($datos['clave'] ?? '') !== '') {
                $sql .= ", contrasena_hash=?";
                $params[] = password_hash($datos['clave'], PASSWORD_DEFAULT);
            }
            $sql .= " WHERE id_usuario=?";
            $params[] = $idUsuario;
            $stmt = $this->pdo->prepare($sql);
            $ok = $stmt->execute($params);
            $this->pdo->commit();
            return $ok;
        } catch (Throwable $e) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            throw $e;
        }
    }

}