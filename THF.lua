local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
	CurrentLevel = 0,
};

sets = {
    ['TP_Priority'] = {
		Head = {'Ryl.Ftm. Bandana'},
		Body = {},
		Hands = {'Ryl.Ftm. Gloves'},
		Legs = {},
        Feet = {'Leaping Boots'},
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
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /thf /lac fwd');

    -- Lock appearance a few seconds after loading
    common.RequestLockStyle(1);
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /thf');
end

profile.HandleCommand = function(args)
    -- Handle utility settings
    utility.SetOptions(args[1]);

    -- Handle common settings
    common.SetMeleeOptions(args[1]);

    -- Rescan the bags and re-resolve every gear set
    if (args[1] == 'gear') then
        common.EvaluateGear(profile.Sets, Settings.CurrentLevel, true);
        common.ReportGear(profile.Sets, Settings.CurrentLevel);
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();
	
	if (player.Status == 'Engaged') then
        -- Default load common melee setup
        common.EquipMelee();
        gFunc.EquipSet(common.Sets.Dream);
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