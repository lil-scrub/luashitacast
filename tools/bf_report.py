# Reads what bf_harvest.py (and optionally bf_prices.py) wrote and prints the
# three views worth having: what each battlefield is worth entering for, what a
# given job can wear, and what can be sold. Gil per battlefield is bf_value.py.
#
#   python3 tools/bf_report.py [KSNM|BCNM] [BRD RDM ...]
import json, os, re, sys, collections

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "wikidata")
ARGS = [a.upper() for a in sys.argv[1:]]
CAT  = ARGS.pop(0) if ARGS and ARGS[0] in ("KSNM", "BCNM") else "KSNM"
DATA = os.path.join(ROOT, CAT.lower())
# The profiles are the directory above this one. LAC_PROFILE
# overrides it, for running against another copy of them.
PROF = os.environ.get("LAC_PROFILE", os.path.dirname(
    os.path.dirname(os.path.abspath(__file__))))

def load(name, default=None, root=None):
    path = os.path.join(root or DATA, name)
    if not os.path.exists(path):
        if default is not None: return default
        sys.exit("missing %s -- run tools/bf_harvest.py %s first" % (path, CAT))
    return json.load(open(path))

ksnm    = load("battlefields.json")
mapping = load("item_map.json")
details = load("item_details.json")
prices  = load("prices.json", {}, root=ROOT)

# Wiki title -> in-game name, so the same item spelled two ways across two
# battlefield pages collapses to one entry.
canon = {n: (v["name"] if v else n) for n, v in mapping.items()}

drops = collections.defaultdict(list)
for bf, page in ksnm.items():
    for group in page["groups"]:
        for row in group["rows"]:
            if row["item"] == "Nothing": continue
            drops[canon.get(row["item"], row["item"])].append(
                {"bf": bf, "rate": row["rate"], "qty": row["qty"],
                 "unverified": row["unverified"], "group": group["head"]})

def sprite(name, field, default=""):
    item = details.get(name)
    return item["sprite"].get(field, default) if item else default

def is_gear(name):
    return bool(sprite(name, "slot") or sprite(name, "weaponType"))

def wearable(name, job):
    if not is_gear(name): return False
    jobs = sprite(name, "jobs").strip()
    return jobs in ("", "All Jobs") or job in jobs.split("/")

def flags(name):
    item = details.get(name)
    if not item: return "?"
    return ("Rare " if item["rare"] else "") + ("EX" if item["ex"] else ("AH" if item["ah"] else "no-AH"))

# A recorded sale outranks an ask: one is gil that moved, the other is a hope.
def gil(name):
    p = prices.get(name, {}).get("single") or {}
    if p.get("last_sale"):  return "sold {:,}".format(p["last_sale"])
    if p.get("bazaar_low"): return "ask  {:,}".format(p["bazaar_low"])
    return "-"

def best(name):
    return max(drops[name], key=lambda d: d["rate"] or 0)

# A piece already named in the job's profile is not news; one that is not is a
# candidate for the ladder. Matched on the file text because that is where the
# names live -- the priority lists are plain Lua tables of them.
def in_profile(name, job):
    path = os.path.join(PROF, job + ".lua")
    if not os.path.exists(path): return False
    return ("'" + name + "'") in open(path).read()

def job_view(job):
    rows = sorted((n for n in drops if wearable(n, job)),
                  key=lambda n: (-sprite(n, "level", 0), n))
    print("\n%s: %d wearable drops" % (job, len(rows)))
    print("%-22s %-4s %-9s %-8s %-6s %-12s %s" % ("item", "lvl", "slot", "flags", "owned", "price", "best source"))
    for n in rows:
        b = best(n)
        print("%-22s %-4s %-9s %-8s %-6s %-12s %s %s%%%s" % (
            n, sprite(n, "level", 0), sprite(n, "slot") or sprite(n, "weaponType"),
            flags(n), "yes" if in_profile(n, job) else "", gil(n),
            b["bf"], round((b["rate"] or 0) * 100, 1),
            " (unverified)" if b["unverified"] else ""))

def battlefield_view(jobs):
    print("\n%s battlefields" % CAT)
    for bf, page in sorted(ksnm.items()):
        h = page["header"]
        print("\n%s  --  %s, %s players, %s" % (
            bf, h.get("entry item", "?"), h.get("members", "?"), h.get("zone", "?")))
        print("  mobs: " + ", ".join("%s x%d" % (m["name"], m["count"]) for m in page["mobs"]))
        for job in jobs:
            mine = sorted({d for d in drops
                           if wearable(d, job) and any(x["bf"] == bf for x in drops[d])})
            if mine: print("  %s: %s" % (job, ", ".join(mine)))

def sellable_view():
    sell = [n for n in drops if details.get(n) and details[n]["ah"] and not details[n]["ex"]]
    print("\nsellable drops: %d (of %d unique; %d are EX)" % (
        len(sell), len(drops), sum(1 for n in drops if details.get(n) and details[n]["ex"])))
    def key(n):
        p = prices.get(n, {}).get("single") or {}
        return -(p.get("last_sale") or p.get("bazaar_low") or 0)
    for n in sorted(sell, key=lambda n: (key(n), n)):
        b = best(n)
        print("  %-24s %-12s %-9s %s %s%%" % (
            n, gil(n), "stack" if details[n]["stackable"] else "single",
            b["bf"], round((b["rate"] or 0) * 100, 1)))

if __name__ == "__main__":
    jobs = ARGS or ["BRD", "RDM"]
    if not prices:
        print("(no prices.json -- run tools/bf_prices.py for auction prices)")
    for job in jobs: job_view(job)
    battlefield_view(jobs)
    sellable_view()
