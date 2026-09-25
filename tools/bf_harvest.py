# Pulls a category of battlefield pages from the HorizonXI wiki, then looks
# every drop up in the horizonxi.com item API. Two sources because they answer
# different questions: the wiki knows the drop groupings and rates, the item API
# knows the authoritative slot/level/job list and the Rare/EX/AH flags -- and it
# returns the game's short names, which is what a LuAshitacast bag scan matches
# against.
#
#   python3 tools/bf_harvest.py [KSNM|BCNM]
#
# Each category writes its own directory under wikidata/, because the two share
# most of their drop tables but none of their entry costs.
import json, os, re, sys, time, urllib.parse, urllib.request

WIKI = "https://horizonffxi.wiki/w/api.php"
GAME = "https://api.horizonxi.com/api/v1/"
UA   = {"User-Agent": "gear-list-builder/1.0 (personal LuAshitacast config)"}
CAT  = (sys.argv[1] if len(sys.argv) > 1 else "KSNM").upper()
OUT  = os.path.join(os.path.dirname(os.path.abspath(__file__)), "wikidata", CAT.lower())

def get(url, headers):
    for attempt in range(4):
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=45) as r:
                return json.loads(r.read().decode("utf8", "replace"))
        except Exception:
            if attempt == 3: raise
            time.sleep(2 * (attempt + 1))

def wiki(**params):
    params.setdefault("format", "json")
    return get(WIKI + "?" + urllib.parse.urlencode(params), UA)

# The game API only answers for horizonxi.com, so the Origin has to be sent.
def game(path, **params):
    url = GAME + path + ("?" + urllib.parse.urlencode(params) if params else "")
    return get(url, dict(UA, Origin="https://horizonxi.com"))

def battlefields():
    d = wiki(action="query", list="categorymembers", cmtitle="Category:" + CAT,
             cmlimit="500", cmnamespace="0")
    return sorted(m["title"] for m in d["query"]["categorymembers"])

def pages(titles):
    out = {}
    for i in range(0, len(titles), 20):
        d = wiki(action="query", prop="revisions", rvprop="content",
                 rvslots="main", redirects=1, titles="|".join(titles[i:i + 20]))
        for p in d.get("query", {}).get("pages", {}).values():
            try: out[p["title"]] = p["revisions"][0]["slots"]["main"]["*"]
            except Exception: pass
        time.sleep(0.15)
    return out

# Drop rates come in two spellings across the pages -- {{Hxi Drop Rate|asb=N/1000}}
# on the pages fed from the drop-rate database, a bare (N%) on the hand-written
# ones -- and a few rows carry no rate at all ("All of:" groups). Read all three
# rather than only the common one, or whole battlefields parse as having no drops.
def parse(text):
    header = {}
    h = re.search(r"\{\{Battlefield Header(.*?)\n\}\}", text, re.S)
    if h:
        for line in h.group(1).split("\n|"):
            if "=" in line:
                k, v = line.split("=", 1)
                header[k.strip().lstrip("|").strip()] = v.strip()
    else:
        # A handful of older pages predate the template and write the same
        # fields as bolded lines. Without this they parse as having no level,
        # no party size and no orb at all.
        for key, pat in (("zone",       r"'''Zone:'''\s*\[\[([^\]|]+)"),
                         ("level",      r"'''Level:'''\s*([^<\n]+)"),
                         ("members",    r"'''Members:'''\s*([^<\n]+)"),
                         ("time",       r"'''Time:'''\s*([^<\n]+)"),
                         ("entry item", r"'''Orb:'''\s*\[\[([^\]|]+)")):
            m = re.search(pat, text)
            if m: header[key] = m.group(1).strip()

    mobs = []
    m = re.search(r"==\s*Mobs\s*==(.*?)(?=\n==)", text, re.S)
    if m:
        for mm in re.finditer(r"\|\s*\[\[([^\]|]+?)(?:\|[^\]]*)?\]\]\s*(?:x\s*(\d+))?", m.group(1)):
            name = mm.group(1).strip()
            # The table's Job column links job pages; they are not mobs.
            if name.lower().startswith((":category", "category")): continue
            if name in JOB_PAGES: continue
            mobs.append({"name": name, "count": int(mm.group(2) or 1)})

    groups = []
    # "Possible Rewards" on most pages, "Treasure" on the oldest ones.
    parts = re.split(r"==\s*(?:Possible Rewards|Treasure)\s*==", text)
    if len(parts) > 1:
        body = re.split(r"\n==[^=]", parts[1])[0]
        for table in re.split(r"\{\|", body)[1:]:
            table = table.split("|}")[0]
            head = re.search(r"!\s*(.+)", table)
            rows = []
            for line in table.split("\n|"):
                item = re.search(r"\[\[([^\]|]+?)(?:\|[^\]]*)?\]\]", line)
                name = item.group(1).strip() if item else (
                    "Nothing" if re.match(r"\s*Nothing", line) else None)
                if not name: continue
                rate = None
                asb = re.search(r"Hxi Drop Rate\|asb=(\d+)/(\d+)", line)
                pct = re.search(r"\((\d+(?:\.\d+)?)%\)", line)
                if asb:   rate = int(asb.group(1)) / int(asb.group(2))
                elif pct: rate = float(pct.group(1)) / 100
                qty = re.search(r"\]\]\s*x\s*(\d+)", line)
                count = int(qty.group(1)) if qty else 1
                # A gil reward writes its amount ahead of the link ("24,000
                # [[Gil]]"). Carried as the quantity so it prices at face value
                # instead of looking like one unsellable item called Gil.
                if name == "Gil":
                    amount = re.search(r"([\d,]+)\s*\[\[Gil\]\]", line)
                    if amount: count = int(amount.group(1).replace(",", ""))
                rows.append({"item": name, "rate": rate,
                             "qty": count,
                             # A row tagged for verification, or a whole table
                             # wrapped in the toau span, is not confirmed for
                             # this era -- kept, but flagged.
                             "unverified": "verification" in line
                                           or "toau" in table.split("\n")[0]})
            if rows:
                groups.append({"head": re.sub(r"\s+", " ", head.group(1)).strip() if head else "",
                               "rows": rows})
        # The two song-scroll BCNMs list their one reward as a bare link with no
        # table around it. Guaranteed, so read it as an "All of:" group rather
        # than recording the battlefield as dropping nothing at all.
        if not groups:
            bare = [{"item": m.group(1).strip(), "rate": 1.0, "qty": 1, "unverified": False}
                    for m in re.finditer(r"^\s*\[\[([^\]|]+?)(?:\|[^\]]*)?\]\]\s*$", body, re.M)]
            if bare: groups.append({"head": "All of:", "rows": bare})
    return {"header": header, "mobs": mobs, "groups": groups}

JOB_PAGES = {"Warrior", "Monk", "White Mage", "Black Mage", "Red Mage", "Thief",
             "Paladin", "Dark Knight", "Beastmaster", "Bard", "Ranger",
             "Samurai", "Ninja", "Dragoon", "Summoner", "Blue Mage"}

def main():
    os.makedirs(OUT, exist_ok=True)
    names = battlefields()
    print("%s battlefields: %d" % (CAT, len(names)))
    fields = {t: parse(x) for t, x in pages(names).items()}
    json.dump(fields, open(os.path.join(OUT, "battlefields.json"), "w"), indent=1)

    # The entry item is the whole cost of a run, and it is paid in seals, not
    # gil -- so the orb pages are worth one more round trip to make gil per seal
    # answerable. A few entry items (Monarch's Orb, Cloud Evoker) are not sold
    # for seals at all and simply have no price line.
    orbs = {}
    entries = sorted({v["header"].get("entry item", "") for v in fields.values()} - {"", "None"})
    for title, text in pages(entries).items():
        m = re.search(r"Price:[^\d\[]*([\d,]+)\s*\[\[([^\]|]+?)\]\]", text)
        if m: orbs[title] = {"seals": int(m.group(1).replace(",", "")),
                             "currency": m.group(2).strip()}
    json.dump(orbs, open(os.path.join(OUT, "orbs.json"), "w"), indent=1)
    print("orb prices:", len(orbs), "of", len(entries))

    drops = sorted({r["item"] for v in fields.values() for g in v["groups"]
                    for r in g["rows"] if r["item"] != "Nothing"})
    print("unique drops:", len(drops))

    # Wiki page titles are not always the in-game name, and the search endpoint
    # is the only thing that bridges them. Fall back to the sole hit when the
    # search narrows to one item but the names differ (Phil. Stone,
    # Cashmere Thrd., Siren's Hair).
    norm = lambda s: re.sub(r"[^a-z0-9+]", "", s.lower())

    # Several wiki titles drop the apostrophe the game keeps (Evokers Boots,
    # Sirens Hair), spell a spell scroll as its scroll (Scroll of Cure V) or add
    # a disambiguator (King of Cups (Card)). Try those rewrites before giving up
    # -- an unresolved name loses the item's flags and job list entirely.
    def variants(name):
        yield name
        yield re.sub(r"\s*\([^)]*\)\s*$", "", name)
        yield re.sub(r"^Scroll of ", "", name)
        yield re.sub(r"\b(\w+)s\b", r"\1's", name, count=1)
        # The search matches the key's tokens, not the printed name, so a title
        # whose words are reordered or padded in the key ("Holla Ring" ->
        # teleport_ring_holla, "Ajari Necklace" -> ajari_bead_necklace) is only
        # found by asking for one distinctive word on its own.
        for word in sorted(re.findall(r"[A-Za-z]{4,}", name), key=len, reverse=True)[:2]:
            yield word

    def resolve(name):
        for query in dict.fromkeys(v for v in variants(name) if v):
            d = game("items", search=query)
            if not (d and d.get("items")): continue
            # The name asked for is always a candidate answer, even when the
            # query that found the page was only one word of it.
            exact = [i for i in d["items"] if norm(i["name"]) == norm(name)]
            if exact: return exact[0]
            # The API abbreviates long names (Orichalcum Ingot is "Ocl. Ingot"),
            # so the key is often the only field that still spells it out.
            hit = ([i for i in d["items"] if i["name"].lower() == query.lower()]
                or [i for i in d["items"] if norm(i["name"]) == norm(query)]
                or [i for i in d["items"] if norm(i["key"]) == norm(query)])
            if hit: return hit[0]
            if d["total"] == 1: return d["items"][0]
        return None

    # Item lookups are two API calls each and never change, so keeping what a
    # previous run resolved makes re-parsing the wiki cheap to iterate on.
    def cached(name):
        path = os.path.join(OUT, name)
        return json.load(open(path)) if os.path.exists(path) else {}
    mapping, details = cached("item_map.json"), cached("item_details.json")
    for name in drops:
        if mapping.get(name): continue   # retry the ones a past run could not place
        hit = resolve(name)
        mapping[name] = hit
        if hit:
            full = game("items/" + urllib.parse.quote(hit["key"]))
            if full: details[hit["name"]] = full
        time.sleep(0.08)
    json.dump(mapping, open(os.path.join(OUT, "item_map.json"), "w"), indent=1)
    json.dump(details, open(os.path.join(OUT, "item_details.json"), "w"), indent=1)
    missing = [n for n, v in mapping.items() if not v]
    print("resolved:", len(details), "unresolved:", len(missing), missing)

if __name__ == "__main__":
    main()
