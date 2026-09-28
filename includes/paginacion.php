<?php
/**
 * Paginación reutilizable para listados del sistema.
 * Devuelve únicamente los registros de la página actual y los metadatos necesarios.
 */
function paginar_registros(array $registros, int $pagina = 1, int $porPagina = 10): array
{
    $porPagina = max(1, $porPagina);
    $total = count($registros);
    $totalPaginas = max(1, (int) ceil($total / $porPagina));
    $pagina = min(max(1, $pagina), $totalPaginas);
    $inicio = ($pagina - 1) * $porPagina;

    return [
        'registros' => array_slice($registros, $inicio, $porPagina),
        'pagina' => $pagina,
        'por_pagina' => $porPagina,
        'total' => $total,
        'total_paginas' => $totalPaginas,
    ];
}

/** Filtra el conjunto completo de registros ANTES de paginar, no solo la página visible. */
function filtrar_registros(array $registros, string $termino): array
{
    $termino = trim($termino);
    if ($termino === '') return $registros;
    $normalizar = static function (string $valor): string {
        return function_exists('mb_strtolower') ? mb_strtolower($valor, 'UTF-8') : strtolower($valor);
    };
    $busqueda = $normalizar($termino);
    return array_values(array_filter($registros, static function ($registro) use ($busqueda, $normalizar): bool {
        $partes = [];
        foreach ((array)$registro as $valor) {
            if (is_scalar($valor) || $valor === null) $partes[] = (string)$valor;
        }
        return strpos($normalizar(implode(' ', $partes)), $busqueda) !== false;
    }));
}
