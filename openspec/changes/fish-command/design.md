# Design

## Context

See `proposal.md` — Why. The constraints that shape the approach:

- LuAshitacast gives a profile one command entry point, `HandleCommand(args)`,
  reached through Ashita's alias mechanism. Every job does the same thing in
  `OnLoad`: `/alias /<job> /lac fwd`, deleted again in `OnUnload`. Ashita
  expands an alias by textual substitution and appends whatever the player typed
  after it, which is how `/bst jug hq sheep` arrives as
  `args = {'jug', 'hq', 'sheep'}`.
- There is no profile-independent place to register a command: anything typed has
  to come back through the loaded profile's `HandleCommand`. So a command that
  works "alongside" the job alias is still a second alias forwarding into the
  same handler — what changes is the word the player types and the word the
  handler sees.
- `utility.SetOptions(option, arg)` receives only `args[1]` today, which is why
  no shared option can take a subcommand.
- Five jobs (`BST`, `BRD`, `BLM`, `PLD`, `RDM`) declare a `Settings.MacroBook`
  and set it in `OnLoad`; the other five set no book at all. `fishing.Toggle`
  already takes the book to restore as a parameter, and gets `nil` from the jobs
  that have none.
- No test runner, no build step. Everything here is verified by reloading the
  addon in game and typing the commands.

## Goals / Non-Goals

**Goals:**

- One word for fishing that does not change with the job, registered and removed
  with the profile like every other alias.
- Rod and bait chosen in game, with the profile as the list of what can be
  chosen.
- Keep the per-tick path allocation-free: `HandleDefault` runs every tick and the
  fishing set is applied from it.

**Non-Goals:**

- Selections that survive a profile reload. Nothing in this project persists
  state to disk, and fishing sessions are short.
- Checking that the chosen rod or bait is actually in the character's bags.
  LuAshitacast silently skips a piece that is not carried, the same way a gear
  ladder entry the character has not got yet is skipped.
- Giving the other utility toggles (`exp`, `warp`, `sneak`, `invis`, `clam`)
  their own aliases. They stay job-forwarded words.
- Any change to what the angler's set covers, or to gear scoring.

## Decisions

### The alias is `/fsh`, not `/fish`

`/fish` is the game's own command for casting a line. An Ashita alias is a
textual substitution over what the player types, so registering `/fish` shadows
the game command for as long as any profile is loaded — fishing would become
impossible from the job the alias was meant to serve. `/fsh` collides with
nothing and is shorter to type, which matters for the command's primary verb.

Alternative considered: `/fishset`, which is unambiguous and self-describing.
Rejected — it reads oddly over the tackle subcommands (`/fishset rod lu`), and
the toggle is typed often enough during a session that eight characters is a
cost.

### The alias forwards an internal word, not `fish`

`utility.OnLoad` registers `/alias /fsh /lac fwd _fish` and
`utility.OnUnload` deletes it. Every job profile calls the pair from its own
`OnLoad`/`OnUnload`, next to its own alias line.

The forwarded word has to differ from `fish`, and that is what retires the old
form. Forwarding `fish` would leave `/<job> fish` working exactly as it does
today, since both words would reach the same branch — keeping both is then
unavoidable, and the proposal's choice is to retire the job-scoped form.
Forwarding `_fish` instead means `/fsh` is the only way to produce the word the
handler looks for; `/bst fish` arrives as an unrecognised word and falls through,
which is the behavior the spec asks for. The leading underscore marks it as a
word the player is not meant to type.

Alternative considered: registering the alias from `fishing.lua`'s module body,
which runs at profile load anyway, avoiding an edit to ten job files. Rejected —
there is no matching unload point, so `/fsh` would outlive the profile that
registered it and forward into whatever loaded next, and the project's
convention is that aliases are `OnLoad`/`OnUnload` business.

### `utility.SetOptions` takes the argument list

The signature becomes `utility.SetOptions(args, book)`; the existing toggles read
`args[1]` internally, unchanged in behavior. A shared command needs `args[2]` and
beyond, and there is no reason to add a second shared entry point when every job
already calls this one. All ten job files change one line.

Alternative considered: a separate `utility.HandleCommand(args, book)` alongside
`SetOptions`. Rejected — it adds a second line to every job's `HandleCommand` for
no gain, and leaves two shared entry points to keep in step.

### Rods and baits are ordered registries in `fishing.lua`

Each is an array of `{ Cmd, Item }` rows, following the `IdleModes` /
`UtilityCommands` pattern in `BRD.lua`: ordered, so the listing is deterministic
and reads in a chosen order rather than Lua's hash order, and adding tackle is
one row. `Cmd` is the short word the player types; `Item` is the item's name.

Names are the game's **short** names, taken from
`tools/wikidata/api/item_index.json` as CLAUDE.md requires — a bag scan matches
the short name, and a wrong name is silently skipped in game. The seed lists,
verified against that index:

| Rod `Cmd` | Item |
|---|---|
| `halcyon` | `Halcyon Rod` |
| `lu` | `Lu Shang's F. Rod` |
| `ebisu` | `Ebisu Fishing Rod` |
| `comp` | `Comp. Fishing Rod` |
| `glass` | `Glass Fiber F. Rod` |
| `carbon` | `Carbon Fish. Rod` |
| `fastwater` | `Fastwater F. Rod` |
| `hume` | `Hume Fishing Rod` |
| `mithran` | `Mithran Fish. Rod` |
| `taru` | `Tarutaru F. Rod` |
| `willow` | `Willow Fish. Rod` |
| `yew` | `Yew Fishing Rod` |
| `bamboo` | `Bamboo Fish. Rod` |
| `hook` | `S.H. Fishing Rod` |

| Bait `Cmd` | Item |
|---|---|
| `insect` | `Insect Ball` |
| `sardine` | `Sardine Ball` |
| `crayfish` | `Crayfish Ball` |
| `trout` | `Trout Ball` |
| `worm` | `Little Worm` |
| `lugworm` | `Little Lugworm` |
| `paste` | `Worm Paste` |
| `minnow` | `Sinking Minnow` |
| `shellbug` | `Shell Bug` |
| `rig` | `Sabiki Rig` |
| `robber` | `Robber Rig` |
| `rogue` | `Rogue Rig` |
| `meatball` | `Meatball` |
| `lizard` | `Lizard Lure` |

Defaults stay what `fishing.lua` hardcodes today: `halcyon` and `insect`, so
`/fsh` alone behaves exactly as `/<job> fish` did.

Alternative considered: keyed tables (`Rods['lu'] = "Lu Shang's F. Rod"`) for a
direct lookup. Rejected — the listing order would be arbitrary. The arrays are a
dozen rows scanned only on a typed command, so the linear lookup costs nothing.

### A selection writes into the fishing set, rather than being read per tick

`sets.Fishing` keeps `Range` and `Ammo` as fields; choosing tackle assigns the
new item into the field. `profile.EquipSet` stays the single
`gFunc.EquipSet(sets.Fishing)` it is today.

Alternative considered: building `{ Range = ..., Ammo = ... }` inside
`EquipSet`. Rejected — that allocates a table every tick while fishing is on,
for a value that changes only when the player types a command.

### One enable path, shared by the toggle and by choosing tackle

An internal `setFishing(enabled, book)` owns both the state flag and the macro
book command; `Toggle` calls it with the flipped state, and the rod and bait
handlers call it with `true`. It returns early when the state is already what is
asked for, so choosing a second bait during a session does not re-issue
`/macro book 20` — the spec requires the book not be switched again.

Book restore keeps its current shape: the job passes the book it declares, and
the five jobs that declare none pass `nil`, leaving the book on 20 when fishing
is switched off. That is today's behavior for those jobs and this change does not
alter it.

### Dispatch inside the fishing command

`args[2]` is the subcommand: `nil` toggles, `rod` and `bait` select or list,
`help` prints the listing. Any other word is reported as unrecognised and changes
nothing — notably it must not fall through to the toggle, or a typo would put the
angler's gear on.

Bare `/fsh` toggles rather than printing help, unlike bare `/brd`. The toggle is
the command's primary verb and the word it replaces, so the common case stays one
word; help is behind `/fsh help`.

## Risks / Trade-offs

- **Ashita might not preserve a fixed argument in the alias body**, i.e.
  `/alias /fsh /lac fwd _fish` may forward nothing or mangle the word → This is
  the one assumption the whole approach rests on, and it is cheap to check first:
  register the alias and confirm `/fsh` reaches the handler before any other
  work. If the alias body cannot carry an argument, the fallback is a distinct
  forwarding target rather than a distinct word, and `utility.OnLoad` is still
  where it is registered.
- **`/<job> fish` silently doing nothing** is a real behavior loss for muscle
  memory → It is the choice the proposal records. `/brd help` stops advertising
  the word at the same time, which is the only place the project listed it.
- **Ten job files change identically**, so one can be missed → A missed
  `OnLoad` is visible immediately (`/fsh` is not registered under that job); a
  missed `SetOptions` call site is a Lua error on the first utility command under
  that job, since `SetOptions` now indexes its first argument. Both surface on
  the first command typed under that job, so the verification step is to load
  each job once.
- **The rod and bait lists are not the whole game** — tackle not in the registry
  cannot be chosen → Adding a row is trivial, and a curated list is what makes a
  one-word name possible. The alternative (free-typed item names) turns a typo
  into gear that never equips.

## Migration Plan

Not applicable — no data, no deployment. The change takes effect on `/lac
reload` or a zone change, and reverting is `git revert`.
