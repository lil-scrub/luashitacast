# Spec Delta

## Purpose

Governs what the bard wears whenever it is not casting: which idle gear mode is
active, how the player switches between modes, how the subjob adjusts a mode,
and when gear is re-resolved against what the character is actually carrying.

## ADDED Requirements

### Requirement: Idle gear follows the active mode

The profile SHALL maintain exactly one active idle mode at any time, and SHALL
equip that mode's gear whenever the character is not casting. Two modes SHALL be
available: a damage mitigation mode and an enmity reduction mode. Modes are
mutually exclusive — no two modes are ever worn together.

#### Scenario: Standing with the mitigation mode active

- **WHEN** the damage mitigation mode is active and the character is idle
- **THEN** the mitigation gear is worn in every slot the mode covers

#### Scenario: Standing with the enmity mode active

- **WHEN** the enmity reduction mode is active and the character is idle
- **THEN** the enmity reduction gear is worn, and no piece of the mitigation
  mode remains equipped in any slot the enmity mode covers

#### Scenario: Only one mode at a time

- **WHEN** a mode is made active
- **THEN** every other mode becomes inactive, and their gear is not layered on
  top of or underneath the active mode

### Requirement: The player switches modes by command

The profile SHALL accept a chat command per mode under the existing `/brd`
alias, following the `/<job> <verb>` convention used elsewhere in the project.
Issuing the command for a mode SHALL make that mode active. The profile SHALL
report the resulting active mode to the player.

#### Scenario: Switching to the enmity mode

- **WHEN** the player issues the enmity mode command while the mitigation mode
  is active
- **THEN** the enmity mode becomes active
- **AND** the profile prints which mode is now active

#### Scenario: Issuing the command for the mode that is already active

- **WHEN** the player issues the command for the mode that is already active
- **THEN** that mode remains active and the profile reports it

#### Scenario: An unrecognised command is ignored

- **WHEN** the player issues `/brd` with a word that matches no mode and no
  other handled command
- **THEN** the profile changes no gear and reports nothing about modes

### Requirement: Mode commands do not collide with reserved commands

Mode command words SHALL NOT collide with commands already handled before the
job profile sees them — the shared utility options (`exp`, `warp`, `sneak`,
`invis`, `clam`, `fish`), the shared accuracy option (`acc`), or the profile's
own `gear` command. A collision SHALL be surfaced when the profile loads rather
than silently shadowing the existing command.

#### Scenario: A mode is registered under a reserved word

- **WHEN** the profile loads with a mode whose command word is already reserved
- **THEN** the profile reports the collision to the player

#### Scenario: Existing commands keep working

- **WHEN** the player issues `gear`, or any shared utility or accuracy option
- **THEN** that command behaves exactly as it did before modes existed, and no
  mode is switched

### Requirement: The player can see the available modes

The profile SHALL provide a way to list every available mode and show which one
is active, so the set of modes is discoverable without reading the profile.

#### Scenario: Listing modes

- **WHEN** the player asks the profile to list modes
- **THEN** every available mode is named, and the active one is identifiable

### Requirement: The player can see every command the profile accepts

The profile SHALL provide a help listing that names each command it accepts,
with a short description of what the command does, and marks the active idle
mode. The listing SHALL be derived from the same registry that dispatches the
commands, so a mode that exists is always listed and a mode that is removed
stops being listed. The listing SHALL NOT name a command the profile does not
act on.

#### Scenario: Asking for help

- **WHEN** the player asks the profile for help
- **THEN** every idle mode, the gear rescan command, the mode listing command
  and the shared utility toggles are each named with a description
- **AND** the active idle mode is identifiable

#### Scenario: A mode is added

- **WHEN** a mode is added to the registry
- **THEN** the help listing names it without any separate edit to the help

#### Scenario: Help does not advertise what the profile ignores

- **WHEN** a command word is reserved so that a mode cannot claim it, but the
  profile itself takes no action on that word
- **THEN** the help listing does not name it as an available command

### Requirement: The mitigation mode is active when the profile loads

The damage mitigation mode SHALL be the active mode after the profile loads.
Mode selection SHALL NOT persist across a profile load, so zoning or changing
job returns the character to the mitigation mode.

#### Scenario: Fresh load

- **WHEN** the profile loads
- **THEN** the damage mitigation mode is active

#### Scenario: Zoning while the enmity mode is active

- **WHEN** the player activates the enmity mode and then zones
- **THEN** the profile reloads with the damage mitigation mode active

### Requirement: The mitigation mode prioritises magic damage reduction

Within each slot, the damage mitigation mode SHALL prefer gear in this order:
gear reducing magic damage taken, then gear reducing damage taken from both
schools, then gear reducing magic damage by other means, then gear reducing
physical damage taken, then raw defence. Gear that increases enmity SHALL be
excluded from this mode outright.

#### Scenario: Magic reduction outranks physical reduction

- **WHEN** a slot offers both a piece reducing magic damage taken and a piece
  reducing physical damage taken, and both are carried and wearable
- **THEN** the piece reducing magic damage taken is equipped

#### Scenario: Reduction of both schools outranks defence

- **WHEN** a slot offers a piece reducing damage taken from both schools and a
  piece carrying only raw defence, and both are carried and wearable
- **THEN** the piece reducing damage taken from both schools is equipped

#### Scenario: Enmity-increasing gear is never chosen

- **WHEN** a piece that increases enmity would otherwise rank highest in a slot
- **THEN** it is not equipped in the mitigation mode

### Requirement: The enmity mode prioritises enmity reduction

Within each slot, the enmity reduction mode SHALL prefer gear that reduces
enmity above gear chosen for any other property.

#### Scenario: Enmity reduction outranks mitigation

- **WHEN** a slot offers both a piece reducing enmity and a piece reducing
  damage taken, and both are carried and wearable
- **THEN** the piece reducing enmity is equipped

#### Scenario: A slot with no enmity reduction available

- **WHEN** a slot offers no carried piece that reduces enmity
- **THEN** the mode's fallback gear for that slot is equipped rather than the
  slot being left empty

### Requirement: Only carried gear is equipped

A mode SHALL equip, in each slot, the highest ranked piece that the character
both is carrying and can wear at the current level. A piece that is listed but
not carried SHALL NOT claim its slot, and SHALL NOT prevent a lower ranked
piece that is carried from being equipped.

#### Scenario: The top ranked piece is not owned

- **WHEN** the highest ranked piece for a slot is not in the character's bags
- **THEN** the highest ranked piece that is carried and wearable is equipped in
  that slot

#### Scenario: A piece is above the character's level

- **WHEN** a carried piece for a slot requires a higher level than the character
  has
- **THEN** it is skipped and the next carried, wearable piece is equipped

#### Scenario: The bags cannot be read

- **WHEN** gear cannot be resolved because the character's containers are not
  readable
- **THEN** the currently equipped gear is left in place rather than being
  cleared, and resolution is retried

### Requirement: Gear is re-resolved when the mode is switched

Switching modes SHALL re-resolve gear against the character's current bag
contents, so a mode reflects gear acquired since the last resolution rather than
resolving against a stale view. A single switch SHALL read the bags at most
once, however many gear tables are refreshed.

#### Scenario: Gear acquired since the last resolution

- **WHEN** the player obtains a piece belonging to a mode and then switches to
  that mode
- **THEN** the newly obtained piece is equipped, without the player having to
  issue a separate gear rescan

#### Scenario: All gear tables are refreshed together

- **WHEN** a mode switch re-resolves gear
- **THEN** every gear table the profile resolves is refreshed from the same
  reading of the bags

### Requirement: A white mage subjob adjusts modes that declare it

A mode MAY declare gear that applies only under a white mage subjob. Where a
mode declares it, that gear SHALL take precedence over the mode's own choice in
the slots it covers, and SHALL apply only when the subjob is white mage. Where a
mode declares none, the subjob SHALL NOT change what that mode equips.

#### Scenario: White mage subjob with a mode that declares subjob gear

- **WHEN** the mitigation mode is active, the subjob is white mage, and the
  declared subjob gear is carried
- **THEN** that gear is equipped in the slots it covers, over the mode's own
  choice

#### Scenario: Declared subjob gear is not carried

- **WHEN** the mitigation mode is active, the subjob is white mage, and the
  declared subjob gear is not carried
- **THEN** the mode's own choice for those slots remains equipped

#### Scenario: A mode that declares no subjob gear

- **WHEN** a mode declaring no subjob gear is active and the subjob is white
  mage
- **THEN** the mode equips exactly what it would equip under any other subjob

#### Scenario: A non white mage subjob

- **WHEN** any mode is active and the subjob is not white mage
- **THEN** no subjob gear is applied

### Requirement: Song handling is unaffected by the active mode

Casting SHALL continue to take precedence over idle gear regardless of which
mode is active, and the active mode's gear SHALL return once casting gear is
released.

#### Scenario: Casting a song while a mode is active

- **WHEN** the character casts a song with any mode active
- **THEN** the song's casting and instrument gear is equipped for the cast

#### Scenario: After a song completes

- **WHEN** the song completes and its casting gear is released
- **THEN** the active mode's gear is equipped again in the released slots
