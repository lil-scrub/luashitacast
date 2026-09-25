-- Stubbed LuAshitacast framework, enough of it to load a job profile outside
-- the game and watch what it equips.
--
-- Not loaded by the game: LuAshitacast only reads <JOB>.lua from the profile
-- root, so nothing in tools/ reaches the addon.
--
-- The profiles have no test runner and no way to be exercised except by
-- reloading them in game, which makes a re-scored ladder impossible to diff.
-- This provides the globals a profile expects -- gFunc, gData, gSettings and
-- AshitaCore -- backed by a fake inventory, so a profile can be loaded, ticked
-- and inspected.
--
-- The fake inventory is built from the profile's own gear lists, one of every
-- item named anywhere in them. A set therefore resolves to the head of each of
-- its ladders, which is what the character would wear owning everything.

local M = {};

local Handle = {};
Handle.__index = Handle;

-- Slot names LuAshitacast recognises, in the order common.lua resolves them.
local SLOTS = {
    'Main', 'Sub', 'Range', 'Ammo', 'Head', 'Neck', 'Ear1', 'Ear2',
    'Body', 'Hands', 'Ring1', 'Ring2', 'Back', 'Waist', 'Legs', 'Feet',
};
M.Slots = SLOTS;

local function isSlot(name)
    for _, slot in ipairs(SLOTS) do
        if (slot == name) then
            return true;
        end
    end
    return false;
end

-- Walk a gear set table and collect every item name it names, in any of the
-- three shapes the profiles use: a plain string, a list of strings, or a list
-- of { Name = ... } entries.
local function collectNames(set, out)
    if (type(set) ~= 'table') then
        return;
    end
    for slot, entries in pairs(set) do
        if (isSlot(slot)) then
            if (type(entries) == 'string') then
                out[entries] = true;
            elseif (type(entries) == 'table') then
                for _, entry in ipairs(entries) do
                    if (type(entry) == 'string') then
                        out[entry] = true;
                    elseif (type(entry) == 'table') and (type(entry.Name) == 'string') then
                        out[entry.Name] = true;
                    end
                end
            end
        end
    end
end
M.CollectNames = collectNames;

function Handle:Message(text)
    table.insert(self.Messages, text);
    if (self.Echo) then
        print('  [msg] ' .. text);
    end
end

-- Apply a set the way the game does: a slot keeps whatever it holds until
-- something equips over it, and 'remove' empties it.
function Handle:Equip(set, forced)
    if (type(set) ~= 'table') then
        return;
    end

    local applied = {};
    for _, slot in ipairs(SLOTS) do
        local item = set[slot];
        if (type(item) == 'table') then
            item = item.Name;
        end
        if (type(item) == 'string') then
            if (string.lower(item) == 'remove') then
                self.Equipment[slot] = nil;
            else
                self.Equipment[slot] = item;
            end
            applied[slot] = item;
        end
    end

    if (next(applied) ~= nil) then
        table.insert(self.EquipLog, { Forced = forced or false, Slots = applied });
    end
end

-- Every item named anywhere in every loaded set table, one of each. Called
-- after the profile has loaded, so the modules it pulled in are known.
function Handle:BuildInventory(extraSets)
    local names = {};

    for _, module in pairs(self.Modules) do
        if (type(module) == 'table') and (type(module.Sets) == 'table') then
            for _, set in pairs(module.Sets) do
                collectNames(set, names);
                -- The jug tables are a map of pet name to a one-slot set.
                if (type(set) == 'table') then
                    for _, nested in pairs(set) do
                        collectNames(nested, names);
                    end
                end
            end
        end
    end

    if (type(extraSets) == 'table') then
        for _, set in pairs(extraSets) do
            collectNames(set, names);
            for _, nested in pairs(set) do
                collectNames(nested, names);
            end
        end
    end

    local ordered = {};
    for name, _ in pairs(names) do
        table.insert(ordered, name);
    end
    table.sort(ordered);

    self.ItemList = {};
    self.Items = {};
    for index, name in ipairs(ordered) do
        table.insert(self.ItemList, { Id = index, Name = name, Count = 1 });
        self.Items[index] = { Name = { name }, Level = 1 };
    end

    return #ordered;
end

-- Drop an item from the fake bags, to test what a set resolves to without it.
function Handle:RemoveItem(name)
    local key = string.lower(name);
    for index, entry in ipairs(self.ItemList) do
        if (string.lower(entry.Name) == key) then
            table.remove(self.ItemList, index);
            return true;
        end
    end
    return false;
end

function Handle:ClearLog()
    self.Messages = {};
    self.EquipLog = {};
    self.Commands = {};
end

-- What the last call to a handler equipped, flattened to slot -> item.
function Handle:LastEquipped()
    local flat = {};
    for _, entry in ipairs(self.EquipLog) do
        for slot, item in pairs(entry.Slots) do
            flat[slot] = item;
        end
    end
    return flat;
end

function M.init(root)
    local h = setmetatable({}, Handle);
    h.Root = root;
    h.Modules = {};
    h.Messages = {};
    h.EquipLog = {};
    h.Commands = {};
    h.Equipment = {};
    h.ItemList = {};
    h.Items = {};
    h.Level = 75;
    h.Echo = false;
    h.Player = {
        MainJob = 'BST',
        MainJobSync = 75,
        SubJob = 'NIN',
        SubJobSync = 37,
        Status = 'Idle',
        HP = 1000,
        MP = 100,
        HPP = 100,
        MPP = 100,
        TP = 0,
    };
    h.Action = nil;

    _G.gFunc = {
        LoadFile = function(path)
            local name = string.gsub(path, '^%./', '');
            if (h.Modules[name] == nil) then
                local chunk = assert(loadfile(h.Root .. '/' .. name));
                h.Modules[name] = chunk();
            end
            return h.Modules[name];
        end,

        -- The real one resolves every _Priority set by level alone. common.lua
        -- then re-resolves against the bags, so this only has to leave a
        -- plausible set behind.
        EvaluateLevels = function(sets, level)
            local buffer = {};
            for name, set in pairs(sets) do
                if (#name > 9) and (string.sub(name, -9) == '_Priority') then
                    local resolved = {};
                    for _, slot in ipairs(SLOTS) do
                        local entries = set[slot];
                        if (type(entries) == 'string') then
                            resolved[slot] = entries;
                        elseif (type(entries) == 'table') then
                            if (entries[1] == nil) then
                                resolved[slot] = entries;
                            else
                                resolved[slot] = entries[1];
                            end
                        end
                    end
                    buffer[string.sub(name, 1, -10)] = resolved;
                end
            end
            for key, value in pairs(buffer) do
                sets[key] = value;
            end
        end,

        EquipSet = function(set)
            h:Equip(set, false);
        end,

        ForceEquipSet = function(set)
            h:Equip(set, true);
        end,

        Message = function(text)
            h:Message(tostring(text));
        end,
    };

    _G.gSettings = {
        AllowAddSet = false,
        EquipBags = { 1 },
    };

    _G.gData = {
        GetPlayer = function()
            return h.Player;
        end,
        GetAction = function()
            return h.Action;
        end,
        GetEquipment = function()
            local equipment = {};
            for slot, item in pairs(h.Equipment) do
                equipment[slot] = { Name = item };
            end
            return equipment;
        end,
        GetContainerAvailable = function(container)
            return (container == 1);
        end,
        GetContainerMax = function(container)
            if (container == 1) then
                return #h.ItemList;
            end
            return 0;
        end,
        Constants = {
            EquipSlots = (function()
                local map = {};
                for index, slot in ipairs(SLOTS) do
                    map[slot] = index;
                end
                return map;
            end)(),
        },
    };

    _G.AshitaCore = {
        GetChatManager = function()
            return {
                QueueCommand = function(_, _, command)
                    table.insert(h.Commands, command);
                end,
            };
        end,
        GetMemoryManager = function()
            return {
                GetPlayer = function()
                    return {
                        GetMainJobLevel = function()
                            return h.Level;
                        end,
                    };
                end,
                GetInventory = function()
                    return {
                        GetContainerItem = function(_, container, index)
                            if (container ~= 1) then
                                return nil;
                            end
                            local entry = h.ItemList[index];
                            if (entry == nil) then
                                return nil;
                            end
                            return { Id = entry.Id, Count = entry.Count };
                        end,
                    };
                end,
            };
        end,
        GetResourceManager = function()
            return {
                GetItemById = function(_, id)
                    return h.Items[id];
                end,
            };
        end,
    };

    return h;
end

-- Load a job profile, build the bags from what it names, and settle the gear
-- resolution. common.lua only rescans every few seconds and refuses an empty
-- scan, so the first tick after the bags appear is forced.
function M.load(root, job)
    local h = M.init(root);
    local chunk = assert(loadfile(root .. '/' .. job .. '.lua'));
    local profile = chunk();
    h.Profile = profile;
    h.ItemCount = h:BuildInventory(profile.Sets);

    local common = h.Modules['common.lua'];
    if (common ~= nil) then
        common.InvalidateScan();
        common.EvaluateGear(profile.Sets, h.Level, true);
        common.EvaluateGear(common.Sets, h.Level, true);
    end

    return h, profile;
end

return M;
