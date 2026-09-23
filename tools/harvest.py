import json, re, time, urllib.parse, urllib.request, os, sys

API = "https://horizonffxi.wiki/w/api.php"
UA  = {"User-Agent": "gear-list-builder/1.0 (personal LuAshitacast config)"}

def api(**params):
    params.setdefault("format", "json")
    url = API + "?" + urllib.parse.urlencode(params)
    for attempt in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=45) as r:
                return json.loads(r.read().decode("utf8", "replace"))
        except Exception as e:
            if attempt == 3: raise
            time.sleep(2 * (attempt + 1))

CATS = ["Head","Neck","Earrings","Body","Hands","Rings","Back","Waist","Legs","Feet",
        "Staves","String Instruments","Wind Instruments"]

def members(cat):
    out, cont = [], {}
    while True:
        d = api(action="query", list="categorymembers", cmtitle="Category:"+cat,
                cmlimit="500", cmnamespace="0", **cont)
        out += [m["title"] for m in d.get("query", {}).get("categorymembers", [])]
        if "continue" in d: cont = d["continue"]
        else: break
    return out

titles = {}
for c in CATS:
    m = members(c)
    for t in m: titles.setdefault(t, c)
    print("%-20s %4d" % (c, len(m)), flush=True)
allt = sorted(titles)
print("unique pages:", len(allt), flush=True)

pages = {}
for i in range(0, len(allt), 50):
    batch = allt[i:i+50]
    d = api(action="query", prop="revisions", rvprop="content", rvslots="main",
            titles="|".join(batch))
    for p in d.get("query", {}).get("pages", {}).values():
        try: pages[p["title"]] = p["revisions"][0]["slots"]["main"]["*"]
        except Exception: pass
    if i % 500 == 0: print("  fetched", i+len(batch), "/", len(allt), flush=True)
    time.sleep(0.15)

print("pages fetched:", len(pages), flush=True)
json.dump({"cats": titles, "pages": pages}, open("wiki_raw.json","w"))
print("saved wiki_raw.json (%.1f MB)" % (os.path.getsize("wiki_raw.json")/1e6))
