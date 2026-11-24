-- Q1: Top 3 in CPOY voting each year
SELECT a.season, a.finish, a.player, p.team, p.ppg, p.team_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'CPOY' AND a.finish <= 3
ORDER BY a.season DESC, a.finish;

-- Q2: Where did each CPOY winner finish in MVP voting?
SELECT a.season, a.player,
       (SELECT m.finish FROM awards AS m
         WHERE m.season = a.season AND m.player = a.player AND m.award = 'MVP') AS mvp_finish
FROM awards AS a
WHERE a.award = 'CPOY' AND a.finish = 1
ORDER BY a.season DESC;