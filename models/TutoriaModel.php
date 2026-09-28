<?php
class TutoriaValidationException extends RuntimeException {}

class TutoriaModel
{
    private PDO $pdo;

    private const HORARIOS = [
        'manana' => ['label' => 'Mañana', 'inicio' => '09:00', 'fin' => '11:00'],
        'tarde'  => ['label' => 'Tarde',  'inicio' => '15:00', 'fin' => '18:00'],
        'noche'  => ['label' => 'Noche',  'inicio' => '19:00', 'fin' => '22:00'],
    ];

    public function __construct(PDO $pdo) { $this->pdo = $pdo; }

    public static function horariosFijos(): array { return self::HORARIOS; }

    public function obtenerListado(array $filtros, int $pagina, int $porPagina, string $rol, int $idUsuario): array
    {
        $where = ['1=1']; $params = [];
        $this->agregarAlcance($where, $params, $rol, $idUsuario);

        if (($filtros['estado'] ?? '') !== '') { $where[] = 't.estado = ?'; $params[] = $filtros['estado']; }
        if ((int)($filtros['id_tutor'] ?? 0) > 0) { $where[] = 't.id_tutor = ?'; $params[] = (int)$filtros['id_tutor']; }
        if ((int)($filtros['id_materia'] ?? 0) > 0) { $where[] = 't.id_materia = ?'; $params[] = (int)$filtros['id_materia']; }
        if (($filtros['turno_horario'] ?? '') !== '') { $where[] = 't.turno_horario = ?'; $params[] = $filtros['turno_horario']; }
        if (($filtros['fecha_desde'] ?? '') !== '') { $where[] = 't.fecha >= ?'; $params[] = $filtros['fecha_desde']; }
        if (($filtros['fecha_hasta'] ?? '') !== '') { $where[] = 't.fecha <= ?'; $params[] = $filtros['fecha_hasta']; }
        if (($filtros['q'] ?? '') !== '') {
            $like = '%' . $filtros['q'] . '%';
            $where[] = "(CONCAT(COALESCE(ue.nombre,''), ' ', COALESCE(ue.apellido,'')) LIKE ? OR CONCAT(up.nombre, ' ', up.apellido) LIKE ? OR m.nombre_materia LIKE ? OR m.aula LIKE ?)";
            array_push($params, $like, $like, $like, $like);
        }

        $whereSql = implode(' AND ', $where);
        $countSql = "SELECT COUNT(*) FROM tutorias t
            JOIN tutores tr ON tr.id_tutor=t.id_tutor
            JOIN profesores p ON p.id_profesor=tr.id_profesor
            JOIN usuarios up ON up.id_usuario=p.id_usuario
            JOIN materias m ON m.id_materia=t.id_materia
            LEFT JOIN estudiantes e ON e.id_estudiante=t.id_estudiante
            LEFT JOIN usuarios ue ON ue.id_usuario=e.id_usuario
            WHERE {$whereSql}";
        $stmt = $this->pdo->prepare($countSql); $stmt->execute($params); $total = (int)$stmt->fetchColumn();

        $offset = max(0, ($pagina - 1) * $porPagina); $limit = max(1, min(100, $porPagina));
        $sql = "SELECT t.*, 
                    COALESCE(t.turno_horario,
                        CASE
                            WHEN t.hora_inicio >= '19:00:00' THEN 'noche'
                            WHEN t.hora_inicio >= '13:00:00' THEN 'tarde'
                            ELSE 'manana'
                        END
                    ) AS turno_horario,
                    CONCAT(up.nombre,' ',up.apellido) docente, up.id_usuario profesor_usuario,
                    CONCAT(COALESCE(ue.nombre,''),' ',COALESCE(ue.apellido,'')) estudiante,
                    ue.id_usuario estudiante_usuario, m.nombre_materia, m.aula,
                    ev.calificacion evaluacion_calificacion, ev.comentario evaluacion_comentario
                FROM tutorias t
                JOIN tutores tr ON tr.id_tutor=t.id_tutor
                JOIN profesores p ON p.id_profesor=tr.id_profesor
                JOIN usuarios up ON up.id_usuario=p.id_usuario
                JOIN materias m ON m.id_materia=t.id_materia
                LEFT JOIN estudiantes e ON e.id_estudiante=t.id_estudiante
                LEFT JOIN usuarios ue ON ue.id_usuario=e.id_usuario
                LEFT JOIN evaluaciones_tutoria ev ON ev.id_tutoria=t.id_tutoria
                WHERE {$whereSql}
                ORDER BY t.fecha ASC, t.hora_inicio ASC, t.id_tutoria ASC
                LIMIT {$limit} OFFSET {$offset}";
        $stmt = $this->pdo->prepare($sql); $stmt->execute($params);

        return ['items'=>$stmt->fetchAll(),'total'=>$total,'pagina'=>$pagina,'porPagina'=>$porPagina,'paginas'=>max(1,(int)ceil($total/$porPagina))];
    }

    public function obtenerDetalle(int $id): ?array
    {
        $stmt = $this->pdo->prepare("SELECT t.*, CONCAT(up.nombre,' ',up.apellido) docente, up.id_usuario profesor_usuario,
                CONCAT(COALESCE(ue.nombre,''),' ',COALESCE(ue.apellido,'')) estudiante, ue.id_usuario estudiante_usuario,
                tr.id_tutor, tr.especialidad tutor_especialidad, tr.biografia tutor_biografia,
                m.nombre_materia, m.aula, ev.id_evaluacion, ev.calificacion evaluacion_calificacion,
                ev.comentario evaluacion_comentario, ev.fecha_evaluacion
            FROM tutorias t
            JOIN tutores tr ON tr.id_tutor=t.id_tutor
            JOIN profesores p ON p.id_profesor=tr.id_profesor
            JOIN usuarios up ON up.id_usuario=p.id_usuario
            JOIN materias m ON m.id_materia=t.id_materia
            LEFT JOIN estudiantes e ON e.id_estudiante=t.id_estudiante
            LEFT JOIN usuarios ue ON ue.id_usuario=e.id_usuario
            LEFT JOIN evaluaciones_tutoria ev ON ev.id_tutoria=t.id_tutoria
            WHERE t.id_tutoria=?");
        $stmt->execute([$id]); $row=$stmt->fetch(); return $row ?: null;
    }

    public function obtenerEventosCalendario(string $inicio, string $fin, string $rol, int $idUsuario): array
    {
        $where=['t.fecha>=?','t.fecha<=?']; $params=[$inicio,$fin];
        $this->agregarAlcance($where,$params,$rol,$idUsuario);
        $sql="SELECT t.id_tutoria,t.id_estudiante,t.id_tutor,t.id_materia,t.fecha,t.hora_inicio,t.hora_fin,
                COALESCE(t.turno_horario,
                    CASE
                        WHEN t.hora_inicio >= '19:00:00' THEN 'noche'
                        WHEN t.hora_inicio >= '13:00:00' THEN 'tarde'
                        ELSE 'manana'
                    END
                ) AS turno_horario,
                t.estado,
                CONCAT(COALESCE(ue.nombre,''),' ',COALESCE(ue.apellido,'')) estudiante,
                CONCAT(up.nombre,' ',up.apellido) docente,m.nombre_materia,m.aula
            FROM tutorias t JOIN tutores tr ON tr.id_tutor=t.id_tutor JOIN profesores p ON p.id_profesor=tr.id_profesor
            JOIN usuarios up ON up.id_usuario=p.id_usuario JOIN materias m ON m.id_materia=t.id_materia
            LEFT JOIN estudiantes e ON e.id_estudiante=t.id_estudiante LEFT JOIN usuarios ue ON ue.id_usuario=e.id_usuario
            WHERE ".implode(' AND ',$where)." ORDER BY t.fecha,t.hora_inicio";
        $stmt=$this->pdo->prepare($sql); $stmt->execute($params); return $stmt->fetchAll();
    }

    public function obtenerTutores(): array
    {
        return $this->pdo->query("SELECT t.id_tutor,p.id_profesor,u.nombre,u.apellido,CONCAT(u.nombre,' ',u.apellido) nombre_completo,t.especialidad
            FROM tutores t JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios u ON u.id_usuario=p.id_usuario
            WHERE u.estado='activo' ORDER BY CASE WHEN u.usuario REGEXP '^docente[0-9]+$' THEN 0 ELSE 1 END, CAST(SUBSTRING(u.usuario,8) AS UNSIGNED), u.usuario")->fetchAll();
    }

    public function obtenerEstudiantes(): array
    {
        return $this->pdo->query("SELECT e.id_estudiante,u.nombre,u.apellido,CONCAT(u.nombre,' ',u.apellido) nombre_completo
            FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE u.estado='activo' ORDER BY CASE WHEN u.usuario REGEXP '^estudiante[0-9]+$' THEN 0 ELSE 1 END, CAST(SUBSTRING(u.usuario,11) AS UNSIGNED), u.usuario")->fetchAll();
    }

    public function obtenerMaterias(): array
    {
        return $this->pdo->query('SELECT id_materia,nombre_materia,aula FROM materias ORDER BY nombre_materia')->fetchAll();
    }

    public function obtenerMateriasPorTutor(int $idTutor): array
    {
        $stmt=$this->pdo->prepare("SELECT m.id_materia,m.nombre_materia,m.aula FROM tutor_materia tm JOIN materias m ON m.id_materia=tm.id_materia WHERE tm.id_tutor=? ORDER BY m.nombre_materia");
        $stmt->execute([$idTutor]); return $stmt->fetchAll();
    }

    public function obtenerEstudiantePorUsuario(int $idUsuario): ?array
    {
        $stmt=$this->pdo->prepare('SELECT e.*,u.nombre,u.apellido FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario WHERE e.id_usuario=?');
        $stmt->execute([$idUsuario]); $row=$stmt->fetch(); return $row ?: null;
    }

    public function obtenerTutorPorUsuario(int $idUsuario): ?array
    {
        $stmt=$this->pdo->prepare('SELECT t.*,p.id_profesor,u.nombre,u.apellido FROM tutores t JOIN profesores p ON p.id_profesor=t.id_profesor JOIN usuarios u ON u.id_usuario=p.id_usuario WHERE p.id_usuario=?');
        $stmt->execute([$idUsuario]); $row=$stmt->fetch(); return $row ?: null;
    }

    public function generarMes(int $idTutor, int $idMateria, string $mes): int
    {
        if (!preg_match('/^\d{4}-\d{2}$/', $mes)) throw new TutoriaValidationException('Selecciona un mes válido.');
        $fechaInicio = DateTimeImmutable::createFromFormat('!Y-m-d', $mes . '-01');
        $err = DateTimeImmutable::getLastErrors();
        if (!$fechaInicio || ($err !== false && ($err['warning_count'] > 0 || $err['error_count'] > 0))) throw new TutoriaValidationException('El mes seleccionado no es válido.');
        $materias = $this->obtenerMateriasPorTutor($idTutor);
        $materia = null; foreach ($materias as $m) if ((int)$m['id_materia'] === $idMateria) { $materia = $m; break; }
        if (!$materia) throw new TutoriaValidationException('La materia seleccionada no pertenece al docente.');
        $hoy = new DateTimeImmutable('today');
        $ultimoDia = $fechaInicio->modify('last day of this month');
        $insertados = 0;
        $this->pdo->beginTransaction();
        try {
            $check = $this->pdo->prepare("SELECT COUNT(*) FROM tutorias WHERE id_tutor=? AND fecha=? AND turno_horario=?");
            $insert = $this->pdo->prepare("INSERT INTO tutorias(id_estudiante,id_tutor,id_materia,fecha,hora_inicio,hora_fin,modalidad,lugar_o_enlace,estado,observaciones,turno_horario) VALUES(NULL,?,?,?,?,?,'presencial',?,'disponible',NULL,?)");
            $indiceDia = 0;
            $turnos = array_keys(self::HORARIOS);
            for ($fecha=$fechaInicio; $fecha <= $ultimoDia; $fecha=$fecha->modify('+1 day')) {
                if ($fecha < $hoy) continue;
                if ((int)$fecha->format('N') === 7) continue;
                // Un espacio por día y rotación de turnos para repartir la carga durante el mes.
                $turno = $turnos[$indiceDia % count($turnos)];
                $slot = self::HORARIOS[$turno];
                $check->execute([$idTutor,$fecha->format('Y-m-d'),$turno]);
                if ((int)$check->fetchColumn() === 0) {
                    $insert->execute([$idTutor,$idMateria,$fecha->format('Y-m-d'),$slot['inicio'],$slot['fin'],$materia['aula'],$turno]);
                    $insertados++;
                }
                $indiceDia++;
            }
            $this->pdo->commit();
            return $insertados;
        } catch (Throwable $e) {
            if ($this->pdo->inTransaction()) $this->pdo->rollBack();
            throw $e;
        }
    }

    public function crear(array $datos): int
    {
        $this->validarDisponibilidad($datos);
        $slot=self::HORARIOS[$datos['turno_horario']];
        $aula=$this->obtenerAulaMateria((int)$datos['id_materia']);
        $stmt=$this->pdo->prepare("INSERT INTO tutorias(id_estudiante,id_tutor,id_materia,fecha,hora_inicio,hora_fin,modalidad,lugar_o_enlace,estado,observaciones,turno_horario) VALUES(NULL,?,?,?,?,?,'presencial',?, 'disponible', NULL, ?)");
        $stmt->execute([(int)$datos['id_tutor'],(int)$datos['id_materia'],$datos['fecha'],$slot['inicio'],$slot['fin'],$aula,$datos['turno_horario']]);
        return (int)$this->pdo->lastInsertId();
    }

    public function editarDisponibilidad(int $id, array $datos): bool
    {
        $actual=$this->obtenerDetalle($id);
        if(!$actual || $actual['estado']!=='disponible') throw new TutoriaValidationException('Solo puedes editar espacios que todavía están disponibles.');
        $this->validarDisponibilidad($datos,$id);
        $slot=self::HORARIOS[$datos['turno_horario']];
        $aula=$this->obtenerAulaMateria((int)$datos['id_materia']);
        $stmt=$this->pdo->prepare('UPDATE tutorias SET id_materia=?,fecha=?,hora_inicio=?,hora_fin=?,lugar_o_enlace=?,turno_horario=? WHERE id_tutoria=? AND estado="disponible"');
        return $stmt->execute([(int)$datos['id_materia'],$datos['fecha'],$slot['inicio'],$slot['fin'],$aula,$datos['turno_horario'],$id]);
    }

    public function solicitarUnirse(int $id, int $idEstudiante): array
    {
        $this->pdo->beginTransaction();
        try {
            $registro=$this->obtenerDetalle($id);
            if(!$registro || $registro['estado']!=='disponible') throw new TutoriaValidationException('Esta tutoría ya no está disponible.');
            $stmt=$this->pdo->prepare("SELECT COUNT(*) FROM tutorias WHERE id_estudiante=? AND fecha=? AND estado IN('pendiente','confirmada') AND hora_inicio=? AND hora_fin=?");
            $stmt->execute([$idEstudiante,$registro['fecha'],$registro['hora_inicio'],$registro['hora_fin']]);
            if((int)$stmt->fetchColumn()>0) throw new TutoriaValidationException('Ya tienes otra solicitud o tutoría confirmada en ese horario.');
            $stmt=$this->pdo->prepare("UPDATE tutorias SET id_estudiante=?,estado='pendiente',fecha_solicitud=NOW() WHERE id_tutoria=? AND estado='disponible' AND id_estudiante IS NULL");
            $stmt->execute([$idEstudiante,$id]);
            if($stmt->rowCount()!==1) throw new TutoriaValidationException('Otro usuario acaba de solicitar este espacio.');
            $this->pdo->commit();
            return $this->obtenerDetalle($id) ?: $registro;
        } catch(Throwable $e) { if($this->pdo->inTransaction()) $this->pdo->rollBack(); throw $e; }
    }

    public function cancelarSolicitud(int $id, int $idUsuario): bool
    {
        $stmt=$this->pdo->prepare("UPDATE tutorias t JOIN estudiantes e ON e.id_estudiante=t.id_estudiante SET t.estado='disponible',t.id_estudiante=NULL,t.fecha_solicitud=NOW() WHERE t.id_tutoria=? AND e.id_usuario=? AND t.estado='pendiente'");
        $stmt->execute([$id,$idUsuario]); return $stmt->rowCount()>0;
    }

    public function cambiarEstado(int $id,string $nuevoEstado,string $rol,int $idUsuario): array
    {
        $registro=$this->obtenerDetalle($id); if(!$registro) throw new TutoriaValidationException('La tutoría indicada no existe.');
        if($rol==='administrador') {
            if(!in_array($nuevoEstado,['confirmada','rechazada'],true) || $registro['estado']!=='pendiente') throw new TutoriaValidationException('Solo puedes aceptar o rechazar solicitudes pendientes.');
        } elseif($rol==='docente') {
            if((int)$registro['profesor_usuario']!==$idUsuario) throw new TutoriaValidationException('Solo puedes gestionar tus propias tutorías.');
            if(!in_array($nuevoEstado,['realizada','cancelada'],true) || $registro['estado']!=='confirmada') throw new TutoriaValidationException('La transición de estado no está permitida.');
        } else throw new TutoriaValidationException('No tienes permiso para realizar esta acción.');

        $stmt=$this->pdo->prepare('UPDATE tutorias SET estado=? WHERE id_tutoria=?'); $stmt->execute([$nuevoEstado,$id]);
        return $registro;
    }

    public function eliminarSiPertenece(int $id,string $rol,int $idUsuario): bool
    {
        if($rol!=='docente') return false;
        $stmt=$this->pdo->prepare("DELETE t FROM tutorias t JOIN tutores tr ON tr.id_tutor=t.id_tutor JOIN profesores p ON p.id_profesor=tr.id_profesor WHERE t.id_tutoria=? AND p.id_usuario=? AND t.estado='disponible'");
        $stmt->execute([$id,$idUsuario]); return $stmt->rowCount()>0;
    }

    public function puedeEditar(int $id,string $rol,int $idUsuario): bool
    {
        if($rol!=='docente') return false;
        $stmt=$this->pdo->prepare("SELECT COUNT(*) FROM tutorias t JOIN tutores tr ON tr.id_tutor=t.id_tutor JOIN profesores p ON p.id_profesor=tr.id_profesor WHERE t.id_tutoria=? AND p.id_usuario=? AND t.estado='disponible'");
        $stmt->execute([$id,$idUsuario]); return (int)$stmt->fetchColumn()>0;
    }

    public function puedeVer(int $id,string $rol,int $idUsuario): bool
    {
        if($rol==='administrador') return true;
        if($rol==='docente') { $stmt=$this->pdo->prepare("SELECT COUNT(*) FROM tutorias t JOIN tutores tr ON tr.id_tutor=t.id_tutor JOIN profesores p ON p.id_profesor=tr.id_profesor WHERE t.id_tutoria=? AND p.id_usuario=?"); $stmt->execute([$id,$idUsuario]); return (int)$stmt->fetchColumn()>0; }
        $stmt=$this->pdo->prepare("SELECT COUNT(*) FROM tutorias t LEFT JOIN estudiantes e ON e.id_estudiante=t.id_estudiante WHERE t.id_tutoria=? AND (t.estado='disponible' OR e.id_usuario=?)");
        $stmt->execute([$id,$idUsuario]); return (int)$stmt->fetchColumn()>0;
    }

    public function asegurarNotaTutoria(int $idTutoria): void
    {
        $stmt=$this->pdo->prepare("SELECT t.id_estudiante,t.fecha,t.fecha_limite_notas,m.nombre_materia,m.id_curso FROM tutorias t JOIN materias m ON m.id_materia=t.id_materia WHERE t.id_tutoria=? AND t.estado='realizada'");
        $stmt->execute([$idTutoria]); $info=$stmt->fetch(); if(!$info || !$info['id_estudiante'] || !$info['id_curso']) return;
        $fechaLimite=$info['fecha_limite_notas'] ?: (new DateTimeImmutable($info['fecha']))->modify('+5 days')->format('Y-m-d');
        if(!$info['fecha_limite_notas']) { $s=$this->pdo->prepare('UPDATE tutorias SET fecha_limite_notas=? WHERE id_tutoria=?'); $s->execute([$fechaLimite,$idTutoria]); }
        $s=$this->pdo->prepare('SELECT id_inscripcion FROM inscripciones WHERE id_estudiante=? AND id_curso=?'); $s->execute([$info['id_estudiante'],$info['id_curso']]); $idIns=$s->fetchColumn(); if(!$idIns) return;
        $tipo='Tutoría: '.$info['nombre_materia']; $s=$this->pdo->prepare('SELECT COUNT(*) FROM calificaciones WHERE id_inscripcion=? AND tipo=?'); $s->execute([$idIns,$tipo]); if((int)$s->fetchColumn()>0) return;
        $s=$this->pdo->prepare("INSERT INTO calificaciones(id_inscripcion,tipo,nota,observacion,fecha) VALUES(?,?,0,?,?)"); $s->execute([$idIns,$tipo,'Nota pendiente de registrar por el docente tras la tutoría.',$fechaLimite]);
    }

    public function obtenerEvaluacion(int $idTutoria): ?array { $s=$this->pdo->prepare('SELECT * FROM evaluaciones_tutoria WHERE id_tutoria=?'); $s->execute([$idTutoria]); $r=$s->fetch(); return $r?:null; }
    public function crearEvaluacion(int $idTutoria,int $calificacion,string $comentario): bool
    {
        if($calificacion<1||$calificacion>5) throw new TutoriaValidationException('La calificación debe estar entre 1 y 5 estrellas.');
        $detalle=$this->obtenerDetalle($idTutoria); if(!$detalle||$detalle['estado']!=='realizada') throw new TutoriaValidationException('Solo puedes evaluar tutorías realizadas.');
        if(!$detalle['estudiante_usuario'] || (int)$detalle['estudiante_usuario']!==(int)($_SESSION['id_usuario']??0)) throw new TutoriaValidationException('No puedes evaluar esta tutoría.');
        try { $s=$this->pdo->prepare('INSERT INTO evaluaciones_tutoria(id_tutoria,calificacion,comentario) VALUES(?,?,?)'); return $s->execute([$idTutoria,$calificacion,trim($comentario)]); }
        catch(PDOException $e) { if((int)($e->errorInfo[1]??0)===1062) throw new TutoriaValidationException('Esta tutoría ya tiene una evaluación.'); throw $e; }
    }

    private function obtenerAulaMateria(int $idMateria): string
    {
        $s=$this->pdo->prepare('SELECT aula FROM materias WHERE id_materia=?');
        $s->execute([$idMateria]);
        $aula=$s->fetchColumn();
        if($aula===false || trim((string)$aula)==='') throw new TutoriaValidationException('La materia no tiene un aula definida.');
        return (string)$aula;
    }

    private function validarDisponibilidad(array $datos,int $idExcluir=0): void
    {
        $idTutor=(int)($datos['id_tutor']??0); $idMateria=(int)($datos['id_materia']??0); $fecha=trim($datos['fecha']??''); $turno=$datos['turno_horario']??'';
        if($idTutor<=0||$idMateria<=0) throw new TutoriaValidationException('Selecciona tutor y materia.');
        if(!isset(self::HORARIOS[$turno])) throw new TutoriaValidationException('Selecciona uno de los tres horarios fijos.');
        $fechaObj=DateTimeImmutable::createFromFormat('!Y-m-d',$fecha); $err=DateTimeImmutable::getLastErrors();
        if(!$fechaObj||($err!==false&&($err['warning_count']>0||$err['error_count']>0))) throw new TutoriaValidationException('La fecha indicada no es válida.');
        if($fechaObj<new DateTimeImmutable('today')) throw new TutoriaValidationException('La fecha no puede ser pasada.');
        if((int)$fechaObj->format('N')===7) throw new TutoriaValidationException('No se pueden programar clases ni tutorías los domingos. Selecciona de lunes a sábado.');
        $s=$this->pdo->prepare('SELECT COUNT(*) FROM tutor_materia WHERE id_tutor=? AND id_materia=?'); $s->execute([$idTutor,$idMateria]); if((int)$s->fetchColumn()===0) throw new TutoriaValidationException('El tutor no tiene asignada esa materia.');
        $s=$this->pdo->prepare('SELECT aula FROM materias WHERE id_materia=?'); $s->execute([$idMateria]); $aula=$s->fetchColumn(); if($aula===false) throw new TutoriaValidationException('La materia no existe.');
        $slot=self::HORARIOS[$turno];
        $s=$this->pdo->prepare("SELECT COUNT(*) FROM tutorias WHERE id_tutor=? AND fecha=? AND turno_horario=? AND estado IN('disponible','pendiente','confirmada') AND id_tutoria<>?"); $s->execute([$idTutor,$fecha,$turno,$idExcluir]); if((int)$s->fetchColumn()>0) throw new TutoriaValidationException('El tutor ya tiene ocupado ese horario en esa fecha.');
    }

    private function agregarAlcance(array &$where,array &$params,string $rol,int $idUsuario): void
    {
        if($rol==='docente') { $where[]='p.id_usuario=?'; $params[]=$idUsuario; }
        elseif($rol==='estudiante') { $where[]='(t.estado=\'disponible\' OR e.id_usuario=?)'; $params[]=$idUsuario; }
    }
}
