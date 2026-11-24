-- DPOY tracker: which 2027 players pass the 3 DPOY checks?
SELECT p.player, p.team, p.pos, p.games, p.rpg, p.spg, p.bpg,
       ROUND(p.spg + p.bpg, 1) AS stocks,
       ROUND(1.0 * p.team_wins / (p.team_wins + p.team_losses), 3) AS win_pct,
       (CASE WHEN p.spg + p.bpg >= 2.5 THEN 1 ELSE 0 END)
     + (CASE WHEN p.rpg >= 8 THEN 1 ELSE 0 END)
     + (CASE WHEN 1.0 * p.team_wins / (p.team_wins + p.team_losses) >= 0.440
             THEN 1 ELSE 0 END) AS checks_passed
FROM player_season AS p
WHERE p.season = 2027 AND p.games >= 8 AND p.traded = 0
ORDER BY checks_passed DESC, stocks DESC
LIMIT 10;

-- ROY tracker: rookies = players with no earlier season in the data
SELECT p.player, p.team, p.age, p.games, p.mpg, p.ppg, p.rpg, p.apg,
       (CASE WHEN p.ppg >= 15 THEN 1 ELSE 0 END)
     + (CASE WHEN p.mpg >= 28 THEN 1 ELSE 0 END) AS checks_passed
FROM player_season AS p
WHERE p.season = 2027 AND p.games >= 8
  AND NOT EXISTS (SELECT 1 FROM player_season AS x
                   WHERE x.player = p.player AND x.season < 2027)
ORDER BY checks_passed DESC, p.ppg DESC
LIMIT 10;