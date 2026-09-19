local fishing = gFunc.LoadFile('./fishing.lua');
local profile = {};

local Settings = {
    UseExperience = false,
    ExperienceUsed = false,
    UseWarp = false,
	UseSneak = false,
	UseInvis = false,
};

local sets = {
	['Milk'] = {
        Body = 'Dream Robe +1',
    },
	['OJ'] = {
		Legs = 'Dream Pants +1'
	},
	['Invisible'] = {
		Hands = 'Dream Mittens +1',
	},
	['Sneak'] = {
		Feet = 'Dream Boots +1',
	},
    ['Chariot'] = {
        Ring1 = 'Chariot Band'
    },
    ['WarpClub'] = {
        Main = 'Warp Cudgel'
    },
};

profile.SetOptions = function(option, arg)
    if (option == 'exp') then
        Settings.UseExperience = not Settings.UseExperience;
        gFunc.Message('use experience set: ' .. tostring(Settings.UseExperience));
    end
    if (option == 'warp') then
        Settings.UseWarp = not Settings.UseWarp;
        gFunc.Message('use warp set: ' .. tostring(Settings.UseWarp));
    end
    if (option == 'sneak') then
        Settings.UseSneak = not Settings.UseSneak;
        gFunc.Message('use sneak set: ' .. tostring(Settings.UseSneak));
    end
    if (option == 'invis') then
        Settings.UseInvis = not Settings.UseInvis;
        gFunc.Message('use invis set: ' .. tostring(Settings.UseInvis));
    end
    if (option == 'fish') then
        fishing.Toggle(arg);
    end
end

profile.EquipSet = function()
    -- Fishing
    fishing.EquipSet();

    -- Experience. The ring only needs to be worn long enough to use it;
    -- once used the bonus is active and the slot is better spent elsewhere.
    if (Settings.UseExperience) then
        if (Settings.ExperienceUsed) then
            Settings.UseExperience = false;
            Settings.ExperienceUsed = false;
            gFunc.Message('experience ring used: releasing ring slot');
        else
            gFunc.EquipSet(sets.Chariot);
        end
    end
    
    -- Warp Club
    if (Settings.UseWarp) then
        gFunc.EquipSet(sets.WarpClub);
    end

	-- Sneak Boots
    if (Settings.UseSneak) then
        gFunc.EquipSet(sets.Sneak);
    end

	-- Invis Gloves
    if (Settings.UseInvis) then
        gFunc.EquipSet(sets.Invisible);
    end

end


profile.CheckItem = function(name)
	if (name == 'Chariot Band') then
		gFunc.EquipSet(sets.Chariot);
		if (Settings.UseExperience) then
			Settings.ExperienceUsed = true;
		end
	end
	if (name == 'Selbina Milk') then
		gFunc.EquipSet(sets.Milk);
	end
	if (string.match(name, 'Orange Juice')) then
		gFunc.EquipSet(sets.OJ);
	end
	if (name == 'Prism Powder') then
		gFunc.EquipSet(sets.Invisible);
	end
	if (name == 'Silent Oil') then
		gFunc.EquipSet(sets.Sneak);
	end
end

profile.CheckCast = function(name)
	if (name == 'Invisible' or string.match(name, 'Tonko')) then
		gFunc.EquipSet(sets.Invisible);
	end
	if (name == 'Sneak') then
		gFunc.EquipSet(sets.Sneak);
	end
end

return profile;