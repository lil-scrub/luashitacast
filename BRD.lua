local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
local staves = gFunc.LoadFile('./staves.lua');

local Settings = {
	CurrentLevel = 0,
	MacroBook = '2',
};

sets = {
	['Pulling_NIN_Priority'] = {
		Main = {'Earth Staff'},
		Ammo = {'Pebble'},
		Head = {'Noble\'s Ribbon'},
		Body = {'Savage Separates', 'Beetle Harness +1', 'Bone Harness +1'},
		Legs = {'Savage loincloth', 'Republic Subligar', 'Bone Subligar +1'},
		Feet = {'Savage Gaiters', 'Angler\'s Boots'},
		Hands = {'Savage Gauntlets', 'Beetle Mittens +1', 'Ryl.Ftm. Gloves'},
	},
	['Pulling_WHM_Priority'] = {
		Main = {'Earth Staff'},
		Ammo = {'Pebble'},
		Head = {'Noble\'s Ribbon'},
		Body = {'Gaudy Harness', 'Savage Separates', 'Beetle Harness +1', 'Bone Harness +1'},
		Legs = {'Savage loincloth', 'Republic Subligar', 'Bone Subligar +1'},
		Feet = {'Savage Gaiters', 'Angler\'s Boots'},
		Hands = {'Savage Gauntlets', 'Beetle Mittens +1', 'Ryl.Ftm. Gloves'},
	},
	['Songs_Priority'] = {
		Main = {'Chanter\'s staff', 'Monster Signa'},
		Neck = {'Bird whistle'},
        	Ring1 = {'Hope Ring'},
        	Ring2 = {'Hope Ring'},
	},
	['RingProc'] = {
		Ring1 = 'Minstrel\'s Ring',
	},
};
songs = {
	['General_Priority'] = {
		Range = {'Ryl.Spr. Horn', 'cornette +1'},
	},
	['Madrigal_Priority'] = {
		Range = {'Traversiere +2', 'cornette +1'},
	},
	['Elegy'] = {
		Range = 'horn +1',
	},
	['Minuet'] = {
		Range = 'cornette +1',
	},
};
profile.Sets = sets;
profile.Songs = songs;

profile.Packer = {
};

evalLevel = function()
	-- Evaluate Level Sync
    local myLevel = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    if (myLevel ~= Settings.CurrentLevel) then
		gFunc.EvaluateLevels(profile.Sets, myLevel);
        gFunc.EvaluateLevels(profile.Songs, myLevel);
        Settings.CurrentLevel = myLevel;
	end
end

equipSong = function(song)
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /brd /lac fwd');

    AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. Settings.MacroBook);
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /brd');
end

profile.HandleCommand = function(args)
    -- Handle utiility settings
    utility.SetOptions(args[1], Settings.MacroBook);
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();
	
	gFunc.EquipSet(common.Dream);

	if (player.SubJob == 'WHM') then
		gFunc.EquipSet(profile.Sets.Pulling_WHM);
	else
		gFunc.EquipSet(profile.Sets.Pulling_NIN);
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
	gFunc.EquipSet(profile.Sets.RingProc);
end

profile.HandleMidcast = function()
	local action = gData.GetAction();
	
	utility.CheckCast(action.Name);

	if (action.Type == 'Bard Song') then
		gFunc.EquipSet(profile.Sets.Songs)

		if (string.match(action.Name, 'Minuet')) then
			gFunc.EquipSet(profile.Songs.Minuet);
		elseif (string.match(action.Name, 'Madrigal')) then
			gFunc.EquipSet(profile.Songs.Madrigal);
		elseif (string.match(action.Name, 'Paeon')) then
			gFunc.EquipSet(profile.Songs.General);
		elseif (string.match(action.Name, 'Mambo')) then
			gFunc.EquipSet(profile.Songs.General);
		elseif (string.match(action.Name, 'Lullaby')) then
			gFunc.EquipSet(profile.Songs.General);
		elseif (string.match(action.Name, 'Ballad')) then
			gFunc.EquipSet(profile.Songs.General);
		elseif (string.match(action.Name, 'Prelude')) then
			gFunc.EquipSet(profile.Songs.General);
		elseif (string.match(action.Name, 'Finale')) then
			gFunc.EquipSet(profile.Songs.General);
		elseif (string.match(action.Name, 'Aubade')) then
			gFunc.EquipSet(profile.Songs.General);
		elseif (string.match(action.Name, 'Elegy')) then
			gFunc.EquipSet(profile.Songs.Elegy);
		end
	end

	staves.EquipStaff(action.Name);

end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;
