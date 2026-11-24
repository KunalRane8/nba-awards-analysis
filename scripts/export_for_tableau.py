"""Export the clean tables from nba_awards.db to CSV files for Tableau Public."""
import csv
import sqlite3

DB = "nba_awards.db"
OUT = "data/tableau/"

EXPORTS = {
    # every player, every season
    "player_season.csv": "SELECT * FROM player_season",
    # one row per award, with the player's stats for that season attached
    "awards_with_stats.csv": """
        SELECT a.season, a.player, a.award, a.finish,
               CASE WHEN a.finish = 1 THEN 1 ELSE 0 END AS is_winner,
               p.team, p.pos, p.age, p.games, p.mpg, p.ppg, p.rpg, p.apg, p.spg, p.bpg,
               p.ts_pct, p.bpm, p.vorp, p.win_shares, p.team_wins, p.team_losses
        FROM awards AS a
        JOIN player_season AS p ON p.season = a.season AND p.player = a.player
    """,
    # team records
    "team_season.csv": "SELECT * FROM team_season",
}

con = sqlite3.connect(DB)
for name, sql in EXPORTS.items():
    cur = con.execute(sql)
    headers = [c[0] for c in cur.description]
    rows = cur.fetchall()
    with open(OUT + name, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(headers)
        w.writerows(rows)
    print(f"{name}: {len(rows)} rows")
con.close()
print("Done -> data/tableau/")
