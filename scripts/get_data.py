"""
Download raw NBA data from Basketball-Reference for the awards analysis.

Saves 3 files into data/raw/ (values kept exactly as published):
  player_per_game.csv   points, rebounds, assists etc. per game, one row per player per team per season
  player_advanced.csv   advanced ratings plus the awards column (MVP-1, DPOY-3, NBA1, AS ...)
  team_records.csv      wins, losses and team ratings, one row per team per season

Seasons 2005 to 2027 (2027 = the current season so far).
Run from the project folder:   python3 scripts/get_data.py
Uses only Python's standard library. Takes about 5 minutes because it waits
4 seconds between pages (Basketball-Reference blocks faster scraping).
"""
import csv
import html as html_lib
import os
import re
import time
import urllib.request

BASE = "https://www.basketball-reference.com"
FIRST_SEASON, LAST_SEASON = 2005, 2027
DELAY_SECONDS = 4
OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data", "raw")
HEADERS = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
                         "(KHTML, like Gecko) Chrome/130.0 Safari/537.36"}

# (output file, page path pattern, table id)
SOURCES = [
    ("player_per_game.csv", "/leagues/NBA_{season}_per_game.html", "per_game_stats"),
    ("player_advanced.csv", "/leagues/NBA_{season}_advanced.html", "advanced"),
    ("team_records.csv", "/leagues/NBA_{season}.html", "advanced-team"),
]

CELL_RE = re.compile(r"<(th|td)\b([^>]*)>(.*?)</\1>", re.S)
STAT_RE = re.compile(r'data-stat="([^"]*)"')
TEAM_LINK_RE = re.compile(r"""href=['"]/teams/([A-Z0-9]+)/""")
TAG_RE = re.compile(r"<[^>]+>")


def fetch(path):
    req = urllib.request.Request(BASE + path, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=30) as r:
        page = r.read().decode("utf-8", errors="replace")
    return re.sub(r"<!--|-->", "", page)  # some tables are hidden inside HTML comments


def cells(tr_html):
    out = []
    for _, attrs, inner in CELL_RE.findall(tr_html):
        m = STAT_RE.search(attrs)
        out.append((m.group(1) if m else "", html_lib.unescape(TAG_RE.sub("", inner)).strip(), inner))
    return out


def read_table(page, table_id):
    """Return (columns, rows). Adds team_abbr (from the team link) to the team table."""
    m = re.search(r'<table\b[^>]*\bid="%s"' % re.escape(table_id), page)
    if not m:
        title = re.search(r"<title>(.*?)</title>", page, re.S)
        raise ValueError(f"table '{table_id}' not found (page title: {title.group(1).strip() if title else 'none'})")
    table = page[m.start():page.find("</table>", m.start())]
    thead = re.search(r"<thead[^>]*>(.*?)</thead>", table, re.S)
    head_rows = re.findall(r"<tr\b[^>]*>(.*?)</tr>", thead.group(1), re.S)
    head = [stat or text for stat, text, _ in cells(head_rows[-1])]
    keep = [i for i, c in enumerate(head) if c != "DUMMY"]  # DUMMY = empty spacer columns
    cols = [head[i] for i in keep]
    add_abbr = "team" in cols and "team_name_abbr" not in cols
    if add_abbr:
        cols.append("team_abbr")
    tbody = re.search(r"<tbody[^>]*>(.*?)(?:</tbody>|\Z)", table, re.S)
    rows = []
    for attrs, inner in re.findall(r"<tr\b([^>]*)>(.*?)</tr>", tbody.group(1) if tbody else "", re.S):
        if "thead" in attrs:  # repeated header rows inside the body
            continue
        c = cells(inner)
        if not c:
            continue
        row = [c[i][1] if i < len(c) else "" for i in keep]
        if add_abbr:
            team_cell = next((raw for stat, _, raw in c if stat == "team"), "")
            link = TEAM_LINK_RE.search(team_cell)
            row.append(link.group(1) if link else "")
        rows.append(row)
    return cols, rows


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for filename, pattern, table_id in SOURCES:
        path_out = os.path.join(OUT_DIR, filename)
        header, total, failed = None, 0, []
        print(f"\n--- {filename} ---")
        with open(path_out, "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f)
            for season in range(FIRST_SEASON, LAST_SEASON + 1):
                path = pattern.format(season=season)
                try:
                    cols, rows = read_table(fetch(path), table_id)
                except Exception as e:
                    print(f"{season}: FAILED ({e})")
                    failed.append(season)
                    time.sleep(DELAY_SECONDS)
                    continue
                if header is None:
                    header = cols
                    w.writerow(["season"] + header + ["source_url"])
                for r in rows:
                    w.writerow([season] + r + [BASE + path])
                total += len(rows)
                print(f"{season}: {len(rows)} rows")
                time.sleep(DELAY_SECONDS)
        print(f"Saved {total} rows -> data/raw/{filename}" + (f"  (failed seasons: {failed})" if failed else ""))


if __name__ == "__main__":
    main()
