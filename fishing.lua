local profile = {};

local Settings = {
    UseFishing = false,
};

local sets = {
    ['Fishing'] = {
        Range = 'Halcyon Rod',
        Ammo  = 'Insect Ball',
        Body  = 'Angler\'s Tunica',
        Hands = 'Angler\'s Gloves',
        Legs  = 'Angler\'s Hose',
        Feet  = 'Angler\'s Boots',
    },
};
profile.Sets = sets;

profile.Toggle = function(book)
    if (Settings.UseFishing) then
        Settings.UseFishing = false;
        gFunc.Message('use fishing set: ' .. tostring(Settings.UseFishing));

        AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. book);
    else
        Settings.UseFishing = true;
        gFunc.Message('use fishing set: ' .. tostring(Settings.UseFishing));

        AshitaCore:GetChatManager():QueueCommand(-1, '/macro book 20');
    end
end

profile.EquipSet = function()
    if (Settings.UseFishing) then
        gFunc.EquipSet(profile.Sets.Fishing);
    end
end

return profile;
