#!/usr/bin/env python3
"""
Builds the shared example database, Example-Shared/Database/cyl_places.sqlite: the places of the demo data
(data.json) and the reviews of the menu example (tables reviews, review_keywords, as CYLExampleDatabase makes them).

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


PINK = "颜色分类:苹果6 4.7【镜面粉字】"
WHITE = "颜色分类:苹果6plus【白边白字】"
GOOD, NEUTRAL, BAD = 0, 1, 2
# The example's mock reviews (CYLReviewStore.mockReviews() of Example/CYLMenuExample), in the same order: user, text,
# date, SKU, rating (0 good, 1 neutral, 2 bad), has photo, has follow-up, keywords.
REVIEWS = [
    ("1**1", "这是我买的第二个了，太棒了，酷毙了，又能当化妆镜，又能当手机壳，价格真的很实惠，质量也不错。", "2015-06-17", PINK, GOOD, 1, 0, ["手机套不错", "质量不错", "划算"]),
    ("雨**4", "刚收到就拆卡看壳，然后手机壳上有一层膜，没看到，找了卖家，卖家非常细心的解说，宝贝不错。", "2015-06-16", WHITE, GOOD, 0, 0, ["态度不错", "手机套不错"]),
    ("j**8", "太炫了，闪瞎眼，质量蛮不错的非常超值，好几个朋友看了都说也要买。", "2015-06-12", PINK, GOOD, 0, 1, ["质量不错", "划算"]),
    ("杨**6", "已经第N次购买了，不管是老板还是客服都非常好，东西更加不用说，超级靓。", "2015-06-13", WHITE, GOOD, 1, 0, ["态度不错", "质量不错"]),
    ("小**猫", "颜色很正，和图片一样，镜面效果很好，就是有点容易留指纹。", "2015-06-11", PINK, GOOD, 1, 1, ["颜色不错"]),
    ("t**2", "背面细节一般，边缘有一点毛刺，不过这个价格可以接受。", "2015-06-10", WHITE, NEUTRAL, 0, 0, ["背面细节一般"]),
    ("阿**宝", "手机壳很薄，手感好，颜色也漂亮，推荐购买。", "2015-06-09", PINK, GOOD, 0, 0, ["手机套不错", "颜色不错"]),
    ("z**9", "物流很快，第二天就到了，壳子做工精细，背面细节一般。", "2015-06-08", WHITE, GOOD, 1, 0, ["质量不错", "背面细节一般"]),
    ("大**熊", "给女朋友买的，她很喜欢，客服回复也很及时。", "2015-06-07", PINK, GOOD, 0, 1, ["态度不错"]),
    ("m**0", "性价比高，用了一周没有掉色，会回购。", "2015-06-05", WHITE, GOOD, 0, 0, ["划算", "质量不错"]),
]


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
        CREATE TABLE reviews (id INTEGER PRIMARY KEY, user TEXT NOT NULL, text TEXT NOT NULL, date TEXT NOT NULL,
                              sku TEXT NOT NULL, rating INTEGER NOT NULL, has_photo INTEGER NOT NULL, has_follow_up INTEGER NOT NULL);
        CREATE TABLE review_keywords (review_id INTEGER NOT NULL REFERENCES reviews(id), keyword TEXT NOT NULL);
        CREATE INDEX review_keywords_keyword ON review_keywords(keyword);
    """)
    db.executemany("INSERT INTO places VALUES (?, ?, ?, ?, ?, ?, ?)", rows())
    for index, (user, text, date, sku, rating, photo, follow_up, keywords) in enumerate(REVIEWS):
        db.execute("INSERT INTO reviews VALUES (?, ?, ?, ?, ?, ?, ?, ?)", (index, user, text, date, sku, rating, photo, follow_up))
        db.executemany("INSERT INTO review_keywords VALUES (?, ?)", [(index, keyword) for keyword in keywords])
    db.commit()
    db.execute("VACUUM")
    db.close()


def dump(path):
    """
    The database's rows, for comparing contents rather than bytes (opened read-only, so it works on any volume).
    """
    db = sqlite3.connect(f"file:{path}?mode=ro&immutable=1", uri=True)
    try:
        return [db.execute(f"SELECT * FROM {table} ORDER BY rowid").fetchall() for table in ("places", "reviews", "review_keywords")]
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
