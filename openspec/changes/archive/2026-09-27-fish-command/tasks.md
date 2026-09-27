# Tasks

## 1. Confirm the alias can carry the forwarded word

- [x] 1.1 In game, register `/alias /fsh /lac fwd _fish` by hand and type
      `/fsh rod lu`; verify the loaded profile's `HandleCommand` receives
      `args = {'_fish', 'rod', 'lu'}` (print the arguments from `HandleCommand`
      temporarily, or watch for the "unrecognised" path). This is the assumption
      the whole approach rests on — see design.md, Risks; if the alias body
      cannot carry `_fish`, stop and re-decide the forwarding word before
      touching the job files.

## 2. Fishing command and tackle registries

- [x] 2.1 In `fishing.lua`, add the ordered `Rods` and `Baits` registries from
      design.md as arrays of `{ Cmd, Item }`, and add `Rod`/`Bait` selections to
      `Settings` defaulting to `halcyon` and `insect`. Verify each `Item` string
      appears verbatim in `tools/wikidata/api/item_index.json` (short names —
      CLAUDE.md), e.g. by grepping the index for every name added.
- [x] 2.2 Make `sets.Fishing` take its `Range` and `Ammo` from the default
      selections instead of the two literals, leaving the angler's body, hands,
      legs and feet as they are. Verify `luajit tools/dump_sets.lua BST 75`
      still runs and the fishing set is unchanged from before the edit.
- [x] 2.3 Extract the enable path into an internal `setFishing(enabled, book)`
      owning the state flag, the report message and the macro book command, and
      have it return early when the state already matches. Rewrite
      `profile.Toggle(book)` to call it with the flipped state. Verify the
      toggle's messages and book switching are identical to before by driving
      `profile.Toggle` from a scratch script over `tools/lacstub.lua`.
- [x] 2.4 Add `profile.HandleCommand(args, book)` dispatching on `args[2]`:
      `nil` toggles, `rod`/`bait` select or list, `help` prints the listing, and
      any other word reports itself unrecognised and changes nothing. Verify by
      driving each form from the scratch script and checking that a garbage word
      does not toggle fishing.
- [x] 2.5 Implement rod and bait selection: a listed `Cmd` writes its `Item`
      into `sets.Fishing.Range` / `.Ammo`, reports the choice, and calls
      `setFishing(true, book)`; an unlisted word reports itself unrecognised and
      leaves both the selection and the fishing state alone. Verify from the
      scratch script that `/fsh bait worm` changes `sets.Fishing.Ammo`, turns
      fishing on from off, and that a second `/fsh bait` does not re-issue the
      macro book command.
- [x] 2.6 Implement the listings: `rod` and `bait` with no name list their
      `Cmd`s with the current selection marked, and `help` lists every accepted
      word plus the selected rod, the selected bait and whether fishing is on.
      Verify from the scratch script that neither changes the fishing state, the
      selections, or the book.

## 3. Shared alias and the utility entry point

- [x] 3.1 In `utility.lua`, add `profile.OnLoad` registering
      `/alias /fsh /lac fwd _fish` and `profile.OnUnload` deleting it. Verify
      in game (after task 4) that `/fsh` works under a job and is gone after
      the profile is unloaded.
- [x] 3.2 Change `utility.SetOptions` to take `(args, book)`, reading `args[1]`
      internally so the existing toggles behave exactly as before, and route
      `args[1] == '_fish'` to `fishing.HandleCommand(args, book)`. Remove the
      `fish` option branch. Verify `luajit tools/dump_sets.lua BST 75` runs and
      that `exp`, `warp`, `sneak`, `invis` and `clam` still toggle when driven
      from the scratch script.

## 4. Wire every job profile

- [x] 4.1 In each of `BLM.lua`, `BRD.lua`, `BST.lua`, `DRG.lua`, `PLD.lua`,
      `RDM.lua`, `SMN.lua`, `THF.lua`, `WAR.lua`, `WHM.lua`: call
      `utility.OnLoad()` from the profile's `OnLoad` and `utility.OnUnload()`
      from its `OnUnload`, next to the job's own alias lines. Verify by grepping
      that all ten files call both.
- [x] 4.2 In the same ten files, change the `utility.SetOptions(args[1], ...)`
      call to pass `args`, keeping each job's existing second argument (its
      `Settings.MacroBook`, or nothing for the five jobs that declare no book).
      Verify by grepping that no `SetOptions(args[1]` call site remains, and that
      `luajit tools/dump_sets.lua <JOB> 75` runs for all ten jobs.
- [x] 4.3 In `BRD.lua`, remove the `fish` row from `UtilityCommands` and the
      `'fish'` entry from `ReservedCommands`. Verify `/brd help` no longer lists
      fishing, by driving `ShowHelp` from the scratch script or by reading the
      generated listing in game.

## 5. Documentation

- [x] 5.1 Update the "Utility toggles" paragraph in `CLAUDE.md`: the toggles are
      `exp`, `warp`, `sneak`, `invis`, `clam`, forwarded from a job's
      `HandleCommand`; fishing is now a shared `/fsh` command registered by
      `utility.OnLoad`, with its own rod and bait subcommands and its tackle
      names taken from the item API. Verify the paragraph names no command the
      code does not accept.

## 6. Verify in game

- [x] 6.1 Load each of the ten job profiles once and type `/fsh help` under it;
      verify the listing appears under every job and that no Lua error is
      printed on load or on the first utility command.
- [x] 6.2 With fishing off, type `/fsh rod lu`; verify the rod is reported,
      fishing turns on, the angler's set and `Lu Shang's F. Rod` are equipped,
      and the macro book switches to 20.
- [x] 6.3 Type `/fsh bait worm`, then `/fsh`; verify the bait changes without
      the book switching again, then that fishing turns off and the macro book
      returns to the job's own book under a job that declares one (`BST`) and
      stays on 20 under one that does not (`WAR`).
- [x] 6.4 Type `/fsh rod nonsense` and `/fsh nonsense` with fishing off;
      verify each reports an unrecognised name and that fishing stays off with
      the previous selections intact.
- [x] 6.5 Type `/bst fish` (and the equivalent under one other job); verify
      nothing happens — no gear change, no macro book change, no message.
