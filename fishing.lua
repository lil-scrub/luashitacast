local profile = {};

local Settings = {
    UseFishing = false,
};

local sets = {
    ['Fishing'] = {
        Range = '',
        Ammo  = '',
        Main  = '',
        Body  = '',
        Hands = '',
        Legs  = '',
        Feet  = '',
    },
};
profile.Sets = sets;

profile.Toggle = function()
    if (Settings.UseFishing) then
        Settings.UseFishing = false;
        print('Turning off fishing');
    else
        Settings.UseFishing = true;
        print('Turning on fishing');
    end
end

return profile;
