1. --Using the athletes table write a query that returns the minimum, average, and maximum age based on gender. 
--Your results should have 2 rows (M and F) and 4 columns (gender, min_age, avg_age, max_age).

SELECT 
	Min(age),
	Max(age),
	Avg(age),
	gender
FROM athletes
GROUP BY gender;


2. --Write a query which finds all events in the summer_games which have an average age of participants of at least 30. 
--Report the event name and the average age of participants.

SELECT 
	event,
	ROUND(AVG(age),1) AS avg_age,
FROM 
    summer_games
INNER JOIN
	athletes
ON
    summer_games.athlete_id = athletes.id
GROUP BY
    event
HAVING
    AVG(age) >= 30



3. --Find all events in the summer_games and winter_games table that include the word "Relay" in their event name. 
--Warning - the same event can appear in multiple rows, so your query should account for this and only display each event name once. 
--Answer this question using a single query.

(SELECT
	DISTINCT
	event
FROM summer_games
WHERE event LIKE '%Relay%')
UNION
(SELECT
 	event
FROM winter_games
WHERE event LIKE '%Relay%')


4. -- a. Create a table which shows, for each Track and Field event in the Summer Olympics, the event name and the name of the athlete who won the gold medal. 
--Note that the gold medal winner is indicated by a 1 in the gold column. 

--b. Build off of your query from part a to find the number of Track and Field gold medals won for each athlete who won at least one. 
--Which athlete won the most Track and Field gold medals?


4A.

  SELECT 
  		DISTINCT
        name,
		athlete_id,
		event,
		COUNT(gold) AS gold_medals,
        COUNT(DISTINCT event) AS events_with_gold
    FROM 
		summer_games
	INNER JOIN
		athletes
	ON
		summer_games.athlete_id = athletes.id
    WHERE 
		sport LIKE '%Track and Field%' AND gold = 1
    GROUP BY 
		athlete_id, name, event
    HAVING COUNT
		(gold) > 0


4B.

WITH tfg AS (
    SELECT 
        athlete_id,
		COUNT(gold) AS gold_medals,
        COUNT(DISTINCT event) AS events_with_gold
    FROM summer_games
    WHERE sport LIKE '%Track and Field%' AND gold = 1
    GROUP BY athlete_id
    HAVING COUNT(gold) > 0
)
SELECT 
    tfg.athlete_id,
    athletes.name,
    tfg.gold_medals,
    'Track and Field' AS sport
FROM tfg
INNER JOIN 
	athletes 
ON 
	tfg.athlete_id = athletes.id;


--Usain St. Leo Bolt, 3 gold_medals--




5.

-- a. Find the unique athlete_id values from the summer_games table for athletes that competed in the sport of Gymnastics. 
--Warning: an athlete can compete in more than one event, so your query should handle this.  

--b. Build off of your query from part a to find the average age of athletes that competed in Gymnastics.



SELECT
	DISTINCT 
	athlete_id,
	event
FROM 
    summer_games
WHERE event LIKE '%Gymnastics%'
GROUP BY 
    athlete_id, event


5b.

	SELECT
		ROUND(AVG(age),1) AS avg_age,
		athlete_id,
		event
	FROM 
		athletes
	INNER JOIN
		summer_games
	ON 
		athletes.id = summer_games.athlete_id
	WHERE
		event LIKE '%Gymnastics%' 
	GROUP BY
		event, athlete_id;




6.

--Provide a list of athletes who won a gold medal and are shorter than the average Olympic athlete.

WITH summer_gold AS (
    SELECT athlete_id AS athlete_id_summer
    FROM summer_games
    WHERE gold = 1
),
winter_gold AS (
    SELECT athlete_id AS athlete_id_winter
    FROM winter_games
    WHERE gold = 1
)
SELECT
    id,
    name,
    height,
    SUM(CASE WHEN summer_gold_medal = 1 THEN 1 ELSE 0 END) AS summer_gold_medals,
    SUM(CASE WHEN winter_gold_medal = 1 THEN 1 ELSE 0 END) AS winter_gold_medals,
    CASE WHEN height < ROUND(AVG(height) OVER(), -1) THEN 1 ELSE 0 END AS below_avg_height
FROM 
    athletes
LEFT JOIN summer_gold ON athletes.id = summer_gold.athlete_id_summer
LEFT JOIN winter_gold ON athletes.id = winter_gold.athlete_id_winter
GROUP BY
    id, name, height, summer_gold_medal, winter_gold_medal;



7.

-- a. Write a query which returns each country in the countries table and the number of (distinct) events that country participated in from the winter_games table. This should include all countries, even those that participated in zero games.
-- b.  Write a query which returns each country in the countries table and the number of (distinct) events that country won a gold medal in from the winter_games table. Make sure that your query is only counting each event once. For example, Sweden (country_id = 178) is listed 4 times in the winter_games table for a gold medal in the Cross Country Skiing event, but this should only count one time in your results table. You do not need to include all countries in this query, only the ones that won gold medals.
-- c. Combine your results for parts a and b into a table that gives, for each country in the countries table, the total number of events that country participated in and the number of gold medals won.



7A.

SELECT
    DISTINCT
	event AS events,
    COUNT(event) AS number_of_events,
    country
FROM 
    countries
LEFT JOIN 
    winter_games
ON
    countries.id = winter_games.country_id
GROUP BY 
    country, winter_games.event

	
	
	

7B.

SELECT
	DISTINCT
		country,
		event,
		COALESCE(SUM(gold),0) AS gold_medals
FROM
	countries
LEFT JOIN
	winter_games
ON
	countries.id = winter_games.country_id
GROUP BY
	country, gold,event



7C.

SELECT
    DISTINCT
	event AS events,
	COUNT(event) AS number_of_events,
    COUNT(gold) AS gold_medals,
    country
FROM 
    countries
INNER JOIN 
    winter_games
ON
    countries.id = winter_games.country_id
WHERE
	gold > 0
GROUP BY 
    country, winter_games.event
	
	



