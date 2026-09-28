# Plan de pruebas Fase 0 MG

## HU-020 — Parámetros [P0]
1. Iniciar sesión como `admin` o usuario `coord_mg`.
2. Abrir Parámetros MG.
3. Verificar clave, valor, fuente y estado de evidencia.
4. Cambiar un valor numérico y guardar.
5. Revisar que la bitácora reciba la operación.
6. Intentar guardar texto en un parámetro numérico.
7. Resultado esperado: se rechaza en servidor.
8. Iniciar sesión como `auxiliar_mg`.
9. Resultado esperado: puede consultar, pero no guardar.

## HU-021 — Roles y permisos [P0]
1. Iniciar sesión con `coord_mg`: debe aparecer el grupo Modalidades de Grado.
2. Iniciar sesión con `auxiliar_mg`: debe aparecer el grupo MG sin parámetros editables.
3. Como auxiliar, intentar enviar un POST de edición de parámetros con CSRF válido.
4. Resultado esperado: acceso denegado.
5. Como docente y estudiante, comprobar acceso de solo lectura a cohortes/calendario/modalidades.
6. Como admin, comprobar acceso completo.
7. Probar un POST MG sin CSRF.
8. Resultado esperado: HTTP 419.

## HU-022 — Catálogo, cohortes y calendario [P0]
1. Abrir Modalidades: deben aparecer las cinco modalidades.
2. Confirmar que Examen de Grado y Graduación por Excelencia no requieren Tutor.
3. Crear una cohorte.
4. Editarla.
5. Desactivarla.
6. Crear un hito de tipo `informe`.
7. Crear un segundo hito `informe`.
8. Resultado esperado: el calendario conserva ambos hitos; la cantidad de informes se deriva de los hitos, no de una constante.
9. Intentar acceder al POST de creación como auxiliar.
10. Resultado esperado: acceso denegado.
