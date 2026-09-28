<?php
declare(strict_types=1);
class MgDocumentoModel {
 public function __construct(private PDO $pdo) {}
 public function plantilla(string $codigo): ?array {$s=$this->pdo->prepare('SELECT * FROM plantillas_documento WHERE codigo=? AND activa=1 ORDER BY version DESC LIMIT 1');$s->execute([$codigo]);return $s->fetch()?:null;}
 public function numero(string $tipo): string {$anio=(int)date('Y');$this->pdo->beginTransaction();try{$s=$this->pdo->prepare('SELECT ultimo_numero FROM contadores_documento WHERE tipo=? AND anio=? FOR UPDATE');$s->execute([$tipo,$anio]);$n=$s->fetchColumn();if($n===false){$this->pdo->prepare('INSERT INTO contadores_documento(tipo,anio,ultimo_numero) VALUES(?,?,1)')->execute([$tipo,$anio]);$n=1;}else{$n=(int)$n+1;$this->pdo->prepare('UPDATE contadores_documento SET ultimo_numero=? WHERE tipo=? AND anio=?')->execute([$n,$tipo,$anio]);}$this->pdo->commit();return sprintf('%03d/%04d',$n,$anio);}catch(Throwable $e){if($this->pdo->inTransaction())$this->pdo->rollBack();throw $e;}}
 public function guardar(array $d): int {$s=$this->pdo->prepare('INSERT INTO documentos_generados(id_plantilla,tipo,id_expediente,destinatario,numero_correlativo,contenido_snapshot,generado_por) VALUES(?,?,?,?,?,?,?)');$s->execute([$d['id_plantilla'],$d['tipo'],$d['id_expediente'],$d['destinatario'],$d['numero'],$d['contenido'],$_SESSION['id_usuario']??null]);return (int)$this->pdo->lastInsertId();}
 public function listar(int $idExp): array {$s=$this->pdo->prepare('SELECT * FROM documentos_generados WHERE id_expediente=? ORDER BY fecha_generacion DESC,id DESC');$s->execute([$idExp]);return $s->fetchAll();}
}
