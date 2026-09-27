# Proposal

## Why

Fishing is reached today by typing the active job's alias — `/bst fish`, `/brd
fish`, `/whm fish` — so the word for a thing that has nothing to do with the job
changes every time the job changes, and the profile has to be reloaded before the
new word works. Fishing also has two pieces of tackle that change constantly in
play, the rod and the bait, and neither can be chosen in game: both are hardcoded
in `fishing.lua`, so swapping bait means editing the file and reloading.

## What Changes

- Register a `/fsh` alias that works under every job profile, alongside the
  job's own alias rather than inside it. `/fsh` with no argument toggles the
  fishing set and the macro book exactly as `/<job> fish` does today. Not
  `/fish`: an Ashita alias shadows what the player types, and `/fish` is the
  game's own command for casting a line.
- **BREAKING**: `/<job> fish` stops working. The `fish` option is removed from
  `utility.SetOptions`, from BRD's `UtilityCommands` help listing, and from its
  `ReservedCommands` guard. Typing it does nothing, the same as any other
  unrecognised word.
- Add `/fsh rod <name>` and `/fsh bait <name>` to choose the rod and the bait
  from named lists held in `fishing.lua`. The choice takes effect immediately and
  survives the set being toggled off and on again.
- Choosing a rod or bait enables fishing if it is off, so one command is enough
  to start: the gear goes on and the macro book switches, the same as the toggle.
- Add listings: `/fsh rod` and `/fsh bait` with no argument name the choices
  available, and `/fsh help` shows every word `/fsh` accepts and what is
  currently selected.
- Give `utility.lua` an `OnLoad`/`OnUnload` pair for the shared alias, and have
  every job profile call it from its own `OnLoad`/`OnUnload`. The utility
  options are handed the whole argument list rather than only its first word, so
  a shared command can take a subcommand.

## Capabilities

### New Capabilities

- `fishing`: the fishing command and its gear — how the fishing set and macro
  book are toggled, how the rod and bait are chosen, what is worn while fishing,
  and how the command is reached from any job.

### Modified Capabilities

<!-- No existing spec covers the utility toggles or the job aliases; the BRD
     help listing loses one row, which its spec does not enumerate. -->

## Impact

- `fishing.lua` — gains the rod and bait registries, their selection and
  listing handlers, and a command entry point; the fishing set's `Range` and
  `Ammo` stop being literals.
- `utility.lua` — loses the `fish` option; gains `OnLoad`/`OnUnload` for the
  shared alias; `SetOptions` takes the argument list instead of one word.
- Every job profile (`BLM`, `BRD`, `BST`, `DRG`, `PLD`, `RDM`, `SMN`, `THF`,
  `WAR`, `WHM`) — registers and deletes the shared alias, and passes the whole
  argument list to `utility.SetOptions`.
- `BRD.lua` — `fish` comes off both `UtilityCommands` and `ReservedCommands`, so
  `/brd help` no longer advertises a word BRD no longer handles.
- `CLAUDE.md` — the utility-toggles paragraph names `fish` as a forwarded
  toggle; it becomes a shared command instead.
- No framework or dependency changes. The only way to verify is in game: reload
  the addon and type the commands.
