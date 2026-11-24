-- Q1: Most All-NBA selections since 2005
SELECT a.player,
       COUNT(*) AS selections,
       SUM(CASE WHEN a.finish = 1 THEN 1 ELSE 0 END) AS first_team
FROM awards AS a
WHERE a.award = 'All-NBA'
GROUP BY a.player
ORDER BY selections DESC, first_team DESC
LIMIT 10;

-- Q2: What does 1st vs 2nd vs 3rd team look like?
SELECT a.finish AS team_level,
       COUNT(*) AS players,
       ROUND(AVG(p.ppg), 1) AS avg_ppg,
       ROUND(AVG(p.bpm), 1) AS avg_bpm,
       ROUND(AVG(p.vorp), 1) AS avg_vorp,
       ROUND(AVG(p.team_wins), 0) AS avg_team_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'All-NBA'
GROUP BY a.finish;

-- Q3: Did the 65-game rule (started 2024) change who makes it?
SELECT CASE WHEN a.season >= 2024 THEN '2024+ (65-game rule)' ELSE '2005-2023' END AS era,
       COUNT(*) AS players,
       ROUND(AVG(p.games), 1) AS avg_games,
       MIN(p.games) AS fewest_games
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'All-NBA'
GROUP BY era;