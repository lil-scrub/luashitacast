local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
-- local swaps = gFunc.LoadFile('./toggles.lua');

local Settings = {
	CurrentLevel = 0,
	UseAccuracy = false,
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
    ['Att_Priority'] = {
        Ring1 = {'Courage Ring'},
        Ring2 = {'Courage Ring'},
        Neck = {'Spike Necklace'},
        Waist = {'Brave Belt'},
        Ear1 = {'Bone Earring +1'},
        Ear2 = {'Bone Earring +1'},
    },
    ['Acc_Priority'] = {
        Ring1 = {'Balance Ring'},
        Ring2 = {'Balance Ring'},
        Neck = {'Spike Necklace'},
        Waist = {'Life Belt'},
        Ear1 = {'Bone Earring +1'},
        Ear2 = {'Bone Earring +1'},
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
	-- Evaluate Level Sync
    local myLevel = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    if (myLevel ~= Settings.CurrentLevel) then
        gFunc.EvaluateLevels(profile.Sets, myLevel);
        Settings.CurrentLevel = myLevel;
	end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /war /lac fwd');
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /war');
end

profile.HandleCommand = function(args)
    if (args[1] == 'acc') then
        if (Settings.UseAccuracy) then
            Settings.UseAccuracy = false;
        else
            Settings.UseAccuracy = true;
        end
        gFunc.Message('Use Accuracy Set: ' .. tostring(Settings.UseAccuracy));
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
		gFunc.EquipSet(common.Dream);
		gFunc.EquipSet(sets.TP);

		-- Dual Weild
		if (Settings.UseDW) then
			gFunc.EquipSet(sets.Weapon_DW);
		else
			gFunc.EquipSet(sets.Weapon);
		end
		
		-- Accuracy
        if (Settings.UseAccuracy) then
            gFunc.EquipSet(sets.Acc);
        else
            gFunc.EquipSet(sets.Att);
        end
	end
	if (player.Status == 'Idle') then
	end
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