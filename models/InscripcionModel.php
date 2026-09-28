<?php
class InscripcionModel {
    private PDO $pdo;
    function __construct(PDO $pdo){$this->pdo=$pdo;}
    function obtenerTodas(){return $this->pdo->query("SELECT i.*,CONCAT(u.nombre,' ',u.apellido) estudiante,c.nombre_curso,c.codigo FROM inscripciones i JOIN estudiantes e ON e.id_estudiante=i.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN cursos c ON c.id_curso=i.id_curso ORDER BY i.fecha_inscripcion DESC")->fetchAll();}
    function obtenerParaProfesor(int $idUsuario){
        $s=$this->pdo->prepare("SELECT i.*,CONCAT(u.nombre,' ',u.apellido) estudiante,c.nombre_curso,c.codigo FROM inscripciones i JOIN estudiantes e ON e.id_estudiante=i.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN cursos c ON c.id_curso=i.id_curso JOIN profesores p ON p.id_profesor=c.id_profesor WHERE p.id_usuario=? ORDER BY i.fecha_inscripcion DESC");
        $s->execute([$idUsuario]); return $s->fetchAll();
    }
    function obtenerPorId($id){$s=$this->pdo->prepare('SELECT * FROM inscripciones WHERE id_inscripcion=?');$s->execute([$id]);return $s->fetch();}
    function crear($d){$s=$this->pdo->prepare('INSERT INTO inscripciones(id_estudiante,id_curso,fecha_inscripcion,estado) VALUES(?,?,?,?)');return $s->execute([$d['id_estudiante'],$d['id_curso'],$d['fecha_inscripcion'],$d['estado'] ?? 'activa']);}
    function editar($id,$d){$s=$this->pdo->prepare('UPDATE inscripciones SET id_estudiante=?,id_curso=?,fecha_inscripcion=?,estado=? WHERE id_inscripcion=?');return $s->execute([$d['id_estudiante'],$d['id_curso'],$d['fecha_inscripcion'],$d['estado'] ?? 'activa',$id]);}
    function eliminar($id){$s=$this->pdo->prepare('DELETE FROM inscripciones WHERE id_inscripcion=?');return $s->execute([$id]);}
}
