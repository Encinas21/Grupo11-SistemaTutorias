# Grupo11 – Sistema Web de Apoyo Académico para Tutorías

Sistema académico desarrollado con PHP 8.2, PDO, MySQL 8 y Apache dentro de Docker.

## Stack

- PHP 8.2 + Apache
- PDO + MySQL 8
- Docker Compose
- phpMyAdmin
- FullCalendar por CDN para el calendario
- Dompdf para generación de PDF
- Arquitectura existente: `controllers/` → `models/` → `views/`
- Seguridad centralizada en `includes/seguridad.php`

## Módulos

- Dashboard.
- Estudiantes.
- Profesores.
- Cursos.
- Inscripciones.
- Calificaciones.
- Asistencia.
- Usuarios, roles y carreras.
- Tutorías académicas.
- Calendario mensual/semanal.
- Perfil de tutor.
- Disponibilidad semanal.
- Materias asignadas al tutor.
- Filtros y paginación del servidor.
- Validación de choques de horarios.
- Evaluaciones de tutorías realizadas.
- Exportación de tutoría individual y listado filtrado a PDF.

## Estructura principal

```text
assets/
  css/style.css
  js/app.js

config/
  conexion.php

controllers/
  tutorias.php
  tutorias_api.php
  tutor_perfil.php
  evaluacion_tutoria.php
  tutoria_pdf.php
  ...

database/
  init.sql
  migracion_sistema_v2.sql

models/
  TutoriaModel.php
  TutorModel.php
  ...

views/
  tutorias/index.php
  tutorias/perfil.php
  layouts/header.php
  layouts/footer.php
  ...

Dockerfile
docker-compose.yml
composer.json
README.md
```

## Cómo levantar el proyecto

Desde la carpeta raíz:

```bash
docker compose down -v
docker compose up -d --build
```

El `-v` elimina el volumen de MySQL y hace que `database/00_init_complete.sql` se ejecute desde cero.

Accesos:

```text
Portal:       http://localhost:8004
phpMyAdmin:   http://localhost:8084
MySQL host:   127.0.0.1:3310
```

Credenciales MySQL:

```text
Base:         student_portal_db
Usuario:      student_portal_user
Contraseña:   la definida en `.env`
Root:         root_password
```


## Modalidades de Grado — Fase 0

La Fase 0 incorpora infraestructura y el catálogo base del módulo MG sin alterar el módulo existente de tutorías.

### Configuración

```bash
cp .env.example .env
```

Edita `.env` antes de levantar Docker.

### Migraciones

Después de levantar los servicios:

```bash
docker compose exec web php scripts/migrar.php
```

Para un entorno limpio de desarrollo:

```bash
docker compose down -v
docker compose up -d --build
docker compose exec web php scripts/migrar.php
```

El esquema oficial es `database/00_init_complete.sql`. Las migraciones nuevas se encuentran en `database/migrations/`.

### Usuarios MG de desarrollo

El seed `database/seeds/00_seed_unico.sql` contiene los usuarios `coord_mg` y `auxiliar_mg` con la credencial de desarrollo definida para los datos demo. No usar estas credenciales en producción.

## Usuarios de prueba

Todos utilizan la contraseña:

```text
password
```

| Rol | Usuario | Correo |
|---|---|---|
| Administrador | `admin` | `admin@upds.net.com` |
| Profesor | `docente1` | `docente@upds.net.com` |
| Profesor | `docente2` | `laura@upds.net.com` |
| Estudiante | `estudiante1` | `estudiante@upds.net.com` |
| Estudiante | `estudiante2` | `juan@upds.net.com` |

## Permisos de Tutorías

### Administrador

- Ve todas las tutorías.
- Crea, edita y elimina tutorías.
- Cambia cualquier estado.
- Usa todos los filtros y exportaciones.
- Gestiona materias de cualquier tutor.
- Gestiona disponibilidad de cualquier tutor.
- Ve perfiles y reseñas.
- Puede eliminar reseñas.

### Profesor

- Ve únicamente las tutorías que tiene asignadas como tutor.
- Puede crear tutorías con su propio perfil de tutor.
- Puede editar sus tutorías.
- Puede cambiar su estado, observaciones, modalidad y horario, respetando las validaciones.
- Puede eliminar tutorías pendientes o confirmadas que tenga asignadas.
- Puede gestionar sus materias asignadas.
- Puede gestionar su disponibilidad semanal.
- Puede consultar perfiles y reseñas.

### Estudiante

- Ve únicamente sus propias tutorías.
- Puede solicitar tutorías.
- Puede editar sus solicitudes mientras estén pendientes.
- Puede eliminar sus solicitudes mientras estén pendientes.
- No puede cambiar el estado manualmente.
- Puede consultar perfiles de tutores.
- Puede evaluar una sola vez una tutoría propia cuando pase a `realizada`.
- Puede exportar sus tutorías visibles.

## Calendario

El módulo utiliza FullCalendar desde CDN.

Funciones:

- Vista mensual.
- Vista semanal.
- Vista de lista.
- Eventos coloreados por estado.
- Clic en evento → detalle de tutoría.
- Clic en día/hora vacío → formulario de nueva tutoría con fecha y hora precargadas.
- El calendario respeta el alcance del rol.

## Validación de horarios

La validación principal está en `models/TutoriaModel.php`.

Antes de crear o editar se verifica:

1. La fecha no sea pasada.
2. La hora de fin sea posterior a la hora de inicio.
3. El tutor tenga la materia asignada.
4. El horario esté dentro de `disponibilidad_tutor`.
5. El tutor no tenga otra tutoría `pendiente` o `confirmada` solapada.
6. El estudiante no tenga otra tutoría `pendiente` o `confirmada` solapada.
7. Las tutorías canceladas no bloqueen el horario.
8. Al editar se excluya la propia tutoría.

La condición de solapamiento utilizada es:

```text
inicio_nuevo < fin_existente
AND
fin_nuevo > inicio_existente
```

Si la validación falla, el formulario se vuelve a mostrar conservando lo escrito y muestra el mensaje en español.

## Evaluaciones

Se reutiliza la tabla existente:

```text
evaluaciones_tutoria
```

Reglas:

- Solo tutorías `realizada`.
- Solo el estudiante propietario.
- Una evaluación por tutoría mediante el `UNIQUE` existente.
- Calificación de 1 a 5.
- Comentario opcional.
- El administrador puede eliminar la evaluación.
- Las evaluaciones aparecen en la tabla de tutorías y en el perfil del tutor.

## PDF

Se incorporó Dompdf mediante Composer.

`composer.json` declara:

```text
dompdf/dompdf
```

El `Dockerfile` instala Composer y ejecuta automáticamente:

```bash
composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader
```

No es necesario instalar `vendor/` manualmente ni versionarlo.

Se pueden generar:

- Constancia/detalle de una tutoría.
- Listado de tutorías respetando los filtros activos.

Los PDF incluyen:

- Nombre del sistema.
- Color principal `#018abd`.
- Fecha de generación.
- Alcance de datos según el rol.

## Codificación UTF-8

La aplicación utiliza `utf8mb4` de extremo a extremo:

- MySQL con `utf8mb4`.
- `SET NAMES utf8mb4` en `database/00_init_complete.sql`.
- `SET NAMES utf8mb4` en la conexión PDO.
- `--character-set-server=utf8mb4` en Docker.
- `<meta charset="utf-8">` en las vistas.
- `htmlspecialchars(..., ENT_QUOTES, 'UTF-8')` mediante `e()`.

### Si la base ya existe

Desde Git Bash, WSL o una terminal compatible con redirección:

```bash
docker compose exec -T web php scripts/migrar.php
```

En PowerShell:

```powershell
docker compose exec -T web php scripts/migrar.php
```

La migración convierte las tablas a `utf8mb4` y agrega los datos de prueba del módulo de tutorías.

### Configuración de entorno\n\nCopia `.env.example` como `.env` y cambia las contraseñas antes de levantar Docker. El proyecto no contiene credenciales por defecto.\n\n### Si los datos anteriores ya están dañados por una codificación incorrecta

Para un entorno de desarrollo donde se pueda reconstruir todo:

```bash
docker compose down -v
docker compose up -d --build
```

Esto vuelve a cargar `database/00_init_complete.sql` con UTF-8 correcto.

## Pruebas rápidas

### Administrador

1. Iniciar sesión con `admin`.
2. Abrir `Tutorías`.
3. Comprobar calendario.
4. Probar vista mensual y semanal.
5. Probar filtros.
6. Comprobar paginación.
7. Abrir el perfil de un tutor.
8. Agregar/quitar una materia.
9. Agregar/eliminar disponibilidad.
10. Crear una tutoría válida.
11. Intentar crear un choque de horario.
12. Editar el estado a `realizada`.
13. Ver una reseña.
14. Eliminar una reseña.
15. Descargar PDF individual y listado.

### Profesor

1. Iniciar sesión con `docente1`.
2. Abrir `Tutorías`.
3. Verificar que solo aparezcan sus tutorías.
4. Abrir una tutoría y editarla.
5. Crear una tutoría como su propio tutor.
6. Gestionar disponibilidad desde su perfil.
7. Gestionar sus materias.
8. Cambiar una tutoría a `realizada`.
9. Descargar PDF de una tutoría visible.
10. Intentar acceder a un tutor diferente cambiando `?id=` y comprobar que no pueda gestionarlo.

### Estudiante

1. Iniciar sesión con `estudiante1`.
2. Abrir `Mis tutorías`.
3. Comprobar que solo aparecen sus tutorías.
4. Solicitar una nueva tutoría.
5. Intentar crear una fecha pasada.
6. Intentar crear un horario fuera de disponibilidad.
7. Intentar crear un choque.
8. Editar una solicitud pendiente.
9. Abrir una tutoría realizada.
10. Registrar una reseña de 1 a 5 estrellas.
11. Intentar evaluarla nuevamente.
12. Consultar el perfil del tutor.
13. Descargar el listado filtrado.

## Git

Después de comprobar el proyecto:

```bash
git status
git add .
git commit -m "Extender módulo de tutorías con calendario filtros perfiles reseñas y PDF"
git push origin main
```

Si el repositorio remoto todavía no está configurado:

```bash
git remote -v
git remote add origin https://github.com/TU_USUARIO/TU_REPOSITORIO.git
git branch -M main
git push -u origin main
```

El contenedor utiliza un volumen Docker separado para `/var/www/html/vendor`, así el bind mount del código no oculta las dependencias instaladas. No se debe subir `vendor/` porque continúa excluido por `.gitignore`.


## Actualización v2 — perfil, tutorías y datos demo

Esta versión incorpora:
- Perfil de estudiante/docente en modo solo lectura; únicamente el administrador puede editar su propio perfil desde Perfil.
- Tutorías por espacios mensuales con tres horarios fijos: 09:00–11:00, 15:00–18:00 y 19:00–22:00.
- El docente publica espacios; el estudiante solicita unirse; el administrador recibe la notificación y acepta/rechaza.
- El aula se obtiene automáticamente de la materia; ya no se solicitan observaciones, lugar ni enlace.
- El administrador consulta calificaciones sin acciones de editar/eliminar.
- Teléfonos validados a exactamente 8 dígitos y usuarios nuevos con prefijo `estudiante` o `docente`.
- Datos demo: 50 estudiantes, 15 docentes y más carreras.

### Si ya tienes un volumen MySQL
Después de reemplazar los archivos del proyecto, ejecuta desde PowerShell:

```powershell
docker compose exec -T web php scripts/migrar.php
docker compose exec -T web php scripts/migrar.php
```

No hace falta borrar el volumen si quieres conservar tus datos. Para una instalación completamente nueva, `docker compose down -v` y luego `docker compose up -d --build` ejecutarán `init.sql` y el seed demo automáticamente.

## Actualización de base de datos – Tutorías v2

Si la base de datos ya existía antes de esta versión, ejecutar dentro del proyecto:

```powershell
docker compose exec -T web php scripts/migrar.php
```

Esta migración agrega, entre otros cambios, `materias.aula`, que es utilizada por el módulo Tutorías para obtener automáticamente el aula de cada materia.

## Modalidades de Grado — Fase 1 (HU-023 a HU-027)

- Importación de padrón MG por CSV con previsualización y confirmación segura.
- Expedientes MG con filtros, ficha, etapas y registro de ingreso a MG2.
- Asignación/cambio de Tutor con historial, consulta de disponibilidad, advertencia de carga y notificaciones.
- Cartas de asignación con plantilla provisional editable en base de datos, correlativo por tipo/año y snapshot para reimpresión.
- Ejemplo CSV: `database/seeds/ejemplo_padron.csv`.
- Migraciones: `010_mg_expedientes.sql` y `011_mg_asignaciones.sql`.

Para ejecutar migraciones dentro de Docker:

```bash
docker compose exec web php scripts/migrar.php
```

Aplicación local: `http://localhost:8004`.


## Docker en Windows

La aplicación web no utiliza un bind mount del directorio del proyecto. El código se incluye en la imagen durante `docker compose build`, evitando errores de Docker Desktop al montar proyectos ubicados en unidades como `D:`.

## Fase 3 — seguimiento MG

Rutas principales: `/controllers/mg_reuniones.php`, `/controllers/mg_informes.php`, `/controllers/mg_calendario_hitos.php`, `/controllers/mg_alertas.php`, `/controllers/mg_dashboard.php` y `/controllers/mg_bitacora.php`.

Migraciones nuevas: `013_mg_seguimiento.sql` y `014_mg_bitacora.sql`.

## Estado de entrega MG — estabilización final

- HU-019 a HU-040 implementadas dentro del alcance P1/P2.
- P3 queda expresamente fuera de alcance, solo documentado.
- Puerto web: `8004`.
- phpMyAdmin: `8084`.
- MySQL host: `3310`.
- Migraciones: `009` a `015`.
- `015_mg_seed_demo.sql` carga datos demo MG completos e idempotentes.
- Los seeds MG duplicados fueron movidos a `database/obsoleto/`.
- El proyecto no requiere bind mount de `D:\Documentos\Proyecto-Final`; el código se copia a la imagen Docker.

### Puesta en marcha

```powershell
Copy-Item .env.example .env
# editar .env y definir DB_PASS / MYSQL_ROOT_PASSWORD

docker compose down
docker compose up -d --build
docker compose exec web php scripts/migrar.php

docker compose ps
```

Aplicación: `http://localhost:8004`  
phpMyAdmin: `http://localhost:8084`

### Datos demo

Las cuentas de desarrollo existentes usan la contraseña `password` salvo que el administrador local las haya cambiado. El seed MG final usa usuarios existentes `estudiante1..6`, tutores basados en `docente3..5`, y las cuentas `coord_mg` / `auxiliar_mg`.

**No subir `.env` a GitHub.**
