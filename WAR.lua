local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
-- local swaps = gFunc.LoadFile('./toggles.lua');

local Settings = {
	CurrentLevel = 0,
	UseDW = false,
};

sets = {
    ['TP_Priority'] = {
		Head = {'Emperor Hairpin', 'Iron Mask +1', 'Bone Mask +1', 'Ryl.Ftm. Bandana'},
		Body = {'Chainmail', 'Bone Harness +1', 'Scale Mail'},
		Hands = {'Ryl.Ftm. Gloves'},
		Legs = {'Chain Hose', 'Bone Subligar +1', 'Scale Cuisses'},
        Feet = {'Leaping Boots'},
    },
	['Weapon_Priority'] = {
		Main = {'Moth Axe', 'Inferno Axe'},
	},
	['Weapon_DW_Priority'] = {
		Main = {'Bee Spatha +1'},
		Sub = {'Shell Shield'},
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
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /war /lac fwd');

    -- Lock appearance a few seconds after loading
    common.RequestLockStyle(1);
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /war');
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

    if (args[1] == 'dw') then
        if (Settings.UseDW) then
            Settings.UseDW = false;
        else
            Settings.UseDW = true;
        end
        gFunc.Message('Dual Wield: ' .. tostring(Settings.UseDW));
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();
	
	if (player.Status == 'Engaged') then
		gFunc.EquipSet(common.Sets.Dream);
		gFunc.EquipSet(sets.TP);

		-- Dual Weild
		if (Settings.UseDW) then
			gFunc.EquipSet(sets.Weapon_DW);
		else
			gFunc.EquipSet(sets.Weapon);
		end
		
		-- Accuracy
		common.EquipMelee();
	end
	if (player.Status == 'Idle') then
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
    gFunc.EquipSet(sets.Att)
end

return profile;