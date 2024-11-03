-- NETFLIX--
DROP TABLE IF EXISTS NETFLIX;
CREATE TABLE netflix
(
show_id varchar(20),
type	varchar(20),
title  varchar(200),
director varchar(300),
casts	varchar(1000),
country  varchar(200),
date_added	varchar(200),
release_year	INT,
rating	varchar(200),
duration	varchar(200),
listed_in	varchar(200),
description		varchar(300)
)
SELECT * FROM netflix;

----BUSINESS QUESTIONS----

-- 1. Count the number of Movies vs TV Shows

SELECT 
 TYPE,
 COUNT(*) AS TOTAL_CONTENT
 FROM NETFLIX
 GROUP BY TYPE;

 -- 2. Find the most common rating for movies and TV shows
SELECT
    TYPE,
    RATING
FROM
    (SELECT
        TYPE,
        RATING,
        COUNT(*) AS count_rating,
        RANK() OVER (PARTITION BY TYPE ORDER BY COUNT(*) DESC) AS ranking
     FROM
        Netflix
     GROUP BY
        TYPE, RATING
    ) AS ranked_ratings
WHERE
    ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM Netflix
WHERE 
    TYPE = 'Movie'
    AND RELEASE_YEAR = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
COUNTRY, 
COUNT(TYPE) AS CONTENT_COUNT
FROM NETFLIX
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT * 
FROM 
    Netflix
WHERE 
    TYPE = 'Movie'
    AND SPLIT_PART(duration, ' ', 1)::INT = (
        SELECT 
            MAX(SPLIT_PART(duration, ' ', 1)::INT) 
        FROM 
            Netflix 
        WHERE 
            TYPE = 'Movie'
    );

-- 6. Find content added in the last 5 years

SELECT * 
FROM 
    Netflix
WHERE TO_DATE(DATE_ADDED,'MONTH DD,YYYY')>= CURRENT_DATE - INTERVAL '5 YEARS'; 

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT TYPE,TITLE,DIRECTOR
FROM NETFLIX
WHERE DIRECTOR= 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
SELECT 
    * 
FROM 
    Netflix
WHERE 
    TYPE = 'TV Show'
    AND 
    SPLIT_PART(DURATION, ' ', 1)::INT > 5;

---9. Count the number of content items in each genre

SELECT 
	UNNEST(STRING_TO_ARRAY(LISTED_IN, ',')) AS GENRE,
	COUNT(SHOW_ID) AS TOTAL_CONTENT
FROM 
    Netflix
	GROUP BY 1
	ORDER BY 2 DESC;

---10.Find each year and the average numbers of content release in India on netflix. 
---return top 5 year with highest avg content release!

SELECT
    EXTRACT(YEAR FROM TO_DATE(TRIM(DATE_ADDED), 'Month DD, YYYY')) AS YEAR_ADDED,
    COUNT(*)
FROM
    netflix
WHERE
    country = 'India'
GROUP BY
    YEAR_ADDED
ORDER BY
    YEAR_ADDED;

11. List all movies that are documentaries
SELECT
    *
FROM
    netflix
WHERE
  TYPE='Movie'
  AND
  LISTED_IN='Documentaries';

---12. Find all content without a director

SELECT 
  *
FROM
    netflix
WHERE
 DIRECTOR IS NULL;

----13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
    *
FROM 
    netflix
WHERE 
    CASTS ILIKE '%Salman Khan%' 
	AND
	RELEASE_YEAR > EXTRACT(YEAR FROM CURRENT_DATE) -10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

---Question 15:
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2
