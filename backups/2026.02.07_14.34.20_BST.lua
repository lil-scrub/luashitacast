local profile = {};
local sets = {
    ['Idle'] = {
        Main = 'Darksteel Pick +1',
        Sub = 'Darksteel Pick +1',
        Ammo = 'Pet Fd. Epsilon',
        Head = 'Beast Helm',
        Neck = 'Spike Necklace',
        Ear1 = 'Bone Earring +1',
        Ear2 = 'Bone Earring +1',
        Body = 'Beast Jackcoat',
        Hands = 'Beast Gloves',
        Ring1 = 'Courage Ring',
        Ring2 = 'Courage Ring',
        Waist = 'Brave Belt',
        Legs = 'Beast Trousers',
        Feet = 'Beast Gaiters',
    },
};
profile.Sets = sets;

profile.Packer = {
};

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
end

profile.OnUnload = function()
end

profile.HandleCommand = function(args)
end

profile.HandleDefault = function()
end

profile.HandleAbility = function()
end

profile.HandleItem = function()
end

profile.HandlePrecast = function()
end

profile.HandleMidcast = function()
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;