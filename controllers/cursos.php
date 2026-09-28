<?php
require_once __DIR__.'/../config/conexion.php'; require_once __DIR__.'/../includes/seguridad.php';
require_once __DIR__.'/../includes/paginacion.php'; require_role(['administrador','docente','estudiante']); require_once __DIR__.'/../models/CursoModel.php';
$m=new CursoModel($pdo);$id=(int)($_GET['id']??0);$accion=$_GET['accion']??'listar';$formError=null;
if($_SERVER['REQUEST_METHOD']==='POST'){
    require_role(['administrador']);validar_csrf();
    try{
        if(($_POST['accion']??'')==='eliminar'){ $m->eliminar((int)($_POST['id']??0));flash('success','Curso eliminado.');redir('/controllers/cursos.php'); }
        if(($_POST['accion']??'')!=='guardar')throw new RuntimeException('Acción no reconocida.');
        $id=(int)($_POST['id']??$id);$error=validar_requeridos($_POST,['nombre_curso'=>'Nombre del curso','codigo'=>'Código']);if($error)throw new RuntimeException($error);
        $catalogo = [
            'BD-101'=>'Base de Datos I','PR-101'=>'Programación I','WEB-101'=>'Tecnología Web I','MAT-101'=>'Matemática Discreta',
            'CON-101'=>'Contabilidad Financiera','DER-101'=>'Derecho Empresarial','MKT-101'=>'Marketing Digital','ARQ-101'=>'Diseño Arquitectónico',
            'CIV-101'=>'Resistencia de Materiales','PSI-101'=>'Psicología General','IND-101'=>'Procesos Industriales','SW-101'=>'Desarrollo de Software',
            'BD-201'=>'Bases de Datos II','MAT-201'=>'Matemática Aplicada','RED-101'=>'Redes de Computadoras','ING-101'=>'Ingeniería de Software','WEB-201'=>'Tecnología Web II',
            'BD-301'=>'Administración de Bases de Datos',
            'ADM-201'=>'Gestión Administrativa II',
            'CON-201'=>'Contabilidad de Costos',
            'DER-201'=>'Derecho Laboral',
            'COM-201'=>'Investigación de Mercados',
            'ARQ-201'=>'Urbanismo I',
            'CIV-201'=>'Hidráulica Aplicada',
            'PSI-201'=>'Psicología Educativa',
            'MKT-201'=>'Marketing Estratégico',
            'IND-201'=>'Logística Industrial',
            'BD-401'=>'Optimización de Bases de Datos',
            'ADM-301'=>'Planificación Estratégica',
            'CON-301'=>'Auditoría Financiera',
            'DER-301'=>'Derecho Tributario',
            'COM-301'=>'Estrategia Comercial',
            'ARQ-301'=>'Diseño Arquitectónico II',
            'CIV-301'=>'Estructuras de Hormigón',
            'PSI-301'=>'Psicología Social',
            'MKT-301'=>'Comercio Electrónico',
            'IND-301'=>'Control de Calidad',
            'BD-501'=>'Seguridad de Bases de Datos',
            'ADM-401'=>'Gestión de Recursos Humanos',
            'CON-401'=>'Presupuestos Empresariales',
            'DER-401'=>'Legislación Comercial',
            'COM-401'=>'Comercio Internacional',
            'ARQ-401'=>'Construcción Sustentable',
            'CIV-401'=>'Geotecnia Aplicada',
            'PSI-401'=>'Evaluación Psicológica',
            'MKT-401'=>'Comunicación Digital',
            'IND-401'=>'Gestión de Producción',
            'PR-201'=>'Programación II',
            'ADM-501'=>'Administración de Proyectos',
            'CON-501'=>'Tributación Aplicada',
            'DER-501'=>'Derecho Corporativo',
            'COM-501'=>'Gestión de Ventas'
        ];
        $prefijosPorCarrera = [1=>['BD','PR','WEB','MAT','SW','RED','ING'],2=>['ADM'],3=>['CON'],4=>['DER'],5=>['COM'],6=>['ARQ'],7=>['CIV'],8=>['PSI'],9=>['MKT'],10=>['IND']];
        $nombre = trim((string)$_POST['nombre_curso']);
        $codigo = strtoupper(trim((string)$_POST['codigo']));
        $carrera = (int)($_POST['id_carrera'] ?? 0);
        if(!preg_match('/^\p{L}+(?:[ \p{L}]+)*(?: [IVX]+)?$/u',$nombre)) throw new RuntimeException('El nombre del curso debe ser un nombre académico válido.');
        if(!validar_codigo_curso($codigo)) throw new RuntimeException('El código debe tener formato SIGLA-000, por ejemplo BD-101.');
        if($carrera<=0 || !isset($prefijosPorCarrera[$carrera])) throw new RuntimeException('Selecciona una carrera válida.');
        $prefijo = explode('-', $codigo, 2)[0];
        if(!in_array($prefijo,$prefijosPorCarrera[$carrera],true)) throw new RuntimeException('La sigla del código no corresponde a la carrera seleccionada.');
        if(!isset($catalogo[$codigo])) throw new RuntimeException('Selecciona un código del catálogo académico disponible.');
        if($catalogo[$codigo] !== $nombre) throw new RuntimeException('El nombre no corresponde al código académico seleccionado.');
        $semestre=trim((string)($_POST['semestre']??''));if($semestre!==''&&(!ctype_digit($semestre)||(int)$semestre<1||(int)$semestre>20))throw new RuntimeException('El semestre del curso debe estar entre 1 y 20.');
        if(!validar_descripcion_coherente((string)($_POST['descripcion']??''), 20))throw new RuntimeException('La descripción debe explicar el contenido del curso en una frase de al menos 4 palabras; no uses texto de prueba.');
        if($id)$m->editar($id,$_POST);else$m->crear($_POST);flash('success',$id?'Curso actualizado.':'Curso creado.');redir('/controllers/cursos.php');
    }catch(Throwable $e){$formError=$e->getMessage();$accion=$id>0?'editar':'crear';}
}
$busqueda=trim((string)($_GET['buscar']??''));$todosLosRegistros=filtrar_registros($m->obtenerTodas(),$busqueda);$paginacion=paginar_registros($todosLosRegistros,(int)($_GET['pagina']??1),10);$registros=$paginacion['registros'];$registro=$id?$m->obtenerPorId($id):null;if($_SERVER['REQUEST_METHOD']==='POST'&&$formError)$registro=array_merge($registro??[],$_POST);$tituloPagina='Cursos';require __DIR__.'/../views/cursos/index.php';
