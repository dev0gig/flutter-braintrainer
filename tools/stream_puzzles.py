#!/usr/bin/env python3
"""
Read Lichess puzzle CSV from stdin, filter and output assets/puzzles.json.
Usage: curl -sL https://database.lichess.org/lichess_db_puzzle.csv.zst | zstd -d | python3 tools/stream_puzzles.py
"""

import csv
import json
import random
import sys
from pathlib import Path

TARGET = 200
# Collect extra candidates to allow random selection
POOL_SIZE = TARGET * 5

CATEGORIES = {
    "mateIn1": {
        "themes": {"mateIn1"},
        "any": False,
        "rating_min": 800,
        "rating_max": 1600,
        "min_pop": 50,
    },
    "mateIn2": {
        "themes": {"mateIn2"},
        "any": False,
        "rating_min": 1000,
        "rating_max": 1800,
        "min_pop": 50,
    },
    "tactic": {
        "themes": {"fork", "pin", "skewer", "sacrifice", "hangingPiece", "trappedPiece", "discoveredAttack"},
        "any": True,
        "rating_min": 1200,
        "rating_max": 2000,
        "min_pop": 50,
    },
}

pools = {k: [] for k in CATEGORIES}
done = set()

reader = csv.DictReader(sys.stdin)
for i, row in enumerate(reader):
    if i % 200_000 == 0:
        counts = {k: len(v) for k, v in pools.items()}
        print(f"Row {i:,}... {counts}", file=sys.stderr)

    themes = set(row.get("Themes", "").split())
    try:
        rating = int(row["Rating"])
        pop = int(row["Popularity"])
    except (ValueError, KeyError):
        continue

    for cat, cfg in CATEGORIES.items():
        if cat in done:
            continue
        if rating < cfg["rating_min"] or rating > cfg["rating_max"]:
            continue
        if pop < cfg["min_pop"]:
            continue
        if cfg["any"]:
            if not (themes & cfg["themes"]):
                continue
        else:
            if not cfg["themes"].issubset(themes):
                continue
        pools[cat].append(row)
        if len(pools[cat]) >= POOL_SIZE:
            done.add(cat)

    if len(done) == len(CATEGORIES):
        break

result = {}
for cat, rows in pools.items():
    random.shuffle(rows)
    selected = rows[:TARGET]
    result[cat] = [
        {
            "id": r["PuzzleId"],
            "fen": r["FEN"],
            "moves": r["Moves"],
            "rating": int(r["Rating"]),
        }
        for r in selected
    ]
    print(f"{cat}: {len(result[cat])} puzzles", file=sys.stderr)

out = Path(__file__).parent.parent / "assets" / "puzzles.json"
with open(out, "w") as f:
    json.dump(result, f, separators=(",", ":"))

total = sum(len(v) for v in result.values())
print(f"Wrote {total} puzzles to {out} ({out.stat().st_size / 1024:.1f} KB)", file=sys.stderr)
