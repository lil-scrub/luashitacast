local profile = {};

local Settings = {
	UseAccuracy = false,
    UseExperience = false,
    UseWarp = false,
};

local sets = {
    ['Melee_Att_Priority'] = {
        Ring1 = {'Courage Ring'},
        Ring2 = {'Courage Ring'},
        Neck = {'Spike Necklace'},
        Waist = {'Brave Belt'},
        Ear1 = {'Bone Earring +1'},
        Ear2 = {'Bone Earring +1'},
    },
    ['Melee_Acc_Priority'] = {
        Ring1 = {'Balance Ring'},
        Ring2 = {'Balance Ring'},
        Neck = {'Peacock Amulet'},
        Waist = {'Life Belt'},
        Ear1 = {'Bone Earring +1'},
        Ear2 = {'Bone Earring +1'},
    },
    ['Dream_Priority'] = {
        Head = 'Dream Hat +1',
        Body = 'Dream Robe +1',
        Legs = 'Dream Pants +1',
		Hands = 'Dream Mittens +1',
		Feet = 'Dream Boots +1',
    },
    ['Flex'] = {
        Head = '';
        Body = '';
        Legs = '';
        Feet = '';
    }
};
profile.Sets = sets;

profile.EvalLevel = function(level)
	-- Evaluate Level Sync
    gFunc.EvaluateLevels(profile.Sets, level);
end

profile.SetMeleeOptions = function(option)
    -- Evaluate Melee Optional Sets
    if (option == 'acc') then
        Settings.UseAccuracy = not Settings.UseAccuracy;
        gFunc.Message('Use Accuracy: ' .. tostring(Settings.UseAccuracy));
    end
end

profile.EquipMelee = function()
    -- Accuracy
    if (Settings.UseAccuracy) then
        gFunc.EquipSet(sets.Melee_Acc);
    else
        gFunc.EquipSet(sets.Melee_Att);
    end
end

return profile;