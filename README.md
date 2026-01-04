![Netflix](netflix.jpg)

# Netflix SQL Analytics Project

Данный проект представляет собой аналитическое исследование каталога Netflix с использованием SQL.  
Цель проекта — продемонстрировать практические навыки работы с реляционными данными, а также умение решать типовые бизнес-задачи, возникающие в аналитике данных.

В рамках проекта анализируется информация о фильмах и сериалах, представленных на платформе Netflix, включая:
- тип контента (фильм или сериал),
- страну производства,
- год выпуска и дату добавления,
- жанры и рейтинги,
- режиссёров и актёрский состав,
- текстовые описания контента.

## 📊 Структура данных

```sql
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix (
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
```

##  📈 Бизнес-задачи и SQL-решения

### 1. Количество фильмов и сериалов

```sql
SELECT type, COUNT(*) AS cnt
FROM netflix
GROUP BY 1;
```
### 2. Наиболее распространённый рейтинг фильмов и сериалов
```sql
SELECT type, rating
FROM (
    SELECT type, rating, COUNT(*) AS cnt,
           RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY 1, 2
) AS t1
WHERE ranking = 1;
```
### 3. Фильмы, выпущенные в 2020 году
```sql
SELECT *
FROM netflix 
WHERE type='Movie'
AND release_year=2020;
```
### 4. 5 стран с наибольшим количеством контента
```sql
SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
### 5. Самый длинный фильм
```sql
SELECT * FROM netflix
WHERE type='Movie'
AND duration=(SELECT MAX(duration) FROM netflix);
```
### 6. Контент, добавленный за последние 5 лет
```sql
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 YEARS';
```
### 7. Фильмы/сериалы режиссёра Раджива Чилаки
```sql
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```
### 8. Сериалы с более чем 5 сезонами
```sql
SELECT *
FROM netflix
WHERE type='TV Show'
AND SPLIT_PART(duration, ' ', 1)::int > 5;
```
### 9. Количество контента в каждом жанре
```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, COUNT(show_id) AS tot_cnt
FROM netflix
GROUP BY 1;
```
### 10. Среднее количество контента в Японии по годам
```sql
SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) AS year,
       COUNT(*) AS yearly_content,
       ROUND(
           COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country='India')::numeric * 100, 2
       ) AS avg_content
FROM netflix
WHERE country='Japan'
GROUP BY 1
ORDER BY 1, 2;
```
### 11. Все документальные фильмы
```sql
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%';
```
### 12. Контент без режиссёра
```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```
### 13. Количество фильмов с актёром Салман Хан за последние 10 лет
```sql
SELECT *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```
### 15. 10 актёров с наибольшим количеством фильмов в Японии
```sql
SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS cast,
       COUNT(*) AS tot_content
FROM netflix
WHERE country LIKE '%Japan'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```
### 16. Классификация контента по ключевым словам «kill» и «violence»
```sql
WITH new_table AS (
    SELECT *,
           CASE
               WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
               ELSE 'Good'
           END AS category
    FROM netflix
)
SELECT category, COUNT(*) AS cnt
FROM new_table
GROUP BY 1;
```
## 🧠 Бизнес-задачи проекта

Проект решает следующие аналитические задачи:

- подсчёт количества фильмов и сериалов;

- анализ рейтингов по типу контента;

- определение наиболее популярных стран и жанров;

- поиск контента по режиссёрам и актёрам;

- анализ длительности фильмов и количества сезонов;

- временной анализ добавления контента;

- классификация контента на основе ключевых слов в описании.

Все SQL-запросы представлены в файле netflix_proj.sql.


## 🛠 Используемые технологии

SQL (PostgreSQL)

- CTE (WITH)

- Оконные функции

- Строковые функции

- Агрегации и группировки


## 🎯 Цель проекта

Продемонстрировать способность:

работать с реальными данными;

анализировать текстовые и временные поля;

решать бизнес-задачи с помощью SQL;

оформлять аналитический проект для портфолио.
