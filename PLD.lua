local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
	CurrentLevel = 0,
	HaveRefresh = false,
	UseAccuracy = false,
};

sets = {
    ['Tank_Priority'] = {
		Head = {'Silver Mask', 'Iron Mask +1', 'Bone Mask +1', 'Ryl.Ftm. Bandana'},
		Body = {'Silver Mail', 'Chainmail', 'Bone Harness +1', 'Scale Mail'},
		Hands = {'Silver Mittens', 'Ryl.Ftm. Gloves'},
		Legs = {'Silver Hose', 'Chain Hose', 'Bone Subligar +1', 'Scale Cuisses'},
        Feet = {'Silver Greaves', 'Leaping Boots'},
    },
	['Weapon_Refresh_Priority'] = {
		Main = {'Mythril Sword', 'Flame Sword', 'Bee Spatha +1', 'Wax Sword +1'},
		Sub = {'Jennet Shield', 'Turtle Shield +1', 'Shell Shield'},
	},
	['Weapon_No_Refresh_Priority'] = {
		Main = {'Oak Cudgel', 'Brass Hammer +1'},
		Sub = {'Jennet Shield', 'Turtle Shield +1', 'Shell Shield'},
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
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /pld /lac fwd');
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /pld');
end

profile.HandleCommand = function(args)
    -- Handle utiility settings
    utility.SetOptions(args[1]);

    -- Handle common settings
    common.SetMeleeOptions(args[1]);

    if (args[1] == 'refresh') then
		Settings.HaveRefresh = not Settings.HaveRefresh;
        gFunc.Message('Have Refresh: ' .. tostring(Settings.HaveRefresh));
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();
	
	if (player.Status == 'Engaged') then
        -- Default load common melee setup
        common.EquipMelee();

		gFunc.EquipSet(sets.Tank);

		-- Refresh
		if (Settings.HaveRefresh) then
			gFunc.EquipSet(sets.Weapon_Refresh);
		else
			gFunc.EquipSet(sets.Weapon_No_Refresh);
		end
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
end

profile.HandleMidcast = function()
	local action = gData.GetAction();
	
	utility.CheckCast(action.Name);
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;