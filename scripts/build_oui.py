"""Convert the IEEE MA-L registry (oui.csv) into the app's vendor table.

Usage: python3 scripts/build_oui.py oui.csv Core/Sources/WifiSpectrumCore/Resources/oui.tsv
"""
import csv, gzip, sys

src, dst = sys.argv[1], sys.argv[2]
rows = {}
with open(src, newline="", encoding="utf-8") as f:
    for r in csv.DictReader(f):
        if r["Registry"] != "MA-L":
            continue
        name = " ".join(r["Organization Name"].split())
        if name:
            rows[r["Assignment"].upper()] = name
opener = gzip.open if dst.endswith(".gz") else open
with opener(dst, "wt", encoding="utf-8") as out:
    for k in sorted(rows):
        out.write(f"{k}\t{rows[k]}\n")
print(len(rows), "entries")
