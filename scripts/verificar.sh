#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
find . -path './vendor' -prune -o -name '*.php' -type f -print0 | xargs -0 -n1 php -l
php -r '
$a=file_get_contents("database/init.sql");
$b=file_get_contents("database/00_init_complete.sql");
if ($a !== $b) { fwrite(STDERR,"FALLA: init.sql y 00_init_complete.sql difieren\\n"); exit(1); }
$ta=preg_match_all("/^CREATE TABLE(?: IF NOT EXISTS)?/mi",$a);
$tb=preg_match_all("/^CREATE TABLE(?: IF NOT EXISTS)?/mi",$b);
if ($ta !== $tb) { fwrite(STDERR,"FALLA: cantidad de tablas diferente\\n"); exit(1); }
echo "OK: init.sql y 00_init_complete.sql idénticos; tablas declaradas: {$ta}\\n";
'
echo 'OK: verificación estática completada.'
