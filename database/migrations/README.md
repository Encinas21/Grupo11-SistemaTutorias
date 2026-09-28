# Migraciones

Los archivos SQL de esta carpeta se ejecutan en orden lexicográfico mediante `scripts/migrar.php`.

Las migraciones históricas que ya están incluidas en `database/00_init_complete.sql` no se vuelven a ejecutar. Las nuevas migraciones del módulo Modalidades de Grado se incorporarán como `009_...sql` a `014_...sql`.

### 013_mg_seguimiento.sql
Reuniones, informes de avance y alertas atendidas.

### 014_mg_bitacora.sql
Asegura la tabla de auditoría MG; la tabla también se crea tempranamente en 009 para soportar auditoría desde P0.
