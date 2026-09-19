local profile = {};

-- Elemental staves keyed by the element string LuAshitacast resolves from
-- the game's own spell resource (gData.Constants.SpellElements).
local staves = {
    ['Fire']    = 'Fire Staff',
    ['Ice']     = 'Ice Staff',
    ['Wind']    = 'Wind Staff',
    ['Earth']   = 'Earth Staff',
    ['Thunder'] = 'Thunder Staff',
    ['Water']   = 'Water Staff',
    ['Light']   = "Apollo's Staff",
    ['Dark']    = 'Dark Staff',
};
profile.Staves = staves;

-- Equip the staff matching the element of the action being cast.
-- Takes the table from gData.GetAction(). Abilities carry no element, and
-- 'Non-Elemental' spells have no staff, so both leave the weapon alone.
profile.EquipStaff = function(action)
    if (action == nil) then
        return;
    end

    local staff = staves[action.Element];
    if (staff ~= nil) then
        gFunc.EquipSet({ Main = staff });
    end
end

-- Earth staff while idle, for damage reduction.
profile.EquipIdleStaff = function()
    gFunc.EquipSet({ Main = staves.Earth });
end

-- Dark staff while resting.
profile.EquipRestingStaff = function()
    gFunc.EquipSet({ Main = staves.Dark });
end

return profile;
