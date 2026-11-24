-- Q1: Most All-Defensive selections since 2005
SELECT a.player,
       COUNT(*) AS selections,
       SUM(CASE WHEN a.finish = 1 THEN 1 ELSE 0 END) AS first_team
FROM awards AS a
WHERE a.award = 'All-Defensive'
GROUP BY a.player
ORDER BY selections DESC, first_team DESC
LIMIT 10;

-- Q2: Which positions make All-Defensive?
SELECT p.pos, COUNT(*) AS selections
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'All-Defensive'
GROUP BY p.pos
ORDER BY selections DESC;

-- Q3: Two-way stars: 1st team All-Defensive AND 1st team All-NBA in the same season
SELECT a.season, a.player
FROM awards AS a
WHERE a.award = 'All-Defensive' AND a.finish = 1
  AND EXISTS (SELECT 1 FROM awards AS n
               WHERE n.season = a.season AND n.player = a.player
                 AND n.award = 'All-NBA' AND n.finish = 1)
ORDER BY a.season DESC;