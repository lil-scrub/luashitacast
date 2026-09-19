local profile = {};

-- HQ first, then the NQ. Both tiers are level 51 with the same element; the
-- HQ is simply a little stronger. These resolve against the bags, so the HQ
-- is used when carried and the NQ fills in when it is not.
local staves = {
    ['Fire']    = { 'Vulcan\'s Staff',  'Fire Staff' },
    ['Ice']     = { 'Aquilo\'s Staff',  'Ice Staff' },
    ['Wind']    = { 'Auster\'s Staff',  'Wind Staff' },
    ['Earth']   = { 'Terra\'s Staff',   'Earth Staff' },
    ['Thunder'] = { 'Jupiter\'s Staff', 'Thunder Staff' },
    ['Water']   = { 'Neptune\'s Staff', 'Water Staff' },
    ['Light']   = { 'Apollo\'s Staff',  'Light Staff' },
    ['Dark']    = { 'Pluto\'s Staff',   'Dark Staff' },
};

-- Exposed as _Priority sets so a job's common.EvaluateGear resolves them in
-- the same pass as its own gear. Once resolved, each element key holds the
-- best staff of that element actually carried.
local sets = {};
for element, list in pairs(staves) do
    sets[element .. '_Priority'] = { Main = list };
end
profile.Sets = sets;

-- Equip the staff matching the element of the action being cast. Abilities
-- carry no element and 'Non-Elemental' spells have no staff, so both leave
-- the weapon alone. An unresolved element is a silent no-op.
profile.EquipStaff = function(action)
    if (action == nil) then
        return;
    end

    gFunc.EquipSet(sets[tostring(action.Element)]);
end

-- Earth staff while idle, for damage reduction.
profile.EquipIdleStaff = function()
    gFunc.EquipSet(sets.Earth);
end

-- Dark staff while resting.
profile.EquipRestingStaff = function()
    gFunc.EquipSet(sets.Dark);
end

return profile;
