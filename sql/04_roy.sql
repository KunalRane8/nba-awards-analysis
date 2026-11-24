-- Q1: Every ROY winner and their stats
SELECT a.season, a.player, p.team, p.age, p.ppg, p.rpg, p.apg, p.mpg, p.team_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'ROY' AND a.finish = 1
ORDER BY a.season DESC;

-- Q2: The average ROY season
SELECT COUNT(*) AS winners,
       ROUND(AVG(p.age), 1) AS avg_age,
       ROUND(AVG(p.ppg), 1) AS avg_ppg,
       ROUND(AVG(p.rpg), 1) AS avg_rpg,
       ROUND(AVG(p.apg), 1) AS avg_apg,
       ROUND(AVG(p.mpg), 1) AS avg_mpg,
       ROUND(AVG(p.team_wins), 0) AS avg_team_wins,
       MAX(p.team_wins) AS most_wins
FROM awards AS a
JOIN player_season AS p ON p.season = a.season AND p.player = a.player
WHERE a.award = 'ROY' AND a.finish = 1;

-- Q3: Did ROY winners become stars? (All-Star picks in their career)
SELECT a.season, a.player,
       (SELECT COUNT(*) FROM awards AS s
         WHERE s.player = a.player AND s.award = 'All-Star') AS all_star_picks
FROM awards AS a
WHERE a.award = 'ROY' AND a.finish = 1
ORDER BY all_star_picks DESC, a.season DESC;