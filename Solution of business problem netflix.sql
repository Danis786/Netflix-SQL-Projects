-- Netflix Data Analysis using SQL
-- Solutions of 14 business problems
-- 1. Count the number of Movies vs TV Shows
SELECT 
    type, COUNT(*) AS count
FROM
    netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rn
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rn = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT 
    *
FROM
    netflix
WHERE
    release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
    country, COUNT(*) AS total_content
FROM
    netflix
WHERE
    country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 6. Find content added in the last 5 years
SELECT 
    *
FROM
    netflix
WHERE
    date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT 
    *
FROM
    netflix
WHERE
    director = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
SELECT 
    *
FROM
    netflix
WHERE
    TYPE = 'TV Show'
        AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- 9. Count the number of content items in each genre
SELECT 
    listed_in, COUNT(*) AS items_content
FROM
    netflix
GROUP BY listed_in;

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
SELECT 
    release_year,
    COUNT(*) AS total_release,
    ROUND(COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    netflix
                WHERE
                    country = 'India') * 100,
            2) AS avg_release
FROM
    netflix
WHERE
    country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT 
    title, release_year, listed_in
FROM
    netflix
WHERE
    type = 'Movie'
        AND listed_in = 'Documentaries';

-- 12. Find all content without a director
SELECT 
    *
FROM
    netflix
WHERE
    director IS NULL OR director = '';

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT 
    title, release_year
FROM
    netflix
WHERE
    type = 'Movie'
        AND cast LIKE '%Salman Khan%'
        AND release_year >= YEAR(CURDATE()) - 10
ORDER BY release_year;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
WITH RECURSIVE actors AS (
    -- Base case: Get the first actor from each list
    SELECT 
        TRIM(SUBSTRING_INDEX(cast, ',', 1)) AS actor_name,
        SUBSTRING(cast, LOCATE(',', cast) + 1) AS remaining_cast
    FROM netflix
    WHERE country = 'India' 
      AND type = 'Movie' 
      AND cast IS NOT NULL
    
    UNION ALL
    
    -- Recursive step: Split the next actor from the remaining string
    SELECT 
        TRIM(SUBSTRING_INDEX(remaining_cast, ',', 1)),
        IF(LOCATE(',', remaining_cast) > 0, SUBSTRING(remaining_cast, LOCATE(',', remaining_cast) + 1), '')
    FROM actors
    WHERE remaining_cast <> ''
)
SELECT actor_name, COUNT(*) AS movie_count
FROM actors
WHERE actor_name <> ''
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 10;

/* 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
SELECT 
    CASE
        WHEN
            description LIKE '%kill%'
                OR description LIKE '%violence%'
        THEN
            'Bad'
        ELSE 'Good'
    END AS content_category,
    COUNT(*) AS total_items
FROM
    netflix
GROUP BY content_category;





-- End of reports