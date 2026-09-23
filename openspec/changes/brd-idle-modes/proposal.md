# Proposal

## Why

BRD wears exactly one standing set, chosen only by subjob, and never reacts to
anything else. That set is ordered for physical damage reduction, but as a bard
the damage that actually lands is mostly magical — hate stays low, so mobs
rarely melee the bard, while area spells hit regardless. The same set is also
the only tool available when the problem is hate rather than damage: it excludes
gear that *adds* enmity but never stacks `Enmity-`, so there is nothing to
switch to when a pull goes wrong or a cure peels a mob.

Mitigation and hate shedding want different gear in the same slots. One set
cannot serve both, and today there is no mechanism to swap between them.

## What Changes

- Add two mutually exclusive idle gear sets, one active at a time:
  - **`Idle_Mit`** — damage mitigation, scored with magic damage taken as the
    highest priority, then other damage reduction, then defence.
  - **`Idle_Enmity`** — `Enmity-`, for shedding hate on demand.
- Add a chat command to switch between them, following the established
  `/<job> <verb>` convention already used by RDM, PLD, BST and WAR.
- Re-resolve gear against the bags when the active set is switched, so a set
  picks up gear acquired since the last scan instead of resolving empty and
  silently doing nothing.
- Introduce a **mode registry** so a third set later costs one table row plus
  its gear, rather than edits in three separate places (a `Settings` field, a
  `HandleCommand` branch and a `HandleDefault` branch — what RDM costs today).
- Add a **help listing** on `/brd help` (and on a bare `/brd`) naming every
  command the profile accepts, with the active idle mode marked. Nothing in the
  repo tells the player what can be typed today: all twenty-four messages across
  the profiles are either state echoes or the gear report, so a command is
  discoverable only by reading the Lua. The listing is generated from the mode
  registry rather than written out, so adding a mode cannot leave it stale.
- **BREAKING (profile-internal):** rename `Pulling_NIN` / `Pulling_WHM` to the
  `Idle_*` family. The name no longer describes the set — it is worn while
  standing, resting, meleeing and pulling alike.
- Collapse the `Pulling_NIN` / `Pulling_WHM` near-duplicate. The two sets are
  byte-identical in 12 of 14 slots; the white mage set differs only by adding
  `Gaudy Harness` to the front of `Body` and promoting `Stoneskin Torque` to the
  front of `Neck` (a piece the other set already lists). Expressing that as a
  two-slot per-set subjob delta instead of a second full ladder removes about
  620 duplicated gear entries, roughly 140 lines of `BRD.lua`.
- Re-score the existing damage reduction ladder onto the new magic-first
  priority. This is a content change to the head of most of the fourteen slots,
  not a reordering of tiebreakers: today's three named carriers are
  `Terra's Staff` (physical damage taken -20%), `Defending Ring` (damage taken
  -10%) and `Shadow Mantle` (annuls physical), and only the generic one keeps
  its place under a magic-first rule.

## Capabilities

### New Capabilities

- `brd-idle-gear`: What BRD wears while not casting — which idle set is active,
  how the player switches between them, how a subjob changes a set, and when
  gear is re-resolved against the bags.

### Modified Capabilities

<!-- None. The project has no existing specs; this is the first capability. -->

## Impact

- **`BRD.lua`** — the whole of the change. New `Idle_Enmity` set, re-scored
  `Idle_Mit`, the mode registry, the subjob delta, and the swap handling in
  `HandleCommand` / `HandleDefault`.
- **No change to `common.lua`.** The registry stays local to BRD until a second
  job wants it. RDM has the same three-edit-site problem and is the obvious
  second customer, but designing the shared abstraction before it has two real
  users is how the wrong one gets built.
- **`tools/`** is added alongside the profile: the wiki harvester, its parser,
  and the parsed item data the two sets were scored from. Nothing in it is
  loaded by the game -- LuAshitacast only reads `<JOB>.lua` from the profile
  root -- and it exists so the next re-score starts from data rather than from
  scratch, which is the risk `design.md` records as "no generator exists in the
  repo".
- **Gear authoring dominates the effort.** The plumbing is small; `Idle_Enmity`
  is fourteen slots that do not exist yet, and `Idle_Mit` is a re-score of an
  existing fourteen. There is no generator in the repo — the regeneration
  mentioned in past commit messages was not a checked-in tool — so both are
  hand work against the HorizonXI wiki.
- **`/lac list` already covers set contents.** The framework lists every
  resolved set, prints one slot by slot, and has an ImGui browser
  (`commandhandlers.lua`). The help added here deliberately covers only the
  command surface, which nothing provides.
- **Command namespace.** `gear` is taken by BRD itself; `exp`, `warp`, `sneak`,
  `invis`, `clam` and `fish` are consumed by `utility.SetOptions`, and `acc` by
  `common.SetMeleeOptions`. Mode names must avoid all of them.
- **No interaction with the Minstrel's Ring swap.** `MinstrelClear` strips seven
  accessory slots after each song and the active idle set refills them on the
  next tick, exactly as it does today.
