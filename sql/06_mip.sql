-- Q1: Every MIP winner: this season vs the season before
SELECT a.season, a.player, p.age,
       prev.ppg AS ppg_before, p.ppg AS ppg_after,
       ROUND(p.ppg - prev.ppg, 1) AS ppg_jump,
       prev.mpg AS mpg_before, p.mpg AS mpg_after
FROM awards AS a
JOIN player_season AS p    ON p.season = a.season     AND p.player = a.player
JOIN player_season AS prev ON prev.season = a.season - 1 AND prev.player = a.player
WHERE a.award = 'MIP'
ORDER BY a.season DESC;

-- Q2: The average MIP jump
SELECT COUNT(*) AS winners,
       ROUND(AVG(p.age), 1) AS avg_age,
       ROUND(AVG(prev.ppg), 1) AS avg_ppg_before,
       ROUND(AVG(p.ppg), 1) AS avg_ppg_after,
       ROUND(AVG(p.ppg - prev.ppg), 1) AS avg_ppg_jump,
       ROUND(AVG(p.mpg - prev.mpg), 1) AS avg_mpg_jump
FROM awards AS a
JOIN player_season AS p    ON p.season = a.season     AND p.player = a.player
JOIN player_season AS prev ON prev.season = a.season - 1 AND prev.player = a.player
WHERE a.award = 'MIP';