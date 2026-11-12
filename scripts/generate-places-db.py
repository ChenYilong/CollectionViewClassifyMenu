#!/usr/bin/env python3
"""
Builds the shared example database, Example-Shared/Database/cyl_places.sqlite, from the demo data (data.json).

    scripts/generate-places-db.py           write the database
    scripts/generate-places-db.py --check   exit 1 when the committed database differs from the data

Every example on every platform (the iOS demo app, Example/CYLMenuExample, the Android example, and later React Native
and Flutter) reads this one file, so they show the same places (docs/cross-platform.md). The rows are made as
CYLExampleDatabase made them: every tag of data.json in the filter's regions except when (tag index + region) % 3 == 2,
with the same names, ratings and prices.
"""
import json
import pathlib
import re
import sqlite3
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
DATA = ROOT / "CollectionViewClassifyMenu/Class/Other/data.json"
OUT = ROOT / "Example-Shared/Database/cyl_places.sqlite"
REGIONS = ["北京 🏙️ 扩展文字", "上海", "广州", "深圳"]
SUFFIXES = [" 扩展文字😀✨", " 🏙️ 扩展文字"]


def short_title(title):
    """
    CYLDemoDataSource.shortTitle(forTitle:): the title without the demo's long suffix.
    """
    for suffix in SUFFIXES:
        if title.endswith(suffix):
            return title[: -len(suffix)]
    return title


def rows():
    """
    The places, in creation order: (id, name, category, tag, region, rating, price).
    """
    text = re.sub(r",\s*([}\]])", r"\1", DATA.read_text(encoding="utf-8"))
    result = []
    tag_index = 0
    for category in json.loads(text):
        for item in category["Items"]:
            tag = item["Item_Title"]
            for region, region_name in enumerate(REGIONS):
                if (tag_index + region) % 3 == 2:
                    continue
                rating = round(3.5 + ((tag_index * 7 + region * 3) % 16) / 10.0, 1)
                price = 30 + ((tag_index * 37 + region * 53) % 270)
                name = f"{short_title(tag)} · {short_title(region_name)}"
                result.append((len(result), name, category["Type"], tag, region_name, rating, price))
            tag_index += 1
    return result


def write(path):
    """
    Writes a fresh database at `path`.
    """
    path.unlink(missing_ok=True)
    db = sqlite3.connect(path)
    db.executescript("""
        PRAGMA user_version = 1;
        CREATE TABLE places (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL, tag TEXT NOT NULL,
                             region TEXT NOT NULL, rating REAL NOT NULL, price INTEGER NOT NULL);
        CREATE INDEX places_tag ON places(tag);
        CREATE INDEX places_region ON places(region);
    """)
    db.executemany("INSERT INTO places VALUES (?, ?, ?, ?, ?, ?, ?)", rows())
    db.commit()
    db.execute("VACUUM")
    db.close()


def dump(path):
    """
    The database's rows, for comparing contents rather than bytes (opened read-only, so it works on any volume).
    """
    db = sqlite3.connect(f"file:{path}?mode=ro&immutable=1", uri=True)
    try:
        return db.execute("SELECT * FROM places ORDER BY id").fetchall()
    finally:
        db.close()


def main():
    if "--check" in sys.argv:
        if not OUT.exists():
            print(f"error: {OUT} is missing; run {sys.argv[0]}")
            return 1
        with tempfile.TemporaryDirectory() as folder:
            fresh = pathlib.Path(folder) / "fresh.sqlite"
            write(fresh)
            if dump(fresh) != dump(OUT):
                print(f"error: {OUT} differs from data.json; run {sys.argv[0]}")
                return 1
        print(f"{OUT.relative_to(ROOT)} matches data.json ({len(rows())} places)")
        return 0
    OUT.parent.mkdir(parents=True, exist_ok=True)
    # Built in a temporary folder and copied: SQLite cannot lock files on some external volumes (exFAT).
    with tempfile.TemporaryDirectory() as folder:
        fresh = pathlib.Path(folder) / "fresh.sqlite"
        write(fresh)
        OUT.write_bytes(fresh.read_bytes())
    print(f"wrote {OUT.relative_to(ROOT)} ({len(rows())} places)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
