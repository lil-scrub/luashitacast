local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
	CurrentLevel = 0,
};

-- Gear candidates pulled from the HorizonXI wiki and the item API.
-- Every _Priority list is scored for unconditional stats only: latent
-- effects, enchantments, set bonuses, Salvage/Assault/Besieged conditionals,
-- and conditional stats (time-of-day, weather, nation control, etc.) do
-- not count. Ties go to the lower-level piece. Names are the game's short
-- names taken from the item API.
--
-- PRUNE THESE TO GEAR YOU ACTUALLY OWN. gFunc.EvaluateLevels picks the first
-- entry your LEVEL allows; it checks neither job nor inventory. An item you
-- do not own still wins its slot, and that slot then silently keeps whatever
-- was already equipped rather than falling through to gear you do have.

sets = {
    -- TP / melee, worn while engaged.
    -- The Att or Acc accessory set (below) is layered under this set by
    -- common.EquipMelee(), so only the piece-slots go here.
    ['Tp_Priority'] = {
        Head  = { 'Optical Hat', 'Aurum Armet', 'Wyrm Armet', 'Drachen Armet',
                  'Breeder Mask', 'Valkyrie\'s Mask', 'Bone Mask +1', 'Ryl.Ftm. Bandana' },
        Body  = { 'Askar Korazin', 'Aurum Cuirass', 'Assault Jerkin', 'Drachen Mail',
                  'Wyrm Mail', 'Wyvern Mail', 'Brigandine +1', 'Bone Harness +1', 'Scale Mail' },
        Hands = { 'Dusk Gloves +1', 'Dusk Gloves', 'Aurum Gauntlets', 'Barbarian Mittens',
                  'Tarasque Mitts +1', 'Tarasque Mitts', 'Spiked Fng.Gnt.',
                  'Ryl.Ftm. Gloves' },
        Legs  = { 'Hct. Subligar +1', 'Hecatomb Subligar', 'Dusk Trousers +1', 'Dusk Trousers',
                  'Armadillo Cuisses', 'Aurum Cuisses', 'Hydra Cuisses',
                  'Drachen Brais', 'Falconer\'s Hose', 'Feral Trousers',
                  'Bone Subligar +1', 'Scale Cuisses' },
        Feet  = { 'Dusk Ledelsens +1', 'Dusk Ledelsens', 'Aurum Sabatons',
                  'Drachen Greaves', 'Leaping Boots' },
    },

    -- Attack-priority accessory set. Layered by common.EquipMelee() when
    -- accuracy mode is off. Best unconditional Attack per slot.
    -- Orochi Nodowa +1/Orochi Nodowa give Attack+7/+6 (plus Regen -- that's
    -- a bonus not a deduction, so we count them). Merman's Earring gives
    -- Attack+6 (magic-damage-taken penalty is defensive, not an att penalty).
    ['Att_Priority'] = {
        Head  = { 'Valkyrie\'s Mask' },
        Neck  = { 'Orochi Nodowa +1', 'Orochi Nodowa', 'Spike Necklace', 'Fang Necklace' },
        Ear1  = { 'Merman\'s Earring', 'Assault Earring', 'Minuet Earring',
                  'Bone Earring +1', 'Bone Earring' },
        Ear2  = { 'Merman\'s Earring', 'Assault Earring', 'Minuet Earring',
                  'Bone Earring +1', 'Bone Earring' },
        Ring1 = { 'Mars\'s Ring', 'Gnd.Kgt. Ring', 'Courage Ring',
                  'Horn Ring +1', 'Horn Ring' },
        Ring2 = { 'Mars\'s Ring', 'Gnd.Kgt. Ring', 'Courage Ring',
                  'Horn Ring +1', 'Horn Ring' },
        Back  = { 'Cerb. Mantle +1', 'Cerberus Mantle', 'Forager\'s Mantle',
                  'Psilos Mantle', 'Amemet Mantle +1', 'Amemet Mantle',
                  'Behem. Mantle +1', 'Behemoth Mantle' },
        Waist = { 'Zeta Sash', 'Wyrm Belt', 'Ninurta\'s Sash',
                  'Swordbelt +1', 'Swordbelt', 'Brave Belt' },
    },

    -- Accuracy-priority accessory set. Layered by common.EquipMelee() when
    -- accuracy mode is on (/drg acc). Best unconditional Accuracy per slot.
    -- Armadillo Cuisses (Acc+15) is conditional (Amnesia only) so it is not
    -- in this set. Frenzy Sallet (Acc+12) is latent only. Assault Earring
    -- carries both Acc+2 and Att+5 -- it appears in both Ear lists.
    ['Acc_Priority'] = {
        Neck  = { 'Merman\'s Gorget' },
        Ear1  = { 'Beastly Earring', 'Assault Earring', 'Minuet Earring',
                  'Accurate Earring', 'Bone Earring +1', 'Bone Earring' },
        Ear2  = { 'Beastly Earring', 'Assault Earring', 'Minuet Earring',
                  'Accurate Earring', 'Bone Earring +1', 'Bone Earring' },
        Ring1 = { 'Mars\'s Ring', 'Beetle Ring +1', 'Beetle Ring' },
        Ring2 = { 'Mars\'s Ring', 'Beetle Ring +1', 'Beetle Ring' },
        Back  = { 'Psilos Mantle', 'Amemet Mantle +1', 'Amemet Mantle' },
        Waist = { 'Nu Sash', 'Wyrm Belt', 'Master Belt' },
    },

    -- Pet-cast set: worn at precast and kept through midcast when calling or
    -- healing the wyvern (Call Wyvern, Spirit Link, Restoring Breath).
    -- Scored on unconditional Wyvern: HP+ only. "HP recovered while healing"
    -- bonuses on Wyrm Greaves, Leo Subligar, and Falconer's Hose, and
    -- enchantment effects on Earth Greaves / Gargoyle Boots / Healing Mail,
    -- do not count.
    --
    -- Chanoix's Gorget  Neck   Lv70  Wyvern: HP+50
    -- Homam Gambieras   Feet   Lv75  Wyvern: HP+50  (+ Haste+3%, Acc+6)
    -- Ostreger Mitts    Hands  Lv74  Wyvern: HP+10
    -- Drachen Brais     Legs   Lv52  Wyvern: HP+10 (flat, per wiki / API)
    -- Falconer's Hose   Legs   Lv50  Wyvern: HP+30
    -- Wyvern Mail       Body   Lv50  Wyvern: HP+65
    -- Wyvern Perch      Main   Lv73  Wyvern: HP+50  (staff / main weapon)
    ['PetCast_Priority'] = {
        Main  = { 'Wyvern Perch' },
        Neck  = { 'Chanoix\'s Gorget' },
        Body  = { 'Wyvern Mail' },
        Hands = { 'Ostreger Mitts' },
        Legs  = { 'Drachen Brais', 'Falconer\'s Hose' },
        Feet  = { 'Homam Gambieras' },
    },
};
profile.Sets = sets;

profile.Packer = {
};

evalLevel = function()
    local level = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    Settings.CurrentLevel = level;
    common.EvaluateGear(profile.Sets, level);

    common.EvalLevel(level);
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /drg /lac fwd');
	utility.OnLoad();

    common.RequestLockStyle(1);
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /drg');
	utility.OnUnload();
end

profile.HandleCommand = function(args)
    utility.SetOptions(args);
    common.SetMeleeOptions(args[1]);

    if (args[1] == 'gear') then
        common.EvaluateGear(profile.Sets, Settings.CurrentLevel, true);
        common.ReportGear(profile.Sets, Settings.CurrentLevel);
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();

	if (player.Status == 'Engaged') then
        common.EquipMelee();
        gFunc.EquipSet(common.Sets.Dream);
        gFunc.EquipSet(sets.Att);
        gFunc.EquipSet(sets.Tp);
	end

    utility.EquipSet();
end

profile.HandleAbility = function()
	local action = gData.GetAction();

	if (action.Name == 'Jump') or (action.Name == 'High Jump') then
		gFunc.EquipSet(sets.Att);
    end
end

profile.HandleItem = function()
	local action = gData.GetAction();
	utility.CheckItem(action.Name);
end

-- Worn at the start of every ability/spell cast.
-- For wyvern actions (Call Wyvern, Spirit Link, Restoring Breath) this is
-- the Pet HP set; the gear is on during the resolution frame.
profile.HandlePrecast = function()
	local action = gData.GetAction();

    if (action.Name == 'Call Wyvern') or
       (action.Name == 'Spirit Link') or
       (action.Name == 'Restoring Breath') then
        gFunc.EquipSet(sets.PetCast);
    end
end

-- Keep the Pet HP set through the midcast phase so the bonus is applied
-- when the server resolves the effect.
profile.HandleMidcast = function()
	local action = gData.GetAction();
	utility.CheckCast(action.Name);

    if (action.Name == 'Call Wyvern') or
       (action.Name == 'Spirit Link') or
       (action.Name == 'Restoring Breath') then
        gFunc.EquipSet(sets.PetCast);
    end
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;
