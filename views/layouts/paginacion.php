<?php if (!empty($paginacion) && $paginacion['total_paginas'] > 1): ?>
    <div class="pagination-summary">
        Mostrando <?= (int) min(($paginacion['pagina'] - 1) * $paginacion['por_pagina'] + 1, $paginacion['total']) ?>–<?= (int) min($paginacion['pagina'] * $paginacion['por_pagina'], $paginacion['total']) ?> de <?= (int) $paginacion['total'] ?> registros
    </div>
    <nav class="pagination" aria-label="Paginación de registros">
        <?php $parametrosPaginacion = []; if (!empty($busqueda)) $parametrosPaginacion['buscar'] = $busqueda; ?>
        <?php if ($paginacion['pagina'] > 1): ?>
            <?php $parametrosPaginacion['pagina'] = $paginacion['pagina'] - 1; ?>
            <a class="btn btn-light btn-sm" href="?<?= e(http_build_query($parametrosPaginacion)) ?>">← Anterior</a>
        <?php endif; ?>
        <?php
        $inicioPagina = max(1, $paginacion['pagina'] - 2);
        $finPagina = min($paginacion['total_paginas'], $paginacion['pagina'] + 2);
        for ($n = $inicioPagina; $n <= $finPagina; $n++):
        ?>
            <?php $parametrosPaginacion['pagina'] = $n; ?>
            <a class="btn <?= $n === $paginacion['pagina'] ? 'btn-primary' : 'btn-light' ?> btn-sm" href="?<?= e(http_build_query($parametrosPaginacion)) ?>"><?= $n ?></a>
        <?php endfor; ?>
        <?php if ($paginacion['pagina'] < $paginacion['total_paginas']): ?>
            <?php $parametrosPaginacion['pagina'] = $paginacion['pagina'] + 1; ?>
            <a class="btn btn-light btn-sm" href="?<?= e(http_build_query($parametrosPaginacion)) ?>">Siguiente →</a>
        <?php endif; ?>
    </nav>
<?php endif; ?>
