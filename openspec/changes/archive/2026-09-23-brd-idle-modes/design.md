# Design

## Context

See `proposal.md` — Why. The constraints below come from the framework and from
`common.lua`, and they are what shape the approach.

**LuAshitacast only ever equips.** A slot keeps its piece until something else
replaces it; there is no unequip. `utility.lua` documents this and works around
it with explicit `'remove'` clear sets. Any design here must answer "what takes
this gear back off?" for every set it puts on.

**Resolution is ownership-aware and per-set.** `common.EvaluateOwned` walks each
`_Priority` set independently, building a fresh table; it never writes back into
the source list. Critically, its `claimed` map — which stops `Ring1` and `Ring2`
taking the same physical item — is declared *inside* the per-set loop. Two
different sets therefore resolve as if each had the whole inventory to itself.

**The bag scan is expensive and shared.** `GetOwnedItems` walks every equippable
container and caches the result for three seconds in a module-level variable.
`EvaluateGear(sets, level, force)` with `force` set calls `InvalidateScan()`
first, so a forced call always pays for a full walk.

**BRD today** equips one standing set per tick, picked by subjob, covering
`Main`, `Ammo` and the twelve armour and accessory slots. `Sub` and `Range` are
left alone — `Range` belongs to the song instrument. `MinstrelClear` strips seven
accessory slots after each song and the standing set refills them next tick.

## Goals / Non-Goals

**Goals:**

- Two idle sets the player switches between, with room for more at low cost.
- Adding a third set costs one registry row plus its gear, and no plumbing.
- Every set resolves against gear actually carried, refreshed at switch time.
- Remove the `Pulling_NIN` / `Pulling_WHM` duplication as part of the move.

**Non-Goals:**

- No shared abstraction in `common.lua`. See Decision 6.
- No engaged/melee handling. BRD has no TP or weapon set, and adding one is a
  separate piece of work with its own interaction with the Minstrel's Ring HP
  swap (the swap is tuned against the standing set's HP total).
- No change to song, precast, midcast or instrument handling.
- No change to the `utility` overlays or their clear-set mechanism.

## Decisions

### 1. Exclusive full sets, not a base plus overlays

Each mode is a complete set covering all fourteen slots. Exactly one is active.

*Alternative considered:* a permanent base set with partial overlays layered on
top, the pattern RDM uses for its `Enmity-` idle. Layering is attractive because
an overlay only claims the slots it has gear for, so it degrades gracefully —
but it requires a declared application order once there is more than one
overlay, and it makes two sets co-worn, which runs straight into the per-set
`claimed` problem described in Context.

Exclusive sets avoid both. Nothing is ever worn alongside anything else, so
there is no ordering question and no cross-set contention. The cost is that each
set must carry a full ladder, which Decision 4 makes affordable.

### 2. Sets resolve independently

A direct consequence of Decision 1. Two sets may both resolve to the same
physical item, which is harmless when they are never worn together. No change to
`common.EvaluateOwned` is needed, and its per-set `claimed` map stays correct.

Had the design layered sets instead, this would have had to change: base and
overlay would need a shared `claimed` map, making every set's resolution depend
on which modes are active.

### 3. A registry table, not per-mode branches

RDM costs three edit sites per mode — a `Settings` field, a `HandleCommand`
branch and a `HandleDefault` branch. A table of mode descriptors collapses that:
`HandleCommand` walks it to match a command, `HandleDefault` walks it to find
the active entry. Adding a mode appends a row.

The table is an array, not a hash. `common.lua` already spells out its sixteen
equipment slots explicitly rather than iterating a map, with the note that
`pairs()` has no defined order; an array keeps mode order deterministic for
listing and for any future tie-breaking.

### 4. Subjob is a small per-set delta, not a second ladder

`Pulling_WHM` is `Pulling_NIN` with one piece added and one promoted:
`Gaudy Harness` at the front of `Body`, and `Stoneskin Torque` moved to the front
of `Neck` from position 13 of the same list. The other twelve slots are
byte-identical. In both cases the white mage list is exactly
`[the leading piece] + [the other set's order with that piece removed]`, which is
what makes the layered form below equivalent: the piece is worn when carried and
wearable, and the slot otherwise falls through to what the base chose.

Prepending to a priority list and layering a small set on top are semantically
identical under ownership-aware resolution — in both cases the piece is worn if
carried and otherwise falls through to what the base chose. So the subjob
variant becomes a two-slot set applied after the active set, declared per mode:

    { Cmd = 'mit',    Set = 'Idle_Mit',    WHM = 'Idle_Mit_WHM' }
    { Cmd = 'enmity', Set = 'Idle_Enmity'                       }

Declaring it per mode rather than globally matters: `Stoneskin Torque` is
mitigation and `Gaudy Harness` is refresh, and neither belongs on an `Enmity-`
set. A blanket subjob overlay would stomp a mode that does not want it.

This is the one place where two sets are co-worn, so Decision 2's reasoning is
narrowed rather than abandoned — but the delta is two named items in two slots
that the mitigation ladder does not itself list, so contention is not reachable.

### 5. Re-resolve on switch: invalidate once, resolve many

Switching sets forces a fresh bag scan so a set picks up gear acquired since the
last scan instead of resolving empty.

This must not repeat the shape of the existing `gear` command, which calls
`EvaluateGear(..., true)` twice against a module-level scan cache and therefore
walks every bag twice — and skips `staves.Sets` entirely, so of three tables,
two are forced and one is never refreshed. The switch path should invalidate the
scan once and then resolve every table, which also gives the `gear` command a
correct implementation to share.

Framing worth keeping honest: re-resolution here is a freshness guarantee, not a
correctness fix. Sets are already resolved every tick by `evalLevel`, and a
failed scan already self-heals on a later tick.

### 6. The registry stays in `BRD.lua`

`common.lua` already holds job-agnostic mode helpers (`SetMeleeOptions`,
`EquipMelee`), so there is precedent for lifting it. RDM has the identical
three-edit-site problem and is the obvious second customer.

It stays local anyway. One real user does not establish the shape of a shared
abstraction, and `common.lua` is the file every job depends on. Lifting it later
is mechanical; unpicking a wrong abstraction from ten profiles is not.

### 7. `Idle_Mit` is active on load

Preserves today's behaviour, and a profile load happens on zoning and job change
— the moments most likely to be followed by movement or a pull. `Idle_Enmity`
becomes the deliberate opt-in. Mode state resets on load rather than persisting;
a shed-hate set that silently survived a zone would be a surprise.

### 8. Command names

`/brd mit` and `/brd enmity`. `gear` is taken by BRD; `exp`, `warp`, `sneak`,
`invis`, `clam` and `fish` are consumed by `utility.SetOptions` before the job
ever sees them, and `acc` by `common.SetMeleeOptions`. The registry should
assert its names against that reserved list at load rather than failing silently
at the first collision.

A bare `/brd` (or `/brd modes`) listing the registered modes and the active one
falls out of the registry for a few lines and is worth having once there is more
than one set to remember.

### 9. `Idle_Mit` is scored magic-first

Priority order: magic damage taken, then damage taken that covers both schools,
then magic defence, then physical damage taken, then defence.

The existing ladder is ordered "a flat percentage off damage taken first, then
raw defence at roughly fifteen points to the percent." That conversion of
defence into a damage-taken equivalent only holds against physical damage —
defence does nothing to a spell — so it cannot survive the change of threat
model unchanged. Generic damage-taken gear such as `Defending Ring` is the only
term that keeps its position.

### 10. Help is generated from the registry, and lists only what BRD acts on

The registry already holds a command word and a label per mode, so the help
listing walks it rather than repeating it in a string. A mode that exists is
therefore always listed, which is the only property that makes a help worth
having -- a hand-written one drifts the first time a mode is added, and a help
that lies is worse than none.

The shared utility toggles are not in the registry and cannot be, since
`utility.lua` consumes them before the profile sees the word. They are listed
from a small table of word and description held next to the registry.

*Alternative considered:* generating the whole listing from `ReservedCommands`,
which already holds every word. It is the wrong source. That array answers "may
a mode claim this word", and its membership is deliberately wider than what BRD
acts on -- `acc` is reserved because `common.SetMeleeOptions` would consume it
in a job that wires it, but BRD does not wire it, so nothing in BRD acts on
`acc` at all. A help built from that array would advertise a command that does
nothing. The two concerns get two tables.

### 11. Output stays in chat, and stays short

`gFunc.Message` is one `print` per call carrying a `[LuAshitacast]` header, so
an N-line help is N prefixed lines in the log. That argues for grouping the
utility toggles onto one line rather than one line each, keeping the whole
listing to roughly seven lines.

*Alternative considered:* an ImGui panel, which the framework already does for
sets via `/lac list gui`. Rejected for now as disproportionate -- it is a new UI
surface to maintain for a listing that is read once and remembered. Chat is
where every other message in this profile goes, and the listing is short enough
to belong there.

*Not in scope:* set contents. The framework already covers that with
`/lac list`, `/lac list <set>` and `/lac list gui`, and duplicating it here
would be a second, worse implementation.

### 12. Conditional gear is its own list, applied over whichever mode is active

Decision 4 hangs the white mage gear off each mode, on the reasoning that
`Stoneskin Torque` is mitigation and `Gaudy Harness` is refresh, so neither
belongs on an `Enmity-` set. In play that reasoning only held for one of them.
Refresh is orthogonal to what either mode scores for, so the player wants
`Gaudy Harness` under a white mage subjob whichever mode is active -- which
Decision 4 makes impossible, since a mode either declares the gear or does not.

Conditional gear therefore becomes a second list, applied after the active mode
and its subjob set, each entry pairing a gear set with a predicate over player
state. `Stoneskin Torque` stays per-mode under Decision 4; `Gaudy Harness` moves
here.

The condition is not decoration. Forcing the refresh body on unconditionally
would cost the enmity mode `Hydra Doublet` at Enmity -9, the best enmity body it
has, in exchange for a latent that is inactive most of the time. Gating on the
latent's own trigger -- MP below 49 points -- means the slot is only spent while
the refresh is actually running.

Gating costs nothing in refresh terms. The latent switches off at 49 MP whether
or not the piece is worn, so MP behaves identically either way; the gate only
returns the body slot to the mode when the latent is dormant.

*On swap churn:* crossing the threshold swaps the body, but bard songs cost no
MP, so the only thing that takes a bard below 49 is subjob casting. Crossings
are occasional rather than continuous and no hysteresis band is warranted. If
play proves otherwise, a band -- on below 49, off above roughly 55 -- is the fix,
and it belongs in the predicate rather than anywhere else.

*Alternative considered:* letting every mode declare the refresh body in its own
subjob set. It works, but it duplicates the piece and its condition once per
mode, and every mode added later has to remember to repeat it. The point of the
registry is that a mode is one row.

## Risks / Trade-offs

- **Re-scoring reaches further than a reorder** → The head of most of the
  fourteen slots moves, including the `Main` slot, whose only entries are the
  two Earth staves the set documents as physical damage taken -20%. Treat
  `Idle_Mit` as new content rather than an edit, and verify resolved output
  against the previous set rather than assuming a small diff.

- **No generator exists in the repo** → Past commits mention regenerating these
  ladders, but no tool is checked in. Both sets are hand work against the
  HorizonXI wiki. This dominates the effort and should be scheduled as such.

- **The rename touches a lot of lines** → `Pulling_NIN` / `Pulling_WHM` appear in
  the set table and in `HandleDefault`. Mitigated by doing the rename as its own
  step, verified to be behaviour-preserving before any scoring changes land.

- **Exclusive sets duplicate ladders by construction** → Two full sets means two
  fourteen-slot lists, and gear good in both appears twice. Accepted: it buys
  the absence of layering order and cross-set contention. If a third and fourth
  mode make the duplication painful, the shared-slot extraction already used in
  `lists.lua` is the escape hatch.

- **A predicate runs every tick** -> Conditional gear is evaluated in
  `HandleDefault`, so its predicate runs as often as the profile ticks. Keep
  predicates to reads of `gData.GetPlayer()` and comparisons; anything that
  scans bags or allocates belongs elsewhere.

- **Help can still drift for anything outside the registry** -> The utility
  toggle descriptions are hand-written, so a toggle added to `utility.lua` will
  not appear until BRD's table is updated. Accepted: those six have not changed
  in the life of the repo, and the alternative is a shared listing contract in
  `utility.lua`, which is the same premature abstraction Decision 6 declines.

- **Switch-time scanning is expensive** → A full bag walk per switch. Acceptable
  because switching is user-initiated and infrequent, the same justification the
  `gear` command already relies on, and Decision 5 halves the current cost.

## Migration Plan

Sequenced so each step is separately verifiable:

1. Rename `Pulling_*` to the `Idle_*` family. Pure rename, no behaviour change.
2. Collapse the subjob duplication into `Idle_Mit` plus a two-slot delta.
3. Add the registry, the switch command and the re-resolve path, with
   `Idle_Mit` as the only registered mode. Behaviour still unchanged.
4. Author `Idle_Enmity` and register it.
5. Re-score `Idle_Mit` magic-first.

Steps 1–3 should produce identical resolved gear. The repository has no test
runner, but the sets can be verified by loading each profile against stubbed
framework globals and diffing the fully expanded sets before and after — the
method used to verify the `lists.lua` extraction in `a9c46de`. Steps 4 and 5 are
content changes and are expected to differ.

Rollback is per step; nothing here leaves persistent state outside the profile.

## Open Questions

All three were answered while scoring the sets against the wiki data now kept in
`tools/wikidata/`.

- **Does defence survive as the final tiebreaker in `Idle_Mit`?** Yes. It is in
  the rule as stated -- damage reduction first, then high defence -- and it does
  real work: `Goliard Trews` and `Dst. Subligar +1` are both physical damage
  taken -3% and tie on everything else, so defence 35 against 29 is what orders
  them.

- **Is magic defence bonus its own term?** Yes, ranked after damage-taken
  reduction and ahead of physical. It decides one slot in practice: `Storm
  Turban` (Magic Def. Bonus +2) now leads Head over `Darksteel Cap +1`, which is
  physical only. The term is rarer than it looks, because several pieces carry
  it only as a set bonus -- `Goliard Trews` among them -- and a set bonus is a
  conditional stat, so it does not count for a single piece.

- **Does `Idle_Enmity` want a subjob delta?** No. `Stoneskin Torque` is
  mitigation and `Gaudy Harness` is refresh; neither is enmity gear, and
  applying them over an `Enmity-` set would stomp the slots the mode exists to
  fill. The mode declares no `WHM` entry, which is what the optional field in
  Decision 4 is for.

## Note on scoring: conditional stats

Ignoring conditional stats, the rule from `ecad9f2`, turned out to matter more
here than in any previous set, because the strongest-looking entries in both
ladders are conditional:

| Piece | Reads as | Actually |
|---|---|---|
| `Horror Head` | Enmity -50 | only on a full moon, on Darksday, at night |
| `Fenrir's Torque` | Enmity -3 | only at night |
| `Sand Mantle` | Physical damage taken -20% | only while petrified |
| `Resentment Cape` | Magic damage taken -5% | only outside its nation's control, and it is Enmity +2 |
| `Goliard Trews` | Magic Def. Bonus | a set bonus, not a per-piece stat |

Scored naively, `Horror Head` outranks every enmity piece in the game and
`Sand Mantle` outranks every back. All five are excluded.
