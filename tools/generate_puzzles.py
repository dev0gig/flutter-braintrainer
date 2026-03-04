#!/usr/bin/env python3
"""
Download and filter Lichess puzzles into assets/puzzles.json.

Requires the Lichess puzzle CSV database:
  https://database.lichess.org/lichess_db_puzzle.csv.zst

Usage:
  # Download the CSV first (one-time, ~350MB compressed):
  curl -L https://database.lichess.org/lichess_db_puzzle.csv.zst | zstd -d > lichess_db_puzzle.csv

  # Then run this script:
  python3 tools/generate_puzzles.py lichess_db_puzzle.csv
"""

import csv
import json
import random
import sys
from pathlib import Path

TARGET_PER_CATEGORY = 200

CATEGORIES = {
    "mateIn1": {
        "required_themes": ["mateIn1"],
        "rating_min": 800,
        "rating_max": 1600,
        "min_popularity": 50,
    },
    "mateIn2": {
        "required_themes": ["mateIn2"],
        "rating_min": 1000,
        "rating_max": 1800,
        "min_popularity": 50,
    },
    "tactic": {
        "required_themes": ["fork", "pin", "skewer", "sacrifice", "hangingPiece", "trappedPiece"],
        "any_theme": True,  # match ANY of these themes (not all)
        "rating_min": 1200,
        "rating_max": 2000,
        "min_popularity": 50,
    },
}


def matches_category(row, cat_config):
    themes = set(row["Themes"].split())
    rating = int(row["Rating"])
    popularity = int(row["Popularity"])

    if rating < cat_config["rating_min"] or rating > cat_config["rating_max"]:
        return False
    if popularity < cat_config["min_popularity"]:
        return False

    required = cat_config["required_themes"]
    if cat_config.get("any_theme"):
        return bool(themes & set(required))
    else:
        return all(t in themes for t in required)


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <path-to-lichess_db_puzzle.csv>")
        sys.exit(1)

    csv_path = Path(sys.argv[1])
    if not csv_path.exists():
        print(f"File not found: {csv_path}")
        sys.exit(1)

    # Collect candidates per category
    candidates = {cat: [] for cat in CATEGORIES}

    print("Reading CSV...")
    with open(csv_path, "r") as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader):
            if i % 500_000 == 0:
                print(f"  Processed {i:,} rows...")
            for cat_name, cat_config in CATEGORIES.items():
                if len(candidates[cat_name]) < TARGET_PER_CATEGORY * 5:
                    if matches_category(row, cat_config):
                        candidates[cat_name].append(row)

            # Stop early if we have enough candidates for all categories
            if all(len(v) >= TARGET_PER_CATEGORY * 3 for v in candidates.values()):
                break

    # Select random subset
    result = {}
    for cat_name, puzzles in candidates.items():
        random.shuffle(puzzles)
        selected = puzzles[:TARGET_PER_CATEGORY]
        result[cat_name] = [
            {
                "id": p["PuzzleId"],
                "fen": p["FEN"],
                "moves": p["Moves"],
                "rating": int(p["Rating"]),
            }
            for p in selected
        ]
        print(f"{cat_name}: {len(result[cat_name])} puzzles selected")

    # Write JSON
    out_path = Path(__file__).parent.parent / "assets" / "puzzles.json"
    with open(out_path, "w") as f:
        json.dump(result, f, separators=(",", ":"))

    size_kb = out_path.stat().st_size / 1024
    total = sum(len(v) for v in result.values())
    print(f"\nWrote {total} puzzles to {out_path} ({size_kb:.1f} KB)")


if __name__ == "__main__":
    main()
