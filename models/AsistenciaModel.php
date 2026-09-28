<?php
class AsistenciaModel {
    private PDO $pdo;
    function __construct(PDO $pdo){$this->pdo=$pdo;}
    function obtenerTodas(?int $idUsuarioProfesor=null){
        $sql="SELECT a.*,CONCAT(u.nombre,' ',u.apellido) estudiante,c.nombre_curso,c.codigo FROM asistencia a JOIN inscripciones i ON i.id_inscripcion=a.id_inscripcion JOIN estudiantes e ON e.id_estudiante=i.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN cursos c ON c.id_curso=i.id_curso LEFT JOIN profesores p ON p.id_profesor=c.id_profesor";
        if($idUsuarioProfesor!==null){$sql.=' WHERE p.id_usuario=?';$sql.=' ORDER BY a.fecha DESC';$s=$this->pdo->prepare($sql);$s->execute([$idUsuarioProfesor]);return $s->fetchAll();}
        $sql.=' ORDER BY a.fecha DESC';return $this->pdo->query($sql)->fetchAll();
    }
    function obtenerPorId($id){$s=$this->pdo->prepare('SELECT * FROM asistencia WHERE id_asistencia=?');$s->execute([$id]);return $s->fetch();}
    function crear($d){$s=$this->pdo->prepare('INSERT INTO asistencia(id_inscripcion,fecha,estado,observacion) VALUES(?,?,?,?)');return $s->execute([$d['id_inscripcion'],$d['fecha'],$d['estado'],$d['observacion']??'']);}
    function editar($id,$d){$s=$this->pdo->prepare('UPDATE asistencia SET id_inscripcion=?,fecha=?,estado=?,observacion=? WHERE id_asistencia=?');return $s->execute([$d['id_inscripcion'],$d['fecha'],$d['estado'],$d['observacion']??'',$id]);}
    function eliminar($id){$s=$this->pdo->prepare('DELETE FROM asistencia WHERE id_asistencia=?');return $s->execute([$id]);}

    /**
     * Lista TODOS los estudiantes inscritos en un curso para una fecha dada,
     * con su asistencia ya registrada (si existe) o null si todavía no se
     * marcó, para que el docente vea el curso completo y no solo lo que ya
     * registró antes.
     */
    function obtenerRosterPorCurso(int $idCurso, string $fecha): array
    {
        $sql = "
            SELECT
                i.id_inscripcion,
                CONCAT(u.nombre, ' ', u.apellido) AS estudiante,
                a.id_asistencia,
                a.estado,
                a.observacion
            FROM inscripciones i
            JOIN estudiantes e ON e.id_estudiante = i.id_estudiante
            JOIN usuarios u ON u.id_usuario = e.id_usuario
            LEFT JOIN asistencia a ON a.id_inscripcion = i.id_inscripcion AND a.fecha = ?
            WHERE i.id_curso = ? AND i.estado = 'activa'
            ORDER BY u.apellido, u.nombre
        ";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([$fecha, $idCurso]);

        return $stmt->fetchAll();
    }

    /**
     * Guarda la asistencia de varios estudiantes de un mismo curso/fecha de
     * una sola vez (crea la fila si no existía, la actualiza si ya existía).
     */
    function guardarMasivo(string $fecha, array $filas): void
    {
        $stmt = $this->pdo->prepare("
            INSERT INTO asistencia (id_inscripcion, fecha, estado, observacion)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE estado = VALUES(estado), observacion = VALUES(observacion)
        ");

        foreach ($filas as $fila) {
            $idInscripcion = (int) ($fila['id_inscripcion'] ?? 0);
            $estado = $fila['estado'] ?? '';

            if ($idInscripcion <= 0 || $estado === '') {
                // Fila sin marcar: se deja tal cual, no es obligatorio
                // registrar la asistencia de todos en la misma sesión.
                continue;
            }

            if (!in_array($estado, ['presente', 'ausente', 'justificado', 'tarde'], true)) {
                continue;
            }

            $stmt->execute([$idInscripcion, $fecha, $estado, trim($fila['observacion'] ?? '')]);
        }
    }
}
