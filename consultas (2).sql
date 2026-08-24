-- =====================================================================
-- DataProject: Lógica de Consultas SQL
-- Base de datos: Sakila / Shakila (tienda de alquiler de películas)
-- Motor: PostgreSQL (adaptado a partir del dump BBDD_Proyecto_shakila_sinuser.sql)
-- =====================================================================
-- Tablas principales usadas: actor, film, category, film_actor,
-- film_category, language, inventory, rental, payment, customer,
-- staff, store
-- =====================================================================


-- 1. Crea el esquema de la BBDD.
-- El esquema se crea ejecutando el script proporcionado por el
-- enunciado (BBDD_Proyecto_shakila_sinuser.sql), que contiene las
-- sentencias CREATE DATABASE / CREATE TABLE / INSERT de todas las
-- tablas de Sakila. Simplemente hay que importarlo en el gestor SQL:
--     mysql -u usuario -p < BBDD_Proyecto_shakila_sinuser.sql
-- (o usar la opción "Import" del cliente gráfico que se esté usando).


-- 2. Nombres de todas las películas con clasificación 'R'.
SELECT title
FROM film
WHERE rating = 'R';


-- 3. Nombres de los actores con actor_id entre 30 y 40.
SELECT first_name, last_name
FROM actor
WHERE actor_id BETWEEN 30 AND 40;


-- 4. Películas cuyo idioma coincide con el idioma original.
SELECT *
FROM film
WHERE language_id = original_language_id;


-- 5. Películas ordenadas por duración de forma ascendente.
SELECT title, length
FROM film
ORDER BY length ASC;


-- 6. Nombre y apellido de los actores con 'Allen' en su apellido.
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%Allen%';


-- 7. Cantidad total de películas por clasificación.
SELECT rating, COUNT(*) AS total_peliculas
FROM film
GROUP BY rating;


-- 8. Título de películas 'PG-13' o con duración mayor a 3 horas (180 min).
SELECT title
FROM film
WHERE rating = 'PG-13' OR length > 180;


-- 9. Variabilidad (varianza) del coste de reemplazo de las películas.
SELECT VARIANCE(replacement_cost) AS variabilidad_reemplazo
FROM film;


-- 10. Mayor y menor duración de una película.
SELECT MAX(length) AS duracion_maxima, MIN(length) AS duracion_minima
FROM film;


-- 11. Coste del antepenúltimo alquiler ordenado por fecha (día).
SELECT p.amount
FROM rental r
JOIN payment p ON p.rental_id = r.rental_id
ORDER BY r.rental_date DESC
LIMIT 1 OFFSET 2;


-- 12. Título de películas que NO son ni 'NC-17' ni 'G'.
SELECT title
FROM film
WHERE rating NOT IN ('NC-17', 'G');


-- 13. Promedio de duración de las películas por clasificación.
SELECT rating, AVG(length) AS promedio_duracion
FROM film
GROUP BY rating;


-- 14. Título de películas con duración mayor a 180 minutos.
SELECT title
FROM film
WHERE length > 180;


-- 15. Dinero total generado por la empresa.
SELECT SUM(amount) AS ingresos_totales
FROM payment;


-- 16. 10 clientes con mayor valor de id.
SELECT *
FROM customer
ORDER BY customer_id DESC
LIMIT 10;


-- 17. Nombre y apellido de los actores de la película 'Egg Igby'.
SELECT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON f.film_id = fa.film_id
WHERE f.title = 'Egg Igby';


-- 18. Todos los nombres de películas únicos.
SELECT DISTINCT title
FROM film;


-- 19. Título de comedias con duración mayor a 180 minutos.
SELECT f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON c.category_id = fc.category_id
WHERE c.name = 'Comedy' AND f.length > 180;


-- 20. Categorías con promedio de duración superior a 110 minutos.
SELECT c.name AS categoria, AVG(f.length) AS promedio_duracion
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
HAVING AVG(f.length) > 110;


-- 21. Media de duración del alquiler de las películas (rental_duration, en días).
SELECT AVG(rental_duration) AS media_duracion_alquiler
FROM film;


-- 22. Columna con nombre y apellidos de todos los actores.
SELECT CONCAT(first_name, ' ', last_name) AS nombre_completo
FROM actor;


-- 23. Número de alquileres por día, ordenados de forma descendente.
SELECT DATE(rental_date) AS dia, COUNT(*) AS numero_alquileres
FROM rental
GROUP BY DATE(rental_date)
ORDER BY numero_alquileres DESC;


-- 24. Películas con duración superior al promedio.
SELECT title, length
FROM film
WHERE length > (SELECT AVG(length) FROM film);


-- 25. Número de alquileres registrados por mes.
SELECT TO_CHAR(rental_date, 'YYYY-MM') AS mes, COUNT(*) AS numero_alquileres
FROM rental
GROUP BY TO_CHAR(rental_date, 'YYYY-MM')
ORDER BY mes;


-- 26. Promedio, desviación estándar y varianza del total pagado.
SELECT
    AVG(amount)      AS promedio_pagado,
    STDDEV(amount)   AS desviacion_estandar,
    VARIANCE(amount) AS varianza
FROM payment;


-- 27. Películas que se alquilan por encima del precio medio (rental_rate).
SELECT title, rental_rate
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film);


-- 28. Id de actores que han participado en más de 40 películas.
SELECT actor_id, COUNT(film_id) AS num_peliculas
FROM film_actor
GROUP BY actor_id
HAVING COUNT(film_id) > 40;


-- 29. Todas las películas y, si están disponibles en inventario, la cantidad disponible.
SELECT f.title, COUNT(i.inventory_id) AS cantidad_disponible
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
GROUP BY f.film_id, f.title;


-- 30. Actores y número de películas en las que ha actuado.
SELECT a.first_name, a.last_name, COUNT(fa.film_id) AS numero_peliculas
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name;


-- 31. Todas las películas y los actores que han actuado en ellas,
--     incluso si alguna película no tiene actores asociados.
SELECT f.title, a.first_name, a.last_name
FROM film f
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
LEFT JOIN actor a ON fa.actor_id = a.actor_id;


-- 32. Todos los actores y las películas en las que han actuado,
--     incluso si algún actor no ha actuado en ninguna película.
SELECT a.first_name, a.last_name, f.title
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
LEFT JOIN film f ON fa.film_id = f.film_id;


-- 33. Todas las películas y todos los registros de alquiler (FULL OUTER JOIN).
-- PostgreSQL sí soporta FULL OUTER JOIN de forma nativa.
SELECT f.title, r.rental_id, r.rental_date
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
FULL OUTER JOIN rental r ON i.inventory_id = r.inventory_id;


-- 34. Los 5 clientes que más dinero se han gastado con nosotros.
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS total_gastado
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_gastado DESC
LIMIT 5;


-- 35. Todos los actores cuyo primer nombre es 'Johnny'.
SELECT *
FROM actor
WHERE first_name = 'Johnny';


-- 36. Renombra la columna "first_name" como Nombre y "last_name" como Apellido.
SELECT first_name AS Nombre, last_name AS Apellido
FROM actor;


-- 37. ID del actor más bajo y más alto en la tabla actor.
SELECT MIN(actor_id) AS id_minimo, MAX(actor_id) AS id_maximo
FROM actor;


-- 38. Cuántos actores hay en la tabla "actor".
SELECT COUNT(*) AS total_actores
FROM actor;


-- 39. Todos los actores ordenados por apellido en orden ascendente.
SELECT *
FROM actor
ORDER BY last_name ASC;


-- 40. Primeras 5 películas de la tabla "film".
SELECT *
FROM film
LIMIT 5;


-- 41. Actores agrupados por nombre, contando cuántos actores tienen el mismo nombre.
SELECT first_name, COUNT(*) AS cantidad
FROM actor
GROUP BY first_name
ORDER BY cantidad DESC;

-- El nombre más repetido es el primero del resultado anterior;
-- para obtenerlo directamente:
SELECT first_name, COUNT(*) AS cantidad
FROM actor
GROUP BY first_name
ORDER BY cantidad DESC
LIMIT 1;


-- 42. Todos los alquileres y los nombres de los clientes que los realizaron.
SELECT r.*, c.first_name, c.last_name
FROM rental r
JOIN customer c ON r.customer_id = c.customer_id;


-- 43. Todos los clientes y sus alquileres si existen (incluyendo los que no tienen).
SELECT c.first_name, c.last_name, r.rental_id, r.rental_date
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id;


-- 44. CROSS JOIN entre las tablas film y category.
SELECT f.title, c.name AS categoria
FROM film f
CROSS JOIN category c;

-- ¿Aporta valor esta consulta? ¿Por qué?
-- No, esta consulta no aporta valor analítico real. El CROSS JOIN genera
-- el producto cartesiano entre todas las películas y todas las categorías,
-- es decir, combina cada película con TODAS las categorías existan o no
-- relación real entre ellas (una película con su categoría real, y también
-- con categorías a las que no pertenece). El resultado es un conjunto de
-- combinaciones sin sentido de negocio y de tamaño innecesariamente grande
-- (nº de películas x nº de categorías). Es útil únicamente con fines
-- didácticos para entender qué es un producto cartesiano, pero para
-- obtener la categoría real de cada película se debe usar un JOIN a
-- través de la tabla intermedia film_category.


-- 45. Actores que han participado en películas de la categoría 'Action'.
SELECT DISTINCT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film_category fc ON fa.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Action';


-- 46. Actores que no han participado en ninguna película.
SELECT a.first_name, a.last_name
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.film_id IS NULL;


-- 47. Nombre de los actores y la cantidad de películas en las que han participado.
SELECT a.first_name, a.last_name, COUNT(fa.film_id) AS cantidad_peliculas
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name;


-- 48. Vista "actor_num_peliculas" con los nombres de los actores y el
--     número de películas en las que han participado.
CREATE OR REPLACE VIEW actor_num_peliculas AS
SELECT a.actor_id, a.first_name, a.last_name, COUNT(fa.film_id) AS numero_peliculas
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name;

-- Consulta de ejemplo sobre la vista:
-- SELECT * FROM actor_num_peliculas;


-- 49. Número total de alquileres realizados por cada cliente.
SELECT customer_id, COUNT(*) AS total_alquileres
FROM rental
GROUP BY customer_id;


-- 50. Duración total de las películas en la categoría 'Action'.
SELECT SUM(f.length) AS duracion_total
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Action';


-- 51. Tabla temporal "cliente_rentas_temporal" con el total de alquileres por cliente.
CREATE TEMPORARY TABLE cliente_rentas_temporal AS
SELECT customer_id, COUNT(*) AS total_alquileres
FROM rental
GROUP BY customer_id;

-- SELECT * FROM cliente_rentas_temporal;


-- 52. Tabla temporal "peliculas_alquiladas" con las películas alquiladas al menos 10 veces.
CREATE TEMPORARY TABLE peliculas_alquiladas AS
SELECT f.film_id, f.title, COUNT(r.rental_id) AS veces_alquilada
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
HAVING COUNT(r.rental_id) >= 10;

-- SELECT * FROM peliculas_alquiladas;


-- 53. Títulos de películas alquiladas por 'Tammy Sanders' que aún no se han
--     devuelto, ordenados alfabéticamente por título.
SELECT f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN customer c ON r.customer_id = c.customer_id
WHERE c.first_name = 'Tammy'
  AND c.last_name = 'Sanders'
  AND r.return_date IS NULL
ORDER BY f.title ASC;


-- 54. Nombres de actores que han actuado en al menos una película de la
--     categoría 'Sci-Fi', ordenados alfabéticamente por apellido.
SELECT DISTINCT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film_category fc ON fa.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Sci-Fi'
ORDER BY a.last_name ASC;


-- 55. Nombre y apellido de actores que han actuado en películas alquiladas
--     después de que 'Spartacus Cheaper' se alquilara por primera vez,
--     ordenados alfabéticamente por apellido.
SELECT DISTINCT a.first_name, a.last_name
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_date > (
    SELECT MIN(r2.rental_date)
    FROM rental r2
    JOIN inventory i2 ON r2.inventory_id = i2.inventory_id
    JOIN film f2 ON i2.film_id = f2.film_id
    WHERE f2.title = 'Spartacus Cheaper'
)
ORDER BY a.last_name ASC;


-- 56. Nombre y apellido de actores que NO han actuado en ninguna película
--     de la categoría 'Music'.
SELECT a.first_name, a.last_name
FROM actor a
WHERE a.actor_id NOT IN (
    SELECT fa.actor_id
    FROM film_actor fa
    JOIN film_category fc ON fa.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
    WHERE c.name = 'Music'
);


-- 57. Título de todas las películas que fueron alquiladas por más de 8 días.
SELECT DISTINCT f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.return_date IS NOT NULL
  AND (r.return_date::date - r.rental_date::date) > 8;


-- 58. Título de todas las películas que son de la misma categoría que 'Animation'.
SELECT f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Animation';


-- 59. Nombres de películas con la misma duración que 'Dancing Fever',
--     ordenados alfabéticamente por título.
SELECT title
FROM film
WHERE length = (SELECT length FROM film WHERE title = 'Dancing Fever')
  AND title <> 'Dancing Fever'
ORDER BY title ASC;


-- 60. Nombres de clientes que han alquilado al menos 7 películas distintas,
--     ordenados alfabéticamente por apellido.
SELECT c.first_name, c.last_name
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT i.film_id) >= 7
ORDER BY c.last_name ASC;


-- 61. Cantidad total de películas alquiladas por categoría.
SELECT c.name AS categoria, COUNT(r.rental_id) AS total_alquileres
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY c.name;


-- 62. Número de películas por categoría estrenadas en 2006.
SELECT c.name AS categoria, COUNT(f.film_id) AS numero_peliculas
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
WHERE f.release_year = 2006
GROUP BY c.name;


-- 63. Todas las combinaciones posibles de trabajadores con las tiendas.
SELECT s.first_name, s.last_name, st.store_id
FROM staff s
CROSS JOIN store st;


-- 64. Cantidad total de películas alquiladas por cada cliente, mostrando
--     ID del cliente, su nombre y apellido junto con la cantidad de
--     películas alquiladas.
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS cantidad_peliculas_alquiladas
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;
