-- MVP tracker: which 2027 players pass the 3 MVP checks?
SELECT p.player, p.team, p.games, p.ppg, p.bpm,
       ROUND(1.0 * p.team_wins / (p.team_wins + p.team_losses), 3) AS win_pct,
       CASE WHEN p.ppg >= 25 THEN 'yes' ELSE 'no' END AS scoring_ok,
       CASE WHEN p.bpm >= 8 THEN 'yes' ELSE 'no' END AS impact_ok,
       CASE WHEN 1.0 * p.team_wins / (p.team_wins + p.team_losses) >= 0.560
            THEN 'yes' ELSE 'no' END AS winning_ok,
       (CASE WHEN p.ppg >= 25 THEN 1 ELSE 0 END)
     + (CASE WHEN p.bpm >= 8 THEN 1 ELSE 0 END)
     + (CASE WHEN 1.0 * p.team_wins / (p.team_wins + p.team_losses) >= 0.560
             THEN 1 ELSE 0 END) AS checks_passed
FROM player_season AS p
WHERE p.season = 2027 AND p.games >= 8 AND p.traded = 0
ORDER BY checks_passed DESC, p.bpm DESC
LIMIT 10;