# Tasks

Ordered so the mechanism lands before the content, per design.md — Migration
Plan. Each of the four groups leaves `BST.lua` in a loadable, playable state.

## 1. Conditional gear and the white mage case

- [x] 1.1 Add a baseline expansion harness: load `BST.lua` against stubbed
      framework globals (`gFunc`, `gData`, `gSettings`, `AshitaCore`) and dump
      every resolved set plus the jug selection to a file, in the manner used
      for `lists.lua` in `a9c46de`. Verify by dumping the current profile and
      keeping the output as the diff baseline for groups 1–4.
- [x] 1.2 Add `Gaudy_Priority = { Body = { 'Gaudy Harness' } }` to the set
      table. Verify the dump from 1.1 shows `Gaudy.Body` resolving to
      `Gaudy Harness` when the piece is in the stubbed bags and to nothing when
      it is not.
- [x] 1.3 Add the local `Conditionals` table with the `/WHM` row — set `Gaudy`,
      predicate `SubJob == 'WHM' and MP < 49`, slots `{ 'Body' }` — with the
      comment explaining that 49 is the latent's own trigger, per design.md
      Decision 2. Verify the predicate returns true at MP 48 under `/WHM` and
      false at MP 49, under `/WHM` and every other subjob.
- [x] 1.4 Evaluate the conditionals in `HandleDefault`, after the `Engaged`
      block and before `utility.EquipSet()`, tracking which entries were live on
      the previous tick. Verify with stubbed player state that a live entry
      equips its set while idle **and** while engaged, per design.md Decision 4.
- [x] 1.5 Add the release step: when an entry goes from live to dormant, equip
      its named slots once from the resolved melee set (`sets.Tp`), and equip
      nothing for a slot the melee set has not resolved. Verify that crossing MP
      49 upward equips `sets.Tp.Body` exactly once, and that a further tick at
      the same MP equips nothing.
- [ ] 1.6 In game: under `/WHM`, rest from below 49 MP past it and back, idle
      and engaged. Verify `Gaudy Harness` goes on below 49, comes off at 49 or
      above, and that the melee body returns in its place.

## 2. The rune-axe mode

- [x] 2.1 Add `Settings.UseRuneAxes = false` and the `/bst rune` toggle in
      `HandleCommand`, echoing the new state the way the jug setting echoes.
      Verify `/bst rune` flips and prints the state, and that `gear`, `jug`,
      `acc` and the six utility words still reach their existing handlers
      unchanged.
- [ ] 2.2 Add `RuneAxe_Priority` with `Main` and `Sub` only. Verify against the
      names `/bst gear` reports while the axes are carried — the open question
      in design.md — rather than the wiki, since the harvested data has no axes.
- [x] 2.3 Branch the engaged weapon swap: `/NIN` with the mode on equips
      `sets.RuneAxe`, `/NIN` with it off equips `sets.DualWield`, every other
      subjob equips `sets.Axe` as today. Verify all three paths in the dump from
      1.1, and that the non-ninja path is byte-identical to the baseline.
- [x] 2.4 Add the `/NIN` row to `Conditionals` — set `Gaudy`, predicate
      `SubJob == 'NIN' and Settings.UseRuneAxes`, no MP test, slots
      `{ 'Body' }` — with the comment recording that the piece is worn here for
      per-axe HP regen, not refresh. Verify the predicate ignores MP entirely and
      is false under `/NIN` with the mode off.
- [ ] 2.5 In game: under `/NIN` with the mode on, engage and verify the rune
      axes stay in hand across several ticks and `Gaudy Harness` is worn at full
      MP; toggle the mode off and verify the dual-wield weapons and the melee
      body come back.
- [ ] 2.6 In game: with the mode left on, change the subjob to something other
      than `/NIN` and `/WHM` and engage. Verify weapons and body are exactly
      what they were before this change.

## 3. Re-score the melee ladder

- [x] 3.1 Score `Tp_Priority` per slot from `tools/wikidata/items.json` —
      BST-usable, within the 75 cap, attack first, then STR, then remaining
      melee value — excluding conditional stats per the `ecad9f2` rule. Verify
      every retained and added entry appears in the data with the stat that
      earned its rank, and that no entry claims `Ammo`.
- [x] 3.2 Replace the `Main`/`Sub`-free slots of `Tp_Priority` with the scored
      order, leaving `DualWield_Priority`, `Axe_Priority` and `Scythe_Priority`
      untouched. Verify the dump from 1.1 shows no weapon slot moved.
- [x] 3.3 Diff the resolved `Tp` set against the 1.1 baseline and read every
      moved slot, confirming each move is explained by the scoring rule rather
      than by an item that is simply new to the list.
- [ ] 3.4 In game: `/bst gear`, then engage. Verify the report shows `Tp`
      filling at least as many slots as before, and that a body is resolved —
      the release step in 1.5 depends on it.

## 4. Re-score the charm ladder

- [x] 4.1 Score `Charm_Priority` per slot from `tools/wikidata/items.json` —
      BST-usable, within the 75 cap, CHR first, then gear that enhances charm
      outright — excluding conditional stats, including the `Main` staff slot,
      which the data does cover. Verify each entry's stat in the data and that
      no entry claims `Ammo`.
- [x] 4.2 Replace `Charm_Priority` with the scored order, leaving the
      `HandleAbility` swap on `Charm` exactly as it is. Verify the charm set is
      still applied only for `Charm` and never from `HandleDefault`.
- [x] 4.3 Diff the resolved `Charm` set against the 1.1 baseline and read every
      moved slot, as in 3.3.
- [ ] 4.4 In game: charm a monster and verify the charm gear goes on for the
      attempt and the melee or idle gear is back afterwards.

## 5. Regression and close-out

- [x] 5.1 Verify the jug path is untouched end to end: `/bst jug tiger`,
      `/bst jug hq tiger`, `/bst jug hq` on a pet with no high quality broth
      (falls back and says so), and an unknown pet name (selection unchanged,
      reported). Verify `Call Beast` equips the pet-bonus set and leaves the
      broth in `Ammo`.
- [x] 5.2 Verify `Reward` and `Call Beast` gear are byte-identical to the 1.1
      baseline — neither set is in scope for re-scoring.
- [x] 5.3 Verify the utility toggles still work from `/bst` (`exp`, `warp`,
      `sneak`, `invis`, `clam`, `fish`) and that `fish` still switches the macro
      book and restores book 4 on the way back.
- [x] 5.4 Update `CLAUDE.md` — the Patterns section — with the BST conditional
      gear and rune-axe mode, in the style of the existing BRD idle-modes entry.
      Verify the entry names the release step, since that is what differs from
      BRD's version.
