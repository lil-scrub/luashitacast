profile = {};

local elements = {
    ['Light'] = {
        staff  = "Apollo's Staff",
        spells = {'Cure', 'Curaga', 'Cursna', 'Raise', 'Reraise', 'Banish', 'Holy',
                  'Regen', 'Protect', 'Shell', 'Phalanx', 'Erase', 'Barblind',
                  'Dia', 'Paralyze', 'Aurorastorm',
                  'Lullaby', 'Finale'},
    },
    ['Dark'] = {
        staff  = 'Dark Staff',
        spells = {'Aspir', 'Drain', 'Bio', 'Blind', 'Sleep', 'Dispel',
                  'Frazzle', 'Warp', 'Escape', 'Voidstorm'},
    },
    ['Earth'] = {
        staff  = 'Earth Staff',
        spells = {'Stone', 'Stonega', 'Quake', 'Stoneskin', 'Enstone', 'Barthunder',
                  'Slow', 'Break', 'Sandstorm'},
    },
    ['Water'] = {
        staff  = 'Water Staff',
        spells = {'Water', 'Waterga', 'Flood', 'Enwater', 'Barfire', 'Baramnesia',
                  'Barvirus', 'Poison', 'Rainstorm'},
    },
    ['Fire'] = {
        staff  = 'Fire Staff',
        spells = {'Fire', 'Firaga', 'Flare', 'Enfire', 'Barblizzard', 'Addle', 'Firestorm'},
    },
    ['Wind'] = {
        staff  = 'Wind Staff',
        spells = {'Aero', 'Aeroga', 'Tornado', 'Enaero', 'Barsleep', 'Barstone',
                  'Barpetrify', 'Haste', 'Blink', 'Sneak', 'Invisible', 'Gravity',
                  'Silence', 'Flurry', 'Windstorm'},
    },
    ['Ice'] = {
        staff  = 'Ice Staff',
        spells = {'Blizzard', 'Blizzaga', 'Freeze', 'Enblizzard', 'Baraero',
                  'Ice Spikes', 'Bind', 'Distract', 'Hailstorm'},
    },
    ['Thunder'] = {
        staff  = 'Thunder Staff',
        spells = {'Thunder', 'Thundaga', 'Burst', 'Enthunder', 'Barpoison',
                  'Barwater', 'Shock Spikes', 'Thunderstorm'},
    },
}

profile.EquipStaff = function(name)
    for _, data in pairs(elements) do
        for _, keyword in ipairs(data.spells) do
            if string.match(name, keyword) then
                gFunc.EquipSet({ Main = data.staff })
                return
            end
        end
    end
end

return profile;
