-- Q1: Most All-Star selections since 2005
SELECT a.player, COUNT(*) AS selections
FROM awards AS a
WHERE a.award = 'All-Star'
GROUP BY a.player
ORDER BY selections DESC
LIMIT 10;

-- Q2: All-Stars vs everyone else (players with 40+ games)
SELECT CASE WHEN EXISTS (SELECT 1 FROM awards AS s
                          WHERE s.season = p.season AND s.player = p.player
                            AND s.award = 'All-Star')
            THEN 'All-Star' ELSE 'Everyone else' END AS player_group,
       COUNT(*) AS player_seasons,
       ROUND(AVG(p.ppg), 1) AS avg_ppg,
       ROUND(AVG(p.bpm), 1) AS avg_bpm,
       ROUND(AVG(p.team_wins), 0) AS avg_team_wins
FROM player_season AS p
WHERE p.games >= 40 AND p.season <= 2026
GROUP BY player_group;

-- Q3: Which teams had the most All-Star selections?
SELECT p.team, COUNT(*) AS all_stars
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'All-Star'
GROUP BY p.team
ORDER BY all_stars DESC
LIMIT 5;