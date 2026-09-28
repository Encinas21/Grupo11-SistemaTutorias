# Plan de pruebas HU-019

## HU-019-a/b [CONFIRMADO]
1. Abrir Tutorías como administrador.
2. Abrir consola del navegador.
3. Comprobar que el calendario carga sin errores JS.
4. Comprobar filtros de fecha.
5. Verificar que los estados, incluido `cancelada`, no estén duplicados.

## HU-019-c/d [CONFIRMADO]
1. Revisar perfil de tutor.
2. Confirmar que no existe formulario de subida de fotografía.
3. Resultado esperado: no se implementa flujo de fotografías.

## HU-019-e [CONFIRMADO]
1. Crear `.env` desde `.env.example`.
2. Levantar Docker.
3. Confirmar conexión a MySQL.
4. Renombrar temporalmente `DB_PASS` a otra variable y reiniciar PHP.
5. Resultado esperado: la aplicación muestra configuración incompleta y no usa una contraseña por defecto.

## HU-019-f/g [CONFIRMADO]
1. Levantar una base nueva con `docker compose down -v && docker compose up -d --build`.
2. Ejecutar `docker compose exec web php scripts/migrar.php`.
3. Resultado esperado: el runner conecta y registra/aplica únicamente migraciones pendientes.
4. Ejecutar de nuevo: las ya aplicadas deben aparecer como omitidas.

## HU-019-h [CONFIRMADO]
Comprobar:
- Portal: `http://localhost:8004`
- phpMyAdmin: `http://localhost:8084`
- MySQL: `127.0.0.1:3310`
