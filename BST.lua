local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
    UseHQJugs = true,
    Jug = "sheep",
    MacroBook = '4',
    -- Off on load. The mode is only ever what the player last asked for, and
    -- it means nothing under any subjob but ninja.
    UseRuneAxes = false
}

-- Gear that earns its slot only while a game condition holds, applied over
-- whatever the profile is already wearing rather than belonging to a set of its
-- own. Each entry pairs a gear set with a predicate over the player and the
-- slots it claims.
--
-- The slots matter because LuAshitacast only ever equips: a slot keeps its
-- piece until something else claims it. BST wears nothing at all while idle, so
-- a conditional piece has to be handed back explicitly when its condition
-- lapses or it stays on with its reason gone. BRD keeps the same list without
-- that step, because its idle mode reclaims every slot every tick anyway.
--
-- The predicates run every tick, from HandleDefault, so keep them to reads of
-- gData.GetPlayer() and comparisons. Anything that scans bags belongs elsewhere.
--
-- Gaudy Harness' latent is live while MP is below 49 points -- below, so 49
-- itself is already off. Gating on the latent's own trigger costs nothing in
-- refresh terms, because the latent stops at 49 whether or not the piece is
-- worn; it only hands the body slot back to the melee set while the effect is
-- dormant.
local Conditionals = {
	{ Set = 'Gaudy', Slots = { 'Body' },
	  When = function(player)
		return (player.SubJob == 'WHM') and (player.MP < 49);
	  end },

	-- Under a ninja subjob the same piece is worn for something else entirely:
	-- 5 HP regen per Rune Axe held, which does not care about MP. So no MP test
	-- here -- the mode being on is the whole condition, and the mode is on only
	-- because the player said they are wielding the axes.
	{ Set = 'Gaudy', Slots = { 'Body' },
	  When = function(player)
		return (player.SubJob == 'NIN') and Settings.UseRuneAxes;
	  end },
};

-- Which conditionals were live on the previous tick, so a condition that has
-- just lapsed can be told from one that was never live.
local ConditionalLive = {};

local sets = {
	['DualWield_Priority'] = {
        Main = {'Darksteel Pick +1', 'Mythril Pick +1', 'Cmb.Cst. Axe', 'Tomahawk'},
        Sub = {'Darksteel Pick +1', 'Mythril Pick +1', 'Barbaroi Axe', 'Tomahawk'},
	},
	['Scythe_Priority'] = {
        Main = {'Darksteel Pick +1'},
        Sub = {'Darksteel Pick +1'},
	},
	['Axe_Priority'] = {
        Main = {'Darksteel Pick +1', 'Barbaroi Axe'},
        Sub = {'darksteel buckler', 'Turtle Shield +1'},
	},
	-- Rune axes, wielded as a pair while the rune mode is on under a ninja
	-- subjob. Gaudy Harness gives 5 HP regen per axe held, which is the whole
	-- point of the mode; the picks hit harder, so this is a trade the player
	-- asks for rather than one the profile makes on its own. Both entries are
	-- listed in both slots: the bag scan claims an item once, so owning one of
	-- each wields both and owning two of one wields the pair.
	['RuneAxe_Priority'] = {
        Main = {'Rune Chopper', 'Rune Axe'},
        Sub = {'Rune Chopper', 'Rune Axe'},
	},
    -- Melee. Multipliers first -- haste, then double and triple attack -- then
    -- flat attack, then STR, then accuracy and the rest. Multipliers lead
    -- because they always did: Skadi's Visor, Brutal Earring and Ninurta's Sash
    -- headed their slots here long before the comment above them said attack
    -- came first.
    --
    -- Conditional stats do not count, the rule from ecad9f2. A latent, an
    -- enchantment, a set bonus, a stat that only applies inside one activity
    -- (Beta Earring's haste is Salvage-only, Storm Loop's +10 attack is
    -- Assault-only) and anything gated on the moon or the time of day are all
    -- ignored, so those pieces rank on their base stats or not at all.
    --
    -- Where two pieces tie, the one usable at the lower level leads: identical
    -- stats, fewer levels to wait. Scored from tools/wikidata/items.json; the
    -- names are the game's short names, which is what a bag scan matches.
    ['Tp_Priority'] = {
        Head  = { 'Askar Zucchetto', 'Skadi\'s Visor', 'Panther Mask +1',
             'Patroclus\'s Helm', 'Panther Mask', 'Brigand\'s Mask', 'Breeder Mask',
             'Walahra Turban', 'Ogre Mask +1', 'Ogre Mask', 'Adaman Celata',
             'Valkyrie\'s Mask', 'Aurum Armet', 'Celata', 'Celata +1', 'Akinji Khud',
             'Super Ribbon', 'Shock Mask', 'Alumine Salade', 'Luisant Salade',
             'Freya\'s Mask', 'Fed. Headgear', 'Win. Headgear', 'Freyr\'s Mask',
             'Emperor Hairpin', 'Shepherd\'s Bonnet', 'Njord\'s Mask' },
        Neck  = { 'Dream Collar', 'Orochi Nodowa +1', 'Storm Gorget', 'Orochi Nodowa',
             'Grand T.K. Collar', 'Tiger Stole', 'Ryl.Grd. Collar', 'Ajase Beads',
             'R.K. Army Collar', 'Justice Torque', 'Chivalrous Chain', 'Qiqirn Collar',
             'Diabolos\'s Torque', 'Sniper\'s Collar', 'Peacock Amulet',
             'Peacock Charm', 'Fang Necklace', 'Spike Necklace' },
        Ear1  = { 'Brutal Earring', 'Merman\'s Earring', 'Assault Earring',
             'Storm Loop', 'Spike Earring', 'Ethereal Earring', 'Tor. Earring +1',
             'Fang Earring', 'Beetle Earring +1', 'Tortoise Earring', 'Bone Earring +1',
             'Beetle Earring', 'Ocl. Earring', 'Triton Earring', 'Minuet Earring',
             'Platinum Earring', 'Gold Earring', 'Gold Earring +1',
             'Mythril Earring +1', 'Reraise Earring', 'Bone Earring', 'Optical Earring' },
        Ear2  = { 'Brutal Earring', 'Merman\'s Earring', 'Assault Earring',
             'Storm Loop', 'Spike Earring', 'Ethereal Earring', 'Tor. Earring +1',
             'Fang Earring', 'Beetle Earring +1', 'Tortoise Earring', 'Bone Earring +1',
             'Beetle Earring', 'Ocl. Earring', 'Triton Earring', 'Minuet Earring',
             'Platinum Earring', 'Gold Earring', 'Gold Earring +1',
             'Mythril Earring +1', 'Reraise Earring', 'Bone Earring', 'Optical Earring' },
        Body  = { 'Askar Korazin', 'Io\'s Mail', 'Byrnie +1', 'Byrnie',
             'Assault Jerkin', 'Adaman Hauberk', 'Aurum Cuirass', 'Haubergeon +1',
             'Hauberk +1', 'Haubergeon', 'Hauberk', 'Ryl.Sqr. Chnml. +2',
             'Ryl.Kgt. Chainmail', 'Alumine Haubert', 'Luisant Haubert',
             'Irn.Msk.Gmbsn. +1', 'Shepherd\'s Doublet', 'Savage Separates',
             'Wonder Kaftan', 'Freyr\'s Jerkin', 'Garrison Tunica', 'Njord\'s Jerkin' },
        Hands = { 'Dusk Gloves +1', 'Dusk Gloves', 'Armada Mufflers', 'Askar Manopolas',
             'Aurum Gauntlets', 'Spiked Fng.Gnt.', 'Tarasque Mitts +1',
             'Barbarian Mittens', 'Skadi\'s Bazubands', 'Adaman Mufflers',
             'Tarasque Mitts', 'Federation Gloves', 'Thick Mufflers',
             'Thick Mufflers +1', 'Tabin Bracers', 'Akinji Bazubands',
             'Jaridah Bazubands', 'Alumine Moufles', 'Luisant Moufles',
             'Ogygos\'s Brc.', 'Freya\'s Gloves', 'Win. Gloves', 'Custom F Gloves',
             'Custom M Gloves', 'Freyr\'s Gloves', 'Bastokan Mittens', 'Kingdom Gloves',
             'Njord\'s Gloves' },
        Ring1 = { 'Fire Ring', 'Mars\'s Ring', 'Gnd.Kgt. Ring', 'Assailant\'s Ring',
             'Ulthalam\'s Ring', 'Cerberus Ring +1', 'Kshama Ring No. 8',
             'Protean Ring', 'Cerberus Ring', 'Tiger Ring', 'Triumph Ring',
             'Triumph Ring +1', 'Bellona\'s Ring', 'Ptr.Prt. Ring', 'Jalzahn\'s Ring',
             'Crossbowman Ring', 'Garnet Ring', 'Malflame Ring', 'Rajas Ring',
             'Bowyer Ring', 'Beetle Ring', 'Fasting Ring', 'Mighty Ring', 'Courage Ring' },
        Ring2 = { 'Fire Ring', 'Mars\'s Ring', 'Gnd.Kgt. Ring', 'Assailant\'s Ring',
             'Ulthalam\'s Ring', 'Cerberus Ring +1', 'Kshama Ring No. 8',
             'Protean Ring', 'Cerberus Ring', 'Tiger Ring', 'Triumph Ring',
             'Triumph Ring +1', 'Bellona\'s Ring', 'Ptr.Prt. Ring', 'Jalzahn\'s Ring',
             'Crossbowman Ring', 'Garnet Ring', 'Malflame Ring', 'Rajas Ring',
             'Bowyer Ring', 'Beetle Ring', 'Fasting Ring', 'Mighty Ring', 'Courage Ring' },
        Back  = { 'Charger Mantle', 'Cerb. Mantle +1', 'Forager\'s Mantle',
             'Amemet Mantle +1', 'Cerberus Mantle', 'Psilos Mantle', 'Amemet Mantle',
             'Behem. Mantle +1', 'Behemoth Mantle', 'Sand Mantle', 'Jaguar Mantle',
             'Commander\'s Cape', 'Ryl. Army Mantle', 'Rep. Army Mantle' },
        Waist = { 'Ninurta\'s Sash', 'Sonic Belt', 'Sonic Belt +1', 'Speed Belt',
             'Swift Belt', 'Quick Belt', 'Swordbelt +1', 'Swordbelt', 'Zeta Sash',
             'Vanguard Belt', 'Master Belt', 'Buccaneer\'s Belt', 'Corsair\'s Belt',
             'Sultan\'s Belt', 'Fire Belt', 'Potent Belt', 'R.K. Belt +1',
             'R.K. Belt +2', 'Acrobat\'s Belt', 'Barbarian\'s Belt', 'Brave belt' },
        Legs  = { 'Byakko\'s Haidate', 'Barb. Zerehs', 'Skadi\'s Chausses',
             'Armada Breeches', 'Adaman Breeches', 'Hct. Subligar +1',
             'Hecatomb Subligar', 'Armadillo Cuisses', 'Dusk Trousers +1',
             'Dusk Trousers', 'Republic Cuisses', 'Thick Breeches +1', 'Aurum Cuisses',
             'Thick Breeches', 'Feral Trousers', 'Ryl.Kgt. Breeches', 'Akinji Salvars',
             'Jaridah Salvars', 'Alumine Brayettes', 'Luisant Brayettes',
             'Ryl.Sqr. Brch. +1', 'Freya\'s Trousers', 'Bastokan Cuisses',
             'Freyr\'s Trousers', 'Bastokan Subligar', 'Republic Subligar',
             'Njord\'s Trousers' },
        Feet  = { 'Dusk Ledelsens +1', 'Aurum Sabatons', 'Dusk Ledelsens',
             'Armada Sollerets', 'Adaman Sollerets', 'Ogre Ledelsens +1',
             'Ogre Ledelsens', 'Federation Gaiters', 'Stout Gamashes',
             'Brave\'s Gamashes', 'Rutter Sabatons', 'Khimaira Gamash.',
             'Thick Sollerets', 'Thick Sollerets +1', 'Abtal Boots', 'Sipahi Boots',
             'Storm Gambieras', 'Alumine Sollerets', 'Luisant Sollerets',
             'Freya\'s Ledelsens', 'Win. Gaiters', 'Savage Gaiters', 'Wonder Clomps',
             'Shepherd\'s Boots', 'Njord\'s Ledelsens', 'Bounding Boots',
             'Leaping Boots' },
    },
    -- Charm. The unrestricted Charm bonus first, then CHR, then gear that
    -- improves Tame. Charm +N is the charm success stat and CHR contributes far
    -- less, so the artifact gear leads nearly every slot.
    --
    -- A charm bonus that only applies against one family is a conditional stat
    -- by the same rule as above -- the Bison, Brave's, Stout and Khimaira line
    -- all read "Vs. <family>: Charm +N" -- so those pieces rank on their CHR
    -- alone. Same source and tie-break as the melee ladder.
    ['Charm_Priority'] = {
        Main  = { 'Apollo\'s Staff', 'Light Staff' },
        Head  = { 'Mst. Helm +1', 'Monster Helm', 'Beast Helm', 'Bst. Helm +1',
             'Maat\'s Cap', 'Panther Mask +1', 'Ogre Mask +1', 'Panther Mask',
             'Noble\'s Ribbon', 'Merman\'s Cap', 'Ogre Mask', 'Entrancing Ribbon',
             'Coral Cap', 'Opo-opo Crown', 'Super Ribbon', 'Jester\'s Headband',
             'Jgl. Headband', 'Rain Hat', 'Alluring Headband', 'Trump Crown',
             'Garrison Sallet' },
        Neck  = { 'Temp. Torque', 'Bird Whistle', 'Star Necklace', 'Beast Whistle',
             'Torque +1', 'Stoneskin Torque', 'Torque', 'Oscar Scarf',
             'Flower Necklace', 'Dog Collar' },
        Ear1  = { 'Epsilon Earring', 'Melody Earring +1', 'Beastly Earring',
             'Delta Earring', 'Heims Earring', 'Melody Earring' },
        Ear2  = { 'Epsilon Earring', 'Melody Earring +1', 'Beastly Earring',
             'Delta Earring', 'Heims Earring', 'Melody Earring' },
        Body  = { 'Mst. Jackcoat +1', 'Monster Jackcoat', 'Bst. Jackcoat +1',
             'Beast Jackcoat', 'Kirin\'s Osode', 'Skadi\'s Cuirie', 'Brave\'s Jacket',
             'Stout Jacket', 'Bison Jacket', 'Khimaira Jacket', 'Gaudy Harness',
             'Byrnie', 'Byrnie +1', 'Black Cotehardie', 'Flora Cotehardie',
             'Brigandine +1', 'Argent Coat', 'Ceremonial Dress', 'Freya\'s Jerkin',
             'Fed. Doublet', 'Win. Doublet', 'Freyr\'s Jerkin', 'Garrison Tunica' },
        Hands = { 'Monster Gloves', 'Mst. Gloves +1', 'Bst. Gloves +1', 'Beast Gloves',
             'Trainer\'s Gloves', 'Trainer\'s Wrist.', 'Marine F Gloves',
             'Marine M Gloves' },
        Ring1 = { 'Heavens Ring', 'Heavens Ring +1', 'Light Ring', 'Balrahn\'s Ring',
             'Allure Ring', 'Allure Ring +1', 'Angel\'s Ring', 'Loyalty Ring',
             'Loyalty Ring +1', 'Kshama Ring No. 6', 'Moon Ring', 'Hope Ring',
             'Dark Ring', 'Vilma\'s Ring', 'Maldust Ring', 'Opal Ring' },
        Ring2 = { 'Heavens Ring', 'Heavens Ring +1', 'Light Ring', 'Balrahn\'s Ring',
             'Allure Ring', 'Allure Ring +1', 'Angel\'s Ring', 'Loyalty Ring',
             'Loyalty Ring +1', 'Kshama Ring No. 6', 'Moon Ring', 'Hope Ring',
             'Dark Ring', 'Vilma\'s Ring', 'Maldust Ring', 'Opal Ring' },
        Waist = { 'Corsette +1', 'Monster Belt', 'Corsette', 'Kaiser Belt',
             'Czar\'s Belt', 'Koenigs Belt', 'Maharaja\'s Belt', 'Pendragon\'s Belt',
             'Sultan\'s Belt', 'Desert Stone', 'Ryl.Kgt. Belt', 'R.K. Belt +1',
             'R.K. Belt +2' },
        Legs  = { 'Bst. Trousers +1', 'Beast Trousers', 'Monster Trousers',
             'Mst. Trousers +1', 'Cln. Subligar +1', 'Clown\'s Subligar',
             'Dst. Codpiece', 'Luna Subligar', 'Elder\'s Braguette', 'Platino Hose',
             'Custom Pants', 'Custom Slacks', 'Bison Kecks', 'Coral Subligar',
             'Merman\'s Subligar', 'Ceremonial Hose' },
        Feet  = { 'Monster Gaiters', 'Mst. Gaiters +1', 'Bst. Gaiters +1',
             'Beast Gaiters', 'Volunteer\'s Nails', 'Dance Shoes +1', 'Heroic Boots +1',
             'Spagyric Nails', 'Dance Shoes', 'Heroic Boots', 'Savage Gaiters',
             'Ceremonial Boots', 'Marine F Boots', 'Marine M Boots' },
    },
    -- Conditional gear, worn over whatever else is on while its condition
    -- holds. Gaudy Harness is the only piece so far, and it is worn for a
    -- different reason under each subjob: its latent gives refresh while MP is
    -- below 49 points, and it gives 5 HP regen per Rune Axe wielded. See
    -- Conditionals above for which condition claims it when.
    ['Gaudy_Priority'] = {
        Body  = { 'Gaudy Harness' },
    },
    -- Call Beast snapshots the pet's bonuses at call time, so every
    -- Pet: stat carried here sticks for the life of the pet. The broth
    -- is equipped after this, so it keeps the ammo slot.
    ['CallBeast_Priority'] = {
        Head  = { 'Beast Helm +1', 'Beast Helm', 'Buffalo Helm', 'Shepherd\'s Bonnet' },
        Ear1  = { 'Beastly Earring' },
        Ear2  = { 'Beastly Earring' },
        Body  = { 'Shepherd\'s Doublet' },
        Hands = { 'Monster Gloves', 'Mst. Gloves +1', 'Beast Bazubands',
             'Shepherd\'s Bracers' },
        Ring1 = { 'Spirited Ring' },
        Ring2 = { 'Spirited Ring' },
        Legs  = { 'Askar Dirs', 'Shepherd\'s Hose' },
        Feet  = { 'Shepherd\'s Boots' },
    },
	['Reward_Priority'] = {
        Ammo = {'Pet Fd. Epsilon', 'Pet Food Delta', 'Pet Fd. Gamma', 'Pet Food Beta'},
        Body = 'Beast Jackcoat',
        Hands = 'Beast Gloves',
        Feet = 'Beast Gaiters',
    },
    ['Jugs'] = {
        ['tiger']     = {Ammo = 'Meat Broth'},
        ['rabbit']    = {Ammo = 'Carrot Broth'},
        ['sheep']     = {Ammo = 'Herbal Broth'},
        ['bill']      = {Ammo = 'Humus'},
        ['flytrap']   = {Ammo = 'Grasshopper Broth'},
        ['lizard']    = {Ammo = 'Carrion Broth'},
        ['fly']       = {Ammo = 'Bug Broth'},
        ['eft']       = {Ammo = 'Mole Broth'},
        ['beetle']    = {Ammo = 'Tree Sap'},
        ['antlion']   = {Ammo = 'Antica Broth'},
        ['crab']      = {Ammo = 'Fish Broth'},
        ['mite']      = {Ammo = 'Blood Broth'},
        ['funguar']   = {Ammo = 'Seedbed Soil'},
        ['homunculus'] = {Ammo = 'Alchemist Water'},
        ['sabotender'] = {Ammo = 'Sun Water'},
    },
    ['Jugs_HQ'] = {
        ['sheep']     = {Ammo = 'S. Herbal Broth'},
        ['rabbit']    = {Ammo = 'Famous Carrot Broth'},
        ['tiger']     = {Ammo = 'Warm Meat Broth'},
        ['bill']      = {Ammo = 'Rich Humus'},
        ['flytrap']   = {Ammo = 'Noisy Grasshopper Broth'},
        ['lizard']    = {Ammo = 'Cold Carrion Broth'},
        ['fly']       = {Ammo = 'Quadav Bug Broth'},
        ['eft']       = {Ammo = 'Lively Mole Broth'},
        ['beetle']    = {Ammo = 'Scarlet Sap'},
        ['antlion']   = {Ammo = 'Fragrant Antica Broth'},
        ['crab']      = {Ammo = 'Fish Oil Broth'},
        ['mite']      = {Ammo = 'Clear Blood Broth'},
    },
};
profile.Sets = sets;


profile.Packer = {
};

-- The slots a lapsed conditional gives back, taken from the melee set: it is
-- the set that owns the body slot while engaged, and the only body the profile
-- has an opinion about while idle. A slot the melee set has not resolved -- the
-- character carries none of its entries -- is left out, so the release equips
-- nothing there rather than stripping the slot bare.
local ReleaseSet = function(slots)
    local release = nil;

    for _, slot in ipairs(slots) do
        local item = sets.Tp[slot];
        if (item ~= nil) then
            release = release or {};
            release[slot] = item;
        end
    end

    return release;
end

-- Apply the conditionals over whatever is already on, and hand back the slots
-- of any that have just gone dormant. Runs every tick, idle and engaged alike:
-- refresh is worth most while standing and resting, which is exactly when the
-- rest of the profile equips nothing.
local EquipConditionals = function(player)
    local live = {};
    for index, conditional in ipairs(Conditionals) do
        live[index] = (conditional.When(player) == true);
    end

    -- Every release first, then every live set. Two conditionals can name the
    -- same gear -- Gaudy Harness does, once per subjob -- and a release running
    -- after the equip would strip the piece the other one had just put on.
    for index, conditional in ipairs(Conditionals) do
        if (not live[index]) and (ConditionalLive[index]) then
            local release = ReleaseSet(conditional.Slots);
            if (release ~= nil) then
                gFunc.EquipSet(release);
            end
        end
    end

    for index, conditional in ipairs(Conditionals) do
        if (live[index]) then
            gFunc.EquipSet(profile.Sets[conditional.Set]);
        end

        ConditionalLive[index] = live[index];
    end
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /bst /lac fwd');

    AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. Settings.MacroBook);

    -- Display Default Jug Setting
    if (Settings.UseHQJugs) then
        gFunc.Message("Jug: hq " .. Settings.Jug);
    else
        gFunc.Message("Jug: " .. Settings.Jug);
    end

    -- Lock appearance a few seconds after loading
    common.RequestLockStyle(1);
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /bst');
end

profile.HandleCommand = function(args)
    -- Handle utility settings
    utility.SetOptions(args[1], Settings.MacroBook);

    -- Handle common settings
    common.SetMeleeOptions(args[1]);

    -- Rescan the bags and re-resolve every gear set
    if (args[1] == 'gear') then
        common.EvaluateGear(profile.Sets, Settings.CurrentLevel, true);
        common.ReportGear(profile.Sets, Settings.CurrentLevel);
    end

    if (args[1] == 'jug') then
        setJug(args[2], args[3]);
    end

    -- /bst rune   wield the rune axes, and the body that pairs with them
    if (args[1] == 'rune') then
        Settings.UseRuneAxes = not Settings.UseRuneAxes;
        gFunc.Message('rune axes: ' .. tostring(Settings.UseRuneAxes));
    end
end


profile.HandleDefault = function()
	local player = gData.GetPlayer();
	evalLevel();
	
	if (player.Status == 'Engaged') then
        -- Default load common melee setup
        common.EquipMelee();

        gFunc.EquipSet(sets.Tp);

        -- Handle Weapons. The rune axes have to be claimed here rather than
        -- left in the player's hands: this runs every tick, so anything swapped
        -- in by hand is gone before the next swing.
        if (player.SubJob == 'NIN') then
            if (Settings.UseRuneAxes) then
                gFunc.EquipSet(sets.RuneAxe);
            else
                gFunc.EquipSet(sets.DualWield);
            end
        else
            gFunc.EquipSet(sets.Axe);
        end
	end

    -- Over the melee set, so a live condition wins its slot, and before the
    -- utility toggles, which keeps today's precedence: a toggle that claims the
    -- body still wins because it is applied last.
    EquipConditionals(player);

    utility.EquipSet();
end

profile.HandleAbility = function()
	local action = gData.GetAction();
	
	if (action.Name == 'Charm') then
		gFunc.EquipSet(sets.Charm);
	end
	if (action.Name == 'Reward') then
		gFunc.EquipSet(sets.Reward);
	end
    if (action.Name == 'Call Beast') then
        -- The pet snapshots these bonuses when it is called, so they matter
        -- at call time and not afterwards.
        gFunc.EquipSet(sets.CallBeast);

        local jug = nil;
        if (Settings.UseHQJugs) then
            jug = sets.Jugs_HQ[Settings.Jug];
        end

        -- Fall back to the normal broth: calling with an empty ammo slot
        -- fails outright, which is worse than calling with the lesser jug.
        if (jug == nil) then
            jug = sets.Jugs[Settings.Jug];
        end

        gFunc.EquipSet(jug);
    end
end

profile.HandleItem = function()
	local action = gData.GetAction();
	
	utility.CheckItem(action.Name);
end

profile.HandlePrecast = function()
end

profile.HandleMidcast = function()
	local action = gData.GetAction();
	
	utility.CheckCast(action.Name);
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

-- Helper functions

evalLevel = function()
	-- Resolve sets against level and what is actually in the bags
    local level = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    Settings.CurrentLevel = level;
    common.EvaluateGear(profile.Sets, level);

    -- Evaluate Level Sync for common equipsets
    common.EvalLevel(level);
end

setJug = function(arg1, arg2)
    -- /bst jug <pet>      normal broth
    -- /bst jug hq <pet>   high quality broth
    -- /bst jug hq         switch the current pet to its high quality broth
    local wantHQ = (arg1 == 'hq');
    local pet = arg1;
    if (wantHQ) then
        pet = arg2;
    end

    if (pet ~= nil) then
        if (sets.Jugs[pet] == nil) then
            gFunc.Message('No jug pet called ' .. tostring(pet));
            return;
        end

        Settings.Jug = pet;
    end

    Settings.UseHQJugs = wantHQ;

    -- Not every pet has a high quality broth. Say so and fall back, rather
    -- than leaving a setting that equips nothing when Call Beast is used.
    if (Settings.UseHQJugs) and (sets.Jugs_HQ[Settings.Jug] == nil) then
        gFunc.Message('No hq broth for ' .. Settings.Jug .. ', using the normal one');
        Settings.UseHQJugs = false;
    end

    -- Display Default Jug Setting
    if (Settings.UseHQJugs) then
        gFunc.Message("Jug: hq " .. Settings.Jug);
    else
        gFunc.Message("Jug: " .. Settings.Jug);
    end
end

return profile;
