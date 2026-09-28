<?php
class MisEstudiantesModel
{
    private PDO $pdo;
    public function __construct(PDO $pdo){$this->pdo=$pdo;}
    public function obtenerCursos(int $idUsuario): array
    {
        $stmt=$this->pdo->prepare("
            SELECT c.id_curso,c.codigo,c.nombre_curso,c.semestre,c.estado,
                   COUNT(DISTINCT i.id_inscripcion) total_estudiantes,
                   ROUND(COALESCE(AVG(cal.nota),0),1) promedio_curso
            FROM cursos c
            JOIN profesores p ON p.id_profesor=c.id_profesor
            LEFT JOIN inscripciones i ON i.id_curso=c.id_curso AND i.estado='activa'
            LEFT JOIN calificaciones cal ON cal.id_inscripcion=i.id_inscripcion
            WHERE p.id_usuario=?
            GROUP BY c.id_curso
            ORDER BY c.codigo
        ");
        $stmt->execute([$idUsuario]); return $stmt->fetchAll();
    }
    public function obtenerEstudiantesPorCurso(int $idCurso,int $idUsuario): array
    {
        $stmt=$this->pdo->prepare("
            SELECT i.id_inscripcion,e.id_estudiante,u.nombre,u.apellido,u.usuario,u.correo,
                   e.semestre,e.registro_universitario,i.fecha_inscripcion,
                   ROUND(COALESCE(AVG(cal.nota),0),1) promedio,
                   COUNT(cal.id_calificacion) cantidad_notas,
                   GROUP_CONCAT(CONCAT(cal.tipo, ': ', FORMAT(cal.nota,1)) ORDER BY cal.fecha,cal.id_calificacion SEPARATOR ' | ') notas
            FROM inscripciones i
            JOIN estudiantes e ON e.id_estudiante=i.id_estudiante
            JOIN usuarios u ON u.id_usuario=e.id_usuario
            JOIN cursos c ON c.id_curso=i.id_curso
            JOIN profesores p ON p.id_profesor=c.id_profesor
            LEFT JOIN calificaciones cal ON cal.id_inscripcion=i.id_inscripcion
            WHERE i.id_curso=? AND p.id_usuario=? AND i.estado='activa'
            GROUP BY i.id_inscripcion,e.id_estudiante,u.id_usuario
            ORDER BY CASE WHEN u.usuario REGEXP '^estudiante[0-9]+$' THEN 0 ELSE 1 END, CAST(SUBSTRING(u.usuario,11) AS UNSIGNED), u.usuario
        ");
        $stmt->execute([$idCurso,$idUsuario]); return $stmt->fetchAll();
    }
}
