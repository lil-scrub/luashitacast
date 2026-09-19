local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
	CurrentLevel = 0,
	MacroBook = '3',
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
		Main = {'Honor sword', 'Mythril Sword', 'Flame Sword', 'Bee Spatha +1', 'Wax Sword +1'},
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