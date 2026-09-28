-- Migración V17: muestra la carrera por su nombre, distribuye semestres por avance académico
-- y diversifica las calificaciones de los estudiantes de demostración.
-- Ejecutar una sola vez en la base de datos ya existente.
START TRANSACTION;

-- Cada estudiante pertenece a UNA carrera. El valor id_carrera es una clave interna,
-- no una cantidad de carreras; la interfaz ahora muestra nombre_carrera.
-- Los números de usuario se agrupan por cohortes: 1-10 en semestre 1, 11-20 en semestre 2, etc.
UPDATE estudiantes e
JOIN usuarios u ON u.id_usuario = e.id_usuario
SET e.semestre = MOD(FLOOR((CAST(REGEXP_SUBSTR(u.usuario, '[0-9]+$') AS UNSIGNED) - 1) / 10), 9) + 1
WHERE u.usuario REGEXP '^estudiante[0-9]+$';

-- Diversifica las notas de demostración por estudiante, curso, tipo de evaluación y semestre.
-- El rango se amplía para que no todos tengan notas parecidas; los semestres avanzados tienden
-- a reflejar mayor progreso, pero conservan variación individual.
UPDATE calificaciones cal
JOIN inscripciones i ON i.id_inscripcion = cal.id_inscripcion
JOIN estudiantes e ON e.id_estudiante = i.id_estudiante
JOIN usuarios u ON u.id_usuario = e.id_usuario
SET cal.nota = LEAST(100, 42 + (e.semestre * 4) + MOD(
    CAST(REGEXP_SUBSTR(u.usuario, '[0-9]+$') AS UNSIGNED) * 17
    + i.id_curso * 11
    + CASE cal.tipo
        WHEN 'Parcial 1' THEN 3
        WHEN 'Trabajo práctico' THEN 13
        WHEN 'Parcial 2' THEN 23
        ELSE 31
      END,
    47
))
WHERE u.usuario REGEXP '^estudiante[0-9]+$';

COMMIT;

SELECT e.semestre, COUNT(*) AS cantidad_estudiantes
FROM estudiantes e JOIN usuarios u ON u.id_usuario=e.id_usuario
WHERE u.usuario REGEXP '^estudiante[0-9]+$'
GROUP BY e.semestre ORDER BY e.semestre;

SELECT MIN(nota) AS nota_minima, ROUND(AVG(nota),1) AS promedio_general, MAX(nota) AS nota_maxima
FROM calificaciones;
