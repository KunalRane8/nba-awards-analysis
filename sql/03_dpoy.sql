-- Q1: Every DPOY winner and their defensive stats
SELECT a.season, a.player, p.team, p.pos, p.rpg, p.spg, p.bpg, p.bpm, p.team_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'DPOY' AND a.finish = 1
ORDER BY a.season DESC;

-- Q2: The average DPOY season
SELECT COUNT(*) AS winners,
       ROUND(AVG(p.rpg), 1) AS avg_rpg,
       ROUND(AVG(p.spg), 1) AS avg_spg,
       ROUND(AVG(p.bpg), 1) AS avg_bpg,
       ROUND(AVG(p.team_wins), 0) AS avg_team_wins,
       MIN(p.team_wins) AS fewest_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'DPOY' AND a.finish = 1;

-- Q3: Which positions win DPOY?
SELECT p.pos, COUNT(*) AS wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'DPOY' AND a.finish = 1
GROUP BY p.pos
ORDER BY wins DESC;