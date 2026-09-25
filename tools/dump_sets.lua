-- Dump every gear set a job profile resolves to, plus what its jug commands
-- and Call Beast do, so two revisions of a profile can be diffed.
--
-- Not loaded by the game. See lacstub.lua for what is faked and why.
--
--     luajit tools/dump_sets.lua [JOB] [LEVEL] > before.txt
--     ... edit the profile ...
--     luajit tools/dump_sets.lua [JOB] [LEVEL] > after.txt
--     diff before.txt after.txt
--
-- Both the resolved sets and the priority ladders they came from are printed:
-- a re-score that only reorders the tail of a ladder does not move the
-- resolved head, and is invisible in the resolved output alone.

local here = string.match(arg[0], '^(.*)[/\\][^/\\]*$') or '.';
-- The profiles are the directory this one lives in. LAC_PROFILE overrides it,
-- for running against another copy of them.
local root = os.getenv('LAC_PROFILE') or (here .. '/..');
package.path = here .. '/?.lua;' .. package.path;

local stub = require('lacstub');

local job = arg[1] or 'BST';
local level = tonumber(arg[2]) or 75;

local h = stub.init(root);
h.Level = level;
local chunk = assert(loadfile(root .. '/' .. job .. '.lua'));
local profile = chunk();
local itemCount = h:BuildInventory(profile.Sets);

local common = h.Modules['common.lua'];
common.InvalidateScan();
common.EvaluateGear(profile.Sets, level, true);
common.EvaluateGear(common.Sets, level, true);

local function sortedKeys(t)
    local keys = {};
    for key, _ in pairs(t) do
        table.insert(keys, key);
    end
    table.sort(keys);
    return keys;
end

local function entryName(entry)
    if (type(entry) == 'table') then
        return tostring(entry.Name);
    end
    return tostring(entry);
end

print('# ' .. job .. '.lua at level ' .. level);
print('# ' .. itemCount .. ' items in the fake bags (one of everything the profile names)');
print('');

print('## resolved sets');
print('');
for _, name in ipairs(sortedKeys(profile.Sets)) do
    if (string.sub(name, -9) ~= '_Priority') then
        local set = profile.Sets[name];
        if (type(set) == 'table') then
            local lines = {};
            for _, slot in ipairs(stub.Slots) do
                if (set[slot] ~= nil) then
                    table.insert(lines, string.format('    %-6s %s', slot, entryName(set[slot])));
                end
            end
            if (#lines > 0) then
                print('  ' .. name);
                for _, line in ipairs(lines) do
                    print(line);
                end
            else
                -- A table of tables, such as the jug lists.
                print('  ' .. name);
                for _, key in ipairs(sortedKeys(set)) do
                    local nested = set[key];
                    if (type(nested) == 'table') then
                        for _, slot in ipairs(stub.Slots) do
                            if (nested[slot] ~= nil) then
                                print(string.format('    %-12s %-6s %s', key, slot, entryName(nested[slot])));
                            end
                        end
                    end
                end
            end
            print('');
        end
    end
end

print('## priority ladders');
print('');
for _, name in ipairs(sortedKeys(profile.Sets)) do
    if (string.sub(name, -9) == '_Priority') then
        print('  ' .. name);
        local set = profile.Sets[name];
        for _, slot in ipairs(stub.Slots) do
            local entries = set[slot];
            if (type(entries) == 'string') then
                print(string.format('    %-6s %s', slot, entries));
            elseif (type(entries) == 'table') then
                local names = {};
                for _, entry in ipairs(entries) do
                    table.insert(names, entryName(entry));
                end
                print(string.format('    %-6s %d: %s', slot, #names, table.concat(names, ', ')));
            end
        end
        print('');
    end
end

-- Behaviour, not just tables: the jug selection is profile-local state, so it
-- is only observable through what the profile says and what Call Beast equips.
print('## commands and handlers');
print('');

local function report(label)
    local equipped = h:LastEquipped();
    local slots = {};
    for _, slot in ipairs(stub.Slots) do
        if (equipped[slot] ~= nil) then
            table.insert(slots, slot .. '=' .. equipped[slot]);
        end
    end
    print('  ' .. label);
    for _, message in ipairs(h.Messages) do
        print('    said:    ' .. message);
    end
    for _, command in ipairs(h.Commands) do
        print('    ran:     ' .. command);
    end
    if (#slots > 0) then
        print('    equipped: ' .. table.concat(slots, ' '));
    end
    print('');
    h:ClearLog();
end

h:ClearLog();
profile.OnLoad();
report('OnLoad');

local function ability(name)
    h.Action = { Name = name, Type = 'Ability' };
    profile.HandleAbility();
    h.Action = nil;
end

local function command(...)
    profile.HandleCommand({ ... });
end

for _, status in ipairs({ 'Idle', 'Engaged' }) do
    for _, subjob in ipairs({ 'NIN', 'WHM', 'WAR' }) do
        h.Player.Status = status;
        h.Player.SubJob = subjob;
        profile.HandleDefault();
        report('HandleDefault ' .. status .. ' /' .. subjob);
    end
end
h.Player.Status = 'Idle';
h.Player.SubJob = 'NIN';

if (job == 'BST') then
    ability('Charm');
    report('HandleAbility Charm');

    ability('Reward');
    report('HandleAbility Reward');

    ability('Call Beast');
    report('HandleAbility Call Beast (default jug)');

    command('jug', 'tiger');
    report('/bst jug tiger');
    ability('Call Beast');
    report('HandleAbility Call Beast (tiger)');

    command('jug', 'hq', 'tiger');
    report('/bst jug hq tiger');
    ability('Call Beast');
    report('HandleAbility Call Beast (hq tiger)');

    command('jug', 'homunculus');
    report('/bst jug homunculus');
    command('jug', 'hq');
    report('/bst jug hq (pet with no hq broth)');
    ability('Call Beast');
    report('HandleAbility Call Beast (homunculus)');

    command('jug', 'wyvern');
    report('/bst jug wyvern (unknown pet)');

    command('jug', 'sheep');
    report('/bst jug sheep (back to the default)');
end
