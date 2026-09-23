# Gear data tools

Not loaded by the game. LuAshitacast only reads `<JOB>.lua` from the profile
root, so nothing in here affects the addon.

These exist because the gear ladders in the job profiles are scored by hand
against the HorizonXI wiki, and every earlier regeneration threw the source
data away afterwards.

## Files

| File | What it is |
|---|---|
| `harvest.py` | Pulls every equipment page from the HorizonXI wiki API into `wikidata/wiki_raw.json` |
| `parse.py` | Parses the raw wikitext into `wikidata/items.json` |
| `wikidata/items.json` | 3,733 items: slot, level, jobs, stats, notes, Horizon changes |
| `wikidata/wiki_raw.json.gz` | The raw wikitext the parse came from, gzipped |

## Regenerating

    cd tools && python3 harvest.py && python3 parse.py

Harvest takes a few minutes and makes roughly 80 API calls against
`https://horizonffxi.wiki/w/api.php`. The API lives at `/w/api.php`, not
`/api.php`, and its search index does not support `insource:`, which is why
this walks the slot categories instead of querying by stat.

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
