# CREATE DATABASE
create database netflix;

# VIEW DATASET
select *
from netflix1;

# CHECK DUPLICATES
select show_id, type, title, count(*) as count
from netflix1
group by show_id, type, title
Having count(*) > 1;

# VIEW DUPLICATES
SELECT n1.*
FROM netflix1 n1
JOIN (
    SELECT show_id
    FROM netflix1
    GROUP BY show_id, type, title
    HAVING COUNT(*) > 1
) duplicates
ON n1.show_id = duplicates.show_id;

#DELETE DUPLICATES KEEP 1 RECORD
WITH RankedNetflix AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY show_id, type, title ORDER BY date_added DESC) AS row_num
    FROM netflix1
)
DELETE FROM netflix1
WHERE (show_id, type, title) IN (
    SELECT show_id, type, title FROM RankedNetflix WHERE row_num > 1
);

# CHECKING NULL VALUES
SELECT COUNT(*) AS null_count
FROM netflix1
WHERE show_id IS NULL;

# TO CHECK NULL VALUES IN EACH COLUMN
SELECT 
    CASE WHEN show_id IS NULL THEN 1 ELSE 0 END AS show_id_null,
    CASE WHEN type IS NULL THEN 1 ELSE 0 END AS type_null,
    CASE WHEN title IS NULL THEN 1 ELSE 0 END AS title_null,
    CASE WHEN director IS NULL THEN 1 ELSE 0 END AS director_null,
    CASE WHEN country IS NULL THEN 1 ELSE 0 END AS country_null,
    CASE WHEN date_added IS NULL THEN 1 ELSE 0 END AS date_added_null,
    CASE WHEN release_year IS NULL THEN 1 ELSE 0 END AS release_year_null,
    CASE WHEN rating IS NULL THEN 1 ELSE 0 END AS rating_null,
    CASE WHEN duration IS NULL THEN 1 ELSE 0 END AS duration_null,
    CASE WHEN listed_in IS NULL THEN 1 ELSE 0 END AS listed_in_null
FROM netflix1;

# FIND MISSING VALUE
SELECT 
    SUM(CASE WHEN type IS NULL THEN 1 ELSE 0 END) AS missing_type,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS missing_title,
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS missing_director
FROM netflix1;

# REPLACE NULLS
UPDATE netflix1
SET 
    director = 'Unknown',
    country = 'Unknown',
    date_added = 'Not Available',
    release_year = 0,
    rating = 'Not Rated',
    duration = 'Unknown',
    listed_in = 'Not Specified'
WHERE director IS NULL 
  AND country IS NULL 
  AND date_added IS NULL 
  AND release_year IS NULL 
  AND rating IS NULL 
  AND duration IS NULL 
  AND listed_in IS NULL;
  
SELECT date_added
FROM netflix1;

# NORMALIZE DATE FORMAT
UPDATE netflix1 
SET date_added = STR_TO_DATE(date_added, '%m/%d/%Y') 
WHERE date_added LIKE '%/%/%';

ALTER TABLE netflix1 
MODIFY COLUMN date_added DATE;

# Exploratory Data Analysis (EDA) 
-- Count Content by Type
Select type, count(*) as total
From netflix1
Group by type;

-- Find the Top 10 Most Common Directors
Select director, count(*) as total
From netflix1
Where director Is Not Null
Group by director
Order by total desc
Limit 11;

-- Number of Realeses per Year (Which release year has the most content?)
Select release_year, count(*) as total
From netflix1
Where release_year Is Not NUll
Group by release_year
Order by release_year Desc;

-- How has Netflix’s content library grown over time?
SELECT YEAR(date_added) AS year, MONTH(date_added) AS month, COUNT(*) AS total_content
FROM netflix1
WHERE date_added IS NOT NULL
GROUP BY year, month
ORDER BY year, month;

-- Yearly Trend of Movie vs. TV Show Releases
SELECT release_year, type, COUNT(*) AS count
FROM netflix1
GROUP BY release_year, type
ORDER BY release_year DESC;

-- Most Popular Genres
SELECT listed_in AS genre, COUNT(*) AS total
FROM netflix1
GROUP BY listed_in
ORDER BY total DESC
LIMIT 10;

-- Top Countries Producing Netflix Content
SELECT country, COUNT(*) AS total_content
FROM netflix1
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 20;

-- How has Netflix’s content in a specific country evolved?
SELECT country, release_year, COUNT(*) AS content_count
FROM netflix1
WHERE country = 'Indonesia'
GROUP BY country, release_year
ORDER BY release_year;