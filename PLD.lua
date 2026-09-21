local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
	CurrentLevel = 0,
	MacroBook = '3',
	UseClub = false,
};

-- Gear candidates for every piece PLD can wear, ordered best first and
-- laddered down the level bands so each list resolves now and upgrades
-- itself while levelling. Resolution is ownership-aware
-- (common.EvaluateGear), so entries you do not own cost nothing and breadth
-- only helps.
--
-- The armour bands follow the HorizonXI Paladin progression: Scale 10,
-- Beetle/Bone 21, Chain 24, Eisenplatte 29, Royal Squire 30, Silver 36,
-- Mythril 49, Gallant (AF) 52-60, Adaman/Koenig/Valor 73.
--
-- No elemental staves here, unlike the caster profiles. Swapping the main
-- hand drops the shield and resets TP, which costs a tank far more than a
-- staff's magic bonus is worth.
sets = {
	-- Out of combat: HP and defence to survive the pull, MP to keep curing.
	['Idle_Priority'] = {
		Head  = { 'Koenig Schaller', 'Valor Coronet', 'Adaman Celata', 'Gallant Coronet',
			 'Helm of the Just', 'Silver Mask', 'Ryl.Sqr. Helm', 'Eisenschaller',
			 'Iron Mask +1', 'Bone Mask +1', 'Ryl.Ftm. Bandana' },
		Neck  = { 'Parade Gorget', 'Chivalrous Chain', 'Justice Badge', 'Promise Badge' },
		Ear1  = { 'Ethereal Earring', 'Reraise Earring', 'Energy Earring +1',
			 'Bone Earring +1', 'Beetle Earring +1' },
		Ear2  = { 'Ethereal Earring', 'Reraise Earring', 'Energy Earring +1',
			 'Bone Earring +1', 'Beetle Earring +1' },
		Body  = { 'Koenig Cuirass', 'Valor Surcoat', 'Adaman Hauberk', 'Gallant Surcoat',
			 'Mythril Cuirass', 'Silver Mail', 'Ryl.Sqr. Chainmail', 'Eisenplatte',
			 'Chainmail', 'Bone Harness +1', 'Scale Mail' },
		Hands = { 'Koenig Handschuhs', 'Valor Gauntlets', 'Adaman Mufflers',
			 'Gallant Gauntlets', 'Mythril Mittens', 'Silver Mittens', 'Ryl.Sqr. Mufflers',
			 'Eisenhentzes', 'Chain Mittens', 'Ryl.Ftm. Gloves' },
		Ring1 = { 'Sattva Ring', 'Astral Ring', 'Ether Ring', 'Bone Ring +1', 'Bone Ring' },
		Ring2 = { 'Sattva Ring', 'Astral Ring', 'Ether Ring', 'Bone Ring +1', 'Bone Ring' },
		Back  = { 'Shadow Mantle', 'Ram Mantle' },
		Waist = { 'Warwolf Belt', 'Mrc.Cpt. Belt', 'Brave Belt' },
		Legs  = { 'Koenig Diechlings', 'Valor Breeches', 'Adaman Cuisses', 'Gallant Breeches',
			 'Mythril Cuisses', 'Silver Hose', 'Ryl.Sqr. Breeches', 'Eisendiechlings',
			 'Chain Hose', 'Bone Subligar +1', 'Scale Cuisses' },
		Feet  = { 'Koenig Schuhs', 'Valor Leggings', 'Adaman Sollerets', 'Gallant Leggings',
			 'Mythril Leggings', 'Silver Greaves', 'Ryl.Sqr. Sollerets', 'Eisenschuhs',
			 'Leaping Boots', 'Bounding Boots' },
	},
	-- Engaged. Accuracy and attack accessories come from common.EquipMelee,
	-- which is applied first, so this list stays on armour.
	['Tank_Priority'] = {
		Head  = { 'Koenig Schaller', 'Valor Coronet', 'Adaman Celata', 'Gallant Coronet',
			 'Helm of the Just', 'Silver Mask', 'Ryl.Sqr. Helm', 'Eisenschaller',
			 'Iron Mask +1', 'Bone Mask +1', 'Ryl.Ftm. Bandana' },
		Body  = { 'Koenig Cuirass', 'Valor Surcoat', 'Adaman Hauberk', 'Gallant Surcoat',
			 'Mythril Cuirass', 'Silver Mail', 'Ryl.Sqr. Chainmail', 'Eisenplatte',
			 'Chainmail', 'Bone Harness +1', 'Scale Mail' },
		Hands = { 'Koenig Handschuhs', 'Valor Gauntlets', 'Adaman Mufflers',
			 'Gallant Gauntlets', 'Mythril Mittens', 'Silver Mittens', 'Ryl.Sqr. Mufflers',
			 'Eisenhentzes', 'Chain Mittens', 'Ryl.Ftm. Gloves' },
		Back  = { 'Shadow Mantle', 'Ram Mantle' },
		Legs  = { 'Koenig Diechlings', 'Valor Breeches', 'Adaman Cuisses', 'Gallant Breeches',
			 'Mythril Cuisses', 'Silver Hose', 'Ryl.Sqr. Breeches', 'Eisendiechlings',
			 'Chain Hose', 'Bone Subligar +1', 'Scale Cuisses' },
		Feet  = { 'Koenig Schuhs', 'Valor Leggings', 'Adaman Sollerets', 'Gallant Leggings',
			 'Mythril Leggings', 'Silver Greaves', 'Ryl.Sqr. Sollerets', 'Eisenschuhs',
			 'Leaping Boots', 'Bounding Boots' },
	},
	-- Hate. Worn for Provoke, Flash, Shield Bash and the defensive abilities,
	-- and laid down under every cure and Banish. In this era the enmity is
	-- almost all in the armour -- Koenig, Adaman, the artifact sets and the
	-- Helm of the Just -- so the accessory slots fall back to HP.
	['Enmity_Priority'] = {
		Head  = { 'Koenig Schaller', 'Valor Coronet', 'Helm of the Just', 'Adaman Celata',
			 'Gallant Coronet', 'Silver Mask', 'Ryl.Sqr. Helm', 'Eisenschaller',
			 'Iron Mask +1', 'Bone Mask +1' },
		Neck  = { 'Parade Gorget', 'Chivalrous Chain', 'Justice Badge', 'Spike Necklace' },
		Ear1  = { 'Ethereal Earring', 'Reraise Earring', 'Bone Earring +1',
			 'Beetle Earring +1' },
		Ear2  = { 'Ethereal Earring', 'Reraise Earring', 'Bone Earring +1',
			 'Beetle Earring +1' },
		Body  = { 'Koenig Cuirass', 'Valor Surcoat', 'Adaman Hauberk', 'Gallant Surcoat',
			 'Mythril Cuirass', 'Silver Mail', 'Ryl.Sqr. Chainmail', 'Eisenplatte',
			 'Chainmail', 'Bone Harness +1', 'Scale Mail' },
		Hands = { 'Koenig Handschuhs', 'Valor Gauntlets', 'Adaman Mufflers',
			 'Gallant Gauntlets', 'Mythril Mittens', 'Silver Mittens', 'Ryl.Sqr. Mufflers',
			 'Eisenhentzes', 'Chain Mittens', 'Ryl.Ftm. Gloves' },
		Ring1 = { 'Sattva Ring', 'Bomb Queen Ring', 'Bone Ring +1', 'Courage Ring' },
		Ring2 = { 'Sattva Ring', 'Bomb Queen Ring', 'Bone Ring +1', 'Courage Ring' },
		Back  = { 'Shadow Mantle', 'Ram Mantle' },
		Waist = { 'Warwolf Belt', 'Mrc.Cpt. Belt', 'Brave Belt' },
		Legs  = { 'Koenig Diechlings', 'Valor Breeches', 'Adaman Cuisses', 'Gallant Breeches',
			 'Mythril Cuisses', 'Silver Hose', 'Ryl.Sqr. Breeches', 'Eisendiechlings',
			 'Chain Hose', 'Bone Subligar +1', 'Scale Cuisses' },
		Feet  = { 'Koenig Schuhs', 'Valor Leggings', 'Adaman Sollerets', 'Gallant Leggings',
			 'Mythril Leggings', 'Silver Greaves', 'Ryl.Sqr. Sollerets', 'Eisenschuhs',
			 'Leaping Boots', 'Bounding Boots' },
	},
	-- Fast cast, worn during the precast phase of every spell. Small on
	-- purpose: a tank should not shed armour waiting for a cure to go off.
	['Precast_Priority'] = {
		Ear1  = { 'Loquac. Earring' },
		Ear2  = { 'Loquac. Earring' },
	},
	-- Cure potency and MND. Laid over the enmity set, so the armour keeps its
	-- hate and only the accessory slots turn into healing.
	['Cure_Priority'] = {
		Neck  = { 'Healing Torque', 'Promise Badge', 'Justice Badge' },
		Ear1  = { 'Geist Earring', 'Morion Earring' },
		Ear2  = { 'Geist Earring', 'Morion Earring' },
		Ring1 = { 'Saintly Ring', 'Tranquility Ring', 'Carect Ring' },
		Ring2 = { 'Saintly Ring', 'Tranquility Ring', 'Carect Ring' },
		Back  = { 'White Cape +1', 'White Cape' },
		Waist = { 'Friar\'s Rope', 'Mrc.Cpt. Belt' },
	},
	-- Divine magic -- Banish, Banish II and Enlight. Also laid over enmity:
	-- Banish is cast on a tank for the hate as much as the damage.
	['Divine_Priority'] = {
		Neck  = { 'Divine Torque', 'Promise Badge', 'Justice Badge' },
		Ear1  = { 'Divine Earring', 'Morion Earring', 'Geist Earring' },
		Ear2  = { 'Divine Earring', 'Morion Earring', 'Geist Earring' },
		Ring1 = { 'Saintly Ring', 'Tranquility Ring' },
		Ring2 = { 'Saintly Ring', 'Tranquility Ring' },
		Back  = { 'White Cape +1', 'White Cape' },
		Waist = { 'Friar\'s Rope' },
	},
	-- Enhancing magic skill -- Protect and Shell.
	['Enhancing_Priority'] = {
		Neck  = { 'Enhancing Torque', 'Justice Badge' },
		Ear1  = { 'Augment. Earring', 'Geist Earring' },
		Ear2  = { 'Augment. Earring', 'Geist Earring' },
		Ring1 = { 'Saintly Ring' },
		Ring2 = { 'Saintly Ring' },
		Back  = { 'White Cape +1', 'White Cape' },
	},
	-- Weaponskill. common.Sets.Melee_Att goes on first and covers the rest.
	['WS_Priority'] = {
		Neck  = { 'Spike Necklace', 'Fang Necklace' },
		Ear1  = { 'Bone Earring +1', 'Beetle Earring +1' },
		Ear2  = { 'Bone Earring +1', 'Beetle Earring +1' },
		Ring1 = { 'Rajas Ring', 'Courage Ring' },
		Ring2 = { 'Rajas Ring', 'Courage Ring' },
		Waist = { 'Warwolf Belt', 'Brave Belt', 'Life Belt' },
	},
	-- Sword, the default. Honor Sword carries the Refresh effect, so it
	-- stays on top of the list.
	['Weapon_Sword_Priority'] = {
		Main = {'Honor Sword', 'Mythril Sword', 'Flame Sword', 'Bee Spatha +1', 'Wax Sword +1'},
		Sub = {'Jennet Shield', 'Turtle Shield +1', 'Shell Shield'},
	},
	-- Club, for Starlight and Moonlight -- the club weaponskills that turn
	-- TP back into MP. Holy Mace sits above the higher-damage Holy Maul on
	-- purpose: its shorter delay means more weaponskills, and MP per minute
	-- is the point of holding a club at all.
	['Weapon_Club_Priority'] = {
		Main = {'Buzdygan', 'Darksteel Maul', 'Holy Mace', 'Holy Maul', 'Maul',
			'Ryl.Sqr. Mace', 'Warhammer', 'Oak Cudgel', 'Brass Hammer +1', 'Ash Club'},
		Sub = {'Jennet Shield', 'Turtle Shield +1', 'Shell Shield'},
	},
};
profile.Sets = sets;

profile.Packer = {
};

-- Abilities that put you up the hate list, or that you want to survive the
-- next few seconds of. Enmity gear does nothing for Sentinel or Cover, but
-- wearing it costs nothing either and these all fire mid-fight.
local enmityAbilities = {
	'Provoke', 'Flash', 'Shield Bash', 'Sentinel', 'Cover', 'Holy Circle',
	'Rampart', 'Invincible', 'Chivalry',
};

evalLevel = function()
	-- Resolve sets against level and what is actually in the bags
    local level = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    Settings.CurrentLevel = level;
    common.EvaluateGear(profile.Sets, level);

    common.EvalLevel(level);
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /pld /lac fwd');

    AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. Settings.MacroBook);

    -- Lock appearance a few seconds after loading
    common.RequestLockStyle(1);
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /pld');
end

profile.HandleCommand = function(args)
    -- Handle utility settings
    utility.SetOptions(args[1], Settings.MacroBook);

    -- Handle common settings
    common.SetMeleeOptions(args[1]);

    -- Rescan the bags and re-resolve every gear set
    if (args[1] == 'gear') then
        common.EvaluateGear(profile.Sets, Settings.CurrentLevel, true);
        common.ReportGear(profile.Sets, Settings.CurrentLevel);
    end

    -- Sword or club. Club is a mode rather than a weaponskill-time swap:
    -- changing weapon wipes TP, so the club has to be held while the TP is
    -- being built if Starlight or Moonlight is ever going to fire.
    if (args[1] == 'club') then
		Settings.UseClub = not Settings.UseClub;
        gFunc.Message('Use Club: ' .. tostring(Settings.UseClub));
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();

	gFunc.EquipSet(common.Sets.Dream);

	if (player.Status == 'Engaged') then
        -- Default load common melee setup
        common.EquipMelee();

		gFunc.EquipSet(sets.Tank);
	else
		gFunc.EquipSet(sets.Idle);
	end

	-- Sword and shield stay on out of combat too: a tank pulls and takes the
	-- first hits before the engaged sets ever apply.
	if (Settings.UseClub) then
		gFunc.EquipSet(sets.Weapon_Club);
	else
		gFunc.EquipSet(sets.Weapon_Sword);
	end

    utility.EquipSet();

end

profile.HandleAbility = function()
	local action = gData.GetAction();

	if (action == nil) then
		return;
	end

	for _, name in ipairs(enmityAbilities) do
		if (action.Name == name) then
			gFunc.EquipSet(sets.Enmity);
			return;
		end
	end
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

	-- Flash is divine magic, but it is cast purely for hate -- no divine
	-- skill gear, just enmity.
	if (action.Name == 'Flash') then
		gFunc.EquipSet(sets.Enmity);
		return;
	end

	if (action.Skill == 'Healing Magic') then
		gFunc.EquipSet(sets.Enmity);
		gFunc.EquipSet(sets.Cure);
	elseif (action.Skill == 'Divine Magic') then
		gFunc.EquipSet(sets.Enmity);
		gFunc.EquipSet(sets.Divine);
	elseif (action.Skill == 'Enhancing Magic') then
		gFunc.EquipSet(sets.Enhancing);
	end
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

-- Starlight and Moonlight convert TP into MP and do no damage, so attack
-- gear buys nothing. Leaving the tank set on is strictly better.
local mpWeaponskills = { 'Starlight', 'Moonlight' };

profile.HandleWeaponskill = function()
	local action = gData.GetAction();

	if (action ~= nil) then
		for _, name in ipairs(mpWeaponskills) do
			if (action.Name == name) then
				return;
			end
		end
	end

	gFunc.EquipSet(common.Sets.Melee_Att);
	gFunc.EquipSet(sets.WS);
end

return profile;
