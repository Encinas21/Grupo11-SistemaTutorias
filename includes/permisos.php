<?php
declare(strict_types=1);

require_once __DIR__ . '/seguridad.php';

/**
 * Permisos MG [PROPUESTA].
 * Se mantienen agrupados por rol para no crear tablas de permisos en este MVP.
 */
function permisos_mg_por_rol(): array
{
    return [
        'administrador' => [
            'mg.parametros.ver', 'mg.parametros.editar',
            'mg.cohortes.ver', 'mg.cohortes.editar',
            'mg.calendario.ver', 'mg.calendario.editar',
            'mg.modalidades.ver', 'mg.modalidades.editar',
            'mg.expedientes.ver', 'mg.expedientes.crear', 'mg.expedientes.editar', 'mg.expedientes.importar',
            'mg.tutores.asignar', 'mg.documentos.ver',
            'mg.tribunales.editar','mg.defensas.ver','mg.defensas.editar','mg.calificaciones.ver','mg.calificaciones.editar','mg.reportes.ver','mg.reportes.estudiante', 'mg.documentos.generar', 'mg.plantillas.editar',
            'mg.reuniones.ver','mg.reuniones.editar','mg.reuniones.validar','mg.informes.ver','mg.informes.editar','mg.alertas.ver','mg.dashboard.ver','mg.bitacora.ver',
        ],
        'coordinador_mg' => [
            'mg.parametros.ver', 'mg.parametros.editar',
            'mg.cohortes.ver', 'mg.cohortes.editar',
            'mg.calendario.ver', 'mg.calendario.editar',
            'mg.modalidades.ver', 'mg.modalidades.editar',
            'mg.expedientes.ver', 'mg.expedientes.crear', 'mg.expedientes.editar', 'mg.expedientes.importar',
            'mg.tutores.asignar', 'mg.documentos.ver', 'mg.documentos.generar', 'mg.plantillas.editar',
            'mg.tribunales.editar','mg.defensas.ver','mg.defensas.editar','mg.calificaciones.ver','mg.calificaciones.editar','mg.reportes.ver','mg.reportes.estudiante',
            'mg.reuniones.ver','mg.reuniones.editar','mg.reuniones.validar','mg.informes.ver','mg.informes.editar','mg.alertas.ver','mg.dashboard.ver','mg.bitacora.ver',
        ],
        'auxiliar_mg' => [
            'mg.parametros.ver',
            'mg.cohortes.ver',
            'mg.calendario.ver',
            'mg.modalidades.ver',
            'mg.expedientes.ver', 'mg.expedientes.crear', 'mg.expedientes.importar', 'mg.documentos.ver',
            'mg.defensas.ver','mg.calificaciones.ver','mg.reportes.estudiante',
            'mg.reuniones.ver','mg.reuniones.editar','mg.reuniones.validar','mg.informes.ver','mg.informes.editar','mg.alertas.ver','mg.dashboard.ver','mg.reportes.ver',
        ],
        'docente' => [
            'mg.cohortes.ver',
            'mg.calendario.ver',
            'mg.modalidades.ver',
            'mg.expedientes.ver', 'mg.documentos.ver', 'mg.defensas.ver','mg.calificaciones.ver','mg.reportes.estudiante',
            'mg.reuniones.ver','mg.reuniones.editar','mg.informes.ver','mg.informes.editar',
        ],
        'estudiante' => [
            'mg.cohortes.ver',
            'mg.calendario.ver',
            'mg.modalidades.ver',
            'mg.expedientes.ver', 'mg.documentos.ver', 'mg.defensas.ver','mg.calificaciones.ver','mg.reportes.estudiante',
            'mg.reuniones.ver','mg.informes.ver',
        ],
    ];
}

function tiene_permiso(string $permiso): bool
{
    $rol = user_role();
    return in_array($permiso, permisos_mg_por_rol()[$rol] ?? [], true);
}

function estudiante_puede_modalidad_grado(): bool
{
    if (user_role() !== 'estudiante') return true;
    global $pdo;
    try {
        $s = $pdo->prepare("SELECT estado_academico FROM estudiantes WHERE id_usuario=? LIMIT 1");
        $s->execute([(int)($_SESSION['id_usuario'] ?? 0)]);
        return in_array((string)$s->fetchColumn(), ['egresado', 'titulado'], true);
    } catch (Throwable $e) {
        try {
            $s = $pdo->prepare("SELECT e.semestre, SUM(i.estado='activa') activos FROM estudiantes e LEFT JOIN inscripciones i ON i.id_estudiante=e.id_estudiante WHERE e.id_usuario=? GROUP BY e.id_estudiante,e.semestre");
            $s->execute([(int)($_SESSION['id_usuario'] ?? 0)]);
            $r = $s->fetch(PDO::FETCH_ASSOC) ?: [];
            return (int)($r['semestre'] ?? 0) >= 9 && (int)($r['activos'] ?? 0) === 0;
        } catch (Throwable $ignored) {
            return false;
        }
    }
}

function requerir_permiso(string $permiso): void
{
    require_login();
    if (str_starts_with($permiso, 'mg.') && user_role() === 'estudiante' && !estudiante_puede_modalidad_grado()) {
        redir('/views/errores/acceso_denegado.php');
    }
    if (!tiene_permiso($permiso)) {
        redir('/views/errores/acceso_denegado.php');
    }
}
