# Design

## Context

See `proposal.md` — Why. The shape of `BST.lua` as it stands is what constrains
the approach:

- `HandleDefault` swaps gear **only** inside an `if (player.Status ==
  'Engaged')` branch: `common.EquipMelee()`, then `sets.Tp`, then `sets.DualWield`
  under `/NIN` or `sets.Axe` otherwise. Outside that branch the profile equips
  nothing but `utility.EquipSet()`.
- LuAshitacast only ever *equips*. A slot keeps its piece until something else
  claims it, which is why `utility.lua` carries an explicit `clearSets` table for
  its toggles. Anything worn conditionally needs a matching release or it stays
  on after its condition lapses.
- Every `<Name>_Priority` table is resolved by `common.EvaluateGear` against
  both the character's level and a cached bag scan, so a slot whose entries are
  all unowned resolves to nothing and `gFunc.EquipSet` then leaves that slot
  alone.
- `tools/wikidata/items.json` holds 3,733 parsed wiki items covering armour,
  accessories and staves. It holds **no axes** — `Tomahawk`, `Barbaroi Axe` and
  `Darksteel Pick +1` are all absent — so weapons cannot be scored from it.
- BRD already has the conditional-gear mechanism this change needs (`BRD.lua`,
  `Conditionals`), including `Gaudy Harness` under a white mage subjob at the
  same MP threshold.

## Goals / Non-Goals

**Goals:**

- Keep the conditional mechanism recognisably BRD's, so the two read the same,
  while adding the release BST needs and BRD does not.
- Make the rune-axe mode one flag read in two places, not a third set of
  branches through `HandleDefault`.
- Re-score the two ladders by the rule each already documents, changing the
  content of the slots and nothing about how either set is used.

**Non-Goals:**

- No mode registry, no help listing. BRD earned those with a growing set of
  modes; BST has one toggle, and a registry for one row is the abstraction
  BRD's own Decision 6 declines.
- No idle set for BST. Conditional gear is worn while idle, but the profile
  still claims no other slot while standing.
- No lifting of `Conditionals` into `common.lua`.
- No re-scoring of `CallBeast_Priority` or `Reward_Priority`, and no change to
  the weapon ladders beyond the new rune-axe list.

## Decisions

### 1. Conditional gear is a list of predicates, copied from BRD rather than shared

`Conditionals` becomes a local table in `BST.lua`, each entry pairing a set name
with a predicate over `gData.GetPlayer()`, evaluated in `HandleDefault`. Same
shape, same tick-cost discipline: reads and comparisons only.

It is copied rather than moved into `common.lua` because the two versions
already differ — BST needs a release step (Decision 3) that BRD has no use for,
since BRD's idle mode re-claims the body slot every tick on its own. Two users
that differ in their core step is the wrong moment to generalise; the second
real user of the *same* mechanism is.

*Alternative considered:* extracting the mechanism to `common.lua` now and
giving the release an optional field. It puts a BST-only concept into shared
code that BRD would carry and never use.

### 2. One `Gaudy` set, two conditional rows

Both subjob cases equip the same single piece, so there is one
`Gaudy_Priority = { Body = { 'Gaudy Harness' } }` and two rows in `Conditionals`
naming it — one for `/WHM` at MP below 49, one for `/NIN` with the rune-axe mode
on. Two rows rather than one predicate with an `or` because the two exist for
different reasons (refresh against per-axe HP regen) and each row carries its
own comment; folding them into one boolean expression loses that and makes the
next condition harder to add.

The `/WHM` threshold is the latent's own trigger, 49, not the 50 in the request:
the latent is dormant at 49 MP, so wearing the piece there spends the body slot
for nothing. This matches `BRD.lua` exactly.

### 3. Release hands the slot back to the melee set

Each conditional entry names the slots it claims. `HandleDefault` remembers which
entries were live last tick; when one goes from live to dormant, the profile
equips those slots from the **resolved melee set** (`sets.Tp`) once. That is the
set that owns the body slot while engaged, and it is the only body the profile
has any opinion about while idle.

Releasing to `'remove'`, the way `utility.lua` clears its toggles, is wrong here:
an empty body slot is worse than a stale one, and a naked body while idle is a
visible bug.

*Edge case, accepted:* if `sets.Tp` has no `Body` resolved — the character owns
none of the listed pieces — the release equips nothing and `Gaudy Harness` stays
on until something else claims the slot. That is strictly better than stripping
the slot, and only reachable on a character carrying no body armour at all.

### 4. Conditionals are evaluated outside the engaged branch

The conditional loop runs every tick, after the `Engaged` block and before
`utility.EquipSet()`. Placing it after the engaged block means the melee set is
already on when a live conditional overrides the body; placing it before
`utility.EquipSet()` preserves today's precedence — a utility toggle that claims
the body (`Clam`) still wins, because it is applied last, exactly as it does
over `sets.Tp` now.

### 5. The rune-axe mode is a `Settings` flag read in two places

`Settings.UseRuneAxes`, defaulting to off, toggled by `/bst rune` and echoed the
way the jug setting already echoes. It is read in exactly two places:

- The engaged weapon branch: `/NIN` with the flag on equips `sets.RuneAxe`
  instead of `sets.DualWield`. Every other path is untouched, so a non-ninja
  subjob is unaffected by the flag, as the spec requires.
- The `/NIN` conditional predicate for `Gaudy Harness`.

The weapon slots are claimed because they have to be: `HandleDefault` re-equips
`sets.DualWield` every tick while engaged, so axes swapped in by hand are gone
before the next swing. A mode that leaves the weapons alone would be a mode
whose entire premise the profile then undoes.

`rune` collides with none of the words consumed ahead of it —
`utility.SetOptions` takes `exp`, `warp`, `sneak`, `invis`, `clam`, `fish`;
`common.SetMeleeOptions` takes `acc`; the profile takes `gear` and `jug`.

*Alternative considered:* detecting the axes from `gData.GetEquipment()` and
skipping the toggle. Rejected — it cannot work alongside the weapon swap, since
the profile would be reading the state it just overwrote.

### 6. `RuneAxe_Priority` is a two-slot weapon set, hand-written

`Main` and `Sub` only, listed best first, resolved by the same
`common.EvaluateGear` path as everything else — so an axe that is not carried
falls through and, with nothing resolved, leaves the slot untouched. The entries
are hand-written because the harvested data carries no axes at all (Context),
and the exact in-game short names are confirmed with `/bst gear` rather than
assumed, the lesson of `f865b79`.

### 7. Both scoring rules are restated, because neither ladder followed its own

Scoring reads `tools/wikidata/items.json`, filtered per slot to items whose job
list includes BST and whose level is within the 75 cap, and applies the
project's standing rule from `ecad9f2`: **conditional stats do not count**.

Neither ladder was ordered by the rule written above it, so both rules are
restated rather than merely applied:

- **Melee: multipliers, then flat attack, then STR, then the rest.** The comment
  said attack first, but `Skadi's Visor` (haste 3%), `Brutal Earring` (Double
  Attack) and `Ninurta's Sash` (haste 6%) all led slots over pieces with more
  attack — the ladder was already multiplier-first and the comment simply did
  not say so. Taken literally the rule would demote all three behind
  `Ogre Mask +1`, `Storm Loop` and `Swordbelt +1`, which is a worse set.
- **Charm: unrestricted `Charm +N`, then CHR, then Tame gear.** `Charm +N` is
  the charm success stat; CHR contributes far less. The old ladder led with
  `Brave's Jacket`, whose charm bonus applies only against plantoids — a
  conditional stat by the `ecad9f2` rule, and the reason family-restricted charm
  ("Vs. beasts: Charm +5", the whole Bison / Brave's / Stout / Khimaira line)
  now ranks on its CHR alone.

*Alternative considered:* applying each rule as literally written and letting
the sets get worse, on the grounds that the comment is the contract. Rejected:
the comment was a description of the intent and it described it badly; the
ladders themselves are the better evidence of what was meant.

### 9. Short item names come from the game API, not the wiki

A bag scan matches the game's short name (`Hecatomb Subligar +1` is
`Hct. Subligar +1` in the bags), and the harvested wiki data carries only long
names — the bug `f865b79` fixed. Every scored entry is therefore resolved
through the horizonxi item API, the same source `tools/bf_harvest.py` already
uses and for the same stated reason, with the results cached so re-running the
scoring costs no calls. An entry the API cannot confirm does not go in the
ladder.

`Main` and `Sub` stay hand-written in `DualWield_Priority`, `Axe_Priority` and
`Scythe_Priority`. `Charm_Priority`'s `Main` is a staff and the data does cover
staves, so it is scored with the rest.

No slot in either set claims `Ammo`: the jug broth takes that slot at
`Call Beast` and must keep it.

### 8. The jug path is not touched

`setJug`, `Settings.Jug`, `Settings.UseHQJugs`, the `Jugs` / `Jugs_HQ` tables and
the `Call Beast` branch are left exactly as they are. They are in the spec
because they are behaviour worth protecting, not because they change. The
verification step (Migration Plan) treats any diff in resolved jug behaviour as
a failure.

## Risks / Trade-offs

- **Re-scoring is content, not a reorder** → Expect the head of most slots in
  both ladders to move, the same way BRD's did. Verify by diffing resolved sets
  before and after and reading the diff, rather than assuming it is small.

- **No generator is checked in** → As with BRD, the scoring is hand work against
  the parsed data. This dominates the effort of the change and should be
  scheduled as two separate passes, one ladder each.

- **A predicate runs every tick** → Two predicates now, both a subjob string
  compare plus one field read. Keep them that way; anything that scans bags or
  allocates belongs outside `HandleDefault`.

- **Body-slot churn under `/WHM`** → Unlike a bard, a beast master under a white
  mage subjob can sit near the threshold while resting, crossing 49 MP
  repeatedly and swapping the body each time. If play proves it noisy, the fix
  is a hysteresis band inside the predicate — on below 49, off above roughly 55
  — and it belongs there and nowhere else. Not built now: the swap is free in
  game terms and the band is guesswork until it is observed.

- **The rune-axe mode silently does nothing under the wrong subjob** → On under
  `/WAR`, it changes neither weapons nor body, and the echo says only that the
  mode is on. Accepted: the alternative is refusing the toggle based on the
  subjob at the moment it is typed, which then goes stale the next time the
  subjob changes.

- **Release depends on `sets.Tp.Body` resolving** → Covered in Decision 3.
  Worth one line in the `/bst gear` report reading, since that report is what
  shows whether the melee body resolved at all.

## Migration Plan

Sequenced so each step is separately verifiable, and so the mechanism lands
before the content:

1. Add the `Conditionals` table, its evaluation in `HandleDefault` outside the
   engaged branch, the release step, and the `/WHM` Gaudy row. Verify: MP across
   49 swaps the body both ways, idle and engaged.
2. Add `Settings.UseRuneAxes`, the `/bst rune` toggle and its echo, the
   `RuneAxe_Priority` set, the engaged weapon branch, and the `/NIN` Gaudy row.
   Verify: axes stay in hand while engaged under `/NIN`, and nothing changes
   under any other subjob.
3. Re-score `Tp_Priority`.
4. Re-score `Charm_Priority`.

Steps 1 and 2 leave the two ladders byte-identical; steps 3 and 4 are expected to
differ and are read as content. The repository has no test runner, so the check
is the one used for the `lists.lua` extraction in `a9c46de` and for BRD's modes:
load the profile against stubbed framework globals and diff the fully expanded
sets before and after. Jug selection and `Call Beast` are part of that diff at
every step and must not move.

Rollback is per step; nothing here writes state outside the profile.

## Open Questions

- **The exact short names of the rune axes.** Confirmed with `/bst gear` while
  carrying them during step 2. Deferrable: it changes the strings in one
  two-slot list and nothing about the specs, the approach or the steps.
- **Whether the rune-axe list wants more than one axe per slot.** Resolved
  during step 2 by what the character actually owns; the set resolves the same
  way whether the list is one entry long or five.
