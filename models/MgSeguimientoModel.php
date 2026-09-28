<?php
declare(strict_types=1);
require_once __DIR__.'/MgParametroModel.php';

class MgSeguimientoModel
{
    public function __construct(private PDO $pdo) {}

    public function reuniones(array $f = []): array
    {
        $where=[];$p=[];
        if (!empty($f['id_usuario_tutor'])) { $where[]='tu.id_usuario=?'; $p[]=(int)$f['id_usuario_tutor']; }
        if (!empty($f['id_usuario_estudiante'])) { $where[]='eu.id_usuario=?'; $p[]=(int)$f['id_usuario_estudiante']; }
        if (!empty($f['id_expediente'])) { $where[]='x.id_expediente=?'; $p[]=(int)$f['id_expediente']; }
        if (!empty($f['estado'])) { $where[]='r.estado_validacion=?'; $p[]=$f['estado']; }
        $sql='SELECT r.*,x.id_expediente,x.etapa_actual,x.estado,e.registro_universitario,eu.nombre AS est_nombre,eu.apellido AS est_apellido,tu.id_usuario AS tutor_usuario,tu.nombre AS tutor_nombre,tu.apellido AS tutor_apellido
              FROM reuniones_mg r JOIN asignaciones_tutor a ON a.id_asignacion=r.id_asignacion
              JOIN expedientes_mg x ON x.id_expediente=a.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios eu ON eu.id_usuario=e.id_usuario
              JOIN tutores t ON t.id_tutor=a.id_tutor JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios tu ON tu.id_usuario=p.id_usuario'.($where?' WHERE '.implode(' AND ',$where):'').' ORDER BY r.fecha DESC,r.hora_inicio DESC,r.id_reunion DESC';
        $s=$this->pdo->prepare($sql);$s->execute($p);return $s->fetchAll();
    }

    public function asignacionesParaTutor(int $uid): array
    {
        $s=$this->pdo->prepare('SELECT a.id_asignacion,x.id_expediente,e.registro_universitario,u.nombre,u.apellido FROM asignaciones_tutor a JOIN expedientes_mg x ON x.id_expediente=a.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN tutores t ON t.id_tutor=a.id_tutor JOIN profesores p ON p.id_profesor=t.id_profesor WHERE p.id_usuario=? AND a.estado="vigente" ORDER BY u.apellido,u.nombre');
        $s->execute([$uid]);return $s->fetchAll();
    }

    public function asignacionPropia(int $idAsignacion,int $uid): ?array
    {
        $s=$this->pdo->prepare('SELECT a.*,x.id_expediente,x.etapa_actual,x.id_estudiante,e.id_usuario AS id_usuario_estudiante FROM asignaciones_tutor a JOIN expedientes_mg x ON x.id_expediente=a.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN tutores t ON t.id_tutor=a.id_tutor JOIN profesores p ON p.id_profesor=t.id_profesor WHERE a.id_asignacion=? AND p.id_usuario=?');$s->execute([$idAsignacion,$uid]);return $s->fetch()?:null;
    }

    public function crearReunion(array $d): int
    {
        $s=$this->pdo->prepare('SELECT a.id_asignacion,x.id_expediente,e.id_usuario AS id_usuario_estudiante,t.id_tutor,p.id_usuario AS id_usuario_tutor FROM asignaciones_tutor a JOIN expedientes_mg x ON x.id_expediente=a.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN tutores t ON t.id_tutor=a.id_tutor JOIN profesores p ON p.id_profesor=t.id_profesor WHERE a.id_asignacion=? AND a.estado="vigente"');$s->execute([(int)$d['id_asignacion']]);$a=$s->fetch();if(!$a)throw new RuntimeException('La asignación de Tutor no existe o ya no está vigente.');
        $s=$this->pdo->prepare('SELECT COUNT(*) FROM reuniones_mg r JOIN asignaciones_tutor a ON a.id_asignacion=r.id_asignacion JOIN expedientes_mg x ON x.id_expediente=a.id_expediente WHERE r.fecha=? AND r.estado_validacion<>"observada" AND r.hora_inicio < ? AND r.hora_fin > ? AND (a.id_tutor=? OR x.id_estudiante=?)');$s->execute([$d['fecha'],$d['hora_fin'],$d['hora_inicio'],$a['id_tutor'],$a['id_estudiante']]);if((int)$s->fetchColumn()>0)throw new RuntimeException('Existe otra reunión que cruza el horario del Tutor o del estudiante.');
        $s=$this->pdo->prepare('INSERT INTO reuniones_mg(id_asignacion,fecha,hora_inicio,hora_fin,modalidad,lugar_o_enlace,temas,avance_sesion,observaciones,asistio_estudiante,asistio_tutor,registrada_por) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)');$s->execute([(int)$d['id_asignacion'],$d['fecha'],$d['hora_inicio'],$d['hora_fin'],$d['modalidad'],$d['lugar_o_enlace']?:null,$d['temas'],$d['avance_sesion']===''?null:(int)$d['avance_sesion'],$d['observaciones']?:null,$d['asistio_estudiante'],$d['asistio_tutor'],$_SESSION['id_usuario']??null]);return (int)$this->pdo->lastInsertId();
    }

    public function reunion(int $id): ?array { $s=$this->pdo->prepare('SELECT r.*,a.id_expediente,x.id_estudiante,e.id_usuario AS id_usuario_estudiante,p.id_usuario AS id_usuario_tutor FROM reuniones_mg r JOIN asignaciones_tutor a ON a.id_asignacion=r.id_asignacion JOIN expedientes_mg x ON x.id_expediente=a.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN tutores t ON t.id_tutor=a.id_tutor JOIN profesores p ON p.id_profesor=t.id_profesor WHERE r.id_reunion=?');$s->execute([$id]);return $s->fetch()?:null; }

    public function validarReunion(int $id,string $estado,string $motivo,int $uid): void
    {
        if(!in_array($estado,['validada','observada'],true))throw new RuntimeException('Estado de validación inválido.');
        $s=$this->pdo->prepare('UPDATE reuniones_mg SET estado_validacion=?,observaciones=CASE WHEN ?<>"" THEN CONCAT(COALESCE(observaciones,""),CASE WHEN COALESCE(observaciones,"")="" THEN "" ELSE "\n" END,?) ELSE observaciones END,validada_por=?,fecha_validacion=NOW() WHERE id_reunion=?');$s->execute([$estado,$motivo,$motivo,$uid,$id]);
    }

    public function hitosInformes(?int $cohorte=null): array
    {
        $p=[];$w='k.tipo="informe"';if($cohorte){$w.=' AND k.id_cohorte=?';$p[]=$cohorte;}$s=$this->pdo->prepare('SELECT k.*,c.nombre AS cohorte_nombre FROM calendario_mg k JOIN cohortes_mg c ON c.id_cohorte=k.id_cohorte WHERE '.$w.' ORDER BY c.fecha_inicio DESC,k.orden,k.fecha_limite');$s->execute($p);return $s->fetchAll();
    }

    public function expedientesInforme(int $uid,string $rol): array
    {
        $where='';$p=[];
        if($rol==='docente'){$where=' AND p.id_usuario=? AND a.estado="vigente"';$p[]=$uid;}
        elseif($rol==='estudiante'){$where=' AND e.id_usuario=?';$p[]=$uid;}
        $sql='SELECT x.id_expediente,x.id_cohorte,e.registro_universitario,u.nombre,u.apellido,c.nombre AS cohorte_nombre,x.etapa_actual FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN cohortes_mg c ON c.id_cohorte=x.id_cohorte LEFT JOIN asignaciones_tutor a ON a.id_expediente=x.id_expediente AND a.estado="vigente" LEFT JOIN tutores t ON t.id_tutor=a.id_tutor LEFT JOIN profesores p ON p.id_profesor=t.id_profesor WHERE 1=1'.$where.' ORDER BY u.apellido,u.nombre';$s=$this->pdo->prepare($sql);$s->execute($p);return $s->fetchAll();
    }

    public function informes(array $f=[]): array
    {
        $w=[];$p=[];if(!empty($f['id_expediente'])){$w[]='i.id_expediente=?';$p[]=(int)$f['id_expediente'];}if(!empty($f['id_usuario'])){$w[]='e.id_usuario=?';$p[]=(int)$f['id_usuario'];}if(!empty($f['id_usuario_tutor'])){$w[]='p.id_usuario=? AND a.estado="vigente"';$p[]=(int)$f['id_usuario_tutor'];}
        $sql='SELECT i.*,k.nombre hito_nombre,k.fecha_limite,k.avance_esperado_pct,c.nombre cohorte_nombre,x.etapa_actual,e.registro_universitario,u.nombre est_nombre,u.apellido est_apellido FROM informes_avance i JOIN calendario_mg k ON k.id_hito=i.id_hito JOIN expedientes_mg x ON x.id_expediente=i.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN cohortes_mg c ON c.id_cohorte=x.id_cohorte LEFT JOIN asignaciones_tutor a ON a.id_expediente=x.id_expediente AND a.estado="vigente" LEFT JOIN tutores t ON t.id_tutor=a.id_tutor LEFT JOIN profesores p ON p.id_profesor=t.id_profesor'.($w?' WHERE '.implode(' AND ',$w):'').' ORDER BY i.fecha_presentacion DESC,i.id_informe DESC';$s=$this->pdo->prepare($sql);$s->execute($p);$rows=$s->fetchAll();foreach($rows as &$r){$r['estado_calculado']=((!empty($r['fecha_limite'])&&$r['fecha_presentacion']>$r['fecha_limite'])?'presentado_tarde':'presentado');}return $rows;
    }

    public function guardarInforme(array $d,?int $id=null): int
    {
        $s=$this->pdo->prepare('SELECT id_expediente FROM calendario_mg k JOIN expedientes_mg x ON x.id_cohorte=k.id_cohorte WHERE k.id_hito=? AND k.tipo="informe" AND x.id_expediente=?');$s->execute([(int)$d['id_hito'],(int)$d['id_expediente']]);if(!$s->fetchColumn())throw new RuntimeException('El hito no corresponde al expediente.');
        if($id){$s=$this->pdo->prepare('UPDATE informes_avance SET porcentaje_avance=?,fecha_presentacion=?,formato=?,respaldo_fisico=?,observaciones=?,registrado_por=? WHERE id_informe=?');$s->execute([(int)$d['porcentaje_avance'],$d['fecha_presentacion'],$d['formato'],(int)$d['respaldo_fisico'],$d['observaciones']?:null,$_SESSION['id_usuario']??null,$id]);return $id;}
        $s=$this->pdo->prepare('INSERT INTO informes_avance(id_expediente,id_hito,porcentaje_avance,fecha_presentacion,formato,respaldo_fisico,presentado_por,observaciones,registrado_por) VALUES(?,?,?,?,?,?,?,?,?)');$s->execute([(int)$d['id_expediente'],(int)$d['id_hito'],(int)$d['porcentaje_avance'],$d['fecha_presentacion'],$d['formato'],(int)$d['respaldo_fisico'],$_SESSION['id_usuario']??null,$d['observaciones']?:null,$_SESSION['id_usuario']??null]);return (int)$this->pdo->lastInsertId();
    }

    public function alertas(): array
    {
        $a=[];
        $q=$this->pdo->query('SELECT x.id_expediente,CONCAT(u.nombre," ",u.apellido) estudiante FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE x.etapa_actual="mg1" AND x.estado="activo" AND NOT EXISTS(SELECT 1 FROM asignaciones_tutor at WHERE at.id_expediente=x.id_expediente AND at.estado="vigente")');foreach($q as $r)$a[]=['tipo'=>'A1','severidad'=>'alta','id'=>(int)$r['id_expediente'],'titulo'=>'MG1 sin Tutor asignado','detalle'=>$r['estudiante'],'url'=>'/controllers/mg_expedientes.php?accion=ficha&id='.$r['id_expediente']];
        $dias=(int)(new MgParametroModel($this->pdo))->obtener('dias_alerta_sin_reunion','10');
        $q=$this->pdo->query('SELECT x.id_expediente,CONCAT(u.nombre," ",u.apellido) estudiante,MAX(r.fecha) ultima FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN asignaciones_tutor at ON at.id_expediente=x.id_expediente AND at.estado="vigente" LEFT JOIN reuniones_mg r ON r.id_asignacion=at.id_asignacion AND r.estado_validacion<>"observada" WHERE x.estado="activo" GROUP BY x.id_expediente,u.nombre,u.apellido');foreach($q as $r){if(empty($r['ultima'])||strtotime($r['ultima'])<strtotime('-'.$dias.' days'))$a[]=['tipo'=>'A2','severidad'=>'alta','id'=>(int)$r['id_expediente'],'titulo'=>'Sin reuniones recientes','detalle'=>$r['estudiante'],'url'=>'/controllers/mg_reuniones.php?id_expediente='.$r['id_expediente']];}
        $min=(int)(new MgParametroModel($this->pdo))->obtener('reuniones_min_semana_perfil','2');$q=$this->pdo->query('SELECT x.id_expediente,CONCAT(u.nombre," ",u.apellido) estudiante,COUNT(r.id_reunion) total FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN asignaciones_tutor at ON at.id_expediente=x.id_expediente AND at.estado="vigente" LEFT JOIN reuniones_mg r ON r.id_asignacion=at.id_asignacion AND YEARWEEK(r.fecha,1)=YEARWEEK(CURDATE(),1) AND r.estado_validacion<>"observada" WHERE x.etapa_actual="mg1" AND x.estado="activo" GROUP BY x.id_expediente,u.nombre,u.apellido');foreach($q as $r){if((int)$r['total']<$min)$a[]=['tipo'=>'A3','severidad'=>'media','id'=>(int)$r['id_expediente'],'titulo'=>'Menos de reuniones mínimas esta semana','detalle'=>$r['estudiante'].' ('.$r['total'].'/'.$min.')','url'=>'/controllers/mg_reuniones.php?id_expediente='.$r['id_expediente']];}
        $q=$this->pdo->query('SELECT i.id_informe,i.id_expediente,CONCAT(u.nombre," ",u.apellido) estudiante,k.nombre hito,k.fecha_limite FROM informes_avance i JOIN calendario_mg k ON k.id_hito=i.id_hito JOIN expedientes_mg x ON x.id_expediente=i.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE k.fecha_limite<CURDATE() AND i.fecha_presentacion>k.fecha_limite');foreach($q as $r)$a[]=['tipo'=>'A4','severidad'=>'alta','id'=>(int)$r['id_informe'],'titulo'=>'Informe presentado fuera de plazo','detalle'=>$r['estudiante'].' - '.$r['hito'],'url'=>'/controllers/mg_informes.php?id_expediente='.$r['id_expediente']];
        $q=$this->pdo->query('SELECT x.id_expediente,k.id_hito,CONCAT(u.nombre," ",u.apellido) estudiante,k.nombre hito,k.fecha_limite FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN calendario_mg k ON k.id_cohorte=x.id_cohorte AND k.tipo="informe" LEFT JOIN informes_avance i ON i.id_hito=k.id_hito AND i.id_expediente=x.id_expediente WHERE x.etapa_actual="mg2" AND k.fecha_limite<CURDATE() AND i.id_informe IS NULL');foreach($q as $r)$a[]=['tipo'=>'A4','severidad'=>'alta','id'=>(int)$r['id_hito']*100000+(int)$r['id_expediente'],'titulo'=>'Informe con fecha límite vencida y no presentado','detalle'=>$r['estudiante'].' - '.$r['hito'],'url'=>'/controllers/mg_informes.php?id_expediente='.$r['id_expediente']];
        $q=$this->pdo->query('SELECT k.id_hito,k.nombre,k.avance_esperado_pct,i.id_informe,i.porcentaje_avance,i.id_expediente,CONCAT(u.nombre," ",u.apellido) estudiante FROM informes_avance i JOIN calendario_mg k ON k.id_hito=i.id_hito JOIN expedientes_mg x ON x.id_expediente=i.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE k.avance_esperado_pct IS NOT NULL AND i.porcentaje_avance<k.avance_esperado_pct');foreach($q as $r)$a[]=['tipo'=>'A5','severidad'=>'media','id'=>(int)$r['id_informe'],'titulo'=>'Avance por debajo de lo esperado','detalle'=>$r['estudiante'].' - '.$r['nombre'].' ('.$r['porcentaje_avance'].'%/'.$r['avance_esperado_pct'].'%)','url'=>'/controllers/mg_informes.php?id_expediente='.$r['id_expediente']];
        $q=$this->pdo->query('SELECT x.id_expediente,CONCAT(u.nombre," ",u.apellido) estudiante,COUNT(k.id_hito) total_hitos,SUM(CASE WHEN i.id_informe IS NULL THEN 1 ELSE 0 END) faltantes FROM expedientes_mg x JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario JOIN calendario_mg k ON k.id_cohorte=x.id_cohorte AND k.tipo="informe" LEFT JOIN informes_avance i ON i.id_hito=k.id_hito AND i.id_expediente=x.id_expediente WHERE x.etapa_actual="mg2" GROUP BY x.id_expediente,u.nombre,u.apellido');foreach($q as $r){if((int)$r['faltantes']>=2)$a[]=['tipo'=>'A6','severidad'=>'alta','id'=>(int)$r['id_expediente'],'titulo'=>'Riesgo de abandono','detalle'=>$r['estudiante'].' tiene '.$r['faltantes'].' informes pendientes','url'=>'/controllers/mg_expedientes.php?accion=ficha&id='.$r['id_expediente']];}
        $diasTrib=(int)(new MgParametroModel($this->pdo))->obtener('dias_anticipacion_tribunal','14');$q=$this->pdo->query('SELECT d.id_defensa,d.id_expediente,COUNT(t.id) tribunales,CONCAT(u.nombre," ",u.apellido) estudiante FROM defensas_mg d JOIN expedientes_mg x ON x.id_expediente=d.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario LEFT JOIN tribunales_defensa t ON t.id_expediente=d.id_expediente AND t.etapa=d.etapa AND t.estado="vigente" WHERE d.etapa="mg1" AND d.estado="programada" AND d.fecha BETWEEN CURDATE() AND DATE_ADD(CURDATE(),INTERVAL '.$diasTrib.' DAY) GROUP BY d.id_defensa,d.id_expediente,u.nombre,u.apellido');$req=(int)(new MgParametroModel($this->pdo))->obtener('tribunales_por_defensa_mg1','2');foreach($q as $r){if((int)$r['tribunales']<$req)$a[]=['tipo'=>'A7','severidad'=>'alta','id'=>(int)$r['id_defensa'],'titulo'=>'Defensa próxima sin tribunales requeridos','detalle'=>$r['estudiante'].' ('.$r['tribunales'].'/'.$req.')','url'=>'/controllers/mg_defensas.php?accion=ver&id='.$r['id_defensa']];}
        $carga=(int)(new MgParametroModel($this->pdo))->obtener('tutor_carga_recomendada','3');$q=$this->pdo->query('SELECT t.id_tutor,CONCAT(u.nombre," ",u.apellido) tutor,COUNT(a.id_asignacion) carga FROM tutores t JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios u ON u.id_usuario=p.id_usuario LEFT JOIN asignaciones_tutor a ON a.id_tutor=t.id_tutor AND a.estado="vigente" GROUP BY t.id_tutor,u.nombre,u.apellido');foreach($q as $r){if((int)$r['carga']>$carga)$a[]=['tipo'=>'A8','severidad'=>'media','id'=>(int)$r['id_tutor'],'titulo'=>'Tutor sobre carga recomendada','detalle'=>$r['tutor'].' ('.$r['carga'].'/'.$carga.')','url'=>'/controllers/mg_expedientes.php?accion=listar'];}
        $q=$this->pdo->query('SELECT d.id_defensa,d.id_expediente,CONCAT(u.nombre," ",u.apellido) estudiante FROM defensas_mg d JOIN expedientes_mg x ON x.id_expediente=d.id_expediente JOIN estudiantes e ON e.id_estudiante=x.id_estudiante JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE d.estado="programada" AND NOT EXISTS(SELECT 1 FROM documentos_generados g WHERE g.id_expediente=d.id_expediente AND g.tipo IN("CITACION_TRIBUNAL","CITACION_ESTUDIANTE"))');foreach($q as $r)$a[]=['tipo'=>'A9','severidad'=>'media','id'=>(int)$r['id_defensa'],'titulo'=>'Defensa sin citaciones generadas','detalle'=>$r['estudiante'],'url'=>'/controllers/mg_defensas.php?accion=ver&id='.$r['id_defensa']];
        return $a;
    }

    public function atendida(string $tipo,int $id): bool { $s=$this->pdo->prepare('SELECT COUNT(*) FROM alertas_atendidas WHERE tipo_alerta=? AND id_referencia=?');$s->execute([$tipo,$id]);return (int)$s->fetchColumn()>0; }
}
