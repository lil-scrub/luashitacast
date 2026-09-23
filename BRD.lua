local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
local staves = gFunc.LoadFile('./staves.lua');

local Settings = {
	CurrentLevel = 0,
	HPSwapped = false,
	MacroBook = '2',
	IdleMode = 1,
};

-- Idle modes. Each entry is a full set the bard stands in, switched to with
-- /brd <Cmd>. Exactly one is active at a time and they are never worn
-- together, so each resolves against the bags independently and two modes
-- naming the same piece cannot fight over it.
--
-- Set   the set worn while the mode is active, covering every slot.
-- WHM   optional, a small set layered over Set under a white mage subjob.
--       Omit it when the subjob changes nothing for the mode.
-- Label what the mode is called when the profile reports it.
--
-- Adding a mode is one row here plus its gear set. Array order is listing
-- order; entry one is active when the profile loads.
local IdleModes = {
	{ Cmd = 'mit', Set = 'Idle_Mit', WHM = 'Idle_Mit_WHM',
	  Label = 'damage mitigation' },
	{ Cmd = 'enmity', Set = 'Idle_Enmity',
	  Label = 'Enmity-' },
};

-- The shared utility toggles, in the order utility.SetOptions tests them. They
-- are consumed before the profile ever sees the word, so they cannot live in
-- the mode registry, and the help listing takes their descriptions from here.
-- Keep this in step with utility.lua: a toggle added there stays invisible to
-- the listing until it is added here too.
local UtilityCommands = {
	{ Cmd = 'exp',   Label = 'experience ring' },
	{ Cmd = 'warp',  Label = 'warp cudgel' },
	{ Cmd = 'sneak', Label = 'sneak feet' },
	{ Cmd = 'invis', Label = 'invisible hands' },
	{ Cmd = 'clam',  Label = 'clamming set' },
	{ Cmd = 'fish',  Label = 'fishing set and macro book' },
};

-- Command words that never reach a mode. The utility options are consumed by
-- utility.SetOptions and the accuracy option by common.SetMeleeOptions, both
-- of which run before the mode lookup; gear and modes are the profile's own.
-- A mode registered under one of these would be shadowed and never fire, so
-- the collision is reported at load rather than left to be discovered in game.
local ReservedCommands = {
	'gear', 'modes', 'help', 'acc', 'exp', 'warp', 'sneak', 'invis', 'clam',
	'fish',
};

sets = {
    -- The damage mitigation idle mode. Worn whenever the bard is not casting
    -- -- standing, resting, pulling and meleeing alike -- so it is the standing
    -- set, not pulling gear specifically.
    --
    -- Ordered magic first. A bard holds little hate, so what actually lands is
    -- mostly spells and area effects rather than melee swings, and raw defence
    -- does nothing about those. Per slot: the most magic damage removed leads,
    -- then gear that removes damage from both schools, then Magic Def. Bonus,
    -- then physical damage taken, then defence. Gear that adds enmity stays
    -- excluded outright -- a bard wants no extra hate.
    --
    -- Damage taken -% counts as magic mitigation because it is: Defending Ring
    -- takes 10% off both schools, which beats Minerva's Ring at magic -8% while
    -- also not handing back 8% physical, so it keeps the ring slot.
    --
    -- Conditional stats are ignored, the rule from ecad9f2. Horror Head reads
    -- Enmity -50 but only on a full moon, on Darksday, at night, and Resentment
    -- Cape's magic -5% only applies outside its nation's control. Scored naively
    -- both would lead their slots.
    --
    -- Main is the one slot with no magic answer at all: no staff on the server
    -- carries magic damage taken, so Terra's Staff keeps it on physical -20%,
    -- which is still free value against the lesser threat.
    ['Idle_Mit_Priority'] = {
        Main  = { 'Terra\'s Staff', 'Earth Staff' },
        Ammo  = { 'Pebble' },
        Head  = { 'Storm Turban', 'Darksteel Cap +1', 'Darksteel Cap', 'Genbu\'s Kabuto',
             'Hecatomb Cap +1', 'Hecatomb Cap', 'Dusk Mask +1', 'Io\'s helm', 'Dusk Mask',
             'Zenith Crown +1', 'Zenith Crown', 'Carapace Helm +1', 'Scorpion Helm +1',
             'Dartorgor\'s Coif', 'Troll Coif', 'Carapace Helm', 'Magus Keffiyeh',
             'Beak Helm +1', 'Akinji Khud', 'Scorpion Mask +1', 'Beak Helm', 'Jaridah Khud',
             'Scorpion Mask', 'T.M. Hat +2', 'Dino Helm', 'Magi Hat', 'Raptor Helm',
             'Wool Cap +1', 'Carapace Mask +1', 'Wool Cap', 'Carapace Mask', 'Namru\'s Tiara',
             'Corsair\'s Hat +1', 'Cuir Bandana +1', 'Cuir Bandana', 'Mage\'s Hat',
             'Red Cap +1', 'Strong Cap', 'Sinister Mask', 'Velvet Hat', 'Red Cap',
             'Shade Tiara +1', 'Trump Crown', 'Wool Hat +1', 'Shade Tiara', 'Great Headgear',
             'Beetle Mask +1', 'Wool Hat', 'Cotton Headgear', 'Lizard Helm +1',
             'Bone Mask +1', 'Kingdom Bandana', 'Republic Cap', 'Bonze\'s Circlet',
             'Lizard Helm', 'Bone Mask', 'San. Bandana' },
        Neck  = { 'Rho Necklace', 'Wivre Gorget +1', 'Tempered Chain', 'Wivre Gorget',
             'Torama Gorget', 'Coeurl Gorget', 'Torque +1', 'Beak Necklace +1',
             'Auditory Torque', 'Blue Gorget', 'Brisingamen +1', 'Chivalrous Chain',
             'Fortified Chain', 'Stoneskin Torque', 'Torque', 'Beak Necklace',
             'Intellect Torque', 'Storm Gorget', 'Carapace Gorget', 'Clay Amulet',
             'Stone Gorget', 'Memento Muffler', 'Wolf Gorget +1', 'Checkered Scarf',
             'Promise Badge', 'Qiqirn Collar', 'Brisingamen', 'Agile Gorget',
             'Medieval Collar', 'Wolf Gorget', 'Holy Phial', 'Hemp Gorget +1', 'Green Gorget',
             'Van Pendant', 'Paisley Scarf', 'Orochi Nodowa +1', 'M. No.17\'s Locket',
             'Jagd Gorget', 'Mohbwa Scarf +1', 'Tiger Stole', 'Hemp Gorget', 'Beetle Gorget',
             'Black Neckerchief', 'Feather Collar +1', 'Leather Gorget +1', 'Green Scarf',
             'Orochi Nodowa', 'Dog Collar', 'Feather Collar', 'Justice Badge',
             'Leather Gorget', 'Shield Pendant', 'Windurstian Scarf', 'Bloodbead Amulet',
             'Grandiose Chain' },
        Ear1  = { 'Merman\'s Earring', 'Coral Earring', 'Intruder Earring', 'Bitter Earring',
             'Cassie Earring', 'Hvn. Earring +1', 'Allure Earring +1', 'Lyt. Earring +1',
             'Hope Earring +1', 'Chaotic Earring', 'Haten Earring', 'Priest\'s Earring',
             'Adroit Earring +1', 'Cmn. Earring +1', 'Cel. Earring +1', 'Genius Earring +1',
             'Grace Earring +1', 'Mana Earring +1', 'Ser. Earring +1', 'Victory Earring +1',
             'Alc. Earring +1', 'Aura Earring +1', 'Deft Earring +1', 'Puis. Earring +1',
             'Solace Earring +1', 'Verve Earring +1', 'Wisdom Earring +1', 'Mecurial Earring',
             'Blc. Earring +1', 'Crg. Earring +1', 'Energy Earring +1', 'Kldg. Earring +1',
             'Optical Earring', 'Reflex Earring +1', 'Morukaka Earring', 'Stoic Earring',
             'Ethereal Earring', 'Insomnia Earring', 'Ryakho\'s Earring', 'Shield Earring' },
        Ear2  = { 'Merman\'s Earring', 'Coral Earring', 'Intruder Earring', 'Bitter Earring',
             'Cassie Earring', 'Hvn. Earring +1', 'Allure Earring +1', 'Lyt. Earring +1',
             'Hope Earring +1', 'Chaotic Earring', 'Haten Earring', 'Priest\'s Earring',
             'Adroit Earring +1', 'Cmn. Earring +1', 'Cel. Earring +1', 'Genius Earring +1',
             'Grace Earring +1', 'Mana Earring +1', 'Ser. Earring +1', 'Victory Earring +1',
             'Alc. Earring +1', 'Aura Earring +1', 'Deft Earring +1', 'Puis. Earring +1',
             'Solace Earring +1', 'Verve Earring +1', 'Wisdom Earring +1', 'Mecurial Earring',
             'Blc. Earring +1', 'Crg. Earring +1', 'Energy Earring +1', 'Kldg. Earring +1',
             'Optical Earring', 'Reflex Earring +1', 'Morukaka Earring', 'Stoic Earring',
             'Ethereal Earring', 'Insomnia Earring', 'Ryakho\'s Earring', 'Shield Earring' },
        Body  = { 'Valkyrie\'s Coat', 'Shadow Coat', 'Dst. Harness +1', 'Darksteel Harness',
             'Kirin\'s Osode', 'Hct. Harness +1', 'Dusk Jerkin', 'Hecatomb Harness',
             'Vishnu\'s Vest', 'Narasimha\'s Vest', 'Scp. Brstplate +1', 'Dalmatica +1',
             'Chl. Jstcorps +1', 'Silk Cloak +1', 'Scp. Breastplate', 'Cpc. Brstplate +1',
             'Cpc. Breastplate', 'Tundra Jerkin', 'Beak Jerkin +1', 'Shaman\'s Cloak',
             'Akinji Peti', 'Corsair\'s Frac', 'Beak Jerkin', 'R.K. Cloak +2', 'Jaridah Peti',
             'Scp. Harness +1', 'Dino Jerkin', 'Raptor Jerkin', 'C.C. Cloak +2',
             'Brigandine +1', 'C.C. Cloak +1', 'Brigandine', 'Wool Gambison +1',
             'Cpc. Harness +1', 'Cuir Bouilli +1', 'Cuir Bouilli', 'Cloak +1', 'Cloak',
             'Mana Cloak', 'Mage\'s Robe', 'Strong Harness', 'Velvet Robe', 'Faerie Tunic',
             'Shade Harness +1', 'Wool Robe +1', 'Shade Harness', 'Mage\'s Tunic',
             'Wool Robe', 'Great Doublet', 'Beetle Harness +1', 'Fine Jerkin',
             'Garrison Tunica', 'Lizard Jerkin', 'Bone Harness +1', 'Priest\'s Robe',
             'Bone Harness', 'Healing Harness', 'Kingdom Tunic' },
        Hands = { 'Merman\'s Bangles', 'Coral Bangles', 'Dst. Mittens +1', 'Darksteel Mittens',
             'Prt. Bangles', 'Seiryu\'s Kote', 'Hct. Mittens +1', 'Dusk Gloves +1',
             'Hecatomb Mittens', 'Dusk Gloves', 'Zenith Mitts +1', 'Zenith Mitts',
             'Cpc. Gauntlets +1', 'Magical Mitts', 'Fencing Bracers', 'Cpc. Gauntlets',
             'Pallas\'s Bracelets', 'Light Gauntlets', 'Beak Gloves +1', 'Akinji Bazubands',
             'Enkelados\'s Brc.', 'Scp. Mittens +1', 'Beak Gloves', 'Dino Gloves',
             'Raptor Gloves', 'Ogygos\'s Brc.', 'Wool Bracers +1', 'Turtle Bangles +1',
             'Cpc. Mittens +1', 'Wool Bracers', 'Turtle Bangles', 'Cuir Gloves +1',
             'Rubious Mitts', 'Gigas Bracelets', 'Cuir Gloves', 'Mage\'s Cuffs', 'Bracers +1',
             'Sennight Bangles', 'Iron Mittens +1', 'Shade Mittens +1', 'Wool Cuffs +1',
             'Shade Mittens', 'Great Gloves', 'Beetle Mittens +1', 'Custom F Gloves',
             'Custom M Gloves', 'Wonder Mitts', 'Fine Gloves', 'Kingdom Gloves',
             'Republic Mittens', 'Lizard Gloves', 'Bone Mittens +1', 'San. Gloves',
             'Bastokan Mittens', 'Bone Mittens' },
        Ring1 = { 'Defending Ring', 'Minerva\'s Ring', 'Shadow Ring', 'Unfettered Ring',
             'Gobniu\'s Ring', 'Jelly Ring', 'Mercenary\'s Ring', 'Phalanx Ring',
             'Unyielding Ring', 'Dragon Ring +1', 'Aegis Ring', 'Dragon Ring',
             'Cerberus Ring +1', 'Adroit Ring +1', 'Cmn. Ring +1', 'Hades Ring +1',
             'Heavens Ring +1', 'Gld.Msk. Ring', 'Demon\'s Ring +1', 'Tiger Ring',
             'Allure Ring +1', 'Celerity Ring +1', 'Genius Ring +1', 'Grace Ring +1',
             'Kshama Ring No.4', 'Bloodbead Ring', 'Bomb Ring', 'Demon\'s Ring',
             'Marid Ring +1', 'Earth Ring', 'Marksman\'s Ring', 'Alacrity Ring +1',
             'Aura Ring +1', 'Deft Ring +1', 'Loyalty Ring +1', 'Puissance Ring +1',
             'Solace Ring +1', 'Verve Ring +1', 'Leather Ring +1', 'Safeguard Ring',
             'San d\'Orian Ring', 'Armored Ring', 'Balance Ring +1', 'Courage Ring +1',
             'Energy Ring +1', 'Gold Ring +1', 'Gold Ring', 'Mythril Ring +1', 'Mythril Ring' },
        Ring2 = { 'Defending Ring', 'Minerva\'s Ring', 'Shadow Ring', 'Unfettered Ring',
             'Gobniu\'s Ring', 'Jelly Ring', 'Mercenary\'s Ring', 'Phalanx Ring',
             'Unyielding Ring', 'Dragon Ring +1', 'Aegis Ring', 'Dragon Ring',
             'Cerberus Ring +1', 'Adroit Ring +1', 'Cmn. Ring +1', 'Hades Ring +1',
             'Heavens Ring +1', 'Gld.Msk. Ring', 'Demon\'s Ring +1', 'Tiger Ring',
             'Allure Ring +1', 'Celerity Ring +1', 'Genius Ring +1', 'Grace Ring +1',
             'Kshama Ring No.4', 'Bloodbead Ring', 'Bomb Ring', 'Demon\'s Ring',
             'Marid Ring +1', 'Earth Ring', 'Marksman\'s Ring', 'Alacrity Ring +1',
             'Aura Ring +1', 'Deft Ring +1', 'Loyalty Ring +1', 'Puissance Ring +1',
             'Solace Ring +1', 'Verve Ring +1', 'Leather Ring +1', 'Safeguard Ring',
             'San d\'Orian Ring', 'Armored Ring', 'Balance Ring +1', 'Courage Ring +1',
             'Energy Ring +1', 'Gold Ring +1', 'Gold Ring', 'Mythril Ring +1', 'Mythril Ring' },
        Back  = { 'Hexerei Cape', 'Umbra Cape', 'Cheviot Cape', 'Shadow Mantle',
             'Behem. Mantle +1', 'Behemoth Mantle', 'Marid Mantle +1', 'Empwr. Mantle +1',
             'Marid Mantle', 'Mahatma Cape', 'Black Mantle +1', 'Feral Mantle',
             'Desert Mantle +1', 'Errant Cape', 'Corse Cape', 'Beak Mantle +1',
             'Ryl. Army Mantle', 'Cvl. Mantle +1', 'Lieutenant\'s Cape', 'Enhancing Mantle',
             'Beak Mantle', 'Cvl. Mantle', 'Lightning Mantle', 'Dino Mantle',
             'Rep. Army Mantle', 'Fed. Army Mantle', 'Jester\'s Cape +1', 'Volitional Mantle',
             'Raptor Mantle', 'Bat Cape', 'Aurora Mantle +1', 'Sentinel\'s Mantle',
             'Lucent Cape', 'Aurora Mantle', 'Red Cape +1', 'Ram Mantle', 'Ram Mantle +1',
             'Wolf Mantle +1', 'Tundra Mantle', 'Black Cape +1', 'White Cape +1',
             'Invisible Mantle', 'Wolf Mantle', 'Dhalmel Mantle +1', 'Nomad\'s Mantle +1',
             'Night Cape', 'Variable Mantle', 'Cotton Cape +1', 'Dhalmel Mantle',
             'Lizard Mantle +1', 'Mist Silk Cape', 'Talisman Cape', 'Nomad\'s Mantle',
             'Variable Cape', 'Cotton Cape', 'Lizard Mantle' },
        Waist = { 'Lieutenant\'s Sash', 'Resolute Belt', 'Forest Rope', 'Kaiser Belt',
             'Marid Belt +1', 'Star Sash', 'Desert Sash', 'Forest Sash', 'Marid Belt',
             'Czar\'s Belt', 'Koenigs Belt', 'Maharaja\'s Belt', 'Pendragon\'s Belt',
             'Sultan\'s Belt', 'Anrin Obi', 'Dorin Obi', 'R.K. Belt +2', 'Earth Belt',
             'R.K. Belt +1', 'Desert Belt', 'Forest Belt', 'Twinthread Obi +1',
             'Ryl.Kgt. Belt', 'Brocade Obi +1', 'Swordbelt +1', 'Corsette +1',
             'Qiqirn Sash +1', 'Jungle Belt', 'Ocean Belt', 'Brocade Obi', 'Swordbelt',
             'Corsette', 'Qiqirn Sash', 'Gold Obi +1', 'Silver Belt +1', 'Survival Belt',
             'Force Belt', 'Oracle\'s Belt', 'Deduct. Gold Obi', 'Enthrall. Gold Obi',
             'Gold Obi', 'Sagac. Gold Obi', 'Mohbwa Sash +1', 'Silver Obi +1',
             'Magic Belt +1', 'Lizard Belt +1', 'Warrior\'s Belt +1', 'Shaman\'s Belt',
             'Mohbwa Sash', 'Silver Obi', 'Magic Belt', 'Lizard Belt', 'Friar\'s Rope',
             'Heko Obi +1', 'Augmenting Belt' },
        Legs  = { 'Goliard Trews', 'Dst. Subligar +1', 'Darksteel Subligar', 'Bahamut\'s Hose',
             'Dusk Trousers +1', 'Dusk Trousers', 'Hct. Subligar +1', 'Hecatomb Subligar',
             'Byakko\'s Haidate', 'Zenith Slacks +1', 'Beak Trousers +1', 'Akinji Salvars',
             'Feral Trousers', 'Beak Trousers', 'Femina Subligar', 'Vir Subligar',
             'Jaridah Salvars', 'Scp. Subligar +1', 'Tiger Trousers', 'Scorpion Subligar',
             'Luna Subligar', 'Battle Hose +1', 'Tabin Hose +1', 'Dino Trousers',
             'Silk Slacks +1', 'Ice Trousers', 'Raptor Trousers', 'Wool Hose +1',
             'Cpc. Subligar +1', 'Blaze Hose', 'Wool Hose', 'Carapace Subligar',
             'Cuir Trousers +1', 'Cuir Trousers', 'Mage\'s Slops', 'Hose +1',
             'Iron Subligar +1', 'Velvet Slops', 'Hose', 'Iron Subligar', 'Shade Tights +1',
             'Wool Slops +1', 'Kingdom Trousers', 'Shade Tights', 'Wool Slops',
             'Republic Subligar', 'San. Trousers', 'Great Brais', 'Fine Trousers',
             'Bone Subligar +1', 'Lizard Trousers', 'Bone Subligar', 'Angler\'s Hose',
             'Nomad\'s Hose', 'Rider\'s Hose', 'Worker Hose' },
        Feet  = { 'Dst. Leggings +1', 'Dst. Leggings', 'Suzaku\'s Sune-Ate', 'Dusk Ledelsens +1',
             'Dusk Ledelsens', 'Hct. Leggings +1', 'Hct. Leggings', 'Zenith Pumps +1',
             'Marduk\'s Crackows', 'Rostrum Pumps', 'Root Sabots', 'Rutter Sabatons',
             'Marid Leggings +1', 'Ataractic Solea', 'Marid Leggings', 'Bk. Ledelsens +1',
             'Akinji Nails', 'Desert Boots +1', 'Scp. Leggings +1', 'Battle Boots +1',
             'Tabin Boots +1', 'Beak Ledelsens', 'Jaridah Nails', 'Scorpion Leggings',
             'Dino Ledelsens', 'Raptor Ledelsens', 'Wool Socks +1', 'Cpc. Leggings +1',
             'Wool Socks', 'Cpc. Leggings', 'C.C. Shoes +2', 'Cuir Highboots +1',
             'Powder Boots', 'C.C. Shoes +1', 'Cuir Highboots', 'Ebony Sabots +1', 'Socks +1',
             'Leggings +1', 'Rubious Pumps', 'Kingdom Clogs', 'Ebony Sabots',
             'Shade Leggings +1', 'San d\'Orian Clogs', 'Air Solea +1', 'Chs. Sabots +1',
             'Shade Leggings', 'Winged Boots +1', 'Great Gaiters', 'Kingdom Boots',
             'Fine Ledelsens', 'Bone Leggings +1', 'San d\'Orian Boots', 'Republic Leggings',
             'Garrison Boots', 'Lizard Ledelsens', 'Bone Leggings' },
    },
    -- The white mage subjob delta, layered over Idle_Mit rather than repeating
    -- it. Two slots differ under a white mage subjob: Gaudy Harness, whose
    -- latent gives refresh while MP is under 49, and Stoneskin Torque, which
    -- enhances a spell that absorbs damage outright and so belongs at the front
    -- of a set ordered for damage reduction. Neither is worth a slot under a
    -- ninja subjob, which cannot cast Stoneskin at all.
    -- Layering is equivalent to the full list this replaces: resolution equips
    -- the piece when it is carried and wearable, and leaves the slot to Idle_Mit
    -- underneath when it is not -- which is exactly what a list led by that
    -- piece did. Stoneskin Torque also appears inside Idle_Mit's own neck list;
    -- promoting it here is what the white mage set used to spell out in full.
    ['Idle_Mit_WHM_Priority'] = {
        Neck  = { 'Stoneskin Torque' },
        Body  = { 'Gaudy Harness' },
    },
    -- The enmity shedding idle mode, for when hate is the problem rather than
    -- damage -- a pull gone wrong, or a cure that would peel the mob.
    --
    -- Ordered on Enmity- alone, most removed first. Where a slot has no Enmity-
    -- piece the mitigation ladder shows through underneath, so the slot holds
    -- the best defensive piece rather than nothing. Conditional enmity is
    -- ignored the same way: Fenrir's Torque is Enmity -3 only at night, and
    -- Horror Head's -50 needs a full moon on Darksday.
    --
    -- No white mage subjob set. Stoneskin Torque and Gaudy Harness are
    -- mitigation and refresh, neither of which is what this mode is for.
    ['Idle_Enmity_Priority'] = {
        Main  = { 'Terra\'s Staff', 'Earth Staff' },
        Ammo  = { 'Pebble' },
        Head  = { 'Hydra Beret', 'Raven Beret', 'Crow Beret', 'Mahatma Hat', 'Errant Hat',
             'Patroclus\'s Helm', 'Yigit Turban', 'Goliard Chapeau', 'Valkyrie\'s Hat',
             'Marduk\'s Tiara', 'Shadow Hat', 'Chl. Roundlet +1', 'Choral Roundlet',
             'Pumpkin Head', 'Darksteel Cap +1', 'Darksteel Cap', 'Genbu\'s Kabuto',
             'Hecatomb Cap +1', 'Hecatomb Cap', 'Dusk Mask +1', 'Io\'s helm', 'Dusk Mask',
             'Zenith Crown +1', 'Zenith Crown', 'Carapace Helm +1', 'Scorpion Helm +1',
             'Dartorgor\'s Coif', 'Troll Coif', 'Carapace Helm', 'Magus Keffiyeh',
             'Beak Helm +1', 'Akinji Khud', 'Scorpion Mask +1', 'Beak Helm', 'Jaridah Khud',
             'Scorpion Mask', 'T.M. Hat +2', 'Dino Helm', 'Magi Hat', 'Raptor Helm',
             'Wool Cap +1', 'Carapace Mask +1', 'Wool Cap', 'Carapace Mask', 'Namru\'s Tiara',
             'Corsair\'s Hat +1', 'Cuir Bandana +1', 'Cuir Bandana', 'Mage\'s Hat',
             'Red Cap +1', 'Strong Cap', 'Sinister Mask', 'Velvet Hat', 'Red Cap',
             'Shade Tiara +1', 'Trump Crown', 'Wool Hat +1', 'Shade Tiara', 'Great Headgear',
             'Beetle Mask +1', 'Wool Hat', 'Cotton Headgear', 'Lizard Helm +1',
             'Bone Mask +1', 'Kingdom Bandana', 'Republic Cap', 'Bonze\'s Circlet',
             'Lizard Helm', 'Bone Mask', 'San. Bandana' },
        Neck  = { 'Benign Necklace', 'Lieutenant\'s Gorget', 'Sniper\'s Collar', 'Rho Necklace',
             'Wivre Gorget +1', 'Tempered Chain', 'Wivre Gorget', 'Torama Gorget',
             'Coeurl Gorget', 'Torque +1', 'Beak Necklace +1', 'Auditory Torque',
             'Blue Gorget', 'Brisingamen +1', 'Chivalrous Chain', 'Fortified Chain',
             'Stoneskin Torque', 'Torque', 'Beak Necklace', 'Intellect Torque',
             'Storm Gorget', 'Carapace Gorget', 'Clay Amulet', 'Stone Gorget',
             'Memento Muffler', 'Wolf Gorget +1', 'Checkered Scarf', 'Promise Badge',
             'Qiqirn Collar', 'Brisingamen', 'Agile Gorget', 'Medieval Collar', 'Wolf Gorget',
             'Holy Phial', 'Hemp Gorget +1', 'Green Gorget', 'Van Pendant', 'Paisley Scarf',
             'Orochi Nodowa +1', 'M. No.17\'s Locket', 'Jagd Gorget', 'Mohbwa Scarf +1',
             'Tiger Stole', 'Hemp Gorget', 'Beetle Gorget', 'Black Neckerchief',
             'Feather Collar +1', 'Leather Gorget +1', 'Green Scarf', 'Orochi Nodowa',
             'Dog Collar', 'Feather Collar', 'Justice Badge', 'Leather Gorget',
             'Shield Pendant', 'Windurstian Scarf', 'Bloodbead Amulet', 'Grandiose Chain' },
        Ear1  = { 'Novia Earring', 'Storm Earring', 'Delta Earring', 'Hvn. Earring +1',
             'Heavens Earring', 'Coral Earring', 'Merman\'s Earring', 'Intruder Earring',
             'Bitter Earring', 'Cassie Earring', 'Allure Earring +1', 'Lyt. Earring +1',
             'Hope Earring +1', 'Chaotic Earring', 'Haten Earring', 'Priest\'s Earring',
             'Adroit Earring +1', 'Cmn. Earring +1', 'Cel. Earring +1', 'Genius Earring +1',
             'Grace Earring +1', 'Mana Earring +1', 'Ser. Earring +1', 'Victory Earring +1',
             'Alc. Earring +1', 'Aura Earring +1', 'Deft Earring +1', 'Puis. Earring +1',
             'Solace Earring +1', 'Verve Earring +1', 'Wisdom Earring +1', 'Mecurial Earring',
             'Blc. Earring +1', 'Crg. Earring +1', 'Energy Earring +1', 'Kldg. Earring +1',
             'Optical Earring', 'Reflex Earring +1', 'Morukaka Earring', 'Stoic Earring',
             'Ethereal Earring', 'Insomnia Earring', 'Ryakho\'s Earring', 'Shield Earring' },
        Ear2  = { 'Novia Earring', 'Storm Earring', 'Delta Earring', 'Hvn. Earring +1',
             'Heavens Earring', 'Coral Earring', 'Merman\'s Earring', 'Intruder Earring',
             'Bitter Earring', 'Cassie Earring', 'Allure Earring +1', 'Lyt. Earring +1',
             'Hope Earring +1', 'Chaotic Earring', 'Haten Earring', 'Priest\'s Earring',
             'Adroit Earring +1', 'Cmn. Earring +1', 'Cel. Earring +1', 'Genius Earring +1',
             'Grace Earring +1', 'Mana Earring +1', 'Ser. Earring +1', 'Victory Earring +1',
             'Alc. Earring +1', 'Aura Earring +1', 'Deft Earring +1', 'Puis. Earring +1',
             'Solace Earring +1', 'Verve Earring +1', 'Wisdom Earring +1', 'Mecurial Earring',
             'Blc. Earring +1', 'Crg. Earring +1', 'Energy Earring +1', 'Kldg. Earring +1',
             'Optical Earring', 'Reflex Earring +1', 'Morukaka Earring', 'Stoic Earring',
             'Ethereal Earring', 'Insomnia Earring', 'Ryakho\'s Earring', 'Shield Earring' },
        Body  = { 'Hydra Doublet', 'Raven Jupon', 'Crow Jupon', 'Goliard Saio', 'Valkyrie\'s Coat',
             'Mahatma Hpl.', 'Shadow Coat', 'Chl. Jstcorps +1', 'Errant Hpl.',
             'Chl. Jstcorps', 'Enlil\'s Gambison', 'Dst. Harness +1', 'Darksteel Harness',
             'Kirin\'s Osode', 'Hct. Harness +1', 'Dusk Jerkin', 'Hecatomb Harness',
             'Vishnu\'s Vest', 'Narasimha\'s Vest', 'Scp. Brstplate +1', 'Dalmatica +1',
             'Silk Cloak +1', 'Scp. Breastplate', 'Cpc. Brstplate +1', 'Cpc. Breastplate',
             'Tundra Jerkin', 'Beak Jerkin +1', 'Shaman\'s Cloak', 'Akinji Peti',
             'Corsair\'s Frac', 'Beak Jerkin', 'R.K. Cloak +2', 'Jaridah Peti',
             'Scp. Harness +1', 'Dino Jerkin', 'Raptor Jerkin', 'C.C. Cloak +2',
             'Brigandine +1', 'C.C. Cloak +1', 'Brigandine', 'Wool Gambison +1',
             'Cpc. Harness +1', 'Cuir Bouilli +1', 'Cuir Bouilli', 'Cloak +1', 'Cloak',
             'Mana Cloak', 'Mage\'s Robe', 'Strong Harness', 'Velvet Robe', 'Faerie Tunic',
             'Shade Harness +1', 'Wool Robe +1', 'Shade Harness', 'Mage\'s Tunic',
             'Wool Robe', 'Great Doublet', 'Beetle Harness +1', 'Fine Jerkin',
             'Garrison Tunica', 'Lizard Jerkin', 'Bone Harness +1', 'Priest\'s Robe',
             'Bone Harness', 'Healing Harness', 'Kingdom Tunic' },
        Hands = { 'Concealing Cuffs', 'Hydra Gloves', 'Raven Bracers', 'Crow Bracers',
             'Marduk\'s Dastanas', 'Mahatma Cuffs', 'Errant Cuffs', 'Valkyrie\'s Cuffs',
             'Choral Cuffs', 'Chl. Cuffs +1', 'Enlil\'s Kolluks', 'Shadow Cuffs',
             'Dst. Mittens +1', 'Prt. Bangles', 'Darksteel Mittens', 'Seiryu\'s Kote',
             'Hct. Mittens +1', 'Dusk Gloves +1', 'Hecatomb Mittens', 'Dusk Gloves',
             'Zenith Mitts +1', 'Coral Bangles', 'Merman\'s Bangles', 'Zenith Mitts',
             'Cpc. Gauntlets +1', 'Magical Mitts', 'Fencing Bracers', 'Cpc. Gauntlets',
             'Pallas\'s Bracelets', 'Light Gauntlets', 'Beak Gloves +1', 'Akinji Bazubands',
             'Enkelados\'s Brc.', 'Scp. Mittens +1', 'Beak Gloves', 'Dino Gloves',
             'Raptor Gloves', 'Ogygos\'s Brc.', 'Wool Bracers +1', 'Turtle Bangles +1',
             'Cpc. Mittens +1', 'Wool Bracers', 'Turtle Bangles', 'Cuir Gloves +1',
             'Rubious Mitts', 'Gigas Bracelets', 'Cuir Gloves', 'Mage\'s Cuffs', 'Bracers +1',
             'Sennight Bangles', 'Iron Mittens +1', 'Shade Mittens +1', 'Wool Cuffs +1',
             'Shade Mittens', 'Great Gloves', 'Beetle Mittens +1', 'Custom F Gloves',
             'Custom M Gloves', 'Wonder Mitts', 'Fine Gloves', 'Kingdom Gloves',
             'Republic Mittens', 'Lizard Gloves', 'Bone Mittens +1', 'San. Gloves',
             'Bastokan Mittens', 'Bone Mittens' },
        Ring1 = { 'Tamas Ring', 'Trooper\'s Ring', 'Serene Ring', 'Peace Ring', 'Defending Ring',
             'Jelly Ring', 'Gobniu\'s Ring', 'Phalanx Ring', 'Unyielding Ring',
             'Dragon Ring +1', 'Unfettered Ring', 'Aegis Ring', 'Dragon Ring',
             'Cerberus Ring +1', 'Adroit Ring +1', 'Cmn. Ring +1', 'Hades Ring +1',
             'Heavens Ring +1', 'Gld.Msk. Ring', 'Demon\'s Ring +1', 'Tiger Ring',
             'Allure Ring +1', 'Celerity Ring +1', 'Genius Ring +1', 'Grace Ring +1',
             'Kshama Ring No.4', 'Bloodbead Ring', 'Bomb Ring', 'Demon\'s Ring',
             'Marid Ring +1', 'Earth Ring', 'Marksman\'s Ring', 'Alacrity Ring +1',
             'Aura Ring +1', 'Deft Ring +1', 'Loyalty Ring +1', 'Puissance Ring +1',
             'Solace Ring +1', 'Verve Ring +1', 'Leather Ring +1', 'Safeguard Ring',
             'San d\'Orian Ring', 'Armored Ring', 'Balance Ring +1', 'Courage Ring +1',
             'Energy Ring +1', 'Gold Ring +1', 'Gold Ring', 'Mythril Ring +1', 'Mythril Ring' },
        Ring2 = { 'Tamas Ring', 'Trooper\'s Ring', 'Serene Ring', 'Peace Ring', 'Defending Ring',
             'Jelly Ring', 'Gobniu\'s Ring', 'Phalanx Ring', 'Unyielding Ring',
             'Dragon Ring +1', 'Unfettered Ring', 'Aegis Ring', 'Dragon Ring',
             'Cerberus Ring +1', 'Adroit Ring +1', 'Cmn. Ring +1', 'Hades Ring +1',
             'Heavens Ring +1', 'Gld.Msk. Ring', 'Demon\'s Ring +1', 'Tiger Ring',
             'Allure Ring +1', 'Celerity Ring +1', 'Genius Ring +1', 'Grace Ring +1',
             'Kshama Ring No.4', 'Bloodbead Ring', 'Bomb Ring', 'Demon\'s Ring',
             'Marid Ring +1', 'Earth Ring', 'Marksman\'s Ring', 'Alacrity Ring +1',
             'Aura Ring +1', 'Deft Ring +1', 'Loyalty Ring +1', 'Puissance Ring +1',
             'Solace Ring +1', 'Verve Ring +1', 'Leather Ring +1', 'Safeguard Ring',
             'San d\'Orian Ring', 'Armored Ring', 'Balance Ring +1', 'Courage Ring +1',
             'Energy Ring +1', 'Gold Ring +1', 'Gold Ring', 'Mythril Ring +1', 'Mythril Ring' },
        Back  = { 'Mahatma Cape', 'Errant Cape', 'Peace Cape +1', 'Peace Cape', 'Amity Cape',
             'Sapient Cape', 'Talisman Cape', 'Esoteric Mantle', 'Miraculous Cape',
             'Shadow Mantle', 'Umbra Cape', 'Hexerei Cape', 'Cheviot Cape',
             'Behem. Mantle +1', 'Behemoth Mantle', 'Marid Mantle +1', 'Empwr. Mantle +1',
             'Marid Mantle', 'Black Mantle +1', 'Feral Mantle', 'Desert Mantle +1',
             'Corse Cape', 'Beak Mantle +1', 'Ryl. Army Mantle', 'Cvl. Mantle +1',
             'Lieutenant\'s Cape', 'Enhancing Mantle', 'Beak Mantle', 'Cvl. Mantle',
             'Lightning Mantle', 'Dino Mantle', 'Rep. Army Mantle', 'Fed. Army Mantle',
             'Jester\'s Cape +1', 'Volitional Mantle', 'Raptor Mantle', 'Bat Cape',
             'Aurora Mantle +1', 'Sentinel\'s Mantle', 'Lucent Cape', 'Aurora Mantle',
             'Red Cape +1', 'Ram Mantle', 'Ram Mantle +1', 'Wolf Mantle +1', 'Tundra Mantle',
             'Black Cape +1', 'White Cape +1', 'Invisible Mantle', 'Wolf Mantle',
             'Dhalmel Mantle +1', 'Nomad\'s Mantle +1', 'Night Cape', 'Variable Mantle',
             'Cotton Cape +1', 'Dhalmel Mantle', 'Lizard Mantle +1', 'Mist Silk Cape',
             'Nomad\'s Mantle', 'Variable Cape', 'Cotton Cape', 'Lizard Mantle' },
        Waist = { 'Theta Sash', 'Buccaneer\'s Belt', 'Spectral Belt', 'Penitent\'s Rope',
             'Healer\'s Belt', 'Talisman Obi', 'Immortal\'s Sash', 'Lieutenant\'s Sash',
             'Forest Rope', 'Kaiser Belt', 'Marid Belt +1', 'Star Sash', 'Desert Sash',
             'Forest Sash', 'Marid Belt', 'Czar\'s Belt', 'Koenigs Belt', 'Maharaja\'s Belt',
             'Pendragon\'s Belt', 'Sultan\'s Belt', 'Anrin Obi', 'Dorin Obi', 'R.K. Belt +2',
             'Earth Belt', 'R.K. Belt +1', 'Desert Belt', 'Forest Belt', 'Twinthread Obi +1',
             'Ryl.Kgt. Belt', 'Brocade Obi +1', 'Swordbelt +1', 'Corsette +1',
             'Qiqirn Sash +1', 'Jungle Belt', 'Ocean Belt', 'Brocade Obi', 'Swordbelt',
             'Corsette', 'Qiqirn Sash', 'Gold Obi +1', 'Silver Belt +1', 'Survival Belt',
             'Force Belt', 'Oracle\'s Belt', 'Deduct. Gold Obi', 'Enthrall. Gold Obi',
             'Gold Obi', 'Sagac. Gold Obi', 'Mohbwa Sash +1', 'Silver Obi +1',
             'Magic Belt +1', 'Lizard Belt +1', 'Warrior\'s Belt +1', 'Shaman\'s Belt',
             'Mohbwa Sash', 'Silver Obi', 'Magic Belt', 'Lizard Belt', 'Friar\'s Rope',
             'Heko Obi +1', 'Augmenting Belt' },
        Legs  = { 'Hydra Brais', 'Raven Hose', 'Crow Hose', 'Goliard Trews', 'Mahatma Slops',
             'Marduk\'s Shalwar', 'Errant Slops', 'Valkyrie\'s Trews', 'Shadow Trews',
             'Choral Cannions', 'Enlil\'s Brayettes', 'Mercenary\'s Trousers',
             'Dst. Subligar +1', 'Darksteel Subligar', 'Bahamut\'s Hose', 'Dusk Trousers +1',
             'Dusk Trousers', 'Hct. Subligar +1', 'Hecatomb Subligar', 'Byakko\'s Haidate',
             'Zenith Slacks +1', 'Beak Trousers +1', 'Akinji Salvars', 'Feral Trousers',
             'Beak Trousers', 'Femina Subligar', 'Vir Subligar', 'Jaridah Salvars',
             'Scp. Subligar +1', 'Tiger Trousers', 'Scorpion Subligar', 'Luna Subligar',
             'Battle Hose +1', 'Tabin Hose +1', 'Dino Trousers', 'Silk Slacks +1',
             'Ice Trousers', 'Raptor Trousers', 'Wool Hose +1', 'Cpc. Subligar +1',
             'Blaze Hose', 'Wool Hose', 'Carapace Subligar', 'Cuir Trousers +1',
             'Cuir Trousers', 'Mage\'s Slops', 'Hose +1', 'Iron Subligar +1', 'Velvet Slops',
             'Hose', 'Iron Subligar', 'Shade Tights +1', 'Wool Slops +1', 'Kingdom Trousers',
             'Shade Tights', 'Wool Slops', 'Republic Subligar', 'San. Trousers',
             'Great Brais', 'Fine Trousers', 'Bone Subligar +1', 'Lizard Trousers',
             'Bone Subligar', 'Angler\'s Hose', 'Nomad\'s Hose', 'Rider\'s Hose',
             'Worker Hose' },
        Feet  = { 'Arborist Nails', 'Hydra Gaiters', 'Raven Gaiters', 'Crow Gaiters',
             'Marduk\'s Crackows', 'Avocat Pigaches', 'Mahatma Pigaches', 'Valkyrie\'s Clogs',
             'Errant Pigaches', 'Shadow Clogs', 'Enlil\'s Crackows', 'Dst. Leggings +1',
             'Suzaku\'s Sune-Ate', 'Dst. Leggings', 'Dusk Ledelsens +1', 'Dusk Ledelsens',
             'Hct. Leggings +1', 'Hct. Leggings', 'Zenith Pumps +1', 'Rostrum Pumps',
             'Root Sabots', 'Rutter Sabatons', 'Marid Leggings +1', 'Ataractic Solea',
             'Marid Leggings', 'Bk. Ledelsens +1', 'Akinji Nails', 'Desert Boots +1',
             'Scp. Leggings +1', 'Battle Boots +1', 'Tabin Boots +1', 'Beak Ledelsens',
             'Jaridah Nails', 'Scorpion Leggings', 'Dino Ledelsens', 'Raptor Ledelsens',
             'Wool Socks +1', 'Cpc. Leggings +1', 'Wool Socks', 'Cpc. Leggings',
             'C.C. Shoes +2', 'Cuir Highboots +1', 'Powder Boots', 'C.C. Shoes +1',
             'Cuir Highboots', 'Ebony Sabots +1', 'Socks +1', 'Leggings +1', 'Rubious Pumps',
             'Kingdom Clogs', 'Ebony Sabots', 'Shade Leggings +1', 'San d\'Orian Clogs',
             'Air Solea +1', 'Chs. Sabots +1', 'Shade Leggings', 'Winged Boots +1',
             'Great Gaiters', 'Kingdom Boots', 'Fine Ledelsens', 'Bone Leggings +1',
             'San d\'Orian Boots', 'Republic Leggings', 'Garrison Boots', 'Lizard Ledelsens',
             'Bone Leggings' },
    },
    -- Singing skill and CHR, worn for every song. The instrument for the
    -- song family goes on top of this.
    ['Songs_Priority'] = {
        Head  = { 'Marduk\'s Tiara', 'Goliard Chapeau', 'Chl. Roundlet +1', 'Demon Helm',
             'Demon Helm +1', 'Errant Hat', 'Mahatma Hat', 'Sha\'ir Turban', 'Lamia Garland',
             'Opo-opo Crown', 'Choral Roundlet', 'Super Ribbon', 'Jester\'s Headband',
             'Jgl. Headband', 'Rain Hat', 'Gala Corsage', 'Alluring Headband',
             'Enlil\'s Tiara', 'Trump Crown', 'Garrison Sallet', 'Noble\'s Ribbon',
             'Entrancing Ribbon' },
        Neck  = { 'Temp. Torque', 'Oscar Scarf', 'String Torque', 'Wind Torque',
             'Star Necklace', 'Stoneskin Torque', 'Torque', 'Torque +1', 'Flower Necklace',
             'Bird Whistle', 'Dog Collar' },
        Ear1  = { 'Delta Earring', 'Epsilon Earring', 'Beastly Earring', 'Musical Earring',
             'Melody Earring', 'Melody Earring +1', 'Heims Earring', 'Singing Earring',
             'String Earring', 'Wind Earring', 'Trimmer\'s Earring' },
        Ear2  = { 'Delta Earring', 'Epsilon Earring', 'Beastly Earring', 'Musical Earring',
             'Melody Earring', 'Melody Earring +1', 'Heims Earring', 'Singing Earring',
             'String Earring', 'Wind Earring', 'Trimmer\'s Earring' },
        Body  = { 'Kirin\'s Osode', 'Marduk\'s Jubbah', 'Chl. Jstcorps +1',
             'Errant Hpl.', 'Mahatma Hpl.', 'Sha\'ir Manteel', 'Sheikh Manteel',
             'Minstrel\'s Coat', 'Black Cotehardie', 'Flora Cotehardie', 'Choral Jstcorps',
             'Healing Jstcorps', 'Justaucorps', 'Justaucorps +1',
             'T.M. Coat +1', 'T.M. Coat +2', 'Brigandine +1',
             'Argent Coat', 'Ceremonial Dress', 'Opaline Dress', 'Platino Coat',
             'Enlil\'s Gambison', 'Fed. Doublet', 'Win. Doublet', 'Custom Tunic',
             'Custom Vest', 'Elder\'s Surcoat', 'Savage Separates', 'Ea\'s Doublet',
             'Garrison Tunica' },
        Hands = { 'Marduk\'s Dastanas', 'Pantin Dastanas +1', 'Chl. Cuffs +1',
             'Sha\'ir Gages', 'Sheikh Gages', 'Tarasque Mitts', 'Tarasque Mitts +1',
             'Marine F Gloves', 'Marine M Gloves', 'Choral Cuffs', 'Enlil\'s Kolluks',
             'Ea\'s Dastanas' },
        Ring1 = { 'Epsilon Ring', 'Dark Ring', 'Light Ring', 'Angel\'s Ring', 'Heavens Ring',
             'Heavens Ring +1', 'Shining Ring', 'Serene Ring', 'Allure Ring', 'Allure Ring +1',
             'Moon Ring', 'Nereid Ring', 'Trumpet Ring', 'Balrahn\'s Ring', 'Kshama Ring No. 6',
             'Vilma\'s Ring', 'Loyalty Ring', 'Loyalty Ring +1', 'Maldust Ring',
             'Malflame Ring', 'Malflash Ring', 'Malflood Ring', 'Malfrost Ring', 'Malgust Ring',
             'Hope Ring', 'Opal Ring' },
        Ring2 = { 'Epsilon Ring', 'Dark Ring', 'Light Ring', 'Angel\'s Ring', 'Heavens Ring',
             'Heavens Ring +1', 'Shining Ring', 'Serene Ring', 'Allure Ring', 'Allure Ring +1',
             'Moon Ring', 'Nereid Ring', 'Trumpet Ring', 'Balrahn\'s Ring', 'Kshama Ring No. 6',
             'Vilma\'s Ring', 'Loyalty Ring', 'Loyalty Ring +1', 'Maldust Ring',
             'Malflame Ring', 'Malflash Ring', 'Malflood Ring', 'Malfrost Ring', 'Malgust Ring',
             'Hope Ring', 'Opal Ring' },
        Back  = { 'Erato\'s Cape', 'Astute Cape', 'Prism Cape', 'Rainbow Cape', 'Aslan Cape',
             'Bard\'s Cape', 'Birdman Cape', 'Miraculous Cape', 'Jester\'s Cape',
             'Jester\'s Cape +1', 'Lucent Cape' },
        Waist = { 'Lambda Sash', 'Al Zahbi Sash', 'Moon Sash', 'Czar\'s Belt', 'Kaiser Belt',
             'Koenigs Belt', 'Maharaja\'s Belt', 'Pendragon\'s Belt', 'Sultan\'s Belt',
             'Enthrall. Broc. Obi', 'Gleeman\'s Belt', 'R.K. Belt +1',
             'R.K. Belt +2', 'Desert Stone', 'Ryl.Kgt. Belt', 'Reverend Sash',
             'Corsette', 'Corsette +1', 'Druid\'s Rope', 'Enthrall. Gold Obi',
             'Mrc.Cpt. Belt' },
        Legs  = { 'Marduk\'s Shalwar', 'Galliard Trousers', 'Zenith Slacks', 'Zenith Slacks +1',
             'Errant Slops', 'Mahatma Slops', 'Sha\'ir Seraweels', 'Sheikh Seraweels',
             'Luna Subligar', 'Choral Cannions', 'Ceremonial Hose', 'Platino Hose',
             'Enlil\'s Brayettes', 'Custom Pants', 'Custom Slacks', 'Elder\'s Braguette',
             'Ea\'s Brais' },
        Feet  = { 'Marduk\'s Crackows', 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs',
             'Heroic Boots', 'Heroic Boots +1', 'Spagyric Nails', 'Oracle\'s Pigaches',
             'Marine F Boots', 'Marine M Boots', 'Ceremonial Boots', 'Savage Gaiters' },
    },
    -- Enfeebling songs get resisted, so Lullaby and Elegy take magic
    -- accuracy instead, plus the element staff from staves.lua.
    ['SongAcc_Priority'] = {
        Head  = { 'Shadow Hat', 'Valkyrie\'s Hat', 'Marduk\'s Tiara', 'Goliard Chapeau',
             'Chl. Roundlet +1', 'Demon Helm', 'Demon Helm +1', 'Carline Ribbon',
             'Lamia Garland', 'Opo-opo Crown', 'Choral Roundlet', 'Super Ribbon',
             'Storm Zucchetto', 'Jester\'s Headband', 'Jgl. Headband', 'Rain Hat',
             'Gala Corsage', 'Alluring Headband', 'Enlil\'s Tiara', 'Trump Crown',
             'Garrison Sallet', 'Noble\'s Ribbon', 'Entrancing Ribbon' },
        Neck  = { 'Temp. Torque', 'Oscar Scarf', 'Lieut. Gorget', 'Star Necklace',
             'Stoneskin Torque', 'Torque', 'Torque +1', 'Flower Necklace', 'Bird Whistle',
             'Dog Collar' },
        Ear1  = { 'Delta Earring', 'Epsilon Earring', 'Beastly Earring', 'Diabolos\'s Earring',
             'Melody Earring', 'Melody Earring +1', 'Heims Earring', 'Singing Earring',
             'Trimmer\'s Earring' },
        Ear2  = { 'Delta Earring', 'Epsilon Earring', 'Beastly Earring', 'Diabolos\'s Earring',
             'Melody Earring', 'Melody Earring +1', 'Heims Earring', 'Singing Earring',
             'Trimmer\'s Earring' },
        Body  = { 'Shadow Coat', 'Valkyrie\'s Coat', 'Kirin\'s Osode', 'Marduk\'s Jubbah',
             'Chl. Jstcorps +1', 'Oracle\'s Robe', 'Errant Hpl.',
             'Mahatma Hpl.', 'Black Cotehardie', 'Flora Cotehardie',
             'Healing Jstcorps', 'Justaucorps', 'Justaucorps +1',
             'T.M. Coat +1', 'T.M. Coat +2', 'Gaudy Harness',
             'Brigandine +1', 'Argent Coat', 'Ceremonial Dress', 'Opaline Dress',
             'Platino Coat', 'Enlil\'s Gambison', 'Fed. Doublet', 'Win. Doublet',
             'Custom Tunic', 'Custom Vest', 'Elder\'s Surcoat', 'Savage Separates',
             'Ea\'s Doublet', 'Garrison Tunica' },
        Hands = { 'Goliard Cuffs', 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Marduk\'s Dastanas',
             'Pantin Dastanas +1', 'Chl. Cuffs +1', 'Sha\'ir Gages', 'Sheikh Gages',
             'Marine F Gloves', 'Marine M Gloves', 'Choral Cuffs', 'Sennight Bangles',
             'Enlil\'s Kolluks', 'Ea\'s Dastanas' },
        Ring1 = { 'Epsilon Ring', 'Dark Ring', 'Light Ring', 'Angel\'s Ring', 'Heavens Ring',
             'Heavens Ring +1', 'Shining Ring', 'Insect Ring', 'Serene Ring', 'Allure Ring',
             'Allure Ring +1', 'Moon Ring', 'Balrahn\'s Ring', 'Kshama Ring No. 6',
             'Vilma\'s Ring', 'Loyalty Ring', 'Loyalty Ring +1', 'Maldust Ring',
             'Malflame Ring', 'Malflash Ring', 'Malflood Ring', 'Malfrost Ring', 'Tamas Ring',
             'Hope Ring', 'Opal Ring' },
        Ring2 = { 'Epsilon Ring', 'Dark Ring', 'Light Ring', 'Angel\'s Ring', 'Heavens Ring',
             'Heavens Ring +1', 'Shining Ring', 'Insect Ring', 'Serene Ring', 'Allure Ring',
             'Allure Ring +1', 'Moon Ring', 'Balrahn\'s Ring', 'Kshama Ring No. 6',
             'Vilma\'s Ring', 'Loyalty Ring', 'Loyalty Ring +1', 'Maldust Ring',
             'Malflame Ring', 'Malflash Ring', 'Malflood Ring', 'Malfrost Ring', 'Tamas Ring',
             'Hope Ring', 'Opal Ring' },
        Back  = { 'Astute Cape', 'Prism Cape', 'Rainbow Cape', 'Aslan Cape', 'Bard\'s Cape',
             'Birdman Cape', 'Miraculous Cape', 'Jester\'s Cape', 'Jester\'s Cape +1',
             'Gramary Cape', 'Lucent Cape' },
        Waist = { 'Al Zahbi Sash', 'Moon Sash', 'Czar\'s Belt', 'Kaiser Belt', 'Koenigs Belt',
             'Maharaja\'s Belt', 'Pendragon\'s Belt', 'Sultan\'s Belt',
             'Enthrall. Broc. Obi', 'Bitter Corset', 'R.K. Belt +1',
             'R.K. Belt +2', 'Desert Stone', 'Ryl.Kgt. Belt', 'Reverend Sash',
             'Corsette', 'Corsette +1', 'Druid\'s Rope', 'Enthrall. Gold Obi',
             'Mrc.Cpt. Belt' },
        Legs  = { 'Shadow Trews', 'Valkyrie\'s Trews', 'Galliard Trousers', 'Marduk\'s Shalwar',
             'Zenith Slacks', 'Zenith Slacks +1', 'Errant Slops', 'Mrc. Trousers',
             'Luna Subligar', 'Ceremonial Hose', 'Platino Hose', 'Enlil\'s Brayettes',
             'Custom Pants', 'Custom Slacks', 'Elder\'s Braguette', 'Ea\'s Brais' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Heroic Boots',
             'Heroic Boots +1', 'Spagyric Nails', 'Zenith Pumps', 'Zenith Pumps +1',
             'Marine F Boots', 'Marine M Boots', 'Ceremonial Boots', 'Savage Gaiters' },
    },
    -- First half of the Minstrel's Ring swap. The standing gear carries HP
    -- now, so maximum HP is taken as far down as it will go before the +HP
    -- set goes on: current HP is clamped to the smaller maximum, and the +HP
    -- set then raises the maximum out from under it. Ordered by the most HP
    -- removed, then mitigation. Ring1 is left free for the ring itself.
    ['MinstrelLow_Priority'] = {
        Head  = { 'Zenith Crown +1', 'Zenith Crown', 'Wivre Hairpin +1', 'Reikyo Hairpin',
             'Wivre Hairpin', 'Faerie Hairpin', 'Emperor Hairpin', 'Empress Hairpin',
             'Gold Hairpin', 'Gold Hairpin +1', 'Electrum Hairpin', 'Coral Hairpin',
             'Merman\'s Hairpin', 'Reraise Hairpin', 'Silver Hairpin', 'Silver Hairpin +1',
             'Akinji Khud', 'Jaridah Khud', 'Eld. Horn Hairpin', 'Horn Hairpin',
             'Horn Hairpin +1', 'Brass Hairpin', 'Brass Hairpin +1', 'Shell Hairpin',
             'Shell Hairpin +1', 'Copper Hairpin', 'Copper Hairpin +1', 'Bone Hairpin',
             'Bone Hairpin +1', 'Darksteel Cap +1', 'Darksteel Cap', 'Io\'s helm',
             'Mahatma Hat', 'Errant Hat', 'Hydra Cap', 'Carapace Helm +1', 'Beak Helm +1',
             'Beak Helm', 'T.M. Hat +2', 'Dino Helm', 'Silk Hat +1', 'Raptor Helm',
             'Wool Cap +1', 'Carapace Mask +1', 'Wool Cap', 'Carapace Mask', 'Namru\'s Tiara',
             'Cuir Bandana +1', 'Cuir Bandana', 'Mage\'s Hat', 'Red Cap +1', 'Strong Cap',
             'Shade Tiara +1', 'Wool Hat +1', 'Shade Tiara', 'Great Headgear' },
        Neck  = { 'Morgana\'s Choker', 'Star Necklace', 'Checkered Scarf', 'Wivre Gorget +1',
             'Wivre Gorget', 'Torama Gorget', 'Coeurl Gorget', 'Torque +1', 'Beak Necklace +1',
             'Auditory Torque', 'Blue Gorget', 'Brisingamen +1', 'Chivalrous Chain',
             'Fortified Chain', 'Stoneskin Torque', 'Torque', 'Beak Necklace',
             'Intellect Torque', 'Carapace Gorget', 'Clay Amulet', 'Stone Gorget',
             'Memento Muffler', 'Wolf Gorget +1', 'Qiqirn Collar', 'Brisingamen',
             'Agile Gorget', 'Medieval Collar', 'Wolf Gorget', 'Holy Phial', 'Hemp Gorget +1',
             'Green Gorget', 'Van Pendant', 'Orochi Nodowa +1', 'M. No.17\'s Locket',
             'Jagd Gorget', 'Mohbwa Scarf +1', 'Tiger Stole', 'Hemp Gorget', 'Beetle Gorget',
             'Black Neckerchief', 'Feather Collar +1', 'Leather Gorget +1', 'Orochi Nodowa',
             'Mohbwa Scarf', 'Dog Collar', 'Feather Collar', 'Justice Badge', 'Leather Gorget',
             'Regen Collar', 'Sniper\'s Collar', 'Dark Torque', 'Divine Torque',
             'Spirit Torque', 'Peacock Amulet', 'Peacock Charm', 'Buburimu Gorget' },
        Ear1  = { 'Astral Earring', 'Merman\'s Earring', 'Coral Earring', 'Intruder Earring',
             'Bitter Earring', 'Cassie Earring', 'Chaotic Earring', 'Haten Earring',
             'Priest\'s Earring', 'Adroit Earring +1', 'Cmn. Earring +1', 'Nimble Earring +1',
             'Cel. Earring +1', 'Genius Earring +1', 'Grace Earring +1', 'Mana Earring +1',
             'Ser. Earring +1', 'Victory Earring +1', 'Alc. Earring +1', 'Aura Earring +1',
             'Deft Earring +1', 'Puis. Earring +1', 'Solace Earring +1', 'Verve Earring +1',
             'Wisdom Earring +1', 'Mecurial Earring', 'Blc. Earring +1', 'Crg. Earring +1',
             'Energy Earring +1', 'Kldg. Earring +1', 'Optical Earring', 'Reflex Earring +1',
             'Stm. Earring +1', 'Jupiter\'s Earring', 'Beta Earring', 'Brutal Earring',
             'Delta Earring', 'Epsilon Earring', 'Eta Earring', 'Gamma Earring',
             'Loquac. Earring', 'Bat Earring', 'Desamilion Earring', 'Fang Earring',
             'Feyuh\'s Earring', 'Gayanj\'s Earring', 'Melnina\'s Earring', 'Plantoid Earring',
             'Geist Earring', 'Cunning Earring', 'Dodge Earring', 'Mythril Earring',
             'Mythril Earring +1', 'Reraise Earring', 'Twinstone Earring', 'Beetle Earring' },
        Ear2  = { 'Astral Earring', 'Merman\'s Earring', 'Coral Earring', 'Intruder Earring',
             'Bitter Earring', 'Cassie Earring', 'Chaotic Earring', 'Haten Earring',
             'Priest\'s Earring', 'Adroit Earring +1', 'Cmn. Earring +1', 'Nimble Earring +1',
             'Cel. Earring +1', 'Genius Earring +1', 'Grace Earring +1', 'Mana Earring +1',
             'Ser. Earring +1', 'Victory Earring +1', 'Alc. Earring +1', 'Aura Earring +1',
             'Deft Earring +1', 'Puis. Earring +1', 'Solace Earring +1', 'Verve Earring +1',
             'Wisdom Earring +1', 'Mecurial Earring', 'Blc. Earring +1', 'Crg. Earring +1',
             'Energy Earring +1', 'Kldg. Earring +1', 'Optical Earring', 'Reflex Earring +1',
             'Stm. Earring +1', 'Jupiter\'s Earring', 'Beta Earring', 'Brutal Earring',
             'Delta Earring', 'Epsilon Earring', 'Eta Earring', 'Gamma Earring',
             'Loquac. Earring', 'Bat Earring', 'Desamilion Earring', 'Fang Earring',
             'Feyuh\'s Earring', 'Gayanj\'s Earring', 'Melnina\'s Earring', 'Plantoid Earring',
             'Geist Earring', 'Cunning Earring', 'Dodge Earring', 'Mythril Earring',
             'Mythril Earring +1', 'Reraise Earring', 'Twinstone Earring', 'Beetle Earring' },
        Body  = { 'Dalmatica +1', 'Dalmatica', 'Flora Cotehardie', 'Akinji Peti',
             'Jaridah Peti', 'Black Cotehardie', 'Assault Jerkin', 'Dst. Harness +1',
             'Darksteel Harness', 'Kirin\'s Osode', 'Vishnu\'s Vest', 'Narasimha\'s Vest',
             'Scp. Brstplate +1', 'Commodore Frac', 'Bachelor Vest', 'Scp. Breastplate',
             'Cpc. Brstplate +1', 'Cardinal Vest', 'Cpc. Breastplate', 'Tundra Jerkin',
             'Beak Jerkin +1', 'Shaman\'s Cloak', 'Beak Jerkin', 'R.K. Cloak +2', 'Dino Jerkin',
             'Raptor Jerkin', 'C.C. Cloak +2', 'C.C. Cloak +1', 'Wool Gambison +1',
             'Cpc. Harness +1', 'Cmb.Cst. Cloak', 'Wool Gambison', 'Cuir Bouilli +1',
             'Cuir Bouilli', 'Cloak +1', 'Cloak', 'Mana Cloak', 'Mage\'s Robe',
             'Strong Harness', 'Velvet Robe', 'Shade Harness +1', 'Wool Robe +1',
             'Shade Harness', 'Mage\'s Tunic', 'Wool Robe', 'Great Doublet',
             'Beetle Harness +1', 'Black Tunic', 'Fine Jerkin', 'Garrison Tunica',
             'Lizard Jerkin', 'Bone Harness +1', 'Priest\'s Robe', 'Bone Harness',
             'Healing Harness', 'Kingdom Tunic' },
        Hands = { 'Zenith Mitts +1', 'Zenith Mitts', 'Dune Bracers', 'Mahatma Cuffs',
             'Errant Cuffs', 'Akinji Bazubands', 'Jaridah Bazubands', 'Merman\'s Bangles',
             'Dst. Mittens +1', 'Prt. Bangles', 'Darksteel Mittens', 'Coral Bangles',
             'Barb. Moufles', 'Marduk\'s Dastanas', 'Sheikh Gages', 'Sha\'ir Gages',
             'Cpc. Gauntlets +1', 'Cpc. Gauntlets', 'Feral Gloves', 'Beak Gloves +1',
             'Beak Gloves', 'Sand Gloves', 'Dino Gloves', 'Silk Cuffs +1', 'Gold Bangles +1',
             'Raptor Gloves', 'Wool Bracers +1', 'Turtle Bangles +1', 'Cpc. Mittens +1',
             'Wool Bracers', 'Turtle Bangles', 'Carapace Mittens', 'Cuir Gloves +1',
             'Rubious Mitts', 'Cuir Gloves', 'Mage\'s Cuffs', 'Bracers +1', 'Sennight Bangles',
             'Iron Mittens +1', 'Garish Mitts', 'Shade Mittens +1', 'Wool Cuffs +1',
             'Shade Mittens', 'Great Gloves', 'Beetle Mittens +1', 'Wool Cuffs',
             'Elder\'s Bracers', 'Magna Gauntlets', 'Fine Gloves', 'Lizard Gloves',
             'Bone Mittens +1', 'Bone Mittens', 'Scentless Armlets', 'Battle Gloves',
             'Linen Cuffs +1', 'Brass Mittens +1' },
        Ring2 = { 'Vivian Ring', 'Serket Ring', 'Ether Ring', 'Vilma\'s Ring', 'Astral Ring',
             'Dark Ring', 'Electrum Ring', 'Fasting Ring', 'Serene Ring', 'Peace Ring',
             'Defending Ring', 'Jelly Ring', 'Gobniu\'s Ring', 'Phalanx Ring',
             'Unyielding Ring', 'Dragon Ring +1', 'Unfettered Ring', 'Aegis Ring',
             'Dragon Ring', 'Cerberus Ring +1', 'Adroit Ring +1', 'Cmn. Ring +1',
             'Hades Ring +1', 'Gld.Msk. Ring', 'Tiger Ring', 'Allure Ring +1',
             'Celerity Ring +1', 'Kshama Ring No.4', 'Marid Ring +1', 'Earth Ring', 'Fire Ring',
             'Marksman\'s Ring', 'Alacrity Ring +1', 'Aura Ring +1', 'Deft Ring +1',
             'Loyalty Ring +1', 'Puissance Ring +1', 'Solace Ring +1', 'Verve Ring +1',
             'Leather Ring +1', 'Safeguard Ring', 'San d\'Orian Ring', 'Armored Ring',
             'Balance Ring +1', 'Courage Ring +1', 'Kshama Ring No.2', 'Kshama Ring No.3',
             'Kshama Ring No.5', 'Bowyer Ring', 'Carect Ring', 'Beetle Ring', 'Beetle Ring +1',
             'Protean Ring', 'Variable Ring' },
        Back  = { 'Aslan Cape', 'Blue Cape +1', 'Solitaire Cape', 'Blue Cape',
             'Bellicose Mantle', 'Umbra Cape', 'Hexerei Cape', 'Cheviot Cape', 'Shadow Mantle',
             'Mahatma Cape', 'Black Mantle +1', 'Feral Mantle', 'Errant Cape', 'Corse Cape',
             'Black Mantle', 'Lamia Mantle +1', 'Beak Mantle +1', 'Ryl. Army Mantle',
             'Cvl. Mantle +1', 'Commander\'s Cape', 'Beak Mantle', 'Cvl. Mantle',
             'Lightning Mantle', 'Dino Mantle', 'Fed. Army Mantle', 'Jester\'s Cape +1',
             'Volitional Mantle', 'Raptor Mantle', 'Bat Cape', 'Aurora Mantle +1',
             'Sentinel\'s Mantle', 'Jester\'s Cape', 'Aurora Mantle', 'Red Cape +1',
             'Ram Mantle', 'Ram Mantle +1', 'Wolf Mantle +1', 'Dodge Cape', 'Tundra Mantle',
             'Black Cape +1', 'White Cape +1', 'Invisible Mantle', 'Wolf Mantle',
             'Dhalmel Mantle +1', 'Nomad\'s Mantle +1', 'Night Cape', 'Variable Mantle',
             'Cotton Cape +1', 'Dhalmel Mantle', 'Lizard Mantle +1', 'Mist Silk Cape',
             'Nomad\'s Mantle', 'Variable Cape', 'Cotton Cape', 'Talisman Cape', 'Lizard Mantle' },
        Waist = { 'Penitent\'s Rope', 'Quick Belt', 'Forest Rope', 'Star Sash', 'Anrin Obi',
             'Dorin Obi', 'Furin Obi', 'Hyorin Obi', 'Karin Obi', 'Korin Obi', 'R.K. Belt +2',
             'Earth Belt', 'Fire Belt', 'Ice Belt', 'Lightning Belt', 'Water Belt', 'Wind Belt',
             'Prism Obi', 'R.K. Belt +1', 'Twinthread Obi +1', 'Ryl.Kgt. Belt',
             'Brocade Obi +1', 'Swordbelt +1', 'Corsette +1', 'Qiqirn Sash +1',
             'Flagellant\'s Rope', 'Twinthread Obi', 'Storm Belt', 'Brocade Obi', 'Swordbelt',
             'Corsette', 'Gold Obi +1', 'Silver Belt +1', 'Steppe Stone', 'Oracle\'s Belt',
             'Deduct. Gold Obi', 'Enthrall. Gold Obi', 'Gold Obi', 'Sagac. Gold Obi',
             'Silver Belt', 'Mohbwa Sash +1', 'Silver Obi +1', 'Magic Belt +1',
             'Lizard Belt +1', 'Shaman\'s Belt', 'Mohbwa Sash', 'Silver Obi', 'Magic Belt',
             'Lizard Belt', 'Friar\'s Rope', 'Heko Obi +1', 'Augmenting Belt', 'Leather Belt +1' },
        Legs  = { 'Zenith Slacks +1', 'Zenith Slacks', 'Akinji Salvars', 'Jaridah Salvars',
             'Frog Trousers', 'Goliard Trews', 'Dst. Subligar +1', 'Darksteel Subligar',
             'Bahamut\'s Hose', 'Byakko\'s Haidate', 'Mahatma Slops', 'Mrc. Subligar',
             'Errant Slops', 'Beak Trousers +1', 'Feral Trousers', 'Beak Trousers',
             'Femina Subligar', 'Vir Subligar', 'Tiger Trousers', 'Luna Subligar',
             'Battle Hose +1', 'Tabin Hose +1', 'Dino Trousers', 'Battle Hose', 'Ice Trousers',
             'Raptor Trousers', 'Silk Slops +1', 'T.M. Slops +2', 'Wool Hose +1',
             'Cpc. Subligar +1', 'Blaze Hose', 'Wool Hose', 'Cuir Trousers +1', 'Cuir Trousers',
             'Mage\'s Slops', 'Hose +1', 'Iron Subligar +1', 'Velvet Slops', 'Hose',
             'Iron Subligar', 'Shade Tights +1', 'Wool Slops +1', 'Kingdom Trousers',
             'Shade Tights', 'Wool Slops', 'Republic Subligar', 'San. Trousers', 'Great Brais',
             'Fine Trousers', 'Bone Subligar +1', 'Lizard Trousers', 'Bone Subligar',
             'Angler\'s Hose', 'Nomad\'s Hose', 'Rider\'s Hose', 'Worker Hose' },
        Feet  = { 'Zenith Pumps +1', 'Zenith Pumps', 'Rostrum Pumps', 'Mahatma Pigaches',
             'Errant Pigaches', 'Akinji Nails', 'Jaridah Nails', 'Dst. Leggings +1',
             'Suzaku\'s Sune-Ate', 'Dst. Leggings', 'Marduk\'s Crackows', 'Goliard Clogs',
             'Rutter Sabatons', 'Bk. Ledelsens +1', 'Feral Ledelsens', 'Battle Boots +1',
             'Tabin Boots +1', 'Beak Ledelsens', 'Caitiff\'s Socks', 'Tiger Ledelsens',
             'Battle Boots', 'Tabin Boots', 'Dino Ledelsens', 'Wulong Shoes +1',
             'Raptor Ledelsens', 'Wool Socks +1', 'Cpc. Leggings +1', 'Wulong Shoes',
             'Wool Socks', 'Cpc. Leggings', 'C.C. Shoes +2', 'Cuir Highboots +1',
             'Powder Boots', 'C.C. Shoes +1', 'Cuir Highboots', 'Ebony Sabots +1', 'Socks +1',
             'Leggings +1', 'Rubious Pumps', 'Ebony Sabots', 'Shade Leggings +1',
             'Air Solea +1', 'Chs. Sabots +1', 'Shade Leggings', 'Winged Boots +1',
             'Great Gaiters', 'Btl. Leggings +1', 'Elder\'s Sandals', 'Fine Ledelsens',
             'Bone Leggings +1', 'Garrison Boots', 'Lizard Ledelsens', 'Bone Leggings',
             'Light Soleas', 'Holly Clogs +1', 'Brass Leggings +1' },
    },
    -- Minstrel's Ring cuts song cast time by 25%, but only while HP is
    -- under 76% and TP under 100%. Equipping max-HP gear raises max HP
    -- without raising current HP, which drops the percentage and can trip
    -- the latent. Ring1 is left free for the ring itself.
    ['MinstrelHP_Priority'] = {
        Head  = { 'Genbu\'s Kabuto', 'Dusk Mask +1', 'Troll Coif', 'Walahra Turban',
             'Dusk Mask', 'Curate\'s Hat', 'Goliard Chapeau', 'Roshi Jinpachi +1', 'Kosshin',
             'Magi Hat', 'Silken Hat', 'Mirage Keffiyeh', 'Oracle\'s Cap', 'Walkure Mask',
             'Trump Crown', 'Tabin Beret +1', 'Choral Roundlet', 'Tabin Beret',
             'Corsair\'s Tricorne', 'Kingdom Bandana', 'Coven Hat', 'Super Ribbon',
             'Scorpion Mask +1', 'San. Bandana', 'Scorpion Mask', 'Republic Cap',
             'Bastokan Cap' },
        Neck  = { 'Chanoix\'s Gorget', 'Rho Necklace', 'Ritter Gorget', 'Tempered Chain',
             'Shield Pendant', 'Windurstian Scarf', 'Bloodbead Amulet', 'Grandiose Chain',
             'Promise Badge', 'Paisley Scarf', 'Evasion Torque', 'Guarding Torque',
             'Parrying Torque', 'Shield Torque', 'Bird Whistle', 'Green Scarf',
             'Buffoon\'s Collar' },
        Ear1  = { 'Morukaka Earring', 'Wrestler\'s Earring', 'Pigeon Earring +1',
             'Bloodbead Earring', 'Stoic Earring', 'Pigeon Earring', 'Esquire\'s Earring',
             'Ethereal Earring', 'Insomnia Earring', 'Hvn. Earring +1', 'Heavens Earring',
             'Angel\'s Earring', 'Ryakho\'s Earring', 'Allure Earring +1', 'Shield Earring',
             'Allure Earring', 'Moon Earring', 'Lyt. Earring +1', 'Enhancing Earring',
             'Bull Earring', 'Loyalty Earring', 'Hope Earring +1', 'Valor Earring',
             'Hope Earring', 'Opal Earring' },
        Ear2  = { 'Morukaka Earring', 'Wrestler\'s Earring', 'Pigeon Earring +1',
             'Bloodbead Earring', 'Stoic Earring', 'Pigeon Earring', 'Esquire\'s Earring',
             'Ethereal Earring', 'Insomnia Earring', 'Hvn. Earring +1', 'Heavens Earring',
             'Angel\'s Earring', 'Ryakho\'s Earring', 'Allure Earring +1', 'Shield Earring',
             'Allure Earring', 'Moon Earring', 'Lyt. Earring +1', 'Enhancing Earring',
             'Bull Earring', 'Loyalty Earring', 'Hope Earring +1', 'Valor Earring',
             'Hope Earring', 'Opal Earring' },
        Body  = { 'Goliard Saio', 'Dusk Jerkin +1', 'Dusk Jerkin', 'Wonder Kaftan',
             'Custom Tunic', 'Custom Vest', 'Savage Separates', 'Magna Bodice', 'Magna Jerkin',
             'Magi Coat', 'Silken Coat', 'Chl. Jstcorps +1', 'Corsair\'s Frac +1',
             'Oracle\'s Robe', 'Hydra Jupon', 'Scp. Harness +1', 'Hct. Harness +1',
             'Minstrel\'s Coat', 'Aketon +1', 'Corsair\'s Frac', 'Justaucorps +1',
             'Scorpion Harness', 'Brigandine +1', 'Silk Cloak +1', 'Choral Jstcorps',
             'Aketon', 'Healing Jstcorps', 'Brigandine', 'Faerie Tunic', 'Kingdom Vest',
             'Republic Harness', 'Bastokan Harness' },
        Hands = { 'Creek F Mitts', 'Creek M Mitts', 'River Gauntlets', 'Seiryu\'s Kote',
             'Alkyoneus\'s Brc.', 'Feronia\'s Bangles', 'Pallas\'s Bracelets',
             'Garden Bangles', 'Wood Gauntlets', 'Wood Gloves', 'Pantin Dastanas +1',
             'Enkelados\'s Brc.', 'Dusk Gloves +1', 'Dusk Gloves', 'Toad Mittens',
             'Magical Mitts', 'Ogygos\'s Brc.', 'Pup. Dastanas +1',
             'C.C. Mitts +2', 'Oracle\'s Gloves', 'Light Gauntlets',
             'Gigas Bracelets', 'C.C. Mitts +1', 'Magi Cuffs', 'Silken Cuffs',
             'Custom F Gloves', 'Custom M Gloves', 'Wonder Mitts', 'Sly Gauntlets',
             'Kingdom Gloves', 'Scp. Mittens +1', 'San. Gloves', 'Scorpion Mittens',
             'Republic Mittens', 'Bastokan Mittens' },
        Ring2 = { 'Bomb Queen Ring', 'Bloodbead Ring', 'Multiple Ring', 'Getsul Ring',
             'Light Ring', 'Ebullient Ring', 'Sattva Ring', 'Bomb Ring', 'Demon\'s Ring +1',
             'Behemoth Ring +1', 'Triton Ring', 'Behemoth Ring', 'Orichalcum Ring',
             'Poseidon\'s Ring', 'Demon\'s Ring', 'Toreador\'s Ring', 'Horizon Ring',
             'Platinum Ring +1', 'Gold Ring +1', 'Gold Ring', 'Mythril Ring +1', 'Mythril Ring',
             'Silver Ring +1', 'Poisona Ring', 'Silver Ring', 'Brass Ring +1', 'Bastokan Ring',
             'Brass Ring' },
        Back  = { 'Gigant Mantle', 'Lieutenant\'s Cape', 'High Brth. Mantle',
             'Behem. Mantle +1', 'Intensifying Cape', 'Storm Mantle', 'Gleeman\'s Cape',
             'Behemoth Mantle', 'Breath Mantle', 'Empwr. Mantle +1', 'Desert Mantle +1',
             'Prism Cape', 'Empwr. Mantle', 'Desert Mantle', 'Enhancing Mantle',
             'Rainbow Cape', 'Lucent Cape', 'Marid Mantle +1', 'Rep. Army Mantle',
             'Marid Mantle' },
        Waist = { 'Steppe Sash', 'Jungle Sash', 'Ocean Sash', 'Steppe Belt', 'Desert Sash',
             'Forest Sash', 'Jungle Belt', 'Ocean Belt', 'Kaiser Belt', 'Marid Belt +1',
             'Marid Belt', 'Czar\'s Belt', 'Koenigs Belt', 'Maharaja\'s Belt',
             'Pendragon\'s Belt', 'Sultan\'s Belt', 'Desert Belt', 'Forest Belt',
             'Powerful Rope', 'Survival Belt', 'Lieutenant\'s Sash', 'Trance Belt',
             'Adept\'s Rope', 'Blood Stone +1', 'Blood Stone', 'Warrior\'s Belt +1',
             'Force Belt', 'Warrior\'s Belt' },
        Legs  = { 'Dusk Trousers +1', 'Dusk Trousers', 'Prince\'s Slops', 'Yigit Seraweels',
             'Vendor\'s Slops', 'Wonder Braccae', 'Galliard Trousers', 'Hct. Subligar +1',
             'Hecatomb Subligar', 'Choral Cannions', 'Federation Brais', 'Magna F Chausses',
             'Magna M Chausses', 'Magi Slops', 'Silken Slops', 'Windurstian Brais',
             'Sturdy Trousers', 'Silk Slacks +1', 'Silk Slacks', 'Sturdy Slacks',
             'Scp. Subligar +1', 'Scorpion Subligar' },
        Feet  = { 'Marine F Boots', 'Marine M Boots', 'Root Sabots', 'Creek F Clomps',
             'Creek M Clomps', 'Dusk Ledelsens +1', 'Dusk Ledelsens', 'Marid Leggings +1',
             'Ataractic Solea', 'Marid Leggings', 'Wonder Clomps', 'Savage Gaiters',
             'Oracle\'s Pigaches', 'Magi Pigaches', 'Silken Pigaches', 'Chl. Slippers +1',
             'Hydra Boots', 'Choral Slippers', 'Hct. Leggings +1', 'Hct. Leggings',
             'Kingdom Boots', 'Scp. Leggings +1', 'Custom F Boots', 'Custom M Boots',
             'Kingdom Clogs', 'San d\'Orian Boots', 'Scorpion Leggings', 'Pigaches +1',
             'San d\'Orian Clogs', 'Republic Leggings', 'Bas. Leggings' },
    },
    -- The +HP swap and the ring have to come back off after the song. The
    -- standing gear cannot always refill these slots -- if nothing in the
    -- list is carried the slot simply keeps what it had -- so they are
    -- cleared explicitly, and the standing gear fills what it can.
    ['MinstrelClear'] = {
        Neck  = 'remove',
        Ear1  = 'remove',
        Ear2  = 'remove',
        Ring1 = 'remove',
        Ring2 = 'remove',
        Back  = 'remove',
        Waist = 'remove',
    },
    ['RingProc'] = {
        Ring1 = 'Minstrel\'s Ring',
    },
};
songs = {
    ['Carol_Priority'] = {
        Range = { 'Crumhorn +1', 'Crumhorn +2', 'Crumhorn' },
    },
    ['Elegy_Priority'] = {
        Range = { 'Horn +1', 'Horn' },
    },
    ['Etude_Priority'] = {
        Range = { 'Mythic Harp +1', 'Rose Harp +1', 'Mythic Harp', 'Rose Harp' },
    },
    ['Finale_Priority'] = {
        Range = { 'Military Harp' },
    },
    ['Hymnus_Priority'] = {
        Range = { 'Angel Lyre' },
    },
    ['Lullaby_Priority'] = {
        Range = { 'Nursemaid\'s Harp', 'Mary\'s Horn' },
    },
    ['Madrigal_Priority'] = {
        Range = { 'Traversiere +1', 'Traversiere +2', 'Traversiere' },
    },
    ['Mambo_Priority'] = {
        Range = { 'Hellish Bugle +1', 'Gemshorn +1', 'Hellish Bugle', 'Gemshorn' },
    },
    ['March_Priority'] = {
        Range = { 'Faerie Piccolo', 'Kingdom Horn', 'San d\'Orian Horn',
             'Ryl.Spr. Horn' },
    },
    ['Mazurka_Priority'] = {
        Range = { 'Harlequin\'s Horn' },
    },
    ['Minne_Priority'] = {
        Range = { 'Harp +1', 'Harp', 'Maple Harp +1' },
    },
    ['Minuet_Priority'] = {
        Range = { 'Cornette +1', 'Cornette +2', 'Cornette' },
    },
    ['Paeon_Priority'] = {
        Range = { 'Ebony Harp +1', 'Ebony Harp +2', 'Ebony Harp' },
    },
    ['Prelude_Priority'] = {
        Range = { 'Angel Flute +1', 'Angel\'s Flute' },
    },
    ['Requiem_Priority'] = {
        Range = { 'Requiem Flute', 'Shofar +1', 'Shofar', 'Hamelin Flute', 'Siren Flute',
             'Flute +1', 'Flute +2' },
    },
    ['Threnody_Priority'] = {
        Range = { 'Sorrowful Harp', 'Piccolo +1', 'Piccolo' },
    },
    ['Virelai_Priority'] = {
        Range = { 'Cyt. Anglica +1', 'Cythara Anglica' },
    },
    -- Used when a song has no instrument of its own.
    ['General_Priority'] = {
        Range = { 'Cyt. Anglica +1', 'San d\'Orian Horn', 'Kingdom Horn', 'Ryl.Spr. Horn', 'Cythara Anglica', 'Hamelin Flute' },
    },
};
profile.Sets = sets;
profile.Songs = songs;

profile.Packer = {
};

evalLevel = function()
	-- Resolve both tables against level and what is actually in the bags
    local level = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    Settings.CurrentLevel = level;
    common.EvaluateGear(profile.Sets, level);
    common.EvaluateGear(staves.Sets, level);
    common.EvaluateGear(profile.Songs, level);

    common.EvalLevel(level);
end

-- Drop the cached bag scan once, then re-resolve every table the profile owns
-- against it. The first EvaluateOwned pays for the walk and repopulates the
-- cache; the rest resolve from it, so a refresh reads the bags once however
-- many tables it touches. Resolving each table with EvaluateGear(force) would
-- invalidate the shared cache again per table and walk the bags once each.
-- Returns false when the bags could not be read, in which case every set keeps
-- the gear it already had rather than being blanked.
local RefreshGear = function()
    local level = Settings.CurrentLevel;

    common.InvalidateScan();

    local ok = common.EvaluateOwned(profile.Sets, level);
    common.EvaluateOwned(profile.Songs, level);
    common.EvaluateOwned(staves.Sets, level);

    return ok;
end

local FindIdleMode = function(cmd)
    if (cmd == nil) then
        return nil;
    end

    for index, mode in ipairs(IdleModes) do
        if (mode.Cmd == cmd) then
            return index;
        end
    end

    return nil;
end

-- Switching re-resolves against the bags so a mode picks up gear acquired
-- since the last scan instead of resolving empty and silently doing nothing.
local SetIdleMode = function(index)
    Settings.IdleMode = index;

    local mode = IdleModes[index];
    if (RefreshGear()) then
        gFunc.Message('idle mode: ' .. mode.Label);
    else
        gFunc.Message('idle mode: ' .. mode.Label
            .. ' (bags unreadable, gear left as-is)');
    end
end

-- What can be typed. Built by walking the registry rather than spelled out, so
-- a mode that exists is always listed and one that is removed stops being
-- listed -- a help that has to be kept in step by hand is a help that lies.
--
-- Only what BRD actually acts on is named. ReservedCommands is deliberately
-- wider: 'acc' is reserved because common.SetMeleeOptions claims it in the jobs
-- that wire it, but BRD does not wire it, so listing it would advertise a
-- command that does nothing here.
--
-- Every Message call prints its own '[LuAshitacast]' header, so the listing is
-- kept to eight lines with the two modes registered -- the six toggles go two
-- to a row rather than one each. It grows a line per mode added, which is the
-- point: the modes are what it exists to show.
-- One column for every row, wide enough for the longest pairing ('sneak invis'
-- and 'help  modes' are both eleven) with two spaces to spare.
local HelpRow = function(marker, cmd, label)
    gFunc.Message(string.format('%s%-13s%s', marker, cmd, label));
end

local ShowHelp = function()
    gFunc.Message('/brd commands:');
    HelpRow('   ', 'help  modes', 'this list, or the idle modes alone');
    HelpRow('   ', 'gear', 'rescan the bags and report every set');

    for index, mode in ipairs(IdleModes) do
        local marker = '   ';
        if (index == Settings.IdleMode) then
            marker = ' * ';
        end
        HelpRow(marker, mode.Cmd, mode.Label);
    end

    for i = 1, #UtilityCommands, 2 do
        local a, b = UtilityCommands[i], UtilityCommands[i + 1];
        if (b == nil) then
            HelpRow('   ', a.Cmd, a.Label);
        else
            HelpRow('   ', a.Cmd .. ' ' .. b.Cmd, a.Label .. ' / ' .. b.Label);
        end
    end
end

local ListIdleModes = function()
    gFunc.Message('idle modes:');

    for index, mode in ipairs(IdleModes) do
        local marker = '   ';
        if (index == Settings.IdleMode) then
            marker = ' * ';
        end
        gFunc.Message(marker .. mode.Cmd .. '  ' .. mode.Label);
    end
end

-- A mode sharing a word with a command handled ahead of it would never fire,
-- because the earlier handler consumes the word first. Say so at load rather
-- than leaving it to be found in game.
local CheckIdleModes = function()
    for _, mode in ipairs(IdleModes) do
        for _, reserved in ipairs(ReservedCommands) do
            if (mode.Cmd == reserved) then
                gFunc.Message('idle mode "' .. mode.Cmd
                    .. '" collides with the reserved command "' .. reserved
                    .. '" and will never fire');
            end
        end
    end
end

-- Song families that have an instrument of their own. The names do not
-- overlap, so the first match wins.
local songFamilies = {
    'Carol', 'Elegy', 'Etude', 'Finale', 'Hymnus', 'Lullaby', 'Madrigal',
    'Mambo', 'March', 'Mazurka', 'Minne', 'Minuet', 'Paeon', 'Prelude',
    'Requiem', 'Threnody', 'Virelai',
};

-- Songs that land an enfeeble and can be resisted. These want magic accuracy
-- rather than raw singing skill.
local resistedSongs = { 'Lullaby', 'Elegy', 'Threnody', 'Requiem' };

equipSong = function(name)
    for _, family in ipairs(songFamilies) do
        if (string.match(name, family)) then
            -- The family may have resolved to nothing if no instrument of
            -- that kind is carried, in which case fall through rather than
            -- singing with no instrument at all.
            local set = songs[family];
            if (type(set) == 'table') and (set.Range ~= nil) then
                gFunc.EquipSet(set);
                return;
            end

            break;
        end
    end

    gFunc.EquipSet(songs.General);
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias /brd /lac fwd');

    AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. Settings.MacroBook);

    CheckIdleModes();

    -- Lock appearance a few seconds after loading
    common.RequestLockStyle(1);
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /brd');
end

profile.HandleCommand = function(args)
    -- Handle utility settings
    utility.SetOptions(args[1], Settings.MacroBook);

    -- Rescan the bags and re-resolve every gear set
    if (args[1] == 'gear') then
        RefreshGear();
        common.ReportGear(profile.Sets, Settings.CurrentLevel);
        return;
    end

    -- With no argument, or with 'help', show everything that can be typed
    if (args[1] == nil) or (args[1] == 'help') then
        ShowHelp();
        return;
    end

    -- 'modes' stays the focused list, for when only the modes matter
    if (args[1] == 'modes') then
        ListIdleModes();
        return;
    end

    -- Switch the idle mode. An unrecognised word is left alone: it may belong
    -- to a handler above, and nothing here should react to it.
    local index = FindIdleMode(args[1]);
    if (index ~= nil) then
        SetIdleMode(index);
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();

	gFunc.EquipSet(common.Sets.Dream);

	-- Strip the +HP swap once the song is done, before the standing gear is
	-- applied, so it does not sit there keeping maximum HP high.
	if (Settings.HPSwapped) then
		Settings.HPSwapped = false;
		gFunc.EquipSet(sets.MinstrelClear);
	end

	local mode = IdleModes[Settings.IdleMode];
	gFunc.EquipSet(profile.Sets[mode.Set]);

	-- Over the mode's set, not instead of it: a slot whose subjob piece is not
	-- carried keeps whatever the mode put there.
	if (mode.WHM ~= nil) and (player.SubJob == 'WHM') then
		gFunc.EquipSet(profile.Sets[mode.WHM]);
	end

	if (player.Status == 'Resting') then
		staves.EquipRestingStaff();
	end

    utility.EquipSet();
end

profile.HandleAbility = function()
	local action = gData.GetAction();
end

profile.HandleItem = function()
	local action = gData.GetAction();

	utility.CheckItem(action.Name);
end

profile.HandlePrecast = function()
	local action = gData.GetAction();

	-- Song cast time, in two stages. The low HP set goes on first and is sent
	-- straight to the server rather than through the equip buffer, so it
	-- actually lands: it takes maximum HP down and current HP is clamped to
	-- it. The +HP set then raises the maximum without raising current HP,
	-- and the percentage falls far enough to trip the Minstrel's Ring latent
	-- (HP under 76% and TP under 100%). Standing gear carries HP of its own
	-- now, which is why the low stage is needed at all. The ring goes on last
	-- so it keeps Ring1.
	if (action ~= nil) and (action.Type == 'Bard Song') then
		gFunc.ForceEquipSet(profile.Sets.MinstrelLow);
		gFunc.EquipSet(profile.Sets.MinstrelHP);
		Settings.HPSwapped = true;
	end

	gFunc.EquipSet(profile.Sets.RingProc);
end

profile.HandleMidcast = function()
	local action = gData.GetAction();

	utility.CheckCast(action.Name);

	if (action.Type == 'Bard Song') then
		local resisted = false;
		for _, song in ipairs(resistedSongs) do
			if (string.match(action.Name, song)) then
				resisted = true;
				break;
			end
		end

		if (resisted) then
			gFunc.EquipSet(profile.Sets.SongAcc);
		else
			gFunc.EquipSet(profile.Sets.Songs);
		end

		equipSong(action.Name);
	end

	staves.EquipStaff(action);
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;
