-- Q1: Every 6MOY winner (games_started shows how often they started)
SELECT a.season, a.player, p.team, p.games, p.games_started, p.mpg, p.ppg, p.team_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = '6MOY' AND a.finish = 1
ORDER BY a.season DESC;

-- Q2: The average 6MOY season
SELECT COUNT(*) AS winners,
       ROUND(AVG(p.age), 1) AS avg_age,
       ROUND(AVG(p.ppg), 1) AS avg_ppg,
       ROUND(AVG(p.mpg), 1) AS avg_mpg,
       ROUND(AVG(p.games_started), 1) AS avg_starts,
       MAX(p.games_started) AS most_starts,
       ROUND(AVG(p.team_wins), 0) AS avg_team_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = '6MOY' AND a.finish = 1;

-- Q3: Who won it more than once?
SELECT a.player, COUNT(*) AS wins
FROM awards AS a
WHERE a.award = '6MOY' AND a.finish = 1
GROUP BY a.player
HAVING COUNT(*) > 1
ORDER BY wins DESC;