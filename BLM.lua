local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
local lists = gFunc.LoadFile('./lists.lua');
local staves = gFunc.LoadFile('./staves.lua');

local Settings = {
    MacroBook = '5',
    CurrentLevel = 0,
};

-- Gear candidates pulled from the HorizonXI wiki: every piece BLM can wear,
-- scored per set and spread across the level bands so each list resolves now
-- and upgrades itself while levelling. Levels are noted after each line.
-- Resolution is ownership-aware (common.EvaluateGear), so entries you do not
-- own cost nothing and breadth only helps.
sets = {
    -- Out of combat, where the point is getting MP back. Maximum MP leads,
    -- and mitigation settles pieces carrying the same MP: the percentage of
    -- damage taken a piece removes, with defence counted at roughly fifteen
    -- points to the percent. Refresh breaks what is still level. The Earth
    -- staff goes on top, which is physical damage taken -20%.
    ['Idle_Priority'] = {
        Head  = { 'Zenith Crown +1', 'Faerie Hairpin', 'Zenith Crown', 'Wivre Hairpin +1',
             'Valkyrie\'s Hat', 'Wivre Hairpin', 'Shadow Hat', 'Gold Hairpin +1',
             'Wzd. Petasos +1', 'Walahra Turban', 'Carline Ribbon', 'Gold Hairpin',
             'Wizard\'s Petasos', 'Electrum Hairpin', 'Merman\'s Hairpin', 'Mana Circlet',
             'Coral Hairpin', 'Reraise Hairpin', 'Magus Keffiyeh', 'Kosshin', 'Rain Hat',
             'Magi Hat', 'Silken Hat', 'Storm Turban', 'Rival Ribbon', 'Silver Hairpin +1',
             'Silver Hairpin', 'Trump Crown', 'Horn Hairpin +1', 'Eld. Horn Hairpin',
             'Horn Hairpin', 'Brass Hairpin +1', 'Shell Hairpin +1', 'Brass Hairpin',
             'Shell Hairpin', 'Circe\'s Hat', 'Copper Hairpin +1', 'Lgn. Circlet',
             'Super Ribbon', 'Copper Hairpin', 'Bone Hairpin +1', 'Bone Hairpin',
             'Macha\'s Crown', 'Bodb\'s Crown', 'Dartorgor\'s Coif', 'Neit\'s Crown',
             'Corsair\'s Hat +1', 'Corsair\'s Hat', 'Mage\'s Hat', 'Wool Hat +1',
             'Jgl. Headband', 'Wool Hat', 'Jester\'s Headband', 'Baron\'s Chapeau',
             'Blissful Chapeau', 'Gala Corsage' },
        Neck  = { 'Rep.Gold Medal', 'Morgana\'s Choker', 'Beak Necklace +1', 'Beak Necklace',
             'Chi Necklace', 'Uggalepih Pendant', 'Star Necklace', 'Rep.Mythril Medal',
             'M. No.17\'s Locket', 'Grandiose Chain', 'Spirit Torque', 'Holy Phial',
             'Mohbwa Scarf +1', 'Rep.Iron Medal', 'Mohbwa Scarf', 'Rep.Bronze Medal',
             'Rho Necklace', 'Wivre Gorget +1', 'Tempered Chain', 'Wivre Gorget',
             'Harmonia\'s Torque', 'Hateful Collar', 'Torque +1', 'Auditory Torque',
             'Brisingamen +1', 'Chivalrous Chain', 'Fortified Chain', 'Stoneskin Torque',
             'Torque', 'Clay Amulet', 'Stone Gorget', 'Memento Muffler', 'Promise Badge',
             'Medieval Collar', 'Van Pendant', 'Paisley Scarf', 'Tiger Stole',
             'Black Neckerchief', 'Feather Collar +1', 'Green Scarf', 'Yinyang Lorgnette',
             'Dog Collar', 'Feather Collar', 'Justice Badge', 'Regen Collar',
             'Windurstian Scarf', 'Bloodbead Amulet', 'Evasion Torque', 'Shield Pendant' },
        Ear1  = lists.Idle.Ear,
        Ear2  = lists.Idle.Ear,
        Body  = { 'Dalmatica +1', 'Dalmatica', 'Goliard Saio', 'Hydra Doublet', 'Wzd. Coat +1',
             'Elder\'s Surcoat', 'Flora Cotehardie', 'Shaman\'s Cloak', 'Black Cotehardie',
             'Magi Coat', 'Silken Coat', 'Hydra Jupon', 'Oracle\'s Robe', 'T.M. Coat +2',
             'T.M. Coat +1', 'Wizard\'s Coat', 'Sorcerer\'s Coat', 'Ryl.Sqr. Robe +2',
             'Ryl.Sqr. Robe +1', 'Ryl.Sqr. Robe', 'Seer\'s Tunic +1', 'Pyro Robe',
             'Seer\'s Tunic', 'Frost Robe', 'Kingdom Tunic', 'Bishop\'s Robe +1',
             'Magna Bodice', 'Magna Jerkin', 'San d\'Orian Tunic', 'Mage\'s Robe',
             'Bishop\'s Robe', 'Black Cloak', 'Silk Cloak +1', 'C.C. Cloak +2', 'C.C. Cloak +1',
             'Cmb.Cst. Cloak', 'Cloak +1', 'Faerie Tunic', 'Wool Robe +1', 'Mage\'s Tunic',
             'Wool Robe', 'Black Tunic', 'Bodb\'s Robe', 'Garrison Tunica', 'Priest\'s Robe',
             'Angler\'s Tunica', 'Nomad\'s Tunica', 'Rider\'s Jack Coat', 'Worker Tunica',
             'Argent Coat' },
        Hands = { 'Dune Bracers', 'Zenith Mitts +1', 'Wood Gauntlets', 'Wood Gloves',
             'Zenith Mitts', 'Marine F Gloves', 'Marine M Gloves', 'Elder\'s Bracers',
             'Morrigan\'s Cuffs', 'Mahatma Cuffs', 'Oracle\'s Gloves', 'Sorcerer\'s Gloves',
             'Magna Gauntlets', 'Magna Gloves', 'Storm Gages', 'Errant Cuffs', 'Magical Mitts',
             'Wzd. Gloves +1', 'Savage Gauntlets', 'Magi Cuffs', 'Wizard\'s Gloves',
             'Silken Cuffs', 'New Moon Armlets', 'Devotee\'s Mitts', 'Zealot\'s Mitts',
             'Custom F Gloves', 'Custom M Gloves', 'Baron\'s Cuffs', 'Macha\'s Cuffs',
             'Nemain\'s Cuffs', 'Merman\'s Bangles', 'Prt. Bangles', 'Coral Bangles',
             'Storm Manopolas', 'Light Gauntlets', 'Sadhu Cuffs', 'Turtle Bangles +1',
             'Turtle Bangles', 'C.C. Mitts +2', 'Silver Bangles +1', 'Concealing Cuffs',
             'C.C. Mitts +1', 'Palmer\'s Bangles', 'Silver Bangles', 'Mage\'s Cuffs',
             'Sennight Bangles', 'Velvet Cuffs', 'Linen Mitts +1', 'Linen Mitts',
             'Scentless Armlets', 'Linen Cuffs +1', 'Angler\'s Gloves', 'Nomad\'s Gloves',
             'Rider\'s Gloves', 'Worker Gloves' },
        Ring1 = { 'Vivian Ring', 'Serket Ring', 'Ether Ring', 'Variable Ring', 'Vilma\'s Ring',
             'Astral Ring', 'Dark Ring', 'Celestial Ring', 'Star Ring', 'Zoredonite Ring',
             'Carect Ring', 'Electrum Ring', 'Ebullient Ring', 'Mana Ring', 'Tamas Ring',
             'Serene Ring', 'Demon\'s Ring +1', 'Hades Ring +1', 'Demon\'s Ring',
             'Poseidon\'s Ring', 'Horizon Ring', 'Peace Ring', 'Fasting Ring', 'Mystic Ring +1',
             'Hades Ring', 'Manashell Ring', 'Death Ring', 'Aura Ring +1', 'Mystic Ring',
             'Painite Ring', 'Kshama Ring No.6', 'Energy Ring +1', 'Kshama Ring No.5',
             'Kshama Ring No.9', 'Aura Ring', 'Black Ring', 'Energy Ring', 'Windurstian Ring',
             'Onyx Ring', 'Defending Ring', 'Sattva Ring', 'Jelly Ring', 'Gobniu\'s Ring',
             'Dragon Ring +1', 'Gld.Msk. Ring', 'Kshama Ring No.4', 'Bomb Ring',
             'Alacrity Ring +1', 'Deft Ring +1', 'Loyalty Ring +1', 'Mythril Ring',
             'Mythril Ring +1' },
        Ring2 = { 'Vivian Ring', 'Serket Ring', 'Ether Ring', 'Variable Ring', 'Vilma\'s Ring',
             'Astral Ring', 'Dark Ring', 'Celestial Ring', 'Star Ring', 'Zoredonite Ring',
             'Carect Ring', 'Electrum Ring', 'Ebullient Ring', 'Mana Ring', 'Tamas Ring',
             'Serene Ring', 'Demon\'s Ring +1', 'Hades Ring +1', 'Demon\'s Ring',
             'Poseidon\'s Ring', 'Horizon Ring', 'Peace Ring', 'Fasting Ring', 'Mystic Ring +1',
             'Hades Ring', 'Manashell Ring', 'Death Ring', 'Aura Ring +1', 'Mystic Ring',
             'Painite Ring', 'Kshama Ring No.6', 'Energy Ring +1', 'Kshama Ring No.5',
             'Kshama Ring No.9', 'Aura Ring', 'Black Ring', 'Energy Ring', 'Windurstian Ring',
             'Onyx Ring', 'Defending Ring', 'Sattva Ring', 'Jelly Ring', 'Gobniu\'s Ring',
             'Dragon Ring +1', 'Gld.Msk. Ring', 'Kshama Ring No.4', 'Bomb Ring',
             'Alacrity Ring +1', 'Deft Ring +1', 'Loyalty Ring +1', 'Mythril Ring',
             'Mythril Ring +1' },
        Back  = { 'Blue Cape +1', 'Mahatma Cape', 'Errant Cape', 'Birdman Cape', 'Blue Cape',
             'Intensifying Cape', 'Storm Cape', 'Altruistic Cape', 'Astute Cape',
             'Merciful Cape', 'Lieutenant\'s Cape', 'Aslan Cape', 'Erato\'s Cape',
             'Miraculous Cape', 'Aurora Mantle +1', 'Talisman Cape', 'Aurora Mantle',
             'Lucent Cape', 'Esoteric Mantle', 'Fed. Army Mantle', 'Tundra Mantle',
             'Invigorating Cape', 'Umbra Cape', 'Cheviot Cape', 'Ryl. Army Mantle',
             'Rep. Army Mantle', 'Jester\'s Cape +1', 'Storm Mantle', 'Jester\'s Cape',
             'Red Cape +1', 'Dodge Cape', 'Green Cape', 'Red Cape', 'Rearguard Mantle',
             'Black Cape +1', 'White Cape +1', 'Midnight Cape', 'Black Cape', 'White Cape',
             'Sarcenet Cape', 'Cotton Cape +1', 'Mist Silk Cape', 'Ashigaru Mantle',
             'Variable Cape', 'Cotton Cape', 'Cape +1', 'Cape' },
        Waist = { 'Forest Rope', 'Desert Rope', 'Lambda Sash', 'Hierarch Belt', 'Jungle Rope',
             'Ocean Rope', 'Desert Stone', 'Forest Stone', 'Steppe Rope', 'Jungle Stone',
             'Ocean Stone', 'Immortal\'s Sash', 'Steppe Stone', 'Storm Sash', 'Powerful Rope',
             'Lieutenant\'s Sash', 'Qiqirn Sash +1', 'Qiqirn Sash', 'Mohbwa Sash +1',
             'Talisman Obi', 'Spectral Belt', 'Hojutsu Belt', 'Mohbwa Sash', 'Adept\'s Rope',
             'Oracle\'s Belt', 'Magic Belt +1', 'Shaman\'s Belt', 'Friar\'s Rope', 'Force Belt',
             'Magic Belt', 'Earth Belt', 'Fire Belt', 'Ice Belt', 'Lightning Belt',
             'Water Belt', 'Wind Belt', 'Desert Belt', 'Forest Belt', 'Brocade Obi +1',
             'Corsette +1', 'Brocade Obi', 'Corsette', 'Gold Obi +1', 'Deduct. Gold Obi',
             'Enthrall. Gold Obi', 'Gold Obi', 'Sagac. Gold Obi', 'Mrc.Cpt. Belt',
             'Silver Obi +1', 'Lizard Belt +1', 'Silver Obi', 'Lizard Belt', 'Heko Obi +1',
             'Heko Obi' },
        Legs  = { 'Zenith Slacks +1', 'Zenith Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth', 'Prince\'s Slops', 'Goliard Trews', 'Vendor\'s Slops',
             'Yigit Seraweels', 'Oracle\'s Braconi', 'Morrigan\'s Slops', 'Elder\'s Braguette',
             'Wizard\'s Tonban', 'Magna F Chausses', 'Magna M Chausses', 'Magi Slops',
             'Silken Slops', 'Seer\'s Slacks +1', 'Seer\'s Slacks', 'Sturdy Slacks',
             'Federation Slops', 'Freesword\'s Slops', 'Windurstian Slops', 'Mage\'s Slops',
             'Aries Subligar', 'Macha\'s Slops', 'Bodb\'s Slops', 'Nemain\'s Slops',
             'Femina Subligar', 'Vir Subligar', 'Silk Slacks +1', 'Silk Slacks',
             'Druid\'s Slops', 'Silk Slops +1', 'T.M. Slops +2', 'C.C. Slacks +2',
             'C.C. Slacks +1', 'Cmb.Cst. Slacks', 'Magic Slacks', 'Wool Slops +1', 'Wool Slops',
             'Martial Slacks', 'Baron\'s Slops', 'Mage\'s Slacks', 'Angler\'s Hose',
             'Nomad\'s Hose', 'Rider\'s Hose', 'Argent Hose', 'Platino Hose', 'Ceremonial Hose',
             'Opaline Hose' },
        Feet  = { 'Zenith Pumps +1', 'Zenith Pumps', 'River Gaiters', 'Rostrum Pumps',
             'Wood F Ledelsens', 'Wood M Ledelsens', 'Mahatma Pigaches', 'Oracle\'s Pigaches',
             'Ataractic Solea', 'Morrigan\'s Pgch.', 'Errant Pigaches', 'Wzd. Sabots +1',
             'Wizard\'s Sabots', 'Mgn. F Ledelsens', 'Mgn. M Ledelsens', 'Magi Pigaches',
             'Inferno Sabots +1', 'Silken Pigaches', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Elder\'s Sandals', 'Inferno Sabots', 'Seer\'s Pumps +1',
             'Kingdom Clogs', 'Seer\'s Pumps', 'Macha\'s Pigaches', 'Nemain\'s Sabots',
             'Root Sabots', 'Desert Boots +1', 'Desert Boots', 'Caitiff\'s Socks',
             'Vampire Boots', 'T.M. Pigaches +2', 'Storm Crackows', 'Pigaches +1',
             'T.M. Pigaches +1', 'C.C. Shoes +2', 'C.C. Shoes +1', 'Ebony Sabots +1',
             'Cmb.Cst. Shoes', 'Ebony Sabots', 'Mountain Gaiters', 'Shoes +1', 'Shoes',
             'Garrison Boots', 'Light Soleas', 'Holly Clogs +1', 'Ceremonial Boots',
             'Opaline Boots', 'Power Sandals', 'Angler\'s Boots', 'Nomad\'s Boots',
             'Rider\'s Boots' },
    },
    -- Fast cast, worn during the precast phase of every spell.
    ['Precast_Priority'] = {
        Ear1  = { 'Loquac. Earring' },
        Ear2  = { 'Loquac. Earring' },
        Feet  = { 'Rostrum Pumps' },
    },
    -- Elemental magic -- magic attack, INT and elemental skill.
    ['Nuke_Priority'] = {
        Head  = { 'Morrigan\'s Coron.', 'Sorcerer\'s Petas.', 'Yigit Turban', 'Opo-opo Crown',
             'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon', 'T.M. Hat +1',
             'T.M. Hat +2', 'Neit\'s Crown', 'Macha\'s Crown',
             'Bastokan Circlet', 'Republic Circlet', 'Seer\'s Crown', 'Seer\'s Crown +1',
             'Bodb\'s Crown', 'Erd. Headband', 'Sage\'s Circlet', 'Eld. Bone Hairpin' },
        Neck  = { 'Prudence Torque', 'Jeweled Collar +1', 'Elemental Torque', 'Philomath Stole',
             'Enlightened Chain', 'Stoneskin Torque', 'Torque', 'Torque +1', 'Mohbwa Scarf',
             'Mohbwa Scarf +1', 'Black Neckerchief' },
        Ear1  = { 'Novio Earring', 'Static Earring', 'Abyssal Earring', 'Omn. Earring',
             'Omn. Earring +1', 'Phantom Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Boroka Earring', 'Heims Earring', 'Elemental Earring',
             'Morion Earring', 'Morion Earring +1', 'Cunning Earring' },
        Ear2  = { 'Novio Earring', 'Static Earring', 'Abyssal Earring', 'Omn. Earring',
             'Omn. Earring +1', 'Phantom Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Boroka Earring', 'Heims Earring', 'Elemental Earring',
             'Morion Earring', 'Morion Earring +1', 'Cunning Earring' },
        Body  = { 'Morrigan\'s Robe', 'Genie Weskit', 'Igqira Weskit', 'Black Cloak',
             'Black Cotehardie', 'Flora Cotehardie', 'Shaman\'s Cloak',
             'C.C. Cloak +1', 'C.C. Cloak +2',
             'Ryl.Sqr. Robe +1', 'Mage\'s Robe', 'Macha\'s Coat', 'Custom Tunic',
             'Bodb\'s Robe', 'Baron\'s Saio', 'Black Tunic', 'Kingdom Tunic',
             'San d\'Orian Tunic', 'Ryl.Ftm. Tunic' },
        Hands = { 'Genie Manillas', 'Igqira Manillas', 'Yigit Gages',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Marine F Gloves',
             'Wizard\'s Gloves', 'Mage\'s Mitts', 'Sly Gauntlets', 'Sennight Bangles',
             'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Epsilon Ring', 'Breeze Ring', 'Dark Ring', 'Serene Ring', 'Ice Ring',
             'Vivian Ring', 'Zoredonite Ring', 'Genius Ring', 'Genius Ring +1',
             'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring', 'Malfrost Ring',
             'Tamas Ring', 'Clear Ring', 'Knowledge Ring', 'Kldg. Ring +1' },
        Ring2 = { 'Epsilon Ring', 'Breeze Ring', 'Dark Ring', 'Serene Ring', 'Ice Ring',
             'Vivian Ring', 'Zoredonite Ring', 'Genius Ring', 'Genius Ring +1',
             'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring', 'Malfrost Ring',
             'Tamas Ring', 'Clear Ring', 'Knowledge Ring', 'Kldg. Ring +1' },
        Back  = { 'Maledictor\'s Shawl', 'Merciful Cape', 'Solitaire Cape', 'Sapient Cape',
             'Fed. Army Mantle', 'Gramary Cape', 'Red Cape', 'Red Cape +1', 'Black Cape',
             'Black Cape +1' },
        Waist = { 'Ksi Sash', 'Immortal\'s Sash', 'Al Zahbi Sash', 'Arachne Obi',
             'Arachne Obi +1', 'Bitter Corset', 'Desert Belt', 'Desert Stone', 'Forest Stone',
             'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Sagac. Gold Obi',
             'Mrc.Cpt. Belt', 'Shaman\'s Belt' },
        Legs  = { 'Shadow Trews', 'Valkyrie\'s Trews', 'Sorcerer\'s Tonban', 'Druid\'s Slops',
             'Magic Slacks', 'Macha\'s Slops', 'Elder\'s Braguette', 'Seer\'s Slacks',
             'Seer\'s Slacks +1', 'Bodb\'s Slops' },
        Feet  = { 'Nashira Crackows', 'Goliard Clogs', 'Yigit Crackows', 'Creek F Clomps',
             'Creek M Clomps', 'Marine F Boots', 'T.M. Pigaches +1',
             'T.M. Pigaches +2', 'Wizard\'s Sabots', 'Inferno Sabots',
             'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Elder\'s Sandals', 'Garrison Boots' },
    },
    -- Magic accuracy and INT for sleeps and binds.
    ['Enfeebling_Priority'] = {
        Head  = { 'Morrigan\'s Coron.', 'Nashira Turban', 'Shadow Hat', 'Opo-opo Crown',
             'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon', 'T.M. Hat +1',
             'Storm Zucchetto', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Macha\'s Crown',
             'Eld. Horn Hairpin', 'Seer\'s Crown', 'Seer\'s Crown +1', 'Bodb\'s Crown',
             'Erd. Headband', 'Sage\'s Circlet', 'Eld. Bone Hairpin' },
        Neck  = { 'Prudence Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Lieut. Gorget', 'Enfeebling Torque', 'Spider Torque', 'Stoneskin Torque',
             'Torque', 'Torque +1', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Yinyang Lorgnette',
             'Holy Phial', 'Fang Necklace', 'Black Neckerchief', 'Justice Badge' },
        Ear1  = { 'Abyssal Earring', 'Static Earring', 'Omn. Earring',
             'Omn. Earring +1', 'Diabolos\'s Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Ryakho\'s Earring', 'Boroka Earring', 'Heims Earring',
             'Harvest Earring', 'Enfeebling Earring', 'Morion Earring', 'Morion Earring +1',
             'Cunning Earring' },
        Ear2  = { 'Abyssal Earring', 'Static Earring', 'Omn. Earring',
             'Omn. Earring +1', 'Diabolos\'s Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Ryakho\'s Earring', 'Boroka Earring', 'Heims Earring',
             'Harvest Earring', 'Enfeebling Earring', 'Morion Earring', 'Morion Earring +1',
             'Cunning Earring' },
        Body  = { 'Nashira Manteel', 'Shadow Coat', 'Valkyrie\'s Coat', 'Black Cloak',
             'Black Cotehardie', 'Flora Cotehardie', 'Shaman\'s Cloak',
             'C.C. Cloak +1', 'C.C. Cloak +2', 'Cmb.Cst. Cloak',
             'Mage\'s Robe', 'Macha\'s Coat', 'Custom Tunic', 'Bodb\'s Robe', 'Baron\'s Saio',
             'Black Tunic', 'Kingdom Tunic', 'San d\'Orian Tunic', 'Ryl.Ftm. Tunic' },
        Hands = { 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Goliard Cuffs',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Mage\'s Mitts', 'Sly Gauntlets', 'Sennight Bangles', 'Seer\'s Mitts',
             'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Dark Ring', 'Flame Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Ptr.Prt. Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 9', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malfrost Ring', 'Tamas Ring', 'Carect Ring', 'Clear Ring', 'Knowledge Ring',
             'Kldg. Ring +1' },
        Ring2 = { 'Dark Ring', 'Flame Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Ptr.Prt. Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 9', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malfrost Ring', 'Tamas Ring', 'Carect Ring', 'Clear Ring', 'Knowledge Ring',
             'Kldg. Ring +1' },
        Back  = lists.Enfeebling.Back,
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Arachne Obi', 'Bitter Corset',
             'Penitent\'s Rope', 'Jungle Stone', 'Ocean Stone', 'Desert Belt', 'Reverend Sash',
             'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Sagac. Gold Obi',
             'Mrc.Cpt. Belt', 'Shaman\'s Belt', 'Friar\'s Rope' },
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews',
             'T.M. Slops +1', 'T.M. Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Macha\'s Slops', 'Elder\'s Braguette',
             'Custom Pants', 'Seer\'s Slacks', 'Seer\'s Slacks +1', 'Bodb\'s Slops' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'T.M. Pigaches +1',
             'T.M. Pigaches +2', 'Wizard\'s Sabots', 'Inferno Sabots',
             'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Elder\'s Sandals', 'Garrison Boots' },
    },
    -- Dark magic -- Drain, Aspir, Bio.
    ['Dark_Priority'] = {
        Head  = { 'Morrigan\'s Coron.', 'Nashira Turban', 'Shadow Hat', 'Opo-opo Crown',
             'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon', 'T.M. Hat +1',
             'T.M. Hat +2', 'Neit\'s Crown', 'Sinister Mask', 'Macha\'s Crown',
             'Eld. Horn Hairpin', 'Seer\'s Crown', 'Seer\'s Crown +1', 'Bodb\'s Crown',
             'Erd. Headband', 'Sage\'s Circlet', 'Eld. Bone Hairpin' },
        Neck  = { 'Prudence Torque', 'Jeweled Collar +1', 'Dark Torque', 'Lieut. Gorget',
             'Philomath Stole', 'Stoneskin Torque', 'Torque', 'Torque +1', 'Mohbwa Scarf',
             'Mohbwa Scarf +1', 'Black Neckerchief' },
        Ear1  = { 'Abyssal Earring', 'Omn. Earring', 'Omn. Earring +1',
             'Diabolos\'s Earring', 'Desamilion Earring', 'Gayanj\'s Earring', 'Boroka Earring',
             'Heims Earring', 'Dark Earring', 'Morion Earring', 'Morion Earring +1',
             'Cunning Earring' },
        Ear2  = { 'Abyssal Earring', 'Omn. Earring', 'Omn. Earring +1',
             'Diabolos\'s Earring', 'Desamilion Earring', 'Gayanj\'s Earring', 'Boroka Earring',
             'Heims Earring', 'Dark Earring', 'Morion Earring', 'Morion Earring +1',
             'Cunning Earring' },
        Body  = { 'Nashira Manteel', 'Morrigan\'s Robe', 'Shadow Coat', 'Black Cloak',
             'Black Cotehardie', 'Flora Cotehardie', 'Healing Jstcorps',
             'C.C. Cloak +1', 'C.C. Cloak +2',
             'Ryl.Sqr. Robe +1', 'Mage\'s Robe', 'Macha\'s Coat', 'Custom Tunic',
             'Bodb\'s Robe', 'Baron\'s Saio', 'Black Tunic', 'Kingdom Tunic',
             'San d\'Orian Tunic', 'Ryl.Ftm. Tunic' },
        Hands = { 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Sorcerer\'s Gloves',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Mage\'s Mitts',
             'Sly Gauntlets', 'Sennight Bangles', 'Seer\'s Mitts', 'Seer\'s Mitts +1',
             'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Epsilon Ring', 'Breeze Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring',
             'Ptr.Prt. Ring', 'Zoredonite Ring', 'Genius Ring', 'Genius Ring +1',
             'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring', 'Malfrost Ring',
             'Tamas Ring', 'Clear Ring', 'Knowledge Ring', 'Kldg. Ring +1' },
        Ring2 = { 'Epsilon Ring', 'Breeze Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring',
             'Ptr.Prt. Ring', 'Zoredonite Ring', 'Genius Ring', 'Genius Ring +1',
             'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring', 'Malfrost Ring',
             'Tamas Ring', 'Clear Ring', 'Knowledge Ring', 'Kldg. Ring +1' },
        Back  = { 'Merciful Cape', 'Prism Cape', 'Rainbow Cape', 'Sapient Cape',
             'Fed. Army Mantle', 'Gramary Cape', 'Red Cape', 'Red Cape +1', 'Black Cape',
             'Black Cape +1' },
        Waist = { 'Ksi Sash', 'Immortal\'s Sash', 'Al Zahbi Sash', 'Arachne Obi',
             'Arachne Obi +1', 'Ice Belt', 'Desert Belt', 'Desert Stone', 'Forest Stone',
             'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Sagac. Gold Obi',
             'Mrc.Cpt. Belt', 'Shaman\'s Belt' },
        Legs  = { 'Morrigan\'s Slops', 'Nashira Seraweels', 'Wzd. Tonban +1',
             'Wizard\'s Tonban', 'Magic Slacks', 'Macha\'s Slops', 'Elder\'s Braguette',
             'Seer\'s Slacks', 'Seer\'s Slacks +1', 'Bodb\'s Slops' },
        Feet  = { 'Goliard Clogs', 'Genie Huaraches', 'Igqira Huaraches', 'Creek F Clomps',
             'Creek M Clomps', 'Marine F Boots', 'T.M. Pigaches +1',
             'T.M. Pigaches +2', 'Wizard\'s Sabots', 'Inferno Sabots',
             'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Elder\'s Sandals', 'Garrison Boots' },
    },
    -- Enhancing magic skill -- Stoneskin and Blink.
    ['Enhancing_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Morrigan\'s Coron.', 'Magus Keffiyeh +1',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1',
             'Super Ribbon', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Circe\'s Hat',
             'Eld. Horn Hairpin', 'Garrison Sallet', 'Traveler\'s Hat',
             'Eld. Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Enhancing Torque', 'Enlightened Chain', 'Stoneskin Torque', 'Torque', 'Torque +1',
             'Promise Badge', 'Yinyang Lorgnette', 'Mohbwa Scarf', 'Holy Phial',
             'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = lists.Enhancing.Ear,
        Ear2  = lists.Enhancing.Ear,
        Body  = { 'Morrigan\'s Robe', 'Errant Hpl.', 'Mahatma Hpl.',
             'Black Cotehardie', 'Flora Cotehardie', 'Healing Jstcorps',
             'C.C. Cloak +1', 'C.C. Cloak +2', 'Cmb.Cst. Cloak',
             'Bishop\'s Robe', 'Bishop\'s Robe +1', 'Macha\'s Coat', 'Baron\'s Saio',
             'Priest\'s Robe' },
        Hands = { 'Yigit Gages', 'Mst.Cst. Bracelets', 'Dune Bracers',
             'Marine F Gloves', 'Magi Cuffs', 'Silk Cuffs +1', 'Seer\'s Mitts',
             'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = lists.Enhancing.Ring,
        Ring2 = lists.Enhancing.Ring,
        Back  = lists.Enhancing.Back,
        Waist = lists.Enhancing.Waist,
        Legs  = { 'Morrigan\'s Slops', 'Zenith Slacks', 'Zenith Slacks +1',
             'T.M. Slops +1', 'T.M. Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Macha\'s Slops', 'Custom Pants',
             'Custom Slacks' },
        Feet  = { 'Goliard Clogs', 'Genie Huaraches', 'Igqira Huaraches', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Cures from a healing subjob.
    ['Cure_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Morrigan\'s Coron.', 'Magus Keffiyeh +1',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1',
             'Super Ribbon', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Circe\'s Hat',
             'Eld. Horn Hairpin', 'Garrison Sallet', 'Traveler\'s Hat',
             'Eld. Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Healing Torque', 'Purgatory Collar', 'Enlightened Chain', 'Stoneskin Torque',
             'Torque', 'Torque +1', 'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1',
             'Holy Phial', 'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Magnetic Earring', 'Celestial Earring',
             'Cmn. Earring', 'Cmn. Earring +1', 'Ryakho\'s Earring',
             'Harvest Earring', 'Geist Earring', 'Healing Earring' },
        Ear2  = { 'Static Earring', 'Magnetic Earring', 'Celestial Earring',
             'Cmn. Earring', 'Cmn. Earring +1', 'Ryakho\'s Earring',
             'Harvest Earring', 'Geist Earring', 'Healing Earring' },
        Body  = { 'Nashira Manteel', 'Morrigan\'s Robe', 'Errant Hpl.',
             'Black Cotehardie', 'Flora Cotehardie', 'Healing Jstcorps',
             'C.C. Cloak +1', 'C.C. Cloak +2', 'Cmb.Cst. Cloak',
             'Bishop\'s Robe', 'Bishop\'s Robe +1', 'Macha\'s Coat', 'Baron\'s Saio',
             'Priest\'s Robe' },
        Hands = { 'Yigit Gages', 'Mst.Cst. Bracelets', 'Dune Bracers',
             'Marine F Gloves', 'Magi Cuffs', 'Silk Cuffs +1', 'Seer\'s Mitts',
             'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = lists.Cure.Ring,
        Ring2 = lists.Cure.Ring,
        Back  = lists.Cure.Back,
        Waist = lists.Cure.Waist,
        Legs  = { 'Morrigan\'s Slops', 'Zenith Slacks', 'Zenith Slacks +1', 'Druid\'s Slops',
             'T.M. Slops +1', 'T.M. Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Macha\'s Slops', 'Custom Pants',
             'Custom Slacks' },
        Feet  = { 'Goliard Clogs', 'Morrigan\'s Pgch.', 'Rostrum Pumps', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Melee, worn while engaged.
    ['TP_Priority'] = {
        Head  = { 'Nashira Turban', 'Morrigan\'s Coron.', 'Pineal Hat', 'Opo-opo Crown',
             'Corsair\'s Tricorne', 'Super Ribbon', 'Storm Zucchetto', 'Neit\'s Crown',
             'Voyager Sallet', 'Spelunker\'s Hat', 'Macha\'s Crown', 'Dandy Spectacles',
             'Fancy Spectacles', 'Emperor Hairpin', 'Empress Hairpin' },
        Neck  = lists.TP.Neck,
        Ear1  = lists.TP.Ear,
        Ear2  = lists.TP.Ear,
        Body  = { 'Nashira Manteel', 'Morrigan\'s Robe', 'Commodore Frac', 'Black Cotehardie',
             'Flora Cotehardie', 'Corsair\'s Frac', 'C.C. Cloak +1',
             'C.C. Cloak +2', 'Cmb.Cst. Cloak', 'Macha\'s Coat',
             'Magna Bodice', 'Magna Jerkin', 'Bodb\'s Robe', 'Garrison Tunica', 'Nemain\'s Robe' },
        Hands = { 'Nashira Gages', 'Goliard Cuffs', 'Morrigan\'s Cuffs', 'Creek F Mitts',
             'Creek M Mitts', 'Wood Gauntlets', 'T.M. Cuffs +1',
             'T.M. Cuffs +2', 'Aiming Bracelets', 'C.C. Mitts +1',
             'C.C. Mitts +2', 'Cmb.Cst. Mitts', 'Sennight Bangles',
             'Macha\'s Cuffs', 'Custom F Gloves', 'Custom M Gloves', 'Bodb\'s Cuffs',
             'Linen Cuffs +1' },
        Ring1 = lists.TP.Ring,
        Ring2 = lists.TP.Ring,
        Back  = lists.TP.Back,
        Waist = lists.TP.Waist,
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews',
             'C.C. Slacks +1', 'C.C. Slacks +2',
             'Cmb.Cst. Slacks', 'Custom Pants', 'Custom Slacks', 'Magna F Chausses',
             'Garrison Hose' },
        Feet  = { 'Nashira Crackows', 'Goliard Clogs', 'Vampiric Boots', 'Marine F Boots',
             'Marine M Boots', 'Creek F Clomps', 'Storm Gambieras', 'Mountain Gaiters',
             'Macha\'s Pigaches', 'Custom F Boots', 'Custom M Boots', 'Savage Gaiters' },
    },
    -- Club, dagger and shield for soloing.
    ['Weapon_Priority'] = {
        Main  = { 'Thanatos Baselard', 'Titan\'s Baselarde', 'Scepter',
             'Rsv.Cpt. Mace', 'Snr.Msk. Rod', 'Daylight Dagger',
             'Palladium Dagger', 'Garuda\'s Dagger', 'Curse Wand', 'Sloth Wand', 'Lust Dagger',
             'Triple Dagger', 'Kingdom Dagger', 'San. Dagger', 'Ryl.Sqr. Dagger',
             'Bastokan Dagger', 'Decurion\'s Dagger', 'Piercing Dagger' },
        Sub   = { },
    },
};

profile.Sets = sets;

profile.Packer = {
};

evalLevel = function()
	-- Resolve sets against level and what is actually in the bags
    local level = AshitaCore:GetMemoryManager():GetPlayer():GetMainJobLevel();
    Settings.CurrentLevel = level;
    common.EvaluateGear(profile.Sets, level);
    common.EvaluateGear(staves.Sets, level);

    common.EvalLevel(level);
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias /blm /lac fwd');

    AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. Settings.MacroBook);

    -- Lock appearance a few seconds after loading
    common.RequestLockStyle(1);
end

profile.OnUnload = function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /blm');
end

profile.HandleCommand = function(args)
    -- Handle utility settings
    utility.SetOptions(args[1], Settings.MacroBook);

    -- Rescan the bags and re-resolve every gear set
    if (args[1] == 'gear') then
        common.EvaluateGear(profile.Sets, Settings.CurrentLevel, true);
        common.ReportGear(profile.Sets, Settings.CurrentLevel);
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();

	gFunc.EquipSet(common.Sets.Dream);

	if (player.Status == 'Engaged') then
		gFunc.EquipSet(sets.TP);
		gFunc.EquipSet(sets.Weapon);
	else
		gFunc.EquipSet(sets.Idle);
		staves.EquipIdleStaff();
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
	gFunc.EquipSet(sets.Precast);
end

profile.HandleMidcast = function()
	local action = gData.GetAction();

	utility.CheckCast(action.Name);

	if (action.Skill == 'Elemental Magic') then
		gFunc.EquipSet(sets.Nuke);
	elseif (action.Skill == 'Enfeebling Magic') then
		gFunc.EquipSet(sets.Enfeebling);
	elseif (action.Skill == 'Dark Magic') then
		gFunc.EquipSet(sets.Dark);
	elseif (action.Skill == 'Enhancing Magic') then
		gFunc.EquipSet(sets.Enhancing);
	elseif (action.Skill == 'Healing Magic') then
		gFunc.EquipSet(sets.Cure);
	end

	-- Staff last so the element keeps the Main slot.
	staves.EquipStaff(action);
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;
