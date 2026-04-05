local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
	CurrentLevel = 0,
	MacroBook = '2',
};

sets = {
	['Pulling_Priority'] = {
		Main = {'Blind Dagger'},
		Ammo = {'Pebble'},
		Head = {'Emperor Hairpin', 'Noble\'s Ribbon'},
		Body = {'Bone Harness +1'},
		Legs = {'Bone Subligar +1'},
		Feet = {'Leaping Boots'},
		Hands = {'Ryl.Ftm. Gloves'},
	},
	['Songs_Priority'] = {
		Main = {'Monster Signa'},
        Ring1 = {'Hope Ring'},
        Ring2 = {'Hope Ring'},
	}
};
songs = {
    ['Paeon_Priority'] = {},
	['Minuet_Priority'] = {
		Range = {'cornette +1'},
	}
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
	gFunc.EquipSet(profile.Sets.Pulling);

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

	if (action.Type == 'Bard Song') then
		gFunc.EquipSet(profile.Sets.Songs)

		if (string.match(action.Name, 'Minuet')) then
			gFunc.EquipSet(profile.Songs.Minuet);
		elseif (string.match(action.Name, 'Madrigal')) then
			gFunc.EquipSet(profile.Songs.Minuet);
		elseif (string.match(action.Name, 'Paeon')) then
			gFunc.EquipSet(profile.Songs.Minuet);
		elseif (string.match(action.Name, 'Mambo')) then
			gFunc.EquipSet(profile.Songs.Minuet);
		elseif (string.match(action.Name, 'Lullaby')) then
			gFunc.EquipSet(profile.Songs.Minuet);
		end
	end

end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;