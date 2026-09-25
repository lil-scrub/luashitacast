# Gear data tools

Not loaded by the game. LuAshitacast only reads `<JOB>.lua` from the profile
root, so nothing in here affects the addon.

These exist because the gear ladders in the job profiles are scored by hand
against the HorizonXI wiki, and every earlier regeneration threw the source
data away afterwards.

The two scripts that read the live profiles -- `bf_report.py`, for its "already
in the set" column, and `dump_sets.lua` -- read the directory above this one.
Point `LAC_PROFILE` at another copy to work against that instead:

    LAC_PROFILE=~/some/other/profile python3 tools/bf_report.py KSNM BRD

## Files

| File | What it is |
|---|---|
| `harvest.py` | Pulls every equipment page from the HorizonXI wiki API into `wikidata/wiki_raw.json` |
| `parse.py` | Parses the raw wikitext into `wikidata/items.json` |
| `wikidata/items.json` | 3,733 items: slot, level, jobs, stats, notes, Horizon changes |
| `wikidata/wiki_raw.json.gz` | The raw wikitext the parse came from, gzipped |
| `bf_harvest.py` | Pulls a battlefield category (20 KSNM, 46 BCNM) and looks every drop up in the game item API |
| `bf_prices.py` | Auction prices for those drops; needs a horizonxi.com account token |
| `bf_report.py` | Prints the drops by job, by battlefield, and by what can be sold |
| `bf_value.py` | Prints what each battlefield is worth in gil per clear |
| `wikidata/ksnm/`, `wikidata/bcnm/` | One directory per harvested category |
| `wikidata/prices.json` | Auction prices, shared across categories and keyed by in-game name |
| `lacstub.lua` | Stubbed LuAshitacast globals: loads a job profile outside the game against a fake inventory |
| `dump_sets.lua` | Dumps a profile's resolved sets, its ladders, and what its handlers equip, for diffing a re-score |

## Diffing a profile

    luajit tools/dump_sets.lua BST 75 > before.txt
    # edit the profile
    luajit tools/dump_sets.lua BST 75 > after.txt
    diff before.txt after.txt

The game is not involved: `lacstub.lua` supplies `gFunc`, `gData`, `gSettings`
and `AshitaCore`, and fills the bags with one of every item the profile names,
so each ladder resolves to its head. The dump covers the resolved sets, the
ladders behind them, and what each handler equips -- including the jug
selection, which is profile-local state and otherwise only observable in game.

## Regenerating

    python3 harvest.py && python3 parse.py

Harvest takes a few minutes and makes roughly 80 API calls against
`https://horizonffxi.wiki/w/api.php`. The API lives at `/w/api.php`, not
`/api.php`, and its search index does not support `insource:`, which is why
this walks the slot categories instead of querying by stat.

The battlefield set is separate because it reads two sources:

    python3 bf_harvest.py KSNM && python3 bf_value.py KSNM
    python3 bf_harvest.py BCNM && python3 bf_value.py BCNM

The wiki knows the crate groupings and drop rates; `https://api.horizonxi.com`
knows the authoritative slot, level and job list, the Rare/EX/AH flags, and the
short in-game names a bag scan actually matches. That API needs an
`Origin: https://horizonxi.com` header or it will not answer.

## Prices need your account

`items/<item>/auction-detail` is the one item endpoint behind a login; without a
token it returns 401, and there is no public route to auction prices. So
`bf_prices.py` is split out and reads `HXI_TOKEN` from the environment,
keeping the token in your shell:

    # logged in at horizonxi.com, in the browser console:
    document.cookie.match(/token=([^;]*)/)[1]

    HXI_TOKEN=<paste> python3 bf_prices.py

One run prices every category harvested so far into one shared
`wikidata/prices.json`, because a price belongs to the item, not to the
battlefield that dropped it, and KSNM and BCNM overlap heavily. `bf_report.py`
merges it when it exists and says so when it does not; `bf_value.py` refuses to
run without it. The public `items/bazaar` feed needs no token but only covers
whatever is sitting in a player bazaar right now -- a handful of the ~600 drops.

## What `bf_value.py` is claiming

Expected gil per clear: every drop row is its own roll, so a battlefield is
worth the sum of `rate x sale price x quantity` over every row of every reward
table. Horizon is "your orb, your drops", so that total is what one clear is
worth to whoever paid the seals -- it is not divided by party size, and the
cost side is seals, not gil.

Two totals are printed because either alone misleads. **expected** counts every
priced drop; **liquid** counts only drops that actually sold in the last 15
days. A 16M Speed Belt that nobody has bought in a fortnight is most of one
battlefield's headline number and none of its realistic take, so the gap
between the columns is the part that is theoretical. Prices are the median of
recorded sales rather than the last one, and bazaar asks are ignored entirely:
they include 99,999,999 placeholders that would swamp any total they touched.

Unpriced rows are counted, never folded in as zero, so a small number reads as
"not worth much" rather than "not known yet". Most of them are EX -- which is
usually the actual reason to run the fight.

## Things worth knowing before scoring from this data

**Names here are wiki page titles, not in-game names.** The profiles use the
game's short names (`Dst. Harness +1`), which is what the bag scan matches
against. The wiki calls that page `Darksteel Harness +1`. Roughly 13% of the
entries in an existing set differ this way, so a name taken straight from the
wiki may silently never equip. Check it against a name already used in the
profiles before adding it.

**Conditional stats have to be ignored**, the rule commit `ecad9f2` set. The
condition is often in its own chunk ahead of the stat rather than beside it:

    Horror Head       Full Moon + Darksday + Nighttime: Enmity -50
    Fenrir's Torque   Daytime: MP +30 / Nighttime: Enmity -3
    Resentment Cape   Enmity +2, Outside nation's control: Magic damage taken -5%

None of those three is worth a slot. Scored naively, `Horror Head` outranks
every enmity piece in the game.

**`jobs` empty means every job can wear it**, not that nobody can.

**Expansion-gated jobs are wrapped in spans** (`<span class="toau">`), so a job
list can name a job that could not wear it in this era.
