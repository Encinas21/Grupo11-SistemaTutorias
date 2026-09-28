<?php
declare(strict_types=1);

class MgExpedienteModel
{
    public function __construct(private PDO $pdo) {}

    public function listar(array $filtros, int $pagina = 1, int $porPagina = 20): array
    {
        $where = [];
        $params = [];
        if (!empty($filtros['q'])) { $where[] = '(u.nombre LIKE ? OR u.apellido LIKE ? OR e.registro_universitario LIKE ? OR x.titulo_trabajo LIKE ?)'; $q='%'.$filtros['q'].'%'; array_push($params,$q,$q,$q,$q); }
        foreach (['id_cohorte'=>'x.id_cohorte','id_modalidad'=>'x.id_modalidad'] as $k=>$col) if (!empty($filtros[$k])) { $where[]="$col = ?"; $params[]=(int)$filtros[$k]; }
        if (!empty($filtros['etapa_actual'])) { $where[]='x.etapa_actual = ?'; $params[]=$filtros['etapa_actual']; }
        if (!empty($filtros['estado'])) { $where[]='x.estado = ?'; $params[]=$filtros['estado']; }
        $sqlBase=' FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN modalidades_grado m ON m.id_modalidad=x.id_modalidad JOIN cohortes_mg c ON c.id_cohorte=x.id_cohorte';
        $sqlWhere=$where?' WHERE '.implode(' AND ',$where):'';
        $stmt=$this->pdo->prepare('SELECT COUNT(*)'.$sqlBase.$sqlWhere); $stmt->execute($params); $total=(int)$stmt->fetchColumn();
        $offset=max(0,($pagina-1)*$porPagina);
        $stmt=$this->pdo->prepare('SELECT x.*,e.registro_universitario,u.nombre,u.apellido,u.correo,m.nombre AS modalidad_nombre,c.nombre AS cohorte_nombre,(SELECT CONCAT(ut.nombre," ",ut.apellido) FROM asignaciones_tutor at JOIN tutores t ON t.id_tutor=at.id_tutor JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios ut ON ut.id_usuario=p.id_usuario WHERE at.id_expediente=x.id_expediente AND at.estado="vigente" LIMIT 1) AS tutor_nombre'.$sqlBase.$sqlWhere.' ORDER BY x.fecha_inicio DESC,x.id_expediente DESC LIMIT '.$porPagina.' OFFSET '.$offset);
        $stmt->execute($params);
        return ['filas'=>$stmt->fetchAll(),'total'=>$total,'pagina'=>$pagina,'por_pagina'=>$porPagina,'paginas'=>max(1,(int)ceil($total/$porPagina))];
    }

    public function obtener(int $id): ?array
    {
        $s=$this->pdo->prepare('SELECT x.*,e.registro_universitario,e.id_usuario AS id_usuario_estudiante,u.nombre,u.apellido,u.correo,c.nombre_carrera,m.nombre AS modalidad_nombre,m.requiere_tutor,cg.nombre AS cohorte_nombre FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN carreras c ON c.id_carrera=e.id_carrera JOIN modalidades_grado m ON m.id_modalidad=x.id_modalidad JOIN cohortes_mg cg ON cg.id_cohorte=x.id_cohorte WHERE x.id_expediente=?'); $s->execute([$id]); return $s->fetch()?:null;
    }
    public function etapas(int $id): array { $s=$this->pdo->prepare('SELECT ee.*,u.nombre,u.apellido FROM expediente_etapas ee LEFT JOIN usuarios u ON u.id_usuario=ee.registrado_por WHERE ee.id_expediente=? ORDER BY ee.fecha_inicio,ee.id'); $s->execute([$id]); return $s->fetchAll(); }
    public function crear(array $d): int
    {
        $validar = $this->pdo->prepare("SELECT estado_academico FROM estudiantes WHERE id_estudiante=?");
        $validar->execute([(int)$d['id_estudiante']]);
        $estado = (string)$validar->fetchColumn();
        if (!$estado === 'egresado') {
            throw new RuntimeException('El estudiante debe haber culminado la carrera para iniciar una modalidad de grado.');
        }
        $this->pdo->beginTransaction();
        try {
            $s=$this->pdo->prepare('INSERT INTO expedientes_mg(id_estudiante,id_modalidad,id_cohorte,etapa_actual,estado,titulo_trabajo,fecha_inicio,observaciones) VALUES(?,?,?,"previa","activo",?,?,?)');
            $s->execute([$d['id_estudiante'],$d['id_modalidad'],$d['id_cohorte'],$d['titulo_trabajo']?:null,$d['fecha_inicio'],$d['observaciones']?:null]);
            $id=(int)$this->pdo->lastInsertId();
            $s=$this->pdo->prepare('INSERT INTO expediente_etapas(id_expediente,etapa,fecha_inicio,registrado_por) VALUES(?,"previa",?,?)'); $s->execute([$id,$d['fecha_inicio'],$_SESSION['id_usuario']??null]);
            $this->pdo->commit(); return $id;
        } catch(Throwable $e){ if($this->pdo->inTransaction())$this->pdo->rollBack(); throw $e; }
    }
    public function cambiarEtapaMg2(int $id,string $fecha,string $resultado): void
    {
        $this->pdo->beginTransaction();
        try {
            $s=$this->pdo->prepare('SELECT * FROM expedientes_mg WHERE id_expediente=? FOR UPDATE'); $s->execute([$id]); $x=$s->fetch(); if(!$x) throw new RuntimeException('Expediente inexistente.');
            if($x['etapa_actual']!=='mg1') throw new RuntimeException('Solo un expediente en MG1 puede ingresar a MG2.');
            $s=$this->pdo->prepare('UPDATE expediente_etapas SET fecha_fin=?,resultado=? WHERE id_expediente=? AND etapa="mg1" AND fecha_fin IS NULL'); $s->execute([$fecha,$resultado,$id]);
            $s=$this->pdo->prepare('INSERT INTO expediente_etapas(id_expediente,etapa,fecha_inicio,registrado_por) VALUES(?,"mg2",?,?)'); $s->execute([$id,$fecha,$_SESSION['id_usuario']??null]);
            $s=$this->pdo->prepare('UPDATE expedientes_mg SET etapa_actual="mg2" WHERE id_expediente=?'); $s->execute([$id]);
            $this->pdo->commit();
        } catch(Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}
    }
    public function cambiarEstado(int $id,string $estado,string $motivo): void
    {
        $s=$this->pdo->prepare('UPDATE expedientes_mg SET estado=?, observaciones=CONCAT(COALESCE(observaciones,""), CASE WHEN COALESCE(observaciones,"")="" THEN "" ELSE "\n" END, ?) WHERE id_expediente=?'); $s->execute([$estado,$motivo,$id]);
    }
    public function estudiantes(): array { return $this->pdo->query("SELECT e.id_estudiante,e.registro_universitario,u.nombre,u.apellido,e.estado_academico FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE e.estado_academico = 'egresado' ORDER BY u.apellido,u.nombre")->fetchAll(); }
    public function modalidades(): array { return $this->pdo->query('SELECT * FROM modalidades_grado WHERE activa=1 ORDER BY nombre')->fetchAll(); }
    public function cohortes(): array { return $this->pdo->query('SELECT * FROM cohortes_mg WHERE activa=1 ORDER BY fecha_inicio DESC')->fetchAll(); }
}
