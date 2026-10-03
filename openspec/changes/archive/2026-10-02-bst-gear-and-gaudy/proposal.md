# Proposal

## Why

`BST.lua` is the last melee profile still wearing gear nobody scored. Its two
working ladders — `Tp_Priority` for melee and `Charm_Priority` for charming —
were written by hand before `tools/wikidata/items.json` existed, so they cannot
be checked against anything and they quietly miss pieces the character can
already wear. BRD's ladders were re-scored from that data in
`2026-09-23-brd-idle-modes`; BST never was.

Separately, `Gaudy Harness` is a BST body piece the profile never equips at all.
Its latent gives refresh while MP is below 49 points, which is worth the body
slot under a white mage subjob, and it gives 5 HP regen per Rune Axe wielded,
which is worth the body slot under a ninja subjob — but only while the beast
master is actually holding the axes, which no automatic check can know.

## What Changes

- **Re-score `Tp_Priority` and `Charm_Priority`** against
  `tools/wikidata/items.json`, the same source BRD's ladders were scored from.
  Both rules are stated precisely, because neither ladder was ordered by the
  rule written above it: melee ranks multipliers (haste, double and triple
  attack) ahead of flat attack, which is how its heads were already chosen and
  what the comment failed to say; charm ranks the unrestricted `Charm +N` bonus
  ahead of CHR, and drops family-restricted charm as the conditional stat it is.
  This is a content change to the armour and accessory slots, not a change to
  how either set is used.
  - The harvested data covers armour, accessories and staves only — it carries
    no axes, so `Main`/`Sub` in `DualWield_Priority`, `Axe_Priority` and
    `Scythe_Priority` stay hand-written exactly as they are.
- **Add conditional gear to BST**, the mechanism BRD already has: a set paired
  with a predicate over the player, applied over whatever the profile is already
  wearing while its condition holds, and released back when it stops. BST needs
  the release step BRD does not: BST equips nothing while idle, so without it a
  conditional piece would stay on after its condition lapsed.
  - **`/WHM`**: `Gaudy Harness` while MP is below 49 points — the latent's own
    trigger.
  - **`/NIN`**: `Gaudy Harness` while the new rune-axe mode is on, with no MP
    test. Under `/NIN` the piece is being worn for the per-axe HP regen, which
    does not care about MP.
- **Add a rune-axe mode**, toggled with a `/bst` subcommand. While it is on and
  the subjob is ninja, `Main`/`Sub` come from a rune-axe priority list instead of
  `DualWield_Priority`, so the axes stay in hand — today the engaged weapon swap
  puts the picks back every tick and silently undoes a manual swap. The mode is
  inert under any other subjob.
- **Conditional gear applies while idle as well as engaged.** `HandleDefault`
  swaps nothing today unless the character is engaged, which is exactly when
  refresh matters least.
- **No change to the jug commands.** `/bst jug <pet>`, `/bst jug hq <pet>` and
  `/bst jug hq` keep working as they do now, including the fallback when a pet
  has no high quality broth, and `Call Beast` keeps equipping the pet-bonus set
  before the broth. This change writes them into the spec so a regression is
  caught rather than discovered mid-pull.
- **`CallBeast_Priority` and `Reward_Priority` stay as they are.** Neither is
  re-scored and neither is removed.

## Capabilities

### New Capabilities

- `bst-gear`: What the beast master wears and when — the melee and charm sets,
  the charm swap, conditional gear under a subjob, the rune-axe mode, and the
  jug selection commands that drive `Call Beast`.

### Modified Capabilities

<!-- None. `brd-idle-gear` is the only existing spec and this change does not
     touch bard behaviour. -->

## Impact

- **`BST.lua`** — the whole of the change: re-scored `Tp_Priority` and
  `Charm_Priority`, a `Gaudy_Priority` set claimed by two conditional rows, the
  release that hands the body slot back, a `Conditionals` table and its
  evaluation in `HandleDefault`, the rune-axe weapon list, and the subcommand in
  `HandleCommand`.
- **No change to `common.lua`, `utility.lua` or `lists.lua`.** The conditional
  mechanism is copied into BST rather than lifted into `common.lua`: BRD's
  version is still its only other user, and two users of a pattern that differ
  (BST needs the release, BRD does not) is the wrong moment to generalise it.
- **`tools/`** gains a stubbed-framework harness (`lacstub.lua`,
  `dump_sets.lua`) so a profile can be loaded and its resolved sets dumped
  outside the game, which is what makes a re-scored ladder diffable. The
  harvested wiki data itself is read, not regenerated.
- **No spec change for BRD.** `brd-idle-gear` describes bard behaviour only, and
  nothing here alters it.

## Assumptions

- "MP below 50" is implemented as **MP below 49 points**, the threshold the
  Gaudy Harness latent actually uses (`tools/wikidata/items.json`: *"Active while
  MP is below 49 points"*), matching what BRD already does. At MP 49 the latent
  is dormant, so wearing the piece there would cost the body slot for nothing.
- The rune-axe priority list is written from the item names the game reports;
  the axes are absent from the harvested data, so the names are confirmed
  in-game with `/bst gear` during implementation rather than taken on trust.
