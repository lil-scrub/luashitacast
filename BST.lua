local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');

local Settings = {
    UseHQJugs = true,
    Jug = "sheep",
    MacroBook = '4'
}

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
    -- Melee. Attack first, then STR, then everything else.
    ['Tp_Priority'] = {
        Head  = { 'Skadi\'s Visor', 'Brigand\'s Mask', 'Aurum Armet', 'Celata', 'Celata +1',
             'Patroclus\'s Helm', 'Akinji Khud', 'Super Ribbon', 'Shock Mask', 'Alumine Salade',
             'Luisant Salade', 'Valkyrie\'s Mask', 'Freya\'s Mask', 'Federation Headgear',
             'Windurstian Headgear', 'Freyr\'s Mask', 'Emperor Hairpin', 'Shepherd\'s Bonnet',
             'Njord\'s Mask' },
        Neck  = { 'Dream Collar', 'Qiqirn Collar', 'Diabolos\'s Torque', 'Sniper\'s Collar',
             'Grand Temple Knight\'s Collar', 'Chivalrous Chain', 'Royal Guard\'s Collar',
             'Royal Knight Army Collar', 'Storm Gorget', 'Peacock Amulet', 'Peacock Charm',
             'Ajase Beads', 'Tiger Stole', 'Fang Necklace', 'Spike Necklace' },
        Ear1  = { 'Brutal Earring', 'Orichalcum Earring', 'Triton Earring', 'Merman\'s Earring',
             'Minuet Earring', 'Platinum Earring', 'Assault Earring', 'Fang Earring',
             'Spike Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Mythril Earring +1', 'Reraise Earring', 'Beetle Earring', 'Bone Earring',
             'Bone Earring +1', 'Optical Earring' },
        Ear2  = { 'Brutal Earring', 'Orichalcum Earring', 'Triton Earring', 'Merman\'s Earring',
             'Minuet Earring', 'Platinum Earring', 'Assault Earring', 'Fang Earring',
             'Spike Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Mythril Earring +1', 'Reraise Earring', 'Beetle Earring', 'Bone Earring',
             'Bone Earring +1', 'Optical Earring' },
        Body  = { 'Askar Korazin', 'Io\'s Mail', 'Adaman Hauberk', 'Hauberk', 'Hauberk +1',
             'Byrnie', 'Haubergeon', 'Haubergeon +1', 'Royal Knight\'s Chainmail',
             'Alumine Haubert', 'Luisant Haubert', 'Iron Musketeer\'s Gambison +1',
             'Shepherd\'s Doublet', 'Savage Separates', 'Wonder Kaftan', 'Freyr\'s Jerkin',
             'Garrison Tunica', 'Njord\'s Jerkin' },
        Hands = { 'Skadi\'s Bazubands', 'Aurum Gauntlets', 'Dusk Gloves', 'Thick Mufflers',
             'Thick Mufflers +1', 'Tabin Bracers', 'Akinji Bazubands', 'Jaridah Bazubands',
             'Spiked Finger Gauntlets', 'Alumine Moufles', 'Luisant Moufles',
             'Ogygos\'s Bracelets', 'Freya\'s Gloves', 'Federation Gloves',
             'Windurstian Gloves', 'Custom F Gloves', 'Custom M Gloves', 'Freyr\'s Gloves',
             'Bastokan Mittens', 'Kingdom Gloves', 'Njord\'s Gloves' },
        Ring1 = { 'Bellona\'s Ring', 'Mars\'s Ring', 'Cerberus Ring', 'Fire Ring',
             'Grand Knight\'s Ring', 'Patriarch Protector\'s Ring', 'Tiger Ring',
             'Jalzahn\'s Ring', 'Ulthalam\'s Ring', 'Kshama Ring No. 8', 'Assailant\'s Ring',
             'Crossbowman\'s Ring', 'Garnet Ring', 'Malflame Ring', 'Rajas Ring', 'Bowyer Ring',
             'Beetle Ring', 'Protean Ring', 'Fasting Ring', 'Mighty Ring', 'Courage Ring' },
        Ring2 = { 'Bellona\'s Ring', 'Mars\'s Ring', 'Cerberus Ring', 'Fire Ring',
             'Grand Knight\'s Ring', 'Patriarch Protector\'s Ring', 'Tiger Ring',
             'Jalzahn\'s Ring', 'Ulthalam\'s Ring', 'Kshama Ring No. 8', 'Assailant\'s Ring',
             'Crossbowman\'s Ring', 'Garnet Ring', 'Malflame Ring', 'Rajas Ring', 'Bowyer Ring',
             'Beetle Ring', 'Protean Ring', 'Fasting Ring', 'Mighty Ring', 'Courage Ring' },
        Back  = { 'Cerberus Mantle', 'Cerberus Mantle +1', 'Forager\'s Mantle', 'Psilos Mantle',
             'Amemet Mantle', 'Amemet Mantle +1', 'Royal Army Mantle', 'Republican Army Mantle',
             'Jaguar Mantle' },
        Waist = { 'Ninurta\'s Sash', 'Buccaneer\'s Belt', 'Corsair\'s Belt', 'Sultan\'s Belt',
             'Fire Belt', 'Potent Belt', 'Royal Knight\'s Belt +1', 'Royal Knight\'s Belt +2',
             'Swift Belt', 'Vanguard Belt', 'Swordbelt', 'Swordbelt +1', 'Acrobat\'s Belt',
             'Barbarian\'s Belt', 'Brave belt' },
        Legs  = { 'Skadi\'s Chausses', 'Adaman Breeches', 'Aurum Cuisses', 'Thick Breeches',
             'Thick Breeches +1', 'Feral Trousers', 'Royal Knight\'s Breeches',
             'Akinji Salvars', 'Jaridah Salvars', 'Alumine Brayettes', 'Luisant Brayettes',
             'Royal Squire\'s Breeches +1', 'Freya\'s Trousers', 'Bastokan Cuisses',
             'Republic Cuisses', 'Freyr\'s Trousers', 'Bastokan Subligar', 'Republic Subligar',
             'Njord\'s Trousers' },
        Feet  = { 'Adaman Sollerets', 'Aurum Sabatons', 'Dusk Ledelsens', 'Thick Sollerets',
             'Thick Sollerets +1', 'Rutter Sabatons', 'Abtal Boots', 'Sipahi Boots',
             'Storm Gambieras', 'Alumine Sollerets', 'Luisant Sollerets', 'Freya\'s Ledelsens',
             'Federation Gaiters', 'Windurstian Gaiters', 'Savage Gaiters', 'Wonder Clomps',
             'Shepherd\'s Boots', 'Njord\'s Ledelsens', 'Bounding Boots', 'Leaping Boots' },
    },
    -- Charm. CHR, plus gear that enhances charm outright.
    ['Charm_Priority'] = {
        Main  = { 'Apollo\'s Staff', 'Light Staff' },
        Head  = { 'Monster Helm +1', 'Beast Helm +1', 'Monster Helm', 'Coral Cap',
             'Merman\'s Cap', 'Opo-opo Crown', 'Beast Helm', 'Super Ribbon',
             'Jester\'s Headband', 'Juggler\'s Headband', 'Rain Hat', 'Alluring Headband',
             'Trump Crown', 'Garrison Sallet', 'Noble\'s Ribbon', 'Entrancing Ribbon' },
        Neck  = { 'Temperance Torque', 'Oscar Scarf', 'Star Necklace', 'Stoneskin Torque',
             'Torque', 'Flower Necklace', 'Beast Whistle', 'Bird Whistle', 'Dog Collar' },
        Ear1  = { 'Delta Earring', 'Epsilon Earring', 'Beastly Earring', 'Melody Earring',
             'Melody Earring +1', 'Heims Earring' },
        Ear2  = { 'Delta Earring', 'Epsilon Earring', 'Beastly Earring', 'Melody Earring',
             'Melody Earring +1', 'Heims Earring' },
        Body  = { 'Brave\'s Jacket', 'Khimaira Jacket', 'Stout Jacket', 'Byrnie', 'Byrnie +1',
             'Black Cotehardie', 'Flora Cotehardie', 'Beast Jackcoat', 'Brigandine +1',
             'Argent Coat', 'Ceremonial Dress', 'Freya\'s Jerkin', 'Federation Doublet',
             'Windurstian Doublet', 'Freyr\'s Jerkin', 'Garrison Tunica' },
        Hands = { 'Monster Gloves', 'Monster Gloves +1', 'Beast Gloves +1', 'Marine F Gloves',
             'Marine M Gloves', 'Trainer\'s Wristbands' },
        Ring1 = { 'Dark Ring', 'Light Ring', 'Angel\'s Ring', 'Allure Ring', 'Allure Ring +1',
             'Moon Ring', 'Kshama Ring No. 6', 'Vilma\'s Ring', 'Loyalty Ring',
             'Loyalty Ring +1', 'Maldust Ring', 'Hope Ring', 'Opal Ring' },
        Ring2 = { 'Dark Ring', 'Light Ring', 'Angel\'s Ring', 'Allure Ring', 'Allure Ring +1',
             'Moon Ring', 'Kshama Ring No. 6', 'Vilma\'s Ring', 'Loyalty Ring',
             'Loyalty Ring +1', 'Maldust Ring', 'Hope Ring', 'Opal Ring' },
        Waist = { 'Monster Belt', 'Czar\'s Belt', 'Kaiser Belt', 'Koenigs Belt',
             'Royal Knight\'s Belt +1', 'Royal Knight\'s Belt +2', 'Desert Stone', 'Corsette',
             'Corsette +1' },
        Legs  = { 'Monster Trousers +1', 'Monster Trousers', 'Bison Kecks', 'Coral Subligar',
             'Merman\'s Subligar', 'Luna Subligar', 'Darksteel Codpiece', 'Ceremonial Hose',
             'Platino Hose', 'Custom Pants', 'Custom Slacks', 'Elder\'s Braguette' },
        Feet  = { 'Monster Gaiters +1', 'Beast Gaiters +1', 'Monster Gaiters', 'Marine F Boots',
             'Marine M Boots', 'Beast Gaiters', 'Ceremonial Boots', 'Savage Gaiters' },
    },
    -- Call Beast snapshots the pet's bonuses at call time, so every
    -- Pet: stat carried here sticks for the life of the pet. The broth
    -- is equipped after this, so it keeps the ammo slot.
    ['CallBeast_Priority'] = {
        Head  = { 'Beast Helm +1', 'Beast Helm', 'Buffalo Helm', 'Shepherd\'s Bonnet' },
        Ear1  = { 'Beastly Earring' },
        Ear2  = { 'Beastly Earring' },
        Body  = { 'Shepherd\'s Doublet' },
        Hands = { 'Monster Gloves', 'Monster Gloves +1', 'Beast Bazubands',
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
end


profile.HandleDefault = function()
	local player = gData.GetPlayer();
	evalLevel();
	
	if (player.Status == 'Engaged') then
        -- Default load common melee setup
        common.EquipMelee();

        gFunc.EquipSet(sets.Tp);

        -- Handle Weapons
        if (player.SubJob == 'NIN') then
            gFunc.EquipSet(sets.DualWield);
        else
            gFunc.EquipSet(sets.Axe);
        end
	end

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
