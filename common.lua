local profile = {};

local Settings = {
	UseAccuracy = false,
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
    ['Dream'] = {
        Head = 'Dream Hat +1',
        Body = 'Dream Robe +1',
        Legs = 'Dream Pants +1',
		Hands = 'Dream Mittens +1',
		Feet = 'Dream Boots +1',
    },
};
profile.Sets = sets;


-- Lockstyle. The command is queued a few seconds after the profile loads
-- rather than immediately: a profile load happens on job change and on
-- zoning, and the client ignores the command while it is still settling.
-- ApplyLockStyle rides along with EvalLevel, which every job calls each
-- tick, so a job only has to ask for it once in OnLoad.
local LockStyleSet = nil;
local LockStyleAt = 0;

profile.RequestLockStyle = function(set)
    if (set == nil) then
        return;
    end

    LockStyleSet = set;
    LockStyleAt = os.time() + 5;
end

local ApplyLockStyle = function()
    if (LockStyleSet == nil) or (os.time() < LockStyleAt) then
        return;
    end

    AshitaCore:GetChatManager():QueueCommand(-1, '/lockstyleset ' .. tostring(LockStyleSet));
    LockStyleSet = nil;
end

profile.EvalLevel = function(level)
	-- Evaluate Level Sync
    profile.EvaluateGear(profile.Sets, level);

    ApplyLockStyle();
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

-- Scan the bags LuAshitacast is allowed to equip from and return what the
-- character is actually carrying, as a map of lowercased item name to the
-- level the item requires. Names come back as ShiftJIS bytes, which are
-- byte-identical to ASCII for the gear names these profiles use.
-- One scan is reused for a few seconds. A job may resolve several set tables
-- in the same tick (its own gear, its songs, the staves), and walking every
-- bag once per table is wasted work.
local scanCache, scanCount, scanAt = {}, 0, -100;

-- Drop the cached scan so the next call walks the bags again. A forced
-- refresh must see gear acquired a moment ago, not the last scan.
local InvalidateScan = function()
    scanCount = 0;
    scanAt = -100;
end
profile.InvalidateScan = InvalidateScan;

local GetOwnedItems = function()
    local now = os.time();
    if ((now - scanAt) < 3) and (scanCount > 0) then
        return scanCache, scanCount;
    end

    local owned = {};
    local found = 0;
    local inventory = AshitaCore:GetMemoryManager():GetInventory();
    local resources = AshitaCore:GetResourceManager();

    for _, container in ipairs(gSettings.EquipBags) do
        if (gData.GetContainerAvailable(container)) then
            local max = gData.GetContainerMax(container);
            for index = 1, max, 1 do
                local item = inventory:GetContainerItem(container, index);
                if (item ~= nil) and (item.Count > 0) and (item.Id > 0) then
                    local resource = resources:GetItemById(item.Id);
                    if (resource ~= nil) then
                        owned[string.lower(resource.Name[1])] = resource.Level;
                        found = found + 1;
                    end
                end
            end
        end
    end

    scanCache, scanCount, scanAt = owned, found, now;

    return owned, found;
end

-- Resolve every _Priority set to the first entry that is both usable at this
-- level and actually carried. gFunc.EvaluateLevels checks level alone, so an
-- item you do not own still wins its slot and that slot then keeps whatever
-- was already equipped. This picks the best piece you really have instead.
-- Returns false, changing nothing, if the bags could not be read.
profile.EvaluateOwned = function(sets, level)
    local owned, found = GetOwnedItems();

    -- An empty scan means the containers are not ready yet -- zoning, or a
    -- profile load that beat the inventory packets. Resolving against it
    -- would blank every set, so leave them alone and let the caller retry.
    if (found == 0) then
        return false;
    end

    -- Buffer the results. Assigning into sets while iterating it with pairs
    -- is undefined behaviour in Lua.
    local buffer = {};
    for name, set in pairs(sets) do
        if (#name > 9) and (string.sub(name, -9) == '_Priority') then
            local resolved = {};
            for slot, entries in pairs(set) do
                if (gData.Constants.EquipSlots[slot] ~= nil) then
                    if (type(entries) == 'string') then
                        resolved[slot] = entries;
                    elseif (type(entries) == 'table') then
                        if (entries[1] == nil) then
                            resolved[slot] = entries;
                        else
                            for _, entry in ipairs(entries) do
                                local itemName = entry;
                                if (type(entry) == 'table') then
                                    itemName = entry.Name;
                                end
                                if (type(itemName) == 'string') then
                                    local required = owned[string.lower(itemName)];
                                    if (required ~= nil) and (level >= required) then
                                        resolved[slot] = entry;
                                        break;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            buffer[string.sub(name, 1, -10)] = resolved;
        end
    end

    for key, value in pairs(buffer) do
        sets[key] = value;
    end

    return true;
end

-- Throttled entry point. Scanning every bag is far too expensive to run each
-- tick, so this evaluates by level first (which always leaves usable sets in
-- place), then retries the inventory scan at most once every few seconds
-- until it succeeds. State is kept per set table so a job's sets and this
-- file's own sets are tracked independently.
local ScanState = {};

profile.EvaluateGear = function(sets, level, force)
    local state = ScanState[sets];
    if (state == nil) then
        state = { Resolved = false, Last = 0, Level = -1 };
        ScanState[sets] = state;
    end

    if (force) or (level ~= state.Level) then
        if (force) then
            InvalidateScan();
        end
        state.Resolved = false;
        state.Last = 0;
        state.Level = level;
        gFunc.EvaluateLevels(sets, level);
    end

    if (state.Resolved) then
        return true;
    end

    local now = os.time();
    if ((now - state.Last) < 3) then
        return false;
    end
    state.Last = now;

    state.Resolved = profile.EvaluateOwned(sets, level);
    return state.Resolved;
end


-- Report what the bags scan found and how many slots each set actually filled.
-- Use this when gear is not swapping: it separates "bags unreadable" from
-- "you own none of the items in these lists", which look identical in game.
profile.ReportGear = function(sets, level)
    local owned, found = GetOwnedItems();

    gFunc.Message('gear scan: ' .. tostring(found) .. ' equippable items in bags, level ' .. tostring(level));
    if (found == 0) then
        gFunc.Message('  bags unreadable right now -- sets left as-is, will retry');
        return;
    end

    local names = {};
    for name, _ in pairs(sets) do
        if (#name > 9) and (string.sub(name, -9) == '_Priority') then
            table.insert(names, string.sub(name, 1, -10));
        end
    end
    table.sort(names);

    for _, name in ipairs(names) do
        local listed, filled = 0, 0;
        for slot, entries in pairs(sets[name .. '_Priority']) do
            if (gData.Constants.EquipSlots[slot] ~= nil) then
                listed = listed + 1;
            end
        end
        local resolved = sets[name];
        if (type(resolved) == 'table') then
            for _, _ in pairs(resolved) do
                filled = filled + 1;
            end
        end
        gFunc.Message(string.format('  %-11s %d of %d slots owned', name, filled, listed));
    end
end


return profile;
