# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Reference

LuAshitacast framework source and documentation: https://github.com/ThornyFFXI/LuAshitacast

## What This Is

LuAshitacast profiles for the character **Crepes** on HorizonXI (FFXI private server). These are Lua scripts that run inside the Ashita addon framework to automatically swap gear based on game actions.

There is no build step, linting, or test runner — changes take effect by reloading the addon in-game (`/lac reload` or changing zones).

## Architecture

Each job has its own profile file (`WAR.lua`, `BRD.lua`, `BLM.lua`, etc.) that follows a standard LuAshitacast interface. Two shared modules are loaded by most job files:

- **`common.lua`** — cross-job gear sets (Dream set, melee priority slots, flex slots)
- **`lists.lua`** — priority slot lists shared by more than one job (accessory slots of the caster Idle/TP/Cure/Enhancing/Enfeebling sets); a job drops one straight into a slot, e.g. `Ear1 = lists.TP.Ear`
- **`utility.lua`** — cross-job toggle options (exp ring, warp club, sneak/invis gear, fishing) and item/cast handlers; loads `fishing.lua`
- **`fishing.lua`** — fishing gear set and macro book switching logic
- **`staves.lua`** — elemental staff selection by spell name (used by caster jobs)
- **`settings.lua`** — LuAshitacast addon settings (bags, delays, offsets)

### Job Profile Structure

Every job file exports a `profile` table with these handler functions called by the framework:

| Handler | When called |
|---|---|
| `OnLoad` / `OnUnload` | Profile load/unload; used to set aliases (`/war`, `/brd`, etc.) and macro books |
| `HandleDefault` | Every game tick; used for idle/engaged gear swaps |
| `HandleCommand` | When the job alias command is used in chat |
| `HandleAbility` | Job ability use |
| `HandleItem` | Item use |
| `HandlePrecast` / `HandleMidcast` | Spell casting phases |
| `HandlePreshot` / `HandleMidshot` | Ranged attack phases |
| `HandleWeaponskill` | Weaponskill execution |

### Gear Sets and Priority Lists

Sets use two naming conventions:

- **`SetName`** — exact gear, equipped directly
- **`SetName_Priority`** — ordered list of fallback items per slot; `gFunc.EvaluateLevels` resolves these to `SetName` based on current level

`gFunc.EvaluateLevels(sets, level)` scans all `_Priority` sets and picks the first item in each slot that the player can equip at `level`. The resolved set (without `_Priority`) is what gets equipped. This is typically called in `HandleDefault` when the player's level changes.

### Key Framework Globals

- `gFunc.EquipSet(set)` — equip a gear set table
- `gFunc.EvaluateLevels(sets, level)` — resolve priority sets for a given level
- `gFunc.LoadFile(path)` — load another Lua file as a module
- `gFunc.Message(str)` — print a message to chat
- `gData.GetPlayer()` — returns player state (`.Status`: `'Idle'`, `'Engaged'`, etc.)
- `gData.GetAction()` — returns current action (`.Name`, `.Type`)
- `gSettings.AllowAddSet` — enables AddSet functionality
- `AshitaCore:GetChatManager():QueueCommand(-1, cmd)` — execute a game command
- `AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel()` — get current job level

## Patterns

**Adding a new job:** Copy an existing job file, replace the sets and job-specific logic. Register the alias in `OnLoad`/`OnUnload`. The file name must match what LuAshitacast expects for the job.

**Adding gear to a priority set:** Append items to the priority list in order of preference (best first). Items the player can't yet equip are skipped automatically.

**Editing a shared list:** A slot set to `lists.<Family>.<Slot>` is shared — changing it in `lists.lua` changes every job named in that list's `Used by:` comment. When one job wants a different order, give it its own inline list and drop it from that comment.

**Utility toggles** (`exp`, `warp`, `sneak`, `invis`, `fish`) are forwarded from any job's `HandleCommand` via `utility.SetOptions(args[1], ...)`. The fishing toggle also switches macro books (book 20 for fishing, restores original book on disable).
