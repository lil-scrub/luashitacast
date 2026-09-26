"""Check every ladder entry in a job profile against the game item API.

The wiki the ladders are scored from is not the authority on what Horizon has
or on what a job may wear, and it spells items with their long names while a
bag scan matches the short ones. Both gaps are silent: a bad entry never
equips and nothing in the game says so. This reads the ladders straight out of
the profile and reports, per entry, whether the item exists on Horizon, whether
the job can wear it, whether it is within the level cap, and whether it belongs
to the slot it was listed under.

    python3 tools/audit_ladders.py BST
    python3 tools/audit_ladders.py DRG 75

Prints nothing for a ladder with no problems. The item list (13k entries, name
and key only) and the per-item details are cached under wikidata/api/, so a
second run costs one request per entry that is new to the profile.
"""

import json, os, re, sys, time, urllib.parse, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
PROFILE = os.path.expanduser(os.environ.get("LAC_PROFILE", os.path.dirname(HERE)))
CACHE = os.path.join(HERE, "wikidata", "api")
GAME = "https://api.horizonxi.com/api/v1/"
# The API answers anonymously but only with the site's own Origin.
UA = {"User-Agent": "Mozilla/5.0", "Origin": "https://horizonxi.com"}

# Ladder slot name -> the slot the API calls it. Ear1/Ear2 and Ring1/Ring2 are
# LuAshitacast's names for a pair the game calls one thing.
SLOTS = {"Main": "Main", "Sub": "Sub", "Ammo": "Ammo", "Head": "Head",
         "Neck": "Neck", "Ear1": "Ear", "Ear2": "Ear", "Body": "Body",
         "Hands": "Hands", "Ring1": "Ring", "Ring2": "Ring", "Back": "Back",
         "Waist": "Waist", "Legs": "Legs", "Feet": "Feet"}


def get(path, **params):
    url = GAME + path + ("?" + urllib.parse.urlencode(params) if params else "")
    for attempt in range(4):
        try:
            req = urllib.request.Request(url, headers=UA)
            with urllib.request.urlopen(req, timeout=60) as r:
                return json.load(r)
        except Exception as exc:
            if attempt == 3:
                print("  !! %s: %s" % (url, exc), file=sys.stderr)
                return None
            time.sleep(1 + attempt)


def cached(name):
    path = os.path.join(CACHE, name)
    return json.load(open(path)) if os.path.exists(path) else {}


def save(name, data):
    os.makedirs(CACHE, exist_ok=True)
    json.dump(data, open(os.path.join(CACHE, name), "w"), indent=0)


def norm(name):
    # Punctuation and spacing differ freely between the profile and the API
    # ("Ryl.Sqr. Chnml. +2"), but + and - do not: Mst. Helm +1 is the relic and
    # Mst. Helm -1 is the broken one that can no longer be worn.
    return re.sub(r"[^a-z0-9+-]", "", name.lower())


def index():
    """key -> short name, for every item on the server."""
    items = cached("item_index.json")
    if items:
        return items
    offset = 0
    while True:
        page = get("items", limit=500, offset=offset)
        if not (page and page.get("items")):
            break
        for item in page["items"]:
            items[item["key"]] = item["name"]
        if len(page["items"]) < 500:
            break
        offset += 500
    save("item_index.json", items)
    return items


def ladders(path):
    """{ladder name: {slot: [entry, ...]}} out of the profile's set table."""
    src = open(path, encoding="utf-8").read()
    found = {}
    for block in re.finditer(r"\['(\w+_Priority)'\]\s*=\s*\{(.*?)\n\s*\},\n", src, re.S):
        slots = {}
        for slot in re.finditer(r"(\w+)\s*=\s*\{([^}]*)\}", block.group(2)):
            slots[slot.group(1)] = re.findall(r"'((?:[^'\\]|\\.)*)'", slot.group(2))
        # A slot holding one item is written without the braces.
        for slot in re.finditer(r"(\w+)\s*=\s*'((?:[^'\\]|\\.)*)'\s*,", block.group(2)):
            slots.setdefault(slot.group(1), [slot.group(2)])
        found[block.group(1)] = slots
    return found


def main():
    job = sys.argv[1].upper()
    cap = int(sys.argv[2]) if len(sys.argv) > 2 else 75

    by_name = {}
    for key, name in index().items():
        by_name.setdefault(norm(name), key)
    details = cached("item_details.json")

    def detail(name):
        key = by_name.get(norm(name))
        if key is None:
            return None
        if key not in details:
            details[key] = get("items/" + urllib.parse.quote(key))
            time.sleep(0.05)
        return details[key]

    problems = 0
    for ladder, slots in sorted(ladders(os.path.join(PROFILE, job + ".lua")).items()):
        lines = []
        for slot, names in slots.items():
            for name in names:
                name = name.replace("\\'", "'")
                item = detail(name)
                if item is None:
                    lines.append((slot, name, "no item of that name on Horizon"))
                    continue
                sprite = item.get("sprite") or {}
                jobs = sprite.get("jobs", "")
                level = sprite.get("level")
                worn = sprite.get("slot", "")
                bad = []
                if jobs.strip() and "All Jobs" not in jobs and job not in jobs.split("/"):
                    bad.append("%s cannot wear it (%s)" % (job, jobs))
                if level and level > cap:
                    bad.append("Lv%d, past the %d cap" % (level, cap))
                want = SLOTS.get(slot)
                if want and worn and want not in [s.strip() for s in worn.split("/")]:
                    bad.append("worn in %s, not %s" % (worn, slot))
                if bad:
                    lines.append((slot, name, "; ".join(bad)))
        if lines:
            problems += len(lines)
            print("%s" % ladder)
            for slot, name, why in lines:
                print("  %-6s %-22s %s" % (slot, name, why))
            print()
    save("item_details.json", details)
    print("%s: %d entr%s to fix" % (job, problems, "y" if problems == 1 else "ies"))


if __name__ == "__main__":
    main()
