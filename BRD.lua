local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
	CurrentLevel = 0,
};

sets = {
	['Pulling'] = {
		Ammo = 'Pebble',
		Head = 'Emperor Hairpin',
		Body = 'Bone Harness +1',
		Legs = 'Bone Subligar +1',
		Feet = 'Leaping Boots',
		Hands = 'Ryl.Ftm. Gloves',
		Ring1 = 'Balance Ring',
		Ring2 = 'Balance Ring',
	},
	['Songs'] = {
        Ring1 = 'Hope Ring',
        Ring2 = 'Hope Ring',
	}
};
songs = {
    ['Paeon'] = {},
	['Minuet'] = {
		Range = 'cornette +1',
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
	gFunc.EquipSet(sets.Songs)

	if (string.match(song, 'Minuet')) then
		gFunc.EquipSet(songs.Minuet);
	elseif (string.match(song, 'Madrigal')) then
		gFunc.EquipSet(songs.Minuet);
	elseif (string.match(song, 'Paeon')) then
		gFunc.EquipSet(songs.Minuet);
	elseif (string.match(song, 'Mambo')) then
		gFunc.EquipSet(songs.Minuet);
	elseif (string.match(song, 'Lullaby')) then
		gFunc.EquipSet(songs.Minuet);
	end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
end

profile.OnUnload = function()
end

profile.HandleCommand = function(args)
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();
	
	if (player.Status == 'Idle') then
		gFunc.EquipSet(common.Dream);
		gFunc.EquipSet(sets.Pulling);
	elseif (player.Status == 'Engaged') then
		gFunc.EquipSet(common.Dream);
		gFunc.EquipSet(sets.Pulling);
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

	if (action.Type == 'Bard Song') then
		equipSong(action.Name)
	end

end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;