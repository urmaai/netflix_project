--Нетфликс проект
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix 
(
show_id varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(250)
);

SELECT * FROM  netflix;

SELECT
	COUNT(*) AS total_content
FROM netflix;

SELECT
	DISTINCT type
FROM netflix;

-- 15 бизнес-задач и решений

--1. Подсчитайте количество фильмов и сериалов
SELECT 
	type,
    COUNT(*) AS cnt
FROM netflix
GROUP BY 1;

--2. Найдите наиболее распространенный рейтинг фильмов и сериалов
SELECT 
	type,
	rating
FROM (
SELECT 
	type,
	rating,
    COUNT(*),
	RANK() OVER (PARTITION BY  type ORDER BY COUNT(*) desc) AS ranking
FROM netflix
GROUP BY 1, 2) as t1
WHERE ranking=1
;

--3. Перечислите все фильмы, выпущенные в определенном году (например, 2020)
SELECT *
FROM netflix 
WHERE type='Movie'
AND 
release_year=2020;

-- 4. Найдите 5 стран с наибольшим количеством контента на Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country, 
	COUNT(*) as total_content 
FROM netflix 
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5;

--5. Определите самый длинный фильм
SELECT * FROM netflix
WHERE type='Movie'
AND
duration=(SELECT MAX(duration) FROM netflix);

--6. Найдите контент, добавленный за последние 5 лет
SELECT * FROM netflix
WHERE 
	TO_DATE(date_added, 'Month DD,YYYY')>=CURRENT_DATE-INTERVAL '5 YEARS';

--7. Найдите все фильмы/сериалы режиссера Раджива Чилаки!

SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

--8. Перечислите все сериалы с более чем 5 сезонами
SELECT * FROM netflix
WHERE type='TV Show' 
AND 
SPLIT_PART(duration, ' ',1)::int>5;

--9. Подсчитайте количество контента в каждом жанре
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	COUNT(show_id) AS tot_cnt
FROM netflix
GROUP BY 1;

--10. Найдите каждый год и среднее количество выпущенного контента в Японии на Netflix.
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) AS year,
	COUNT(*) AS yearly_content,
	ROUND(
	COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric*100,2) 
	AS avg_content
FROM netflix
WHERE country='Japan'
GROUP BY 1
ORDER BY 1,2;

--11. Перечислите все документальные фильмы
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';

--12. Найдите весь контент без режиссера
SELECT * FROM netflix
WHERE director IS NULL;

--13. Найдите, в скольких фильмах актер Салман Хан снялся за последние 10 лет!
SELECT * FROM netflix
WHERE casts like '%Salman Khan%'
AND
	release_year>EXTRACT(YEAR FROM CURRENT_DATE)-10

--14. Найдите 10 актеров, которые снялись в наибольшем количестве фильмов, произведенных в Японии.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as cast,
	COUNT(*) AS tot_content
FROM netflix
WHERE country LIKE '%Japan'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--15. Классифицируйте контент на основе наличия ключевых слов «убийство» и «насилие»
--в поле описания. Пометьте контент, содержащий эти ключевые слова, как «Плохой», 
--а весь остальной контент как «Хороший». Подсчитайте, сколько элементов попадает в
--каждую категорию.

WITH new_table 
AS( 
SELECT
  *,
  CASE
    WHEN description ILIKE '%kill%' or description ILIKE '%violence%' THEN 'Bad'
    ELSE 'Good'
  END AS category
FROM netflix)

SELECT 
	category,
	COUNT(*) AS cnt
FROM new_table
GROUP BY 1;


