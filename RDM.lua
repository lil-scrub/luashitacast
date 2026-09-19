local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
local staves = gFunc.LoadFile('./staves.lua');

local Settings = {
    MacroBook = '1',
    CurrentLevel = 0,
    UseMelee = false,
};

-- Filling these in: gFunc.EvaluateLevels picks the first entry in a
-- _Priority list that your LEVEL allows. It does not check your job or your
-- inventory, so an item you cannot wear or do not own still wins its slot
-- and leaves it empty instead of falling through to the next entry. Only
-- list gear you actually have. The commented entries are era-standard
-- suggestions -- uncomment them as you acquire them.
-- Gear candidates pulled from the HorizonXI wiki: every piece RDM can wear,
-- scored per set and laddered down the level bands so each list resolves at
-- any level. The level of each entry is noted after the line.
--
-- PRUNE THESE TO GEAR YOU ACTUALLY OWN. gFunc.EvaluateLevels picks the first
-- entry your LEVEL allows; it checks neither job nor inventory. An item you do
-- not own still wins its slot, and that slot then silently keeps whatever was
-- already equipped rather than falling through to gear you do have.
sets = {
    -- Melee / TP, worn while engaged in melee mode.
    ['TP_Priority'] = {
        Head  = { 'Nashira Turban', 'Torama Mask', 'Shadow Mask', 'Akinji Khud', 'Jester\'s Headband', 'Spelunker\'s Hat' }, -- lv 75/69/62/55/46/40
        Neck  = { 'Dream Collar', 'Sniper\'s Collar', 'Opo-opo Necklace', 'Ashura Necklace', 'Auditory Torque', 'Jagd Gorget' }, -- lv 75/69/61/54/47/40
        Ear1  = { 'Jupiter\'s Earring', 'Fenrir\'s Earring', 'Merman\'s Earring', 'Bitter Earring', 'Vision Earring', 'Intruder Earring' }, -- lv 76/70/63/56/50/40
        Ear2  = { 'Jupiter\'s Earring', 'Fenrir\'s Earring', 'Merman\'s Earring', 'Bitter Earring', 'Vision Earring', 'Intruder Earring' }, -- lv 76/70/63/56/50/40
        Body  = { 'Nashira Manteel', 'Blue Cotehardie', 'Carapace Breastplate', 'Akinji Peti', 'Brigandine +1', 'Macha\'s Coat' }, -- lv 75/69/61/55/45/35
        Hands = { 'Nashira Gages', 'Torama Gloves', 'Creek F Mitts', 'Akinji Bazubands', 'Combat Caster\'s Mitts +1', 'Sennight Bangles' }, -- lv 75/69/62/55/43/36
        Ring1 = { 'Tau Ring', 'Marid Ring', 'Grand Knight\'s Ring', 'Fluorite Ring', 'Carapace Ring', 'Ametrine Ring' }, -- lv 75/67/60/54/45/36
        Ring2 = { 'Tau Ring', 'Marid Ring', 'Grand Knight\'s Ring', 'Fluorite Ring', 'Carapace Ring', 'Ametrine Ring' }, -- lv 75/67/60/54/45/36
        Back  = { 'Cerberus Mantle', 'Psilos Mantle', 'Amemet Mantle', 'Republican Army Mantle', 'Jaguar Mantle', 'Rearguard Mantle' }, -- lv 75/69/61/55/47/40
        Waist = { 'Ninurta\'s Sash', 'Pendragon\'s Belt', 'Bitter Corset', 'Flagellant\'s Rope', 'Vanguard Belt', 'Katana Obi' }, -- lv 75/67/60/53/45/30
        Legs  = { 'Nashira Seraweels', 'Feral Trousers', 'Akinji Salvars', 'Combat Caster\'s Slacks +1', 'Bastokan Cuisses', 'Bastokan Subligar' }, -- lv 75/63/55/43/34/25
        Feet  = { 'Nashira Crackows', 'Torama Ledelsens', 'Feral Ledelsens', 'Akinji Nails', 'Mountain Gaiters', 'Custom F Boots' }, -- lv 75/69/63/55/38/29
    },
    -- Out of combat in caster mode. The Earth staff goes on top.
    ['Idle_Priority'] = {
        Head  = { 'Duelist\'s Chapeau +1', 'Torama Mask', 'Coral Visor', 'Scorpion Mask', 'Vampire Mask', 'Carapace Mask' }, -- lv 75/69/63/57/51/45
        Neck  = { 'Rho Necklace', 'Merrow No. 17\'s Locket', 'Star Necklace', 'Beak Necklace', 'Clay Amulet', 'Shield Pendant' }, -- lv 75/65/59/50/42/35
        Ear1  = { 'Gamma Earring', 'Chaotic Earring', 'Elusive Earring', 'Refresh Earring', 'Astral Earring', 'Geist Earring' }, -- lv 75/69/60/51/45/38
        Ear2  = { 'Gamma Earring', 'Chaotic Earring', 'Elusive Earring', 'Refresh Earring', 'Astral Earring', 'Geist Earring' }, -- lv 75/69/60/51/45/38
        Body  = { 'Morrigan\'s Robe', 'Blue Cotehardie', 'Minstrel\'s Coat', 'Shaman\'s Cloak', 'High Mana Cloak', 'Royal Squire\'s Robe +1' }, -- lv 75/69/62/56/50/43
        Hands = { 'Duelist\'s Gloves +1', 'Torama Gloves', 'Feronia\'s Bangles', 'Light Gauntlets', 'Aiming Bracelets', 'Carapace Mittens' }, -- lv 75/69/63/57/51/45
        Ring1 = { 'Dilation Ring', 'Serene Ring', 'Bloodbead Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Electrum Ring' }, -- lv 75/69/62/56/50/40
        Ring2 = { 'Dilation Ring', 'Serene Ring', 'Bloodbead Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Electrum Ring' }, -- lv 75/69/62/56/50/40
        Back  = { 'Maledictor\'s Shawl', 'Birdman Cape', 'Desert Mantle', 'Federal Army Mantle', 'Dodge Cape', 'Red Cape' }, -- lv 75/69/62/55/49/43
        Waist = { 'Lambda Sash', 'Czar\'s Belt', 'Lieutenant\'s Sash', 'Flagellant\'s Rope', 'Brocade Obi', 'Mantra Belt' }, -- lv 75/67/60/53/46/40
        Legs  = { 'Galliard Trousers', 'Darksteel Subligar', 'Beak Trousers', 'Tactician Magician\'s Slops +1', 'Carapace Subligar', 'Mage\'s Slops' }, -- lv 75/65/58/52/45/38
        Feet  = { 'Duelist\'s Boots +1', 'Root Sabots', 'Feral Ledelsens', 'Scorpion Leggings', 'Kung Fu Shoes', 'Carapace Leggings' }, -- lv 75/69/63/57/51/45
    },
    -- Fast cast, worn during the precast phase of every spell.
    ['Precast_Priority'] = {
        Head  = { 'Warlock\'s Chapeau +1', 'Warlock\'s Chapeau' }, -- lv 74/60
        Ear1  = { 'Loquacious Earring' }, -- lv 75
        Ear2  = { 'Loquacious Earring' }, -- lv 75
        Body  = { 'Duelist\'s Tabard +1' }, -- lv 75
        Ring1 = { 'Pi Ring' }, -- lv 75
        Ring2 = { 'Pi Ring' }, -- lv 75
        Back  = { 'Warlock\'s Mantle' }, -- lv 30
    },
    -- Enfeebling midcast (magic accuracy, MND/INT).
    ['Enfeebling_Priority'] = {
        Head  = { 'Morrigan\'s Coronal', 'Opo-opo Crown', 'Magi Hat', 'Neit\'s Crown', 'Sinister Mask', 'Eldritch Horn Hairpin' }, -- lv 75/65/53/45/39/30
        Neck  = { 'Phi Necklace', 'Enfeebling Torque', 'Stoneskin Torque', 'Intellect Torque', 'Mohbwa Scarf', 'Holy Phial' }, -- lv 75/65/58/50/40/26
        Ear1  = { 'Abyssal Earring', 'Diabolos\'s Earring', 'Desamilion Earring', 'Boroka Earring', 'Geist Earring', 'Morion Earring' }, -- lv 72/65/55/49/38/30
        Ear2  = { 'Abyssal Earring', 'Diabolos\'s Earring', 'Desamilion Earring', 'Boroka Earring', 'Geist Earring', 'Morion Earring' }, -- lv 72/65/55/49/38/30
        Body  = { 'Nashira Manteel', 'Blue Cotehardie', 'Black Cotehardie', 'Tactician Magician\'s Coat +1', 'Brigandine +1', 'Mage\'s Robe' }, -- lv 75/69/59/52/45/38
        Hands = { 'Shadow Cuffs', 'Dragon Kote', 'Dune Bracers', 'Magi Cuffs', 'Engineer\'s Gloves', 'Sennight Bangles' }, -- lv 75/68/62/53/45/36
        Ring1 = { 'Epsilon Ring', 'Serene Ring', 'Vivian Ring', 'Aquamarine Ring', 'Vilma\'s Ring', 'Tamas Ring' }, -- lv 75/69/61/54/40/30
        Ring2 = { 'Epsilon Ring', 'Serene Ring', 'Vivian Ring', 'Aquamarine Ring', 'Vilma\'s Ring', 'Tamas Ring' }, -- lv 75/69/61/54/40/30
        Back  = { 'Altruistic Cape', 'Sapient Cape', 'Gramary Cape', 'Red Cape', 'Black Cape', 'Mist Silk Cape' }, -- lv 73/60/50/43/32/10
        Waist = { 'Ksi Sash', 'Arachne Obi', 'Bitter Corset', 'Royal Knight\'s Belt +1', 'Reverend Sash', 'Deductive Gold Obi' }, -- lv 75/66/60/52/41/34
        Legs  = { 'Nashira Seraweels', 'Warlock\'s Tights', 'White Slacks +1', 'Macha\'s Slops', 'Bodb\'s Slops' }, -- lv 75/56/50/35/25
        Feet  = { 'Goliard Clogs', 'Marine F Boots', 'Warlock\'s Boots', 'Inferno Sabots', 'Mannequin Pumps', 'Custom F Boots' }, -- lv 75/62/52/41/35/29
    },
    -- Enhancing midcast (enhancing magic skill).
    ['Enhancing_Priority'] = {
        Head  = { 'Duelist\'s Chapeau +1', 'Opo-opo Crown', 'Magi Hat', 'Neit\'s Crown', 'Sinister Mask', 'Circe\'s Hat' }, -- lv 75/65/53/45/39/30
        Neck  = { 'Colossus\'s Torque', 'Enhancing Torque', 'Stoneskin Torque', 'Promise Badge', 'Mohbwa Scarf', 'Holy Phial' }, -- lv 75/65/58/48/40/26
        Ear1  = { 'Static Earring', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring' }, -- lv 72/55/49/38
        Ear2  = { 'Static Earring', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring' }, -- lv 72/55/49/38
        Body  = { 'Morrigan\'s Robe', 'Blue Cotehardie', 'Black Cotehardie', 'Tactician Magician\'s Coat +1', 'Brigandine +1', 'Bishop\'s Robe' }, -- lv 75/69/59/52/45/35
        Hands = { 'Duelist\'s Gloves +1', 'Dragon Kote', 'Dune Bracers', 'Magi Cuffs', 'Devotee\'s Mitts', 'Baron\'s Cuffs' }, -- lv 75/68/62/53/27/20
        Ring1 = { 'Pi Ring', 'Serene Ring', 'Vivian Ring', 'Aquamarine Ring', 'Vilma\'s Ring', 'Tamas Ring' }, -- lv 75/69/61/54/40/30
        Ring2 = { 'Pi Ring', 'Serene Ring', 'Vivian Ring', 'Aquamarine Ring', 'Vilma\'s Ring', 'Tamas Ring' }, -- lv 75/69/61/54/40/30
        Back  = { 'Merciful Cape', 'Miraculous Cape', 'Red Cape', 'White Cape', 'Mist Silk Cape' }, -- lv 73/60/43/32/10
        Waist = { 'Ksi Sash', 'Water Belt', 'Grace Corset', 'Royal Knight\'s Belt +1', 'Reverend Sash', 'Deductive Gold Obi' }, -- lv 75/65/58/52/41/34
        Legs  = { 'Galliard Trousers', 'Warlock\'s Tights', 'White Slacks +1', 'Macha\'s Slops' }, -- lv 75/56/50/35
        Feet  = { 'Duelist\'s Boots +1', 'Marine F Boots', 'Warlock\'s Boots', 'Mannequin Pumps', 'Custom F Boots', 'Garrison Boots' }, -- lv 75/62/52/35/29/18
    },
    -- Cure midcast (MND, healing magic skill).
    ['Cure_Priority'] = {
        Head  = { 'Duelist\'s Chapeau +1', 'Opo-opo Crown', 'Magi Hat', 'Neit\'s Crown', 'Sinister Mask', 'Circe\'s Hat' }, -- lv 75/65/53/45/39/30
        Neck  = { 'Colossus\'s Torque', 'Healing Torque', 'Stoneskin Torque', 'Promise Badge', 'Mohbwa Scarf', 'Holy Phial' }, -- lv 75/65/58/48/40/26
        Ear1  = { 'Magnetic Earring', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring' }, -- lv 72/55/49/38
        Ear2  = { 'Magnetic Earring', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring' }, -- lv 72/55/49/38
        Body  = { 'Duelist\'s Tabard +1', 'Blue Cotehardie', 'Black Cotehardie', 'Tactician Magician\'s Coat +1', 'Brigandine +1', 'Bishop\'s Robe' }, -- lv 75/69/59/52/45/35
        Hands = { 'Warlock\'s Gloves +1', 'Dragon Kote', 'Dune Bracers', 'Magi Cuffs', 'Devotee\'s Mitts', 'Baron\'s Cuffs' }, -- lv 74/68/62/53/27/20
        Ring1 = { 'Pi Ring', 'Serene Ring', 'Vivian Ring', 'Aquamarine Ring', 'Vilma\'s Ring', 'Tamas Ring' }, -- lv 75/69/61/54/40/30
        Ring2 = { 'Pi Ring', 'Serene Ring', 'Vivian Ring', 'Aquamarine Ring', 'Vilma\'s Ring', 'Tamas Ring' }, -- lv 75/69/61/54/40/30
        Back  = { 'Maledictor\'s Shawl', 'Miraculous Cape', 'Red Cape', 'White Cape', 'Mist Silk Cape' }, -- lv 75/60/43/32/10
        Waist = { 'Lambda Sash', 'Water Belt', 'Grace Corset', 'Royal Knight\'s Belt +1', 'Reverend Sash', 'Deductive Gold Obi' }, -- lv 75/65/58/52/41/34
        Legs  = { 'Galliard Trousers', 'Druid\'s Slops', 'Warlock\'s Tights', 'White Slacks +1', 'Macha\'s Slops' }, -- lv 75/64/56/50/35
        Feet  = { 'Duelist\'s Boots +1', 'Marine F Boots', 'Warlock\'s Boots', 'Mannequin Pumps', 'Custom F Boots', 'Garrison Boots' }, -- lv 75/62/52/35/29/18
    },
    -- Melee weapon and shield. Weapons were not part of the armor pull --
    -- fill these in from what you own.
    ['Weapon_Priority'] = {
        -- Main = { 'Mythril Sword' },
        -- Sub  = { 'Turtle Shield +1' },
    },
};
profile.Sets = sets;

profile.Packer = {
};

evalLevel = function()
	-- Evaluate Level Sync
    local level = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    if (level ~= Settings.CurrentLevel) then
        gFunc.EvaluateLevels(profile.Sets, level);
        Settings.CurrentLevel = level;
	end

    common.EvalLevel(level);
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias /rdm /lac fwd');

    AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. Settings.MacroBook);
end

profile.OnUnload = function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /rdm');
end

profile.HandleCommand = function(args)
    -- Handle utility settings
    utility.SetOptions(args[1], Settings.MacroBook);

    -- Handle common settings
    common.SetMeleeOptions(args[1]);

    -- Swap between meleeing for TP and staying on the staff to cast
    if (args[1] == 'melee') then
        Settings.UseMelee = not Settings.UseMelee;
        gFunc.Message('Melee mode: ' .. tostring(Settings.UseMelee));
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();

	gFunc.EquipSet(common.Sets.Dream);

	if (Settings.UseMelee) then
		common.EquipMelee();
		gFunc.EquipSet(sets.TP);
		gFunc.EquipSet(sets.Weapon);
	else
		gFunc.EquipSet(sets.Idle);
		staves.EquipIdleStaff();
	end

	if (player.Status == 'Resting') then
		staves.EquipRestingStaff();
	end

	utility.EquipSet();
end

profile.HandleAbility = function()
	local action = gData.GetAction();
end

profile.HandleItem = function()
	local action = gData.GetAction();

	utility.CheckItem(action.Name);
end

profile.HandlePrecast = function()
	gFunc.EquipSet(sets.Precast);
end

profile.HandleMidcast = function()
	local action = gData.GetAction();

	utility.CheckCast(action.Name);

	if (action.Skill == 'Enfeebling Magic') then
		gFunc.EquipSet(sets.Enfeebling);
	elseif (action.Skill == 'Enhancing Magic') then
		gFunc.EquipSet(sets.Enhancing);
	elseif (action.Skill == 'Healing Magic') then
		gFunc.EquipSet(sets.Cure);
	end

	-- Staff last so the element wins the Main slot over any set above.
	staves.EquipStaff(action);
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;
