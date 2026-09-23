import json, re
d = json.load(open("wiki_raw.json"))
pages = d["pages"]

def field(block, name):
    m = re.search(r"\n\s*\|\s*%s\s*=\s*(.*?)(?=\n\s*\|\s*[a-z ]+\s*=|\Z)" % name, block, re.S|re.I)
    return m.group(1).strip() if m else ""

items = {}
for title, text in pages.items():
    m = re.search(r"\{\{Item Statistics(.*?)\n\s*\}\}", text, re.S)
    if not m:
        m = re.search(r"\{\{Item Statistics(.*)", text, re.S)
        if not m: continue
    block = m.group(1)
    stats = field(block, "stats")
    horizon = ""
    h = re.search(r"HorizonChangesBox\|(.*?)\n\}\}", text, re.S)
    if h: horizon = h.group(1).strip()
    lvl = field(block, "level")
    lm = re.search(r"\d+", lvl)
    items[title] = {
        "slot":  re.sub(r"\[\[|\]\]", "", field(block, "slot")).strip(),
        "level": int(lm.group()) if lm else None,
        "jobs":  field(block, "jobs"),
        "stats": stats,
        "notes": field(block, "notes")[:400],
        "horizon": horizon[:400],
        "cat": d["cats"].get(title, ""),
    }
json.dump(items, open("items.json","w"))
print("parsed:", len(items), "of", len(pages))
noslot = [t for t,v in items.items() if not v["slot"]]
print("no slot field:", len(noslot))
nolevel = [t for t,v in items.items() if v["level"] is None]
print("no level field:", len(nolevel))
# BRD-wearable
brd = {t:v for t,v in items.items() if re.search(r"\[\[BRD\]\]", v["jobs"]) or v["jobs"].strip()==""}
print("BRD-wearable or all-jobs:", len(brd))
print("explicit BRD:", sum(1 for v in items.values() if re.search(r"\[\[BRD\]\]", v['jobs'])))
