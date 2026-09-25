# Auction-house prices for every harvested battlefield drop.
#
# This is a separate script because it is the one step that needs your
# horizonxi.com account. The price endpoint is the only part of the item API
# behind a login, so the token stays in your shell and never goes anywhere but
# api.horizonxi.com:
#
#   1. log in at https://horizonxi.com
#   2. DevTools console:  document.cookie.match(/token=([^;]*)/)[1]
#   3. HXI_TOKEN=<paste> python3 tools/bf_prices.py
#
# Writes wikidata/prices.json -- one shared file keyed by in-game name, because
# a price is a property of the item, not of the battlefield that drops it, and
# KSNM and BCNM share most of their drop tables.
import json, os, sys, time, urllib.parse, urllib.request

GAME = "https://api.horizonxi.com/api/v1/"
DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "wikidata")

def detail(key, token, stack):
    url = GAME + "items/" + urllib.parse.quote(key) + "/auction-detail?stack=" + ("1" if stack else "0")
    req = urllib.request.Request(url, headers={
        "User-Agent": "gear-list-builder/1.0 (personal LuAshitacast config)",
        "Origin": "https://horizonxi.com",
        "Accept": "application/json",
        "Authorization": "Bearer " + token})
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                return json.loads(r.read().decode("utf8", "replace"))
        except urllib.error.HTTPError as e:
            if e.code == 401:
                sys.exit("401 from the price endpoint: the token is missing, wrong, or expired.")
            if e.code == 404: return None
            if attempt == 2: return None
            time.sleep(1.5 * (attempt + 1))
        except Exception:
            if attempt == 2: return None
            time.sleep(1.5 * (attempt + 1))

# The real shape, confirmed against a --dump:
#
#   {"item": {...},
#    "ah":     {"totalListings": 1, "soldLast15Days": 0,
#               "sales": [{"price", "sellDate", "sellerName", "buyerName"}]},
#    "bazaar": {"totalListings": 4,
#               "listings": [{"charname", "price", "quantity", "zone", "status"}]},
#    "itemNames": {...}}
#
# Both halves are worth keeping and they are not the same claim. An "ah" sale is
# gil that actually changed hands; a "bazaar" listing is one player's ask, which
# nobody may ever pay. soldLast15Days is the liquidity read -- an item with a
# high last sale and nothing moving for a fortnight is not really worth that.
def summarise(payload):
    if not payload: return None
    ah  = payload.get("ah") or {}
    baz = payload.get("bazaar") or {}
    sales = [r for r in (ah.get("sales") or []) if isinstance(r.get("price"), (int, float))]
    sales.sort(key=lambda r: r.get("sellDate") or "")
    prices = sorted(int(r["price"]) for r in sales)
    asks = sorted(int(r["price"]) for r in (baz.get("listings") or [])
                  if isinstance(r.get("price"), (int, float)))
    return {
        "last_sale":      int(sales[-1]["price"]) if sales else None,
        "last_sale_date": (sales[-1].get("sellDate") or "")[:10] if sales else None,
        "median_sale":    prices[len(prices) // 2] if prices else None,
        "sales":          len(prices),
        "sold_15d":       ah.get("soldLast15Days"),
        "ah_listings":    ah.get("totalListings"),
        "bazaar_low":     asks[0] if asks else None,
        "bazaar_listings": baz.get("totalListings"),
    }

def main():
    token = os.environ.get("HXI_TOKEN", "").strip()
    if not token:
        sys.exit(__doc__ or "set HXI_TOKEN (see the comment at the top of this file)")
    # Every category harvested so far, unioned: the same item priced once.
    details = {}
    for cat in sorted(os.listdir(DATA)):
        path = os.path.join(DATA, cat, "item_details.json")
        if os.path.exists(path): details.update(json.load(open(path)))

    # --dump writes one untouched response to disk. The parser above guesses at
    # the payout shape; this is how you check the guess against what the server
    # actually sent when a run comes back with no prices at all.
    if "--dump" in sys.argv:
        key = sys.argv[sys.argv.index("--dump") + 1]
        for stack in (False, True):
            raw = detail(key, token, stack)
            name = "debug_%s_%s.json" % (key, "stack" if stack else "single")
            json.dump(raw, open(os.path.join(DATA, name), "w"), indent=1)
            print(name, "->", "null" if raw is None else list(raw.keys()))
        return
    # --new tops up after a fresh harvest: keep what is already priced and only
    # fetch items the file has never seen. A full run is still the right call
    # when the prices themselves are what went stale.
    path = os.path.join(DATA, "prices.json")
    out = {}
    if "--new" in sys.argv and os.path.exists(path):
        out = json.load(open(path))
        print("keeping %d priced items, fetching what is missing" % len(out))
    for i, (name, item) in enumerate(sorted(details.items()), 1):
        if not item.get("ah"):      # EX and no-AH items have no price to fetch
            continue
        if name in out:
            continue
        row = {"single": summarise(detail(item["key"], token, False))}
        if item.get("stackable"):
            row["stack"] = summarise(detail(item["key"], token, True))
        out[name] = row
        if i % 25 == 0: print("  %d/%d" % (i, len(details)), flush=True)
        time.sleep(0.1)
    json.dump(out, open(path, "w"), indent=1)
    def has(v, field): return ((v or {}).get("single") or {}).get(field)
    sold   = sum(1 for v in out.values() if has(v, "last_sale"))
    asked  = sum(1 for v in out.values() if has(v, "bazaar_low"))
    print("fetched %d items: %d with a recorded sale, %d with a bazaar ask"
          % (len(out), sold, asked))

if __name__ == "__main__":
    main()
