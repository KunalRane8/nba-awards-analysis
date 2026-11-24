"""
Load the 3 CSVs in data/raw/ into a SQLite database (nba_awards.db).

Each CSV becomes one raw_ table. Every column is stored as TEXT, exactly as in
the CSV, so the raw layer stays untouched. All cleaning happens in SQL.

Run from the project folder:   python3 scripts/load_to_sqlite.py
Safe to re-run: it rebuilds the raw tables each time.
"""
import csv
import os
import sqlite3

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(ROOT, "nba_awards.db")
FILES = {
    "player_per_game.csv": "raw_player_per_game",
    "player_advanced.csv": "raw_player_advanced",
    "team_records.csv": "raw_team_records",
}


def main():
    con = sqlite3.connect(DB_PATH)
    for filename, table in FILES.items():
        with open(os.path.join(ROOT, "data", "raw", filename), newline="", encoding="utf-8") as f:
            reader = csv.reader(f)
            header = next(reader)
            rows = list(reader)
        con.execute(f'DROP TABLE IF EXISTS "{table}"')
        con.execute(f'CREATE TABLE "{table}" ({", ".join(f"{chr(34)}{c}{chr(34)} TEXT" for c in header)})')
        con.executemany(f'INSERT INTO "{table}" VALUES ({", ".join("?" for _ in header)})', rows)
        print(f"{table}: {len(rows)} rows")
    con.commit()
    con.close()
    print("Done -> nba_awards.db")


if __name__ == "__main__":
    main()
