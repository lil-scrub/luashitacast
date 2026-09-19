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
sets = {
    -- Worn while engaged in melee mode.
    ['TP_Priority'] = {
        -- Head  = {'Empress Hairpin'},
        -- Body  = {'Gambison', 'Angler\'s Tunica'},
        -- Hands = {'Ryl.Ftm. Gloves'},
        -- Legs  = {'Savage loincloth'},
        -- Feet  = {'Leaping Boots'},
    },
    -- Sword and shield for melee mode.
    ['Weapon_Priority'] = {
        -- Main = {'Mythril Sword', 'Bee Spatha +1', 'Wax Sword +1'},
        -- Sub  = {'Turtle Shield +1', 'Shell Shield'},
    },
    -- Worn out of combat in caster mode. The Earth staff is applied on top.
    ['Idle_Priority'] = {
        -- Body  = {'Seer\'s Tunic'},
        -- Legs  = {'Seer\'s Slacks'},
    },
    -- Fast cast, worn during the precast phase of every spell.
    ['Precast_Priority'] = {
        -- Head  = {'Seer\'s Crown'},
    },
    ['Enfeebling_Priority'] = {
        -- Neck  = {'Enfeebling Torque'},
    },
    ['Enhancing_Priority'] = {
    },
    ['Cure_Priority'] = {
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
