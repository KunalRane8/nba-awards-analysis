-- Q1: Every MVP winner and their stats
SELECT a.season, a.player, p.team, p.ppg, p.rpg, p.apg, p.ts_pct, p.bpm, p.team_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'MVP' AND a.finish = 1
ORDER BY a.season DESC;

-- Q2: The average MVP season
SELECT COUNT(*) AS winners,
       ROUND(AVG(p.ppg), 1) AS avg_ppg,
       ROUND(AVG(p.rpg), 1) AS avg_rpg,
       ROUND(AVG(p.apg), 1) AS avg_apg,
       ROUND(AVG(p.ts_pct), 3) AS avg_ts,
       ROUND(AVG(p.bpm), 1) AS avg_bpm,
       ROUND(AVG(p.team_wins), 0) AS avg_team_wins,
       MIN(p.team_wins) AS fewest_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'MVP' AND a.finish = 1;

-- Q3: Where did each MVP rank in team wins and BPM that season?
SELECT a.season, a.player, p.team, p.team_wins,
       (SELECT COUNT(*) FROM team_season AS t
         WHERE t.season = a.season AND t.wins > p.team_wins) + 1 AS team_rank,
       (SELECT COUNT(*) FROM player_season AS x
         WHERE x.season = a.season AND x.games >= 50 AND x.bpm > p.bpm) + 1 AS bpm_rank
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'MVP' AND a.finish = 1
ORDER BY a.season DESC;