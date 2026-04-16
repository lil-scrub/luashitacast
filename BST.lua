local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
    UseHQJugs = true,
    Jug = "sheep"
}

local sets = {
	['DualWield_Priority'] = {
        Main = {'Darksteel Pick +1', 'Mythril Pick +1', 'Cmb.Cst. Axe', 'Tomahawk'},
        Sub = {'Darksteel Pick +1', 'Mythril Pick +1', 'Barbaroi Axe', 'Tomahawk'},
	},
	['Scythe_Priority'] = {
        Main = {'Darksteel Pick +1'},
        Sub = {'Darksteel Pick +1'},
	},
	['Axe_Priority'] = {
        Main = {'Darksteel Pick +1', 'Barbaroi Axe'},
        Sub = {'darksteel buckler', 'Turtle Shield +1'},
	},
    ['Tp_Priority'] = {
        Head = {'Beast Helm', 'Emperor hairpin'},
        Body = {'Savage Seperates', 'Ryl.Sqr. Chainmail', 'Chainmail'},
        Hands = {'Beast Gloves', 'Ryl.Ftm. Gloves'},
        Legs = {'Beast Trousers', 'Ryl.Sqr. Breeches', 'Chain Hose'},
        Feet = {'Beast Gaiters', 'Leaping Boots'},
    },
    ['Charm'] = {
        Main = 'Apollo\'s Staff',
        Head = 'Beast Helm',
        Body = 'Beast Jackcoat',
        Hands = 'Beast Gloves',
        Ring1 = 'Hope Ring',
        Ring2 = 'Hope Ring',
        Legs = 'Beast Trousers',
        Feet = 'Beast Gaiters',
    },
	['Reward_Priority'] = {
        Ammo = {'Pet Fd. Epsilon', 'Pet Food Delta', 'Pet Fd. Gamma', 'Pet Food Beta'},
        Body = 'Beast Jackcoat',
        Hands = 'Beast Gloves',
        Feet = 'Beast Gaiters',
    },
    ['Jugs'] = {
        ['tiger']     = {Ammo = 'Meat Broth'},
        ['rabbit']    = {Ammo = 'Carrot Broth'},
        ['sheep']     = {Ammo = 'Herbal Broth'},
        ['bill']      = {Ammo = 'Humus'},
        ['flytrap']   = {Ammo = 'Grasshopper Broth'},
        ['lizard']    = {Ammo = 'Carrion Broth'},
        ['fly']       = {Ammo = 'Bug Broth'},
        ['eft']       = {Ammo = 'Mole Broth'},
        ['beetle']    = {Ammo = 'Tree Sap'},
        ['antlion']   = {Ammo = 'Antica Broth'},
        ['crab']      = {Ammo = 'Fish Broth'},
        ['mite']      = {Ammo = 'Blood Broth'},
        ['funguar']   = {Ammo = 'Seedbed Soil'},
        ['homunculus'] = {Ammo = 'Alchemist Water'},
        ['sabotender'] = {Ammo = 'Sun Water'},
    },
    ['Jugs_HQ'] = {
        ['sheep']     = {Ammo = 'S. Herbal Broth'},
        ['rabbit']    = {Ammo = 'Famous Carrot Broth'},
        ['tiger']     = {Ammo = 'Warm Meat Broth'},
        ['bill']      = {Ammo = 'Rich Humus'},
        ['flytrap']   = {Ammo = 'Noisy Grasshopper Broth'},
        ['lizard']    = {Ammo = 'Cold Carrion Broth'},
        ['fly']       = {Ammo = 'Quadav Bug Broth'},
        ['eft']       = {Ammo = 'Lively Mole Broth'},
        ['beetle']    = {Ammo = 'Scarlet Sap'},
        ['antlion']   = {Ammo = 'Fragrant Antica Broth'},
        ['crab']      = {Ammo = 'Fish Oil Broth'},
        ['mite']      = {Ammo = 'Clear Blood Broth'},
    },
};
profile.Sets = sets;


profile.Packer = {
};

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /bst /lac fwd');

    -- Display Default Jug Setting
    if (Settings.UseHQJugs) then
        gFunc.Message("Jug: hq " .. Settings.Jug);
    else
        gFunc.Message("Jug: " .. Settings.Jug);
    end
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /bst');
end

profile.HandleCommand = function(args)
    -- Handle utiility settings
    utility.SetOptions(args[1]);

    -- Handle common settings
    common.SetMeleeOptions(args[1]);

    if (args[1] == 'jug') then
        setJug(args[2], args[3]);
    end
end


profile.HandleDefault = function()
	local player = gData.GetPlayer();
	evalLevel();
	
	if (player.Status == 'Engaged') then
        -- Default load common melee setup
        common.EquipMelee();

        gFunc.EquipSet(sets.Tp);

        -- Handle Weapons
        if (player.SubJob == 'NIN') then
            gFunc.EquipSet(sets.DualWield);
        else
            gFunc.EquipSet(sets.Axe);
        end
	end

    utility.EquipSet();
end

profile.HandleAbility = function()
	local action = gData.GetAction();
	
	if (action.Name == 'Charm') then
		gFunc.EquipSet(sets.Charm);
	end
	if (action.Name == 'Reward') then
		gFunc.EquipSet(sets.Reward);
	end
    if (action.Name == 'Call Beast') then
        if (Settings.UseHQJugs) then
            gFunc.EquipSet(sets.Jugs_HQ[Settings.Jug]);
        else
            gFunc.EquipSet(sets.Jugs[Settings.Jug]);
        end
    end
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

-- Helper functions

evalLevel = function()
	-- Evaluate Level Sync
    local level = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    if (level ~= Settings.CurrentLevel) then
        gFunc.EvaluateLevels(profile.Sets, level);
        Settings.CurrentLevel = level;
	end

    -- Evaluate Level Sync for common equipsets
    common.EvalLevel(level);
end

setJug = function(arg1, arg2)
    if (arg1 == "hq") then
        Settings.UseHQJugs = true
        if sets.Jugs_HQ[arg2] ~= nil then
            -- Pet specified, no hq tag
            Settings.Jug = arg2;
        end
    elseif sets.Jugs[arg1] ~= nil then
        Settings.UseHQJugs = false
        -- Pet specified, no hq tag
        Settings.Jug = arg1;
    end
    
    -- Display Default Jug Setting
    if (Settings.UseHQJugs) then
        gFunc.Message("Jug: hq " .. Settings.Jug);
    else
        gFunc.Message("Jug: " .. Settings.Jug);
    end
end

return profile;
