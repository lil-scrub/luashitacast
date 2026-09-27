local profile = {};

-- The rods and baits that can be chosen, in listing order.
--
-- Ordered arrays rather than keyed tables: the listing then reads in a chosen
-- order rather than Lua's hash order, and adding tackle is one row. The lookup
-- is linear over a dozen rows and only runs on a typed command, so it costs
-- nothing.
--
-- Cmd is the short word the player types after '/fsh rod' or '/fsh bait'.
-- Item is the game's short item name -- what a bag scan matches -- taken from
-- the item API index (tools/wikidata/api/item_index.json), not the wiki, the
-- rule CLAUDE.md sets for every gear name in this project. A name the server
-- does not have is silently skipped in game, the same as a ladder entry the
-- character has not got yet.
local Rods = {
    { Cmd = 'halcyon',   Item = 'Halcyon Rod' },
    { Cmd = 'lu',        Item = 'Lu Shang\'s F. Rod' },
    { Cmd = 'ebisu',     Item = 'Ebisu Fishing Rod' },
    { Cmd = 'comp',      Item = 'Comp. Fishing Rod' },
    { Cmd = 'glass',     Item = 'Glass Fiber F. Rod' },
    { Cmd = 'carbon',    Item = 'Carbon Fish. Rod' },
    { Cmd = 'fastwater', Item = 'Fastwater F. Rod' },
    { Cmd = 'hume',      Item = 'Hume Fishing Rod' },
    { Cmd = 'mithran',   Item = 'Mithran Fish. Rod' },
    { Cmd = 'taru',      Item = 'Tarutaru F. Rod' },
    { Cmd = 'willow',    Item = 'Willow Fish. Rod' },
    { Cmd = 'yew',       Item = 'Yew Fishing Rod' },
    { Cmd = 'bamboo',    Item = 'Bamboo Fish. Rod' },
    { Cmd = 'hook',      Item = 'S.H. Fishing Rod' },
};

local Baits = {
    { Cmd = 'insect',   Item = 'Insect Ball' },
    { Cmd = 'sardine',  Item = 'Sardine Ball' },
    { Cmd = 'crayfish', Item = 'Crayfish Ball' },
    { Cmd = 'trout',    Item = 'Trout Ball' },
    { Cmd = 'worm',     Item = 'Little Worm' },
    { Cmd = 'lugworm',  Item = 'Little Lugworm' },
    { Cmd = 'paste',    Item = 'Worm Paste' },
    { Cmd = 'minnow',   Item = 'Sinking Minnow' },
    { Cmd = 'shellbug', Item = 'Shell Bug' },
    { Cmd = 'rig',      Item = 'Sabiki Rig' },
    { Cmd = 'robber',   Item = 'Robber Rig' },
    { Cmd = 'rogue',    Item = 'Rogue Rig' },
    { Cmd = 'meatball', Item = 'Meatball' },
    { Cmd = 'lizard',   Item = 'Lizard Lure' },
};

-- Find a registry row by the word the player typed. Nothing matches nil, so a
-- missing argument falls to the listing rather than to an error.
local function findTackle(registry, cmd)
    if (cmd == nil) then
        return nil;
    end

    local word = string.lower(cmd);
    for _, entry in ipairs(registry) do
        if (entry.Cmd == word) then
            return entry;
        end
    end

    return nil;
end

-- Defaults are what this file used to hardcode, so '/fsh' alone behaves
-- exactly as '/<job> fish' did.
local Settings = {
    UseFishing = false,
    Rod = 'halcyon',
    Bait = 'insect',
};

-- The two kinds of tackle, each tying its registry to the set slot it fills and
-- the Settings field holding the choice, keyed by the word the player types.
-- One selection handler and one listing handler then serve both.
local Tackle = {
    ['rod']  = { Label = 'rod',  Registry = Rods,  Slot = 'Range', Key = 'Rod' },
    ['bait'] = { Label = 'bait', Registry = Baits, Slot = 'Ammo',  Key = 'Bait' },
};

-- Range and Ammo are fields the selection writes into, not values read back per
-- tick: EquipSet runs every tick while fishing is on, and the tackle changes
-- only when the player types a command.
local sets = {
    ['Fishing'] = {
        Range = findTackle(Rods, Settings.Rod).Item,
        Ammo  = findTackle(Baits, Settings.Bait).Item,
        Body  = 'Angler\'s Tunica',
        Hands = 'Angler\'s Gloves',
        Legs  = 'Angler\'s Hose',
        Feet  = 'Angler\'s Boots',
    },
};
profile.Sets = sets;

-- The one place the fishing state changes, so the macro book command has a
-- single owner: the toggle comes through here with the flipped state, choosing
-- tackle with true.
--
-- Returning early when the state already matches is what keeps a second bait
-- choice in the same session from re-issuing '/macro book 20'.
--
-- Switching off restores the book the loaded job declares as its own; the five
-- jobs that declare none pass nil and the book stays on 20, which is today's
-- behavior for them.
local function setFishing(enabled, book)
    if (Settings.UseFishing == enabled) then
        return;
    end

    Settings.UseFishing = enabled;
    gFunc.Message('use fishing set: ' .. tostring(Settings.UseFishing));

    if (enabled) then
        AshitaCore:GetChatManager():QueueCommand(-1, '/macro book 20');
    elseif (book ~= nil) then
        AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. book);
    end
end

-- Choosing tackle starts fishing, so one command is enough to get going.
local function selectTackle(kind, cmd, book)
    local entry = findTackle(kind.Registry, cmd);
    if (entry == nil) then
        gFunc.Message('no ' .. kind.Label .. ' called "' .. tostring(cmd)
            .. '": try /fsh ' .. kind.Label);
        return;
    end

    Settings[kind.Key] = entry.Cmd;
    sets.Fishing[kind.Slot] = entry.Item;
    gFunc.Message(kind.Label .. ': ' .. entry.Item);

    setFishing(true, book);
end

-- One column of the listing: the marker, the word to type, and the item it
-- names, padded so the item names line up.
local function tackleColumn(kind, entry)
    local marker = '   ';
    if (entry.Cmd == Settings[kind.Key]) then
        marker = ' * ';
    end

    return marker .. string.format('%-10s', entry.Cmd) .. entry.Item;
end

-- Two to a row: every Message call prints its own '[LuAshitacast]' header, so
-- fourteen rods one per line is fourteen headers -- the same reason BRD's help
-- pairs its toggles.
local function listTackle(kind)
    gFunc.Message(kind.Label .. 's (* selected):');

    for index = 1, #kind.Registry, 2 do
        local line = tackleColumn(kind, kind.Registry[index]);
        local second = kind.Registry[index + 1];
        if (second == nil) then
            gFunc.Message(line);
        else
            gFunc.Message(string.format('%-34s', line) .. tackleColumn(kind, second));
        end
    end
end

local function helpRow(cmd, label)
    gFunc.Message(string.format('   %-13s%s', cmd, label));
end

-- What can be typed, plus what is currently selected, so one command answers
-- both "what does this accept" and "what am I fishing with".
local function showHelp()
    gFunc.Message('/fsh commands:');
    helpRow('(no word)', 'toggle the fishing set and macro book');
    helpRow('rod <name>', 'choose a rod, or list the rods with no name');
    helpRow('bait <name>', 'choose a bait, or list the baits with no name');
    helpRow('help', 'this list');
    gFunc.Message('   fishing: ' .. tostring(Settings.UseFishing)
        .. ', rod: ' .. sets.Fishing.Range
        .. ', bait: ' .. sets.Fishing.Ammo);
end

profile.Toggle = function(book)
    setFishing(not Settings.UseFishing, book);
end

-- Reached from utility.SetOptions, which routes the forwarded '_fish' word
-- here; args[1] is that word and args[2] is the subcommand.
profile.HandleCommand = function(args, book)
    if (args[2] == nil) then
        profile.Toggle(book);
        return;
    end

    local subcommand = string.lower(args[2]);

    if (subcommand == 'help') then
        showHelp();
        return;
    end

    local kind = Tackle[subcommand];
    if (kind ~= nil) then
        if (args[3] == nil) then
            listTackle(kind);
        else
            selectTackle(kind, args[3], book);
        end
        return;
    end

    -- Anything else is reported rather than falling through to the toggle: a
    -- typo must not put the angler's gear on.
    gFunc.Message('/fsh: no command "' .. tostring(args[2])
        .. '": try /fsh help');
end

profile.EquipSet = function()
    if (Settings.UseFishing) then
        gFunc.EquipSet(profile.Sets.Fishing);
    end
end

return profile;
