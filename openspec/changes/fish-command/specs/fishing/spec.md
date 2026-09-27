# Spec Delta

## Purpose

Governs fishing: the command that reaches it from any job, the gear and macro
book worn while fishing, and the rod and bait the character fishes with.

## ADDED Requirements

### Requirement: Fishing has its own command, available under every job

The profile set SHALL register a `/fish` chat command while any job profile is
loaded, and SHALL remove it when that profile is unloaded. `/fish` SHALL be
available alongside the loaded job's own alias, not inside it: the word for
fishing SHALL NOT change when the job changes. The job aliases SHALL NOT accept
a fishing option — `/<job> fish` does nothing, the same as any other word the
job does not handle.

#### Scenario: Fishing from one job

- **WHEN** a job profile is loaded and the player types `/fish`
- **THEN** the command is handled, and the same word works after switching to
  any other job

#### Scenario: The old job-scoped form

- **WHEN** the player types `fish` as an option to a job alias, such as
  `/bst fish`
- **THEN** nothing happens: no gear changes and no macro book changes

#### Scenario: Unloading the profile

- **WHEN** the loaded job profile is unloaded
- **THEN** `/fish` is no longer registered

### Requirement: `/fish` toggles the fishing set and macro book

`/fish` with no argument SHALL toggle fishing. Enabling it SHALL switch the
macro book to the fishing book; disabling it SHALL restore the macro book the
loaded job declares as its own, when that job declares one. The profile SHALL
report the resulting state to the player either way.

#### Scenario: Turning fishing on

- **WHEN** fishing is off and the player types `/fish`
- **THEN** fishing becomes enabled, the macro book switches to the fishing book,
  and the new state is reported

#### Scenario: Turning fishing off

- **WHEN** fishing is on and the player types `/fish`
- **THEN** fishing becomes disabled, the macro book returns to the loaded job's
  own book if it declares one, and the new state is reported

### Requirement: Fishing gear is worn while fishing is enabled

While fishing is enabled the profile SHALL wear the fishing set — the angler's
body, hands, legs and feet — together with the selected rod in the ranged slot
and the selected bait in the ammo slot. The set SHALL be applied over whatever
the job is wearing, and SHALL take precedence over the job's own gear in the
slots it covers. While fishing is disabled the profile SHALL apply no part of
the fishing set.

#### Scenario: Standing with fishing enabled

- **WHEN** fishing is enabled
- **THEN** the angler's pieces are worn, the selected rod is in the ranged slot,
  and the selected bait is in the ammo slot

#### Scenario: Fishing disabled

- **WHEN** fishing is disabled
- **THEN** no slot is claimed by fishing, and the job's own gear governs every
  slot

### Requirement: The rod and the bait are chosen by command

The profile SHALL accept `/fish rod <name>` and `/fish bait <name>`, where
`<name>` is one short word naming an entry in the profile's list of rods or
baits. A recognised name SHALL become the selection, SHALL be reported to the
player, and SHALL take effect on the next gear application without a reload. A
name that is not in the list SHALL be reported as unrecognised and SHALL leave
the current selection unchanged. The profile SHALL start with a default rod and
a default bait selected, so `/fish` alone is usable without choosing either.

#### Scenario: Choosing a listed rod

- **WHEN** the player types `/fish rod` with a name from the rod list
- **THEN** that rod becomes the selection, it is reported, and it is the rod
  worn in the ranged slot from then on

#### Scenario: Choosing a listed bait

- **WHEN** the player types `/fish bait` with a name from the bait list
- **THEN** that bait becomes the selection, it is reported, and it is the bait
  worn in the ammo slot from then on

#### Scenario: A name that is not listed

- **WHEN** the player names a rod or bait the list does not carry
- **THEN** the profile reports that the name is not recognised, and the previous
  selection stays in force

#### Scenario: A selection outlives the toggle

- **WHEN** a rod or bait is chosen, fishing is turned off, and fishing is turned
  on again
- **THEN** the chosen rod and bait are the ones worn

### Requirement: Choosing tackle starts fishing

Choosing a rod or a bait while fishing is disabled SHALL enable fishing, with
the same effect as the toggle: the fishing set goes on and the macro book
switches to the fishing book. Choosing tackle while fishing is already enabled
SHALL leave it enabled and SHALL NOT switch the macro book again.

#### Scenario: Choosing a rod with fishing off

- **WHEN** fishing is off and the player chooses a listed rod or bait
- **THEN** the selection is made and fishing becomes enabled, wearing the
  fishing set and switching to the fishing book

#### Scenario: Choosing a rod with fishing on

- **WHEN** fishing is on and the player chooses a listed rod or bait
- **THEN** the selection is made and fishing stays enabled

#### Scenario: An unrecognised name does not start fishing

- **WHEN** fishing is off and the player names a rod or bait the list does not
  carry
- **THEN** fishing stays off

### Requirement: The command lists what it accepts

`/fish rod` and `/fish bait` with no name SHALL list the names available for
that kind of tackle and mark the current selection. `/fish help` SHALL list
every word `/fish` accepts, along with the selected rod and bait and whether
fishing is currently enabled. Neither listing SHALL change the fishing state,
the selections, or the macro book.

#### Scenario: Listing the rods

- **WHEN** the player types `/fish rod` with no name
- **THEN** the available rod names are listed with the current one marked, and
  nothing about the fishing state changes

#### Scenario: Listing the baits

- **WHEN** the player types `/fish bait` with no name
- **THEN** the available bait names are listed with the current one marked, and
  nothing about the fishing state changes

#### Scenario: Asking for help

- **WHEN** the player types `/fish help`
- **THEN** every accepted word is listed, together with the selected rod, the
  selected bait, and whether fishing is enabled
