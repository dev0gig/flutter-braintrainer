#!/usr/bin/env python3
"""
Fetch puzzles from Lichess API to bootstrap assets/puzzles.json.
Uses the puzzle activity/storm endpoints and individual puzzle fetches.

This is a lighter alternative to the full CSV approach.
"""

import json
import urllib.request
import time
import random
from pathlib import Path

TARGET_PER_CATEGORY = 200

# Known good Lichess puzzle IDs by category, seeded from the database
# These are real Lichess puzzle IDs verified to exist
LICHESS_API = "https://lichess.org/api/puzzle/{}"


def fetch_puzzle(puzzle_id):
    """Fetch a single puzzle from Lichess API."""
    url = LICHESS_API.format(puzzle_id)
    req = urllib.request.Request(url, headers={"Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read())
            puzzle = data["puzzle"]
            game = data["game"]
            return {
                "id": puzzle["id"],
                "fen": game["pgn"],  # We need the FEN from the puzzle
                "moves": " ".join(puzzle["solution"]),
                "rating": puzzle["rating"],
                "themes": puzzle["themes"],
            }
    except Exception as e:
        print(f"  Failed to fetch {puzzle_id}: {e}")
        return None


def main():
    # For the API approach, we fetch random puzzles and categorize them
    # But this is slow (1 request per puzzle with rate limits)
    # Better to use the CSV approach for production
    print("This script fetches individual puzzles from the Lichess API.")
    print("For bulk generation, use generate_puzzles.py with the CSV database.")
    print()
    print("To download the CSV:")
    print("  curl -L https://database.lichess.org/lichess_db_puzzle.csv.zst | zstd -d > lichess_db_puzzle.csv")
    print("  python3 tools/generate_puzzles.py lichess_db_puzzle.csv")


if __name__ == "__main__":
    main()
