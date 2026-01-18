# Netflix Movies and TV Shows Data Analysis using SQL

<img width="2226" height="678" alt="image" src="https://github.com/user-attachments/assets/8185bb25-3bfa-4262-972b-881c641695eb" />


## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions

## Objectives

 - Analyze the distribution of content types (movies vs TV shows).
 - Identify the most common ratings for movies and TV shows.
 - List and analyze content based on release years, countries and durations.
 - Explore and categorize content based on specific criteria and keywords.

## Schemas

```sql
create database Netflix;
use Netflix;

CREATE TABLE netflix (
  show_id TEXT,
  type TEXT,
  title TEXT,
  director TEXT,
  cast TEXT,
  country TEXT,
  date_added TEXT,
  release_year INT,
  rating TEXT,
  duration TEXT,
  listed_in TEXT,
  description TEXT
);
SELECT * FROM netflix;
```
## Business Problems and Solutions

### 1. Count the number of Movies vs TV Shows

```sql
SELECT 
    type, COUNT(*) AS count
FROM
    netflix
GROUP BY type;
```
**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the most common rating for movies and TV shows

```sql
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
```
**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List all movies released in a specific year (e.g., 2020)

```sql
SELECT 
    *
FROM
    netflix
WHERE
    release_year = 2020;
```
**Objective:** Retrieve all movies released in a specific year.

### 4. Find the top 5 countries with the most content on Netflix

```sql
SELECT 
    country, COUNT(*) AS total_content
FROM
    netflix
WHERE
    country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;
```
**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Find content added in the last 5 years

```sql
SELECT 
    *
FROM
    netflix
WHERE
    date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
```
**Objective:** Retrieve content added to Netflix in the last 5 years.

### 6. Find all the movies/TV shows by director 'Rajiv Chilaka'!

```sql
SELECT 
    *
FROM
    netflix
WHERE
    director = 'Rajiv Chilaka';
```
**Objective:** List all content directed by 'Rajiv Chilaka'.

### 7. List all TV shows with more than 5 seasons

```sql
SELECT 
    *
FROM
    netflix
WHERE
    TYPE = 'TV Show'
        AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
```
**Objective:** Identify TV shows with more than 5 seasons.

### 8. Count the number of content items in each genre

```sql
SELECT 
    listed_in, COUNT(*) AS items_content
FROM
    netflix
GROUP BY listed_in;
```
**Objective:** Count the number of content items in each genre.

### 9. Find each year and the average numbers of content release by India on netflix.
###    return top 5 year with highest avg content release !

```sql
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
```
**Objective:** Calculate and rank years by the average number of content releases by India.

### 10. List all movies that are documentaries

```sql
SELECT 
    title, release_year, listed_in
FROM
    netflix
WHERE
    type = 'Movie'
        AND listed_in = 'Documentaries';
```
**Objective:** Retrieve all movies classified as documentaries.

### 11. Find all content without a director

```sql
SELECT 
    *
FROM
    netflix
WHERE
    director IS NULL OR director = '';
```
**Objective:** List content that does not have a director.

### 12. Find how many movies actor 'Salman Khan' appeared in last 10 years!

```sql
SELECT 
    title, release_year
FROM
    netflix
WHERE
    type = 'Movie'
        AND cast LIKE '%Salman Khan%'
        AND release_year >= YEAR(CURDATE()) - 10
ORDER BY release_year;
```
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 13. Find the top 10 actors who have appeared in the highest number of movies produced in India.

```sql
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
```
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 14.Categorize the content based on the presence of the keywords 'kill' and 'violence'.

```sql
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
```
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
