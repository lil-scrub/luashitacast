# Tasks

Steps 1-3 must not change what the profile equips. Step 1 builds the tool that
proves it; steps 4 and 5 are content and are expected to differ.

## 1. Verification harness

- [x] 1.1 Write a script that loads a profile against stubbed `gFunc`, `gData`,
      `gSettings` and `AshitaCore` globals and prints every resolved set as
      sorted `set|slot|index|item` lines; verify it prints a non-empty dump for
      `BRD.lua` and exits cleanly for every other profile in the repo
- [x] 1.2 Capture a baseline dump of `BRD.lua` from the current commit and store
      it outside the repo; verify re-running the script against an unmodified
      tree reproduces the baseline byte for byte

## 2. Rename to the Idle family (behaviour preserving)

- [x] 2.1 Rename `Pulling_NIN_Priority` to `Idle_Mit_Priority` and
      `Pulling_WHM_Priority` to `Idle_Mit_WHM_Priority`, updating the two
      references in `HandleDefault`; verify `luac -p BRD.lua` passes
- [x] 2.2 Update the set comments so they describe standing gear rather than
      pulling specifically; verify no occurrence of `Pulling` remains in
      `BRD.lua`
- [x] 2.3 Verify the dump from task 1.1 differs from the 1.2 baseline only in
      set names, with every slot, index and item identical

## 3. Collapse the subjob duplication

- [x] 3.1 Reduce `Idle_Mit_WHM_Priority` to only the two slots that differ from
      `Idle_Mit_Priority` — `Neck` leading with `Stoneskin Torque` and `Body`
      leading with `Gaudy Harness`; verify the set declares exactly two slots
- [x] 3.2 Change `HandleDefault` to equip `Idle_Mit` unconditionally and then
      equip `Idle_Mit_WHM` over it only when the subjob is white mage; verify
      `luac -p BRD.lua` passes
- [x] 3.3 Verify the dump shows `Idle_Mit` unchanged and `Idle_Mit_WHM` reduced
      to two slots, about 620 duplicated gear entries and roughly 140 lines of
      `BRD.lua` removed
- [ ] 3.4 Confirm in game under a white mage subjob that `Stoneskin Torque` and
      `Gaudy Harness` are still worn when carried, and that the twelve other
      slots match what a ninja subjob equips

## 4. Mode registry and switching

- [x] 4.1 Add the mode registry as an ordered array of descriptors, each naming
      its command word, its gear set and its optional subjob set, with
      `Idle_Mit` as the only entry; verify `luac -p BRD.lua` passes
- [x] 4.2 Rewrite `HandleDefault` to equip the active entry's set and its subjob
      set instead of branching on subjob directly; verify the dump is unchanged
      from task 3.3 and that gear in game is identical to before
- [x] 4.3 Add mode switching to `HandleCommand`, reporting the resulting active
      mode; verify `/brd mit` reports the mitigation mode and equips its gear
- [x] 4.4 Assert at load that no registered command word collides with `gear`,
      `acc`, or the utility options `exp`, `warp`, `sneak`, `invis`, `clam` and
      `fish`; verify a deliberately colliding entry prints a warning on load and
      that removing it silences the warning
- [x] 4.5 Add mode listing that names every registered mode and marks the active
      one; verify it lists the registered modes in game
- [x] 4.6 Verify the mitigation mode is active after a profile load, and that
      the mode does not survive a zone or job change

## 5. Re-resolution on switch

- [x] 5.1 Add a routine that drops the cached bag scan once and then re-resolves
      every gear table the profile owns — profile sets, songs and staves; verify
      it resolves all three from a single bag reading
- [x] 5.2 Call that routine when the active mode changes; verify that obtaining
      a piece belonging to a mode and then switching to that mode equips it
      without a separate `/brd gear`
- [x] 5.3 Rewire the existing `gear` command onto the same routine; verify it
      now walks the bags once rather than twice and refreshes the staves table
      it previously skipped
- [x] 5.4 Verify `/brd gear` still prints the per-set owned-slot report and that
      its counts are unchanged for sets that were not edited

## 6. Enmity reduction set

- [x] 6.1 Author `Idle_Enmity_Priority` across all fourteen slots the mitigation
      set covers, ranking gear that reduces enmity first and falling back to
      mitigation gear where no enmity reduction exists for a slot; verify every
      one of the fourteen slots is populated
- [x] 6.2 Decide whether the enmity set needs a white mage subjob set of its own
      and add one only if it does; record the decision in `design.md` under the
      matching open question
- [x] 6.3 Register the enmity mode in the registry; verify `/brd enmity` makes it
      active and `/brd mit` returns to mitigation
- [x] 6.4 Verify with `/brd gear` that the enmity set reports a plausible
      owned-slot count, and that switching between the two modes in game visibly
      changes equipment rather than leaving pieces of the previous mode on

## 7. Re-score the mitigation set

- [x] 7.1 Re-score every slot of `Idle_Mit_Priority` magic-first — magic damage
      taken, then damage taken from both schools, then magic defence, then
      physical damage taken, then defence — keeping gear that increases enmity
      excluded; verify every slot is still populated and `luac -p BRD.lua` passes
- [x] 7.2 Resolve the two open scoring questions in `design.md` while scoring —
      whether raw defence survives as the final tiebreaker, and whether magic
      defence is its own term — and record both answers in `design.md`
- [x] 7.3 Re-examine the `Main` slot specifically: its only entries are the two
      Earth staves, documented as physical damage taken -20%, which no longer
      rank first under a magic-first rule; verify the slot lists whatever now
      ranks above them or record why the staves still lead
- [x] 7.4 Verify with the dump that the re-score changed the head of the slots it
      was expected to change, and that no slot resolved empty

## 8. Help listing

- [x] 8.1 Add a table of the shared utility toggles paired with a one-line
      description, held next to the mode registry; verify it names exactly the
      six words `utility.SetOptions` acts on and no others
- [x] 8.2 Add the help listing, generated by walking the mode registry and that
      table, marking the active idle mode; verify it names every mode, `gear`,
      `modes` and the utility toggles, and does not name `acc`
- [x] 8.3 Route `/brd help` and a bare `/brd` to the help listing, leaving
      `/brd modes` as the focused mode list; verify all three in the harness
- [x] 8.4 Add `help` to `ReservedCommands` so a mode cannot shadow it; verify a
      mode registered as `help` warns at load
- [x] 8.5 Verify the whole listing is at most eight chat lines, since each is
      printed with its own `[LuAshitacast]` header
- [x] 8.6 Verify adding a throwaway mode to the registry makes it appear in the
      help with no other edit, then remove it

## 9. Conditional gear

- [x] 9.1 Add a `Refresh_WHM_Priority` set holding `Gaudy Harness` in `Body`,
      and remove `Gaudy Harness` from `Idle_Mit_WHM_Priority` so that set is
      `Stoneskin Torque` in `Neck` alone; verify `Idle_Mit_WHM` resolves to one
      slot and the new set to one
- [x] 9.2 Add a conditional list next to the mode registry, each entry pairing a
      set name with a predicate over the player, holding one entry: the refresh
      body when the subjob is white mage and MP is below 49; verify
      `luac -p BRD.lua` passes
- [x] 9.3 Apply the conditional list in `HandleDefault` after the active mode
      and its subjob set; verify with the harness that the refresh body is
      equipped under both modes at MP 20 and under neither at MP 60
- [x] 9.4 Verify the subjob still gates it: at MP 20 with a ninja subjob the
      refresh body is not equipped, and `Stoneskin Torque` still applies in the
      mitigation mode under a white mage subjob
- [x] 9.5 Verify the enmity mode keeps `Hydra Doublet` in `Body` when MP is at
      or above 49, confirming the gate returns the slot to the mode
- [ ] 9.6 Confirm in game: with a white mage subjob, cast until MP drops below
      49 and check the refresh body appears in both `/brd mit` and `/brd enmity`,
      and leaves once MP is back above the threshold

## 10. Final checks

- [x] 10.1 Run `luac -p` over every Lua file in the repo and verify all pass
- [x] 10.2 Verify every other job profile's dump is byte-identical to its baseline,
      confirming nothing outside `BRD.lua` was disturbed
- [ ] 10.3 Reload in game and verify the full loop: both modes switch, the subjob
      gear applies, songs cast and return to the active mode's gear afterwards,
      and resting still equips the resting staff
- [x] 10.4 Update `CLAUDE.md` to document the mode registry alongside the existing
      utility-toggle notes; verify it names the commands and says that adding a
      mode is one registry row plus its gear set
