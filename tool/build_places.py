"""Build the offline places database bundled with the app.

Source: GeoNames (https://www.geonames.org), licensed CC BY 4.0.

Usage:
    python -I tool/build_places.py <cities1000.txt> <admin1CodesASCII.txt> <countryInfo.txt> <out.tsv.gz>

Output format (UTF-8, gzip, tab separated, sorted by population desc):
    line 1: "#TZ" followed by every timezone id (rows reference them by index)
    line 2: "#CC" followed by "code=country name" pairs
    rows:   name, ascii name (empty if same as name), admin1 name, country code,
            latitude, longitude, timezone index, population
"""

import gzip
import sys


def main() -> None:
    cities_path, admin1_path, country_path, out_path = sys.argv[1:5]

    admin1 = {}
    with open(admin1_path, encoding="utf-8") as f:
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) >= 2:
                admin1[parts[0]] = parts[1]

    countries = {}
    with open(country_path, encoding="utf-8") as f:
        for line in f:
            if line.startswith("#"):
                continue
            parts = line.rstrip("\n").split("\t")
            if len(parts) > 4:
                countries[parts[0]] = parts[4]

    rows = []
    with open(cities_path, encoding="utf-8") as f:
        for line in f:
            p = line.rstrip("\n").split("\t")
            if len(p) < 18 or not p[17]:
                continue
            name, ascii_name = p[1], p[2]
            cc, a1 = p[8], p[10]
            pop = int(p[14] or 0)
            rows.append(
                (
                    name,
                    "" if ascii_name == name else ascii_name,
                    admin1.get(f"{cc}.{a1}", ""),
                    cc,
                    f"{float(p[4]):.4f}",
                    f"{float(p[5]):.4f}",
                    p[17],
                    pop,
                )
            )

    rows.sort(key=lambda r: -r[7])
    tz_ids = sorted({r[6] for r in rows})
    tz_index = {tz: i for i, tz in enumerate(tz_ids)}
    used_cc = sorted({r[3] for r in rows})

    with gzip.open(out_path, "wt", encoding="utf-8", compresslevel=9) as out:
        out.write("#TZ\t" + "\t".join(tz_ids) + "\n")
        out.write(
            "#CC\t"
            + "\t".join(f"{cc}={countries.get(cc, cc)}" for cc in used_cc)
            + "\n"
        )
        for r in rows:
            out.write(
                "\t".join(
                    [r[0], r[1], r[2], r[3], r[4], r[5], str(tz_index[r[6]]), str(r[7])]
                )
                + "\n"
            )

    print(f"{len(rows)} places, {len(tz_ids)} timezones -> {out_path}")


if __name__ == "__main__":
    main()
