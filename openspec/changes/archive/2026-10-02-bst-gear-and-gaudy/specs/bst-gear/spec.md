# Spec Delta

## Purpose

Governs what the beast master wears and when: the melee and charm sets, the
swap that happens while charming, gear worn only while a subjob condition
holds, the rune-axe mode, and the jug selection that drives `Call Beast`.

## ADDED Requirements

### Requirement: Melee gear is worn while engaged

The profile SHALL maintain one melee set covering every armour and accessory
slot, and SHALL equip it whenever the character is engaged. The set SHALL be
ordered by melee multipliers first — haste, double attack and triple attack —
then flat attack, then STR, then remaining melee value. A stat that applies only
under a condition (a latent, an enchantment, a set bonus) SHALL NOT count
towards a piece's rank. The set SHALL be resolved against both the character's
level and what the character is actually carrying, so a slot names the best
piece the character owns and can wear rather than the best piece that exists.

#### Scenario: Engaging a target

- **WHEN** the character becomes engaged
- **THEN** the melee set is worn in every slot it covers

#### Scenario: A listed piece is not carried

- **WHEN** the melee set's first choice for a slot is not in the character's
  bags
- **THEN** the highest-ranked piece for that slot that is carried and usable at
  the character's level is worn instead

#### Scenario: Disengaging

- **WHEN** the character stops being engaged
- **THEN** the profile stops applying the melee set, and changes no slot except
  those some other rule in this capability claims

### Requirement: Charm gear is worn only for the charm attempt

The profile SHALL maintain one charm set, ordered by the unrestricted Charm
bonus first, then CHR, then gear that improves Tame, and SHALL equip it when the
character uses Charm. A charm bonus that applies only against one monster family
is a conditional stat and SHALL NOT count towards a piece's rank. The charm set
SHALL NOT be worn at any other time.

#### Scenario: Charming a monster

- **WHEN** the character uses Charm
- **THEN** the charm set is worn for that ability

#### Scenario: Standing or fighting

- **WHEN** the character is idle or engaged and is not using Charm
- **THEN** no part of the charm set is applied by this rule

### Requirement: Gaudy Harness is worn while its subjob condition holds

The profile SHALL wear `Gaudy Harness` while either subjob condition below
holds, whether the character is idle or engaged, and SHALL hand the body slot
back to whatever set otherwise claims it once the condition stops holding. The
conditions are:

- **White mage subjob**: MP is below the Gaudy Harness latent's threshold of 49
  points. Refresh is the reason the piece is worn, and the latent is dormant at
  or above that MP.
- **Ninja subjob**: the rune-axe mode is on. No MP test applies — under a ninja
  subjob the piece is worn for its per-axe HP regen, which does not depend on
  MP.

Under any other subjob the profile SHALL NOT wear `Gaudy Harness`.

#### Scenario: White mage subjob drops below the threshold

- **WHEN** the subjob is white mage and MP falls below 49
- **THEN** `Gaudy Harness` is worn, whether the character is idle or engaged

#### Scenario: White mage subjob recovers MP

- **WHEN** the subjob is white mage, `Gaudy Harness` is worn, and MP reaches 49
  or more
- **THEN** `Gaudy Harness` is taken off and the body slot returns to the set
  that otherwise claims it — the melee set while engaged, and the piece worn
  before the swap while idle

#### Scenario: Ninja subjob with the rune-axe mode on

- **WHEN** the subjob is ninja and the rune-axe mode is on
- **THEN** `Gaudy Harness` is worn regardless of the character's MP

#### Scenario: Ninja subjob with the rune-axe mode off

- **WHEN** the subjob is ninja and the rune-axe mode is off
- **THEN** `Gaudy Harness` is not worn, whatever the character's MP

#### Scenario: Any other subjob

- **WHEN** the subjob is neither white mage nor ninja
- **THEN** `Gaudy Harness` is not worn, whatever the character's MP and whatever
  the rune-axe mode is set to

### Requirement: The rune-axe mode is toggled by command and claims the weapon slots

The profile SHALL accept a `/bst` subcommand that turns the rune-axe mode on and
off, following the `/<job> <verb>` convention used elsewhere in the project, and
SHALL report the resulting state to the player. The mode SHALL be off when the
profile loads.

While the mode is on and the subjob is ninja, the profile SHALL equip the
character's rune axes in the main and sub weapon slots while engaged, in place
of the dual-wield weapons it would otherwise equip. Under any other subjob the
mode SHALL change no weapon, so the weapons equipped while engaged are the ones
the profile already chooses today.

#### Scenario: Turning the mode on

- **WHEN** the player issues the rune-axe subcommand while the mode is off
- **THEN** the mode becomes on and the profile prints its new state

#### Scenario: Turning the mode off

- **WHEN** the player issues the rune-axe subcommand while the mode is on
- **THEN** the mode becomes off and the profile prints its new state

#### Scenario: Engaging with the mode on under a ninja subjob

- **WHEN** the subjob is ninja, the mode is on, and the character is engaged
- **THEN** the rune axes are equipped in the main and sub slots, and the
  dual-wield weapons the profile would otherwise equip are not

#### Scenario: Engaging with the mode on under another subjob

- **WHEN** the subjob is not ninja, the mode is on, and the character is engaged
- **THEN** the weapons equipped are the ones the profile chooses for that subjob
  with the mode off

#### Scenario: A rune axe is not carried

- **WHEN** the mode is on under a ninja subjob and a rune axe is not in the
  character's bags
- **THEN** that weapon slot keeps whatever is already in it, and no error is
  raised

### Requirement: Call Beast equips the pet-bonus set and the selected broth

The profile SHALL equip its pet-bonus set when the character uses `Call Beast`,
and SHALL then equip the broth for the currently selected jug pet, so the broth
keeps the ammunition slot.

#### Scenario: Calling a jug pet

- **WHEN** the character uses `Call Beast`
- **THEN** the pet-bonus set is worn and the selected pet's broth occupies the
  ammunition slot

### Requirement: The player selects the jug pet and broth quality by command

The profile SHALL accept jug selection under the `/bst` alias in three forms:
selecting a pet with its normal broth, selecting a pet with its high quality
broth, and switching the already-selected pet to its high quality broth. The
profile SHALL report the selected pet and broth quality after any of them, and
on profile load.

An unknown pet name SHALL leave the selection unchanged and SHALL be reported.
Selecting a high quality broth for a pet that has none SHALL fall back to that
pet's normal broth and SHALL be reported, rather than leaving a selection that
equips nothing when `Call Beast` is used.

#### Scenario: Selecting a pet

- **WHEN** the player names a known jug pet
- **THEN** that pet becomes the selection and the profile reports the pet and
  broth quality

#### Scenario: Selecting a high quality broth

- **WHEN** the player asks for the high quality broth of a pet that has one
- **THEN** that pet's high quality broth is what `Call Beast` equips, and the
  profile reports it

#### Scenario: A pet with no high quality broth

- **WHEN** the player asks for the high quality broth of a pet that has none
- **THEN** the profile reports that there is no high quality broth for that pet
  and falls back to its normal broth

#### Scenario: An unknown pet name

- **WHEN** the player names a pet the profile does not know
- **THEN** the selection is unchanged and the profile reports the unknown name

### Requirement: Gear is re-resolved against the bags on demand

The profile SHALL accept a `/bst` command that rescans the character's bags,
re-resolves every gear set against the scan, and reports how many slots each set
filled, so gear acquired since the last scan is picked up without reloading the
profile and an empty set is distinguishable from an unreadable bag.

#### Scenario: Rescanning after acquiring gear

- **WHEN** the player issues the gear command after obtaining a piece that a set
  ranks above what it currently resolves to
- **THEN** the sets are re-resolved from a fresh scan and the new piece is what
  that slot equips afterwards

#### Scenario: Reporting what was found

- **WHEN** the player issues the gear command
- **THEN** the profile reports the number of equippable items found and, per
  set, how many of its slots are filled by gear actually carried
