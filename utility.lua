local fishing = gFunc.LoadFile('./fishing.lua');
local profile = {};

local Settings = {
    UseExperience = false,
    ExperienceUsed = false,
    UseWarp = false,
    UseClam = false,
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
    -- Mithra Shorts +1 improve clamming results; Savage Top +1 carries the
    -- enchantment that teleports to Purgonorgo Isle. Both block a
    -- neighbouring slot: the top blocks hands, the shorts block feet.
    ['Clam'] = {
        Body = 'Savage Top +1',
        Legs = 'Mithra Shorts +1',
        -- The top blocks handgear and the shorts block footgear. Without
        -- clearing these the job keeps re-equipping hands and feet every
        -- tick and the two sets fight each other.
        Hands = 'remove',
        Feet = 'remove',
    },
};

-- LuAshitacast only ever equips: a slot keeps its piece until something else
-- replaces it, so switching an option off leaves its gear on. These clear the
-- slot once when the option is turned off.
local clearSets = {
    ['Chariot']   = { Ring1 = 'remove' },
    ['WarpClub']  = { Main = 'remove' },
    ['Sneak']     = { Feet = 'remove' },
    ['Invisible'] = { Hands = 'remove' },
    ['Clam']      = { Body = 'remove', Legs = 'remove' },
};

-- Clearing happens at the moment the option is switched off rather than being
-- deferred a tick: a deferred clear runs after the job has already refilled
-- the slot, and would strip the piece the job just put there.
local function releaseSet(name)
    gFunc.EquipSet(clearSets[name]);
end

profile.SetOptions = function(option, arg)
    if (option == 'exp') then
        Settings.UseExperience = not Settings.UseExperience;
        if (not Settings.UseExperience) then
            releaseSet('Chariot');
        end
        gFunc.Message('use experience set: ' .. tostring(Settings.UseExperience));
    end
    if (option == 'warp') then
        Settings.UseWarp = not Settings.UseWarp;
        if (not Settings.UseWarp) then
            releaseSet('WarpClub');
        end
        gFunc.Message('use warp set: ' .. tostring(Settings.UseWarp));
    end
    if (option == 'sneak') then
        Settings.UseSneak = not Settings.UseSneak;
        if (not Settings.UseSneak) then
            releaseSet('Sneak');
        end
        gFunc.Message('use sneak set: ' .. tostring(Settings.UseSneak));
    end
    if (option == 'invis') then
        Settings.UseInvis = not Settings.UseInvis;
        if (not Settings.UseInvis) then
            releaseSet('Invisible');
        end
        gFunc.Message('use invis set: ' .. tostring(Settings.UseInvis));
    end
    if (option == 'clam') then
        Settings.UseClam = not Settings.UseClam;
        if (not Settings.UseClam) then
            releaseSet('Clam');
        end
        gFunc.Message('use clamming set: ' .. tostring(Settings.UseClam));
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
            releaseSet('Chariot');
            gFunc.Message('experience ring used: releasing ring slot');
        else
            gFunc.EquipSet(sets.Chariot);
        end
    end
    
    -- Warp Club
    if (Settings.UseWarp) then
        gFunc.EquipSet(sets.WarpClub);
    end

    -- Clamming
    if (Settings.UseClam) then
        gFunc.EquipSet(sets.Clam);
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