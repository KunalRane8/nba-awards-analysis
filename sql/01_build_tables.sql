-- =====================================================================
-- NBA Awards Analysis | Step 3: Build and clean the database (SQLite)
-- Input:  raw_ tables loaded by scripts/load_to_sqlite.py
-- Output: player_season, awards, team_season
-- Run top to bottom. Safe to re-run.
-- =====================================================================

-- 1. player_season: one row per player per season (traded players = combined row)
DROP TABLE IF EXISTS player_season;

CREATE TABLE player_season AS
SELECT
    CAST(p.season AS INTEGER)              AS season,
    p.name_display                         AS player,
    CAST(p.age AS INTEGER)                 AS age,
    p.pos                                  AS pos,
    p.team_name_abbr                       AS team,
    CASE WHEN p.team_name_abbr LIKE '%TM' THEN 1 ELSE 0 END AS traded,
    CAST(p.games AS INTEGER)               AS games,
    CAST(p.games_started AS INTEGER)       AS games_started,
    CAST(p.mp_per_g AS REAL)               AS mpg,
    CAST(p.pts_per_g AS REAL)              AS ppg,
    CAST(p.trb_per_g AS REAL)              AS rpg,
    CAST(p.ast_per_g AS REAL)              AS apg,
    CAST(p.stl_per_g AS REAL)              AS spg,
    CAST(p.blk_per_g AS REAL)              AS bpg,
    CAST(NULLIF(p.fg_pct, '') AS REAL)     AS fg_pct,
    CAST(NULLIF(p.fg3_pct, '') AS REAL)    AS fg3_pct,
    CAST(NULLIF(p.ft_pct, '') AS REAL)     AS ft_pct,
    CAST(NULLIF(a.ts_pct, '') AS REAL)     AS ts_pct,
    CAST(NULLIF(a.per, '') AS REAL)        AS per,
    CAST(NULLIF(a.usg_pct, '') AS REAL)    AS usg_pct,
    CAST(a.ws AS REAL)                     AS win_shares,
    CAST(NULLIF(a.bpm, '') AS REAL)        AS bpm,
    CAST(a.vorp AS REAL)                   AS vorp,
    CAST(t.wins AS INTEGER)                AS team_wins,
    CAST(t.losses AS INTEGER)              AS team_losses,
    p.awards                               AS awards
FROM raw_player_per_game AS p
JOIN raw_player_advanced AS a
    ON a.season = p.season
   AND a.name_display = p.name_display
   AND a.team_name_abbr = p.team_name_abbr
LEFT JOIN raw_team_records AS t
    ON t.season = p.season
   AND t.team_abbr = p.team_name_abbr
WHERE p.team_name_abbr <> ''
  AND (p.team_name_abbr LIKE '%TM'
       OR NOT EXISTS (SELECT 1
                      FROM raw_player_per_game AS x
                      WHERE x.season = p.season
                        AND x.name_display = p.name_display
                        AND x.team_name_abbr LIKE '%TM'));


-- 2. awards: one row per player per award, split out of the awards text column
DROP TABLE IF EXISTS awards;

CREATE TABLE awards AS
SELECT season, player, 'MVP' AS award,
       CAST(SUBSTR(awards, INSTR(awards, 'MVP-') + 4) AS INTEGER) AS finish
FROM player_season WHERE ',' || awards || ',' LIKE '%,MVP-%'
UNION ALL
SELECT season, player, 'DPOY',
       CAST(SUBSTR(awards, INSTR(awards, 'DPOY-') + 5) AS INTEGER)
FROM player_season WHERE ',' || awards || ',' LIKE '%,DPOY-%'
UNION ALL
SELECT season, player, 'ROY',
       CAST(SUBSTR(awards, INSTR(awards, 'ROY-') + 4) AS INTEGER)
FROM player_season WHERE ',' || awards || ',' LIKE '%,ROY-%'
UNION ALL
SELECT season, player, '6MOY',
       CAST(SUBSTR(awards, INSTR(awards, '6MOY-') + 5) AS INTEGER)
FROM player_season WHERE ',' || awards || ',' LIKE '%,6MOY-%'
UNION ALL
SELECT season, player, 'MIP',
       CAST(SUBSTR(awards, INSTR(awards, 'MIP-') + 4) AS INTEGER)
FROM player_season WHERE ',' || awards || ',' LIKE '%,MIP-%'
UNION ALL
SELECT season, player, 'CPOY',
       CAST(SUBSTR(awards, INSTR(awards, 'CPOY-') + 5) AS INTEGER)
FROM player_season WHERE ',' || awards || ',' LIKE '%,CPOY-%'
UNION ALL
SELECT season, player, 'All-NBA',
       CAST(SUBSTR(awards, INSTR(awards, ',NBA') + 4, 1) AS INTEGER)
FROM player_season WHERE ',' || awards || ',' LIKE '%,NBA_,%'
UNION ALL
SELECT season, player, 'All-Defensive',
       CAST(SUBSTR(awards, INSTR(awards, ',DEF') + 4, 1) AS INTEGER)
FROM player_season WHERE ',' || awards || ',' LIKE '%,DEF_,%'
UNION ALL
SELECT season, player, 'All-Star', NULL
FROM player_season WHERE ',' || awards || ',' LIKE '%,AS,%';


-- 3. team_season: clean team records
DROP TABLE IF EXISTS team_season;

CREATE TABLE team_season AS
SELECT
    CAST(season AS INTEGER)                    AS season,
    team_abbr                                  AS team,
    REPLACE(team, '*', '')                     AS team_name,
    CASE WHEN team LIKE '%*' THEN 1 ELSE 0 END AS made_playoffs,
    CAST(wins AS INTEGER)                      AS wins,
    CAST(losses AS INTEGER)                    AS losses,
    CAST(srs AS REAL)                          AS srs,
    CAST(REPLACE(net_rtg, '+', '') AS REAL)    AS net_rtg
FROM raw_team_records;
