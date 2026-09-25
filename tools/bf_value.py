# What a battlefield is worth in gil, per clear.
#
#   python3 tools/bf_value.py [KSNM|BCNM] [--top N] [--all] [substring]
#
# Expected value, not a jackpot: every drop row is its own roll, so a run is
# worth the sum of (drop rate x what that item actually sells for) across every
# row of every reward table. A 5% Damascus Ingot is worth more per run than a
# 90% Philosopher's Stone, and only this sum says so.
#
# Horizon runs "your orb, your drops", so the whole crate goes to whoever paid
# the seals. These totals are what one clear is worth to the orb holder -- they
# are not divided by party size, and the cost side is seals, not gil.
#
# Two numbers are printed because one of them lies on its own:
#
#   expected   every priced drop counted
#   liquid     only drops that actually sold in the last 15 days
#
# An item with a fat last sale and nothing moving for a fortnight is gil on
# paper. The gap between the two columns is how much of the take is theoretical.
#
# Unpriced rows are EX (never sellable, and often the real reason to go) or
# simply never listed; both are counted separately rather than folded in as
# zero, so a low number is readable as "not worth much" or "not known yet".
import json, os, sys, collections

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "wikidata")

def parse_args(argv):
    cat, top, show_all, pick = "KSNM", 10, False, None
    rest = []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a.upper() in ("KSNM", "BCNM"): cat = a.upper()
        elif a == "--all": show_all = True
        elif a == "--top": i += 1; top = int(argv[i])
        else: rest.append(a)
        i += 1
    if rest: pick = " ".join(rest).lower()
    return cat, top, show_all, pick

CAT, TOP, SHOW_ALL, PICK = parse_args(sys.argv[1:])
DATA = os.path.join(ROOT, CAT.lower())

def load(name, root=None, default=None):
    path = os.path.join(root or DATA, name)
    if not os.path.exists(path):
        if default is not None: return default
        sys.exit("missing %s -- run tools/bf_harvest.py %s first" % (path, CAT))
    return json.load(open(path))

fields  = load("battlefields.json")
mapping = load("item_map.json")
details = load("item_details.json")
prices  = load("prices.json", root=ROOT, default={})
orbs    = load("orbs.json", default={})

canon = {n: (v["name"] if v else n) for n, v in mapping.items()}

# A sale is gil that moved; the median of the recorded sales is steadier than
# the last one, which is often an outlier or a friend's undercut. Bazaar asks
# are deliberately ignored here -- they include 99,999,999 placeholders that
# would swamp every total they touched.
def unit_price(name):
    if name == "Gil": return 1        # the row's quantity is the gil amount
    p = (prices.get(name) or {}).get("single") or {}
    return p.get("median_sale") or p.get("last_sale")

def liquid(name):
    if name == "Gil": return True
    return bool(((prices.get(name) or {}).get("single") or {}).get("sold_15d"))

def why_unpriced(name):
    item = details.get(name)
    if not item: return "unknown item"
    if item.get("ex"): return "EX"
    if not item.get("ah"): return "no AH"
    return "never listed"

# "All of:" rows are guaranteed and carry no rate on the wiki; everywhere else a
# missing rate means the page never recorded one, which is not the same as 1.0.
def row_rate(group, row):
    if row["rate"] is not None: return row["rate"]
    return 1.0 if group["head"].lower().startswith("all of") else None

def value(bf):
    page = fields[bf]
    rows, unrated = [], 0
    for group in page["groups"]:
        for row in group["rows"]:
            if row["item"] == "Nothing": continue
            name = canon.get(row["item"], row["item"])
            rate = row_rate(group, row)
            if rate is None:
                unrated += 1
                continue
            price = unit_price(name)
            rows.append({"name": name, "rate": rate, "qty": row["qty"],
                         "price": price, "liquid": liquid(name),
                         "ev": (price or 0) * rate * row["qty"]})
    # The same item in two tables is two independent rolls: add the gil, keep
    # the rate readable as the chance of seeing it at all.
    merged = {}
    for r in rows:
        m = merged.setdefault(r["name"], dict(r, rate=0.0, ev=0.0))
        m["rate"] = 1 - (1 - m["rate"]) * (1 - r["rate"])
        m["ev"] += r["ev"]
    rows = sorted(merged.values(), key=lambda r: -r["ev"])
    orb = orbs.get(page["header"].get("entry item", ""), {})
    seals = orb.get("seals")
    return {
        "bf": bf, "header": page["header"], "rows": rows, "unrated": unrated,
        "seals": seals, "currency": orb.get("currency", ""),
        "per_seal": (sum(r["ev"] for r in rows) / seals) if seals else None,
        "ev":     sum(r["ev"] for r in rows),
        "ev_liq": sum(r["ev"] for r in rows if r["liquid"]),
        "priced": sum(1 for r in rows if r["price"]),
    }

# A few fights have two wiki pages under one name ("Treasure And/and
# Tribulations"), one of them an older copy whose table never recorded a drop
# rate. Listing both would double the fight and rank the dead copy at zero.
def unique(names):
    best = {}
    for bf in names:
        rated = sum(1 for g in fields[bf]["groups"] for r in g["rows"]
                    if row_rate(g, r) is not None)
        key = bf.lower()
        if rated > best.get(key, (-1, None))[0]: best[key] = (rated, bf)
    return sorted(bf for _, bf in best.values())

def money(n): return "{:>11,}".format(int(round(n)))

def summary(vals):
    print("\n%s battlefields by expected gil per clear\n" % CAT)
    print("%-32s %-6s %-3s %12s %12s %9s %7s %8s  %s"
          % ("battlefield", "lvl", "pt", "expected", "liquid", "priced",
             "seals", "gil/seal", "entry"))
    for v in vals:
        h = v["header"]
        print("%-32s %-6s %-3s %s %s %5d/%-3d %7s %8s  %s" % (
            v["bf"][:32], h.get("level", "?")[:6], h.get("members", "?"),
            money(v["ev"]), money(v["ev_liq"]), v["priced"], len(v["rows"]),
            v["seals"] or "-", "{:,}".format(int(v["per_seal"])) if v["per_seal"] else "-",
            h.get("entry item", "?")))
    tot = sum(v["ev"] for v in vals)
    print("\n%-32s %-6s %-3s %s %s" % ("all %d" % len(vals), "", "",
          money(tot), money(sum(v["ev_liq"] for v in vals))))

    # The orb is the real cost, and it is not gil -- so what a seal buys, not
    # what a clear pays, is the ranking to enter a battlefield by.
    ranked = [v for v in vals if v["per_seal"]]
    if ranked:
        cur = ranked[0]["currency"] or "seal"
        print("\ngil per %s\n" % cur)
        for v in sorted(ranked, key=lambda v: -v["per_seal"]):
            print("%-32s %7s seals %11s /seal  %11s liquid /seal" % (
                v["bf"][:32], v["seals"], "{:,}".format(int(v["per_seal"])),
                "{:,}".format(int(v["ev_liq"] / v["seals"]))))

def detail(v):
    h = v["header"]
    print("\n%s  --  Lv%s, %s players, %s, %s" % (
        v["bf"], h.get("level", "?"), h.get("members", "?"),
        h.get("entry item", "?"), h.get("zone", "?")))
    print("   expected %s  liquid %s%s%s" % (
        money(v["ev"]).strip(), money(v["ev_liq"]).strip(),
        "  (%s %ss -> %s gil/seal)" % (v["seals"], v["currency"],
                                       "{:,}".format(int(v["per_seal"]))) if v["per_seal"] else "",
        "   (%d rows with no recorded drop rate)" % v["unrated"] if v["unrated"] else ""))
    priced = [r for r in v["rows"] if r["price"]]
    shown  = priced if SHOW_ALL else priced[:TOP]
    print("   %-26s %6s %11s %11s  %s" % ("drop", "rate", "each", "per run", ""))
    for r in shown:
        print("   %-26s %5.1f%% %11s %11s  %s" % (
            r["name"][:26], r["rate"] * 100, "{:,}".format(r["price"]),
            "{:,}".format(int(round(r["ev"]))), "" if r["liquid"] else "(stale)"))
    rest = priced[len(shown):]
    if rest:
        print("   %-26s %6s %11s %11s" % ("+ %d more priced drops" % len(rest), "", "",
              "{:,}".format(int(round(sum(r["ev"] for r in rest))))))
    unpriced = collections.defaultdict(list)
    for r in v["rows"]:
        if not r["price"]: unpriced[why_unpriced(r["name"])].append(r["name"])
    for reason, names in sorted(unpriced.items()):
        print("   no gil value (%s): %s" % (reason, ", ".join(sorted(names))))

if __name__ == "__main__":
    if not prices:
        sys.exit("no wikidata/prices.json -- run tools/bf_prices.py (needs HXI_TOKEN)")
    vals = sorted((value(bf) for bf in unique(fields)), key=lambda v: -v["ev"])
    if PICK:
        vals = [v for v in vals if PICK in v["bf"].lower()] or sys.exit("no battlefield matching %r" % PICK)
        for v in vals: detail(v)
    else:
        summary(vals)
        for v in vals: detail(v)
