local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
local staves = gFunc.LoadFile('./staves.lua');

local Settings = {
    CurrentLevel = 0,
};

-- Gear candidates pulled from the HorizonXI wiki: every piece WHM can wear,
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
             'Walahra Turban', 'Carline Ribbon', 'Gold Hairpin', 'Hlr. Cap +1', 'Curate\'s Hat',
             'Electrum Hairpin', 'Merman\'s Hairpin', 'Mana Circlet', 'Coral Hairpin',
             'Reraise Hairpin', 'Magus Keffiyeh', 'Kosshin', 'Rain Hat', 'Magi Hat',
             'Silken Hat', 'Storm Turban', 'Aristocrat\'s Crown', 'Rival Ribbon',
             'Silver Hairpin +1', 'Silver Hairpin', 'Trump Crown', 'Healer\'s Cap',
             'Horn Hairpin +1', 'Eld. Horn Hairpin', 'Horn Hairpin', 'Brass Hairpin +1',
             'Namru\'s Tiara', 'Shell Hairpin +1', 'Brass Hairpin', 'Shell Hairpin',
             'Circe\'s Hat', 'Copper Hairpin +1', 'Lgn. Circlet', 'Copper Hairpin',
             'Bone Hairpin +1', 'Bone Hairpin', 'Enlil\'s Tiara', 'Ea\'s Tiara', 'Wool Cap +1',
             'Wool Cap', 'Corsair\'s Hat +1', 'Corsair\'s Hat', 'Mage\'s Hat', 'Wool Hat +1',
             'Great Headgear', 'Jgl. Headband', 'Wool Hat', 'Cotton Headgear' },
        Neck  = { 'Rep.Gold Medal', 'Morgana\'s Choker', 'Beak Necklace +1', 'Beak Necklace',
             'Chi Necklace', 'Uggalepih Pendant', 'Star Necklace', 'Rep.Mythril Medal',
             'M. No.17\'s Locket', 'Grandiose Chain', 'Spirit Torque', 'Holy Phial',
             'Mohbwa Scarf +1', 'Rep.Iron Medal', 'Mohbwa Scarf', 'Rep.Bronze Medal',
             'Rho Necklace', 'Wivre Gorget +1', 'Tempered Chain', 'Wivre Gorget',
             'Harmonia\'s Torque', 'Hateful Collar', 'Torque +1', 'Auditory Torque',
             'Brisingamen +1', 'Chivalrous Chain', 'Fortified Chain', 'Stoneskin Torque',
             'Torque', 'Clay Amulet', 'Stone Gorget', 'Memento Muffler', 'Promise Badge',
             'Agile Gorget', 'Medieval Collar', 'Hemp Gorget +1', 'Van Pendant',
             'Paisley Scarf', 'Tiger Stole', 'Hemp Gorget', 'Black Neckerchief',
             'Feather Collar +1', 'Green Scarf', 'Yinyang Lorgnette', 'Dog Collar',
             'Feather Collar', 'Justice Badge', 'Regen Collar', 'Windurstian Scarf',
             'Bloodbead Amulet', 'Evasion Torque', 'Shield Pendant' },
        Ear1  = { 'Loquac. Earring', 'Zedoma\'s Earring', 'Astral Earring', 'Celestial Earring',
             'Magnetic Earring', 'Star Earring', 'Insomnia Earring', 'Gamma Earring',
             'Desamilion Earring', 'Hades Earring +1', 'Hades Earring', 'Mana Earring +1',
             'Rapture Earring', 'Death Earring', 'Phtm. Earring +1', 'Gayanj\'s Earring',
             'Phantom Earring', 'Mana Earring', 'Aura Earring +1', 'Night Earring',
             'Enhancing Earring', 'Bat Earring', 'Geist Earring', 'Aura Earring',
             'Morion Earring +1', 'Energy Earring +1', 'Black Earring', 'Morion Earring',
             'Valor Earring', 'Energy Earring', 'Onyx Earring', 'Merman\'s Earring',
             'Intruder Earring', 'Bitter Earring', 'Cassie Earring', 'Allure Earring +1',
             'Lyt. Earring +1', 'Hope Earring +1', 'Cel. Earring +1', 'Alc. Earring +1',
             'Mecurial Earring', 'Blc. Earring +1', 'Crg. Earring +1', 'Morukaka Earring',
             'Stoic Earring', 'Ethereal Earring', 'Shield Earring' },
        Ear2  = { 'Loquac. Earring', 'Zedoma\'s Earring', 'Astral Earring', 'Celestial Earring',
             'Magnetic Earring', 'Star Earring', 'Insomnia Earring', 'Gamma Earring',
             'Desamilion Earring', 'Hades Earring +1', 'Hades Earring', 'Mana Earring +1',
             'Rapture Earring', 'Death Earring', 'Phtm. Earring +1', 'Gayanj\'s Earring',
             'Phantom Earring', 'Mana Earring', 'Aura Earring +1', 'Night Earring',
             'Enhancing Earring', 'Bat Earring', 'Geist Earring', 'Aura Earring',
             'Morion Earring +1', 'Energy Earring +1', 'Black Earring', 'Morion Earring',
             'Valor Earring', 'Energy Earring', 'Onyx Earring', 'Merman\'s Earring',
             'Intruder Earring', 'Bitter Earring', 'Cassie Earring', 'Allure Earring +1',
             'Lyt. Earring +1', 'Hope Earring +1', 'Cel. Earring +1', 'Alc. Earring +1',
             'Mecurial Earring', 'Blc. Earring +1', 'Crg. Earring +1', 'Morukaka Earring',
             'Stoic Earring', 'Ethereal Earring', 'Shield Earring' },
        Body  = { 'Dalmatica +1', 'Dalmatica', 'Goliard Saio', 'Hydra Doublet',
             'Hlr. Bliaut +1', 'Elder\'s Surcoat', 'Flora Cotehardie', 'Shaman\'s Cloak',
             'Healer\'s Bliaut', 'Black Cotehardie', 'Cleric\'s Bliaut', 'Magi Coat',
             'Silken Coat', 'Hydra Jupon', 'Oracle\'s Robe', 'T.M. Coat +2',
             'Aristocrat\'s Coat', 'T.M. Coat +1', 'Noble\'s Tunic', 'Ryl.Sqr. Robe +2',
             'Ryl.Sqr. Robe +1', 'Ryl.Sqr. Robe', 'Seer\'s Tunic +1', 'Pyro Robe',
             'Seer\'s Tunic', 'Frost Robe', 'Kingdom Tunic', 'Bishop\'s Robe +1',
             'Magna Bodice', 'Magna Jerkin', 'San d\'Orian Tunic', 'Mage\'s Robe',
             'Bishop\'s Robe', 'Divine Breastplate', 'Silk Cloak +1', 'Holy Breastplate',
             'Minstrel\'s Coat', 'Aketon +1', 'Aketon', 'Battle Jupon +1', 'Tabin Jupon +1',
             'C.C. Cloak +2', 'C.C. Cloak +1', 'Cloak +1', 'Faerie Tunic', 'Wool Robe +1',
             'Mage\'s Tunic', 'Wool Robe', 'Great Doublet', 'Black Tunic', 'Garrison Tunica',
             'Priest\'s Robe', 'Angler\'s Tunica', 'Nomad\'s Tunica', 'Rider\'s Jack Coat',
             'Worker Tunica' },
        Hands = { 'Dune Bracers', 'Zenith Mitts +1', 'Wood Gauntlets', 'Wood Gloves',
             'Zenith Mitts', 'Marine F Gloves', 'Marine M Gloves', 'Elder\'s Bracers',
             'Mahatma Cuffs', 'Oracle\'s Gloves', 'Magna Gauntlets', 'Magna Gloves',
             'Storm Gages', 'Errant Cuffs', 'Magical Mitts', 'Cleric\'s Mitts',
             'Blessed Mitts +1', 'Savage Gauntlets', 'Blessed Mitts', 'Aristocrat\'s Mitts',
             'Magi Cuffs', 'Noble\'s Mitts', 'Silken Cuffs', 'Ivory Mitts', 'Healer\'s Mitts',
             'New Moon Armlets', 'Devotee\'s Mitts', 'Zealot\'s Mitts', 'Custom F Gloves',
             'Custom M Gloves', 'Baron\'s Cuffs', 'Prt. Bangles', 'Storm Manopolas',
             'Light Gauntlets', 'Wool Bracers +1', 'Turtle Bangles +1', 'Wool Bracers',
             'Turtle Bangles', 'Engineer\'s Gloves', 'C.C. Mitts +2', 'Silver Bangles +1',
             'Concealing Cuffs', 'Mage\'s Cuffs', 'Bracers +1', 'Sennight Bangles',
             'Velvet Cuffs', 'Bracers', 'Federation Gloves', 'Linen Mitts +1',
             'Scentless Armlets', 'Battle Gloves', 'Linen Cuffs +1', 'Gloves +1',
             'Angler\'s Gloves', 'Anu\'s Gages', 'Nomad\'s Gloves' },
        Ring1 = { 'Vivian Ring', 'Serket Ring', 'Ether Ring', 'Variable Ring', 'Vilma\'s Ring',
             'Astral Ring', 'Dark Ring', 'Celestial Ring', 'Star Ring', 'Zoredonite Ring',
             'Carect Ring', 'Electrum Ring', 'Ebullient Ring', 'Mana Ring', 'Tamas Ring',
             'Serene Ring', 'Demon\'s Ring +1', 'Hades Ring +1', 'Demon\'s Ring',
             'Poseidon\'s Ring', 'Horizon Ring', 'Peace Ring', 'Fasting Ring', 'Mystic Ring +1',
             'Hades Ring', 'Manashell Ring', 'Death Ring', 'Aura Ring +1', 'Mystic Ring',
             'Painite Ring', 'Kshama Ring No.6', 'Energy Ring +1', 'Kshama Ring No.5',
             'Kshama Ring No.9', 'Aura Ring', 'Black Ring', 'Energy Ring', 'Windurstian Ring',
             'Onyx Ring', 'Defending Ring', 'Sattva Ring', 'Jelly Ring', 'Gobniu\'s Ring',
             'Dragon Ring +1', 'Aegis Ring', 'Gld.Msk. Ring', 'Kshama Ring No.4', 'Bomb Ring',
             'Alacrity Ring +1', 'Deft Ring +1', 'Mythril Ring', 'Mythril Ring +1' },
        Ring2 = { 'Vivian Ring', 'Serket Ring', 'Ether Ring', 'Variable Ring', 'Vilma\'s Ring',
             'Astral Ring', 'Dark Ring', 'Celestial Ring', 'Star Ring', 'Zoredonite Ring',
             'Carect Ring', 'Electrum Ring', 'Ebullient Ring', 'Mana Ring', 'Tamas Ring',
             'Serene Ring', 'Demon\'s Ring +1', 'Hades Ring +1', 'Demon\'s Ring',
             'Poseidon\'s Ring', 'Horizon Ring', 'Peace Ring', 'Fasting Ring', 'Mystic Ring +1',
             'Hades Ring', 'Manashell Ring', 'Death Ring', 'Aura Ring +1', 'Mystic Ring',
             'Painite Ring', 'Kshama Ring No.6', 'Energy Ring +1', 'Kshama Ring No.5',
             'Kshama Ring No.9', 'Aura Ring', 'Black Ring', 'Energy Ring', 'Windurstian Ring',
             'Onyx Ring', 'Defending Ring', 'Sattva Ring', 'Jelly Ring', 'Gobniu\'s Ring',
             'Dragon Ring +1', 'Aegis Ring', 'Gld.Msk. Ring', 'Kshama Ring No.4', 'Bomb Ring',
             'Alacrity Ring +1', 'Deft Ring +1', 'Mythril Ring', 'Mythril Ring +1' },
        Back  = { 'Blue Cape +1', 'Mahatma Cape', 'Errant Cape', 'Birdman Cape', 'Blue Cape',
             'Intensifying Cape', 'Storm Cape', 'Altruistic Cape', 'Astute Cape',
             'Merciful Cape', 'Lieutenant\'s Cape', 'Aslan Cape', 'Erato\'s Cape',
             'Empwr. Mantle +1', 'Miraculous Cape', 'Aurora Mantle +1', 'Talisman Cape',
             'Empwr. Mantle', 'Enhancing Mantle', 'Aurora Mantle', 'Lucent Cape',
             'Esoteric Mantle', 'Fed. Army Mantle', 'Tundra Mantle', 'Invigorating Cape',
             'Ryl. Army Mantle', 'Rep. Army Mantle', 'Jester\'s Cape +1', 'Storm Mantle',
             'Red Cape +1', 'Dodge Cape', 'Green Cape', 'Red Cape', 'Rearguard Mantle',
             'Black Cape +1', 'White Cape +1', 'Midnight Cape', 'Black Cape', 'White Cape',
             'Sarcenet Cape', 'Cotton Cape +1', 'Mist Silk Cape', 'Ashigaru Mantle',
             'Variable Cape', 'Cotton Cape', 'Cape +1', 'Cape' },
        Waist = { 'Forest Rope', 'Desert Rope', 'Lambda Sash', 'Hierarch Belt', 'Jungle Rope',
             'Ocean Rope', 'Cleric\'s Belt', 'Desert Stone', 'Forest Stone', 'Steppe Rope',
             'Jungle Stone', 'Ocean Stone', 'Steppe Stone', 'Storm Sash', 'Powerful Rope',
             'Lieutenant\'s Sash', 'Qiqirn Sash +1', 'Qiqirn Sash', 'Mohbwa Sash +1',
             'Talisman Obi', 'Spectral Belt', 'Hojutsu Belt', 'Mohbwa Sash', 'Adept\'s Rope',
             'Oracle\'s Belt', 'Magic Belt +1', 'Shaman\'s Belt', 'Friar\'s Rope', 'Force Belt',
             'Magic Belt', 'Earth Belt', 'Fire Belt', 'Ice Belt', 'Lightning Belt',
             'Water Belt', 'Wind Belt', 'Desert Belt', 'Forest Belt', 'Brocade Obi +1',
             'Corsette +1', 'Brocade Obi', 'Corsette', 'Gold Obi +1', 'Survival Belt',
             'Deduct. Gold Obi', 'Enthrall. Gold Obi', 'Gold Obi', 'Sagac. Gold Obi',
             'Silver Obi +1', 'Lizard Belt +1', 'Silver Obi', 'Lizard Belt', 'Heko Obi +1',
             'Heko Obi' },
        Legs  = { 'Zenith Slacks +1', 'Zenith Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth', 'Prince\'s Slops', 'Bls. Trousers +1', 'Hlr. Pantaln. +1',
             'Goliard Trews', 'Vendor\'s Slops', 'Blessed Trousers', 'Frog Trousers',
             'Elder\'s Braguette', 'Aristo. Slacks', 'Noble\'s Slacks', 'Healer\'s Pantaln.',
             'Magna F Chausses', 'Magna M Chausses', 'Magi Slops', 'Silken Slops',
             'Seer\'s Slacks +1', 'Seer\'s Slacks', 'Sturdy Slacks', 'Federation Slops',
             'Freesword\'s Slops', 'Windurstian Slops', 'Mage\'s Slops', 'Enlil\'s Brayettes',
             'Ea\'s Brais', 'Anu\'s Brais', 'Femina Subligar', 'Vir Subligar', 'Battle Hose +1',
             'Tabin Hose +1', 'Silk Slacks +1', 'Battle Hose', 'Tabin Hose', 'Silk Slacks',
             'Silk Slops +1', 'T.M. Slops +2', 'Silk Slops', 'Wool Hose +1', 'Blaze Hose',
             'Wool Hose', 'C.C. Slacks +2', 'C.C. Slacks +1', 'Cmb.Cst. Slacks', 'Magic Slacks',
             'Wool Slops +1', 'Wool Slops', 'Great Brais', 'Martial Slacks', 'Cotton Brais',
             'Angler\'s Hose', 'Nomad\'s Hose', 'Rider\'s Hose' },
        Feet  = { 'Zenith Pumps +1', 'Zenith Pumps', 'River Gaiters', 'Rostrum Pumps',
             'Wood F Ledelsens', 'Wood M Ledelsens', 'Mahatma Pigaches', 'Oracle\'s Pigaches',
             'Ataractic Solea', 'Errant Pigaches', 'Blessed Pumps +1', 'Hlr. Duckbills +1',
             'Healer\'s Duckbills', 'Mgn. F Ledelsens', 'Mgn. M Ledelsens', 'Aristo. Pumps',
             'Magi Pigaches', 'Inferno Sabots +1', 'Noble\'s Pumps', 'Silken Pigaches',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Elder\'s Sandals',
             'Inferno Sabots', 'Seer\'s Pumps +1', 'Kingdom Clogs', 'Seer\'s Pumps',
             'Enlil\'s Crackows', 'Anu\'s Gaiters', 'Root Sabots', 'Cure Clogs',
             'Desert Boots +1', 'Battle Boots +1', 'Tabin Boots +1', 'Battle Boots',
             'Tabin Boots', 'Wool Socks +1', 'Wool Socks', 'C.C. Shoes +2', 'C.C. Shoes +1',
             'Ebony Sabots +1', 'Socks +1', 'Cmb.Cst. Shoes', 'Ebony Sabots',
             'Mountain Gaiters', 'Socks', 'Federation Gaiters', 'Garrison Boots',
             'Light Soleas', 'Holly Clogs +1', 'Gaiters +1', 'Ceremonial Boots',
             'Power Sandals', 'Angler\'s Boots', 'Nomad\'s Boots' },
    },
    -- Fast cast, worn during the precast phase of every spell.
    ['Precast_Priority'] = {
        Ear1  = { 'Loquac. Earring' },
        Ear2  = { 'Loquac. Earring' },
        Body  = { 'Marduk\'s Jubbah' },
        Feet  = { 'Rostrum Pumps' },
    },
    -- Cure potency, healing magic skill and MND.
    ['Cure_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Marduk\'s Tiara', 'Hlr. Cap +1',
             'Aristocrat\'s Crown', 'Noble\'s Crown', 'Opo-opo Crown', 'Healer\'s Cap',
             'Magi Hat', 'Silk Hat +1', 'Rain Hat', 'Sinister Mask', 'Enlil\'s Tiara',
             'Circe\'s Hat', 'Ea\'s Tiara', 'Baron\'s Chapeau', 'Garrison Sallet',
             'Traveler\'s Hat', 'Eld. Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Healing Torque', 'Purgatory Collar', 'Enlightened Chain', 'Ajari Necklace',
             'Stoneskin Torque', 'Torque', 'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1',
             'Holy Phial', 'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Delta Earring', 'Static Earring', 'Magnetic Earring', 'Celestial Earring',
             'Cmn. Earring', 'Cmn. Earring +1', 'Ryakho\'s Earring', 'Eris\' Earring',
             'Eris\' Earring +1', 'Harvest Earring', 'Nemesis Earring', 'Geist Earring',
             'Healing Earring' },
        Ear2  = { 'Delta Earring', 'Static Earring', 'Magnetic Earring', 'Celestial Earring',
             'Cmn. Earring', 'Cmn. Earring +1', 'Ryakho\'s Earring', 'Eris\' Earring',
             'Eris\' Earring +1', 'Harvest Earring', 'Nemesis Earring', 'Geist Earring',
             'Healing Earring' },
        Body  = { 'Nashira Manteel', 'Errant Hpl.', 'Mahatma Hpl.',
             'Aristocrat\'s Coat', 'Noble\'s Tunic', 'Black Cotehardie', 'Flora Cotehardie',
             'Healing Jstcorps', 'C.C. Cloak +1', 'C.C. Cloak +2',
             'Cmb.Cst. Cloak', 'Enlil\'s Gambison', 'Bishop\'s Robe',
             'Bishop\'s Robe +1', 'Ea\'s Doublet', 'Baron\'s Saio', 'Priest\'s Robe',
             'Anu\'s Doublet' },
        Hands = { 'Marduk\'s Dastanas', 'Hlr. Mitts +1', 'Blessed Mitts',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Healer\'s Mitts', 'Magi Cuffs',
             'Silk Cuffs +1', 'Ivory Mitts', 'Concealing Cuffs', 'Enlil\'s Kolluks',
             'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Mycophile Cuffs', 'Anu\'s Gages',
             'Zealot\'s Mitts' },
        Ring1 = { 'Virology Ring', 'Pi Ring', 'Aqua Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Mermaid Ring', 'Vilma\'s Ring', 'Malflood Ring',
             'Solace Ring', 'Tamas Ring', 'Carect Ring', 'Lapis Lazuli Ring',
             'Tranquility Ring', 'Saintly Ring' },
        Ring2 = { 'Virology Ring', 'Pi Ring', 'Aqua Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Mermaid Ring', 'Vilma\'s Ring', 'Malflood Ring',
             'Solace Ring', 'Tamas Ring', 'Carect Ring', 'Lapis Lazuli Ring',
             'Tranquility Ring', 'Saintly Ring' },
        Back  = { 'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Peace Cape',
             'Miraculous Cape', 'Sapient Cape', 'Ryl. Army Mantle', 'Amity Cape',
             'Esoteric Mantle', 'Red Cape', 'Red Cape +1', 'White Cape', 'White Cape +1',
             'Talisman Cape', 'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt',
             'Deduct. Broc. Obi', 'Penitent\'s Rope', 'Twinthread Obi', 'Twinthread Obi +1',
             'Forest Belt', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deduct. Gold Obi', 'Mrc.Cpt. Belt', 'Friar\'s Rope', 'Talisman Obi' },
        Legs  = { 'Marduk\'s Shalwar', 'Cleric\'s Pantaln.', 'Errant Slops', 'Druid\'s Slops',
             'T.M. Slops +1', 'T.M. Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth' },
        Feet  = { 'Marduk\'s Crackows', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Crow Gaiters', 'Raven Gaiters',
             'Enlil\'s Crackows', 'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots',
             'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Enhancing magic skill.
    ['Enhancing_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Marduk\'s Tiara', 'Hlr. Cap +1',
             'Aristocrat\'s Crown', 'Noble\'s Crown', 'Opo-opo Crown', 'Healer\'s Cap',
             'Magi Hat', 'Silk Hat +1', 'Namru\'s Tiara', 'Rain Hat', 'Sinister Mask',
             'Enlil\'s Tiara', 'Circe\'s Hat', 'Ea\'s Tiara', 'Garrison Sallet',
             'Traveler\'s Hat', 'Eld. Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Enhancing Torque', 'Enlightened Chain', 'Ajari Necklace', 'Stoneskin Torque',
             'Torque', 'Promise Badge', 'Yinyang Lorgnette', 'Mohbwa Scarf', 'Holy Phial',
             'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Cmn. Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augment. Earring' },
        Ear2  = { 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Cmn. Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augment. Earring' },
        Body  = { 'Marduk\'s Jubbah', 'Reverend Mail', 'Errant Hpl.', 'Black Cotehardie',
             'Flora Cotehardie', 'Healing Jstcorps', 'C.C. Cloak +1',
             'C.C. Cloak +2', 'Cmb.Cst. Cloak', 'Bishop\'s Robe',
             'Bishop\'s Robe +1', 'Enlil\'s Gambison', 'Ea\'s Doublet', 'Baron\'s Saio',
             'Priest\'s Robe', 'Anu\'s Doublet' },
        Hands = { 'Marduk\'s Dastanas', 'Hlr. Mitts +1', 'Yigit Gages',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Silk Cuffs +1', 'Ivory Mitts', 'Enlil\'s Kolluks', 'Seer\'s Mitts',
             'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Anu\'s Gages', 'Zealot\'s Mitts' },
        Ring1 = { 'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring',
             'Solace Ring +1', 'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring',
             'Saintly Ring' },
        Ring2 = { 'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring',
             'Solace Ring +1', 'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring',
             'Saintly Ring' },
        Back  = { 'Merciful Cape', 'Prism Cape', 'Rainbow Cape', 'Miraculous Cape',
             'Sapient Cape', 'Ryl. Army Mantle', 'Red Cape', 'Red Cape +1', 'White Cape',
             'White Cape +1', 'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt',
             'Deduct. Broc. Obi', 'Penitent\'s Rope', 'Twinthread Obi', 'Twinthread Obi +1',
             'Forest Belt', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deduct. Gold Obi', 'Mrc.Cpt. Belt', 'Friar\'s Rope' },
        Legs  = { 'Zenith Slacks', 'Zenith Slacks +1', 'Errant Slops',
             'T.M. Slops +1', 'T.M. Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth' },
        Feet  = { 'Goliard Clogs', 'Marduk\'s Crackows', 'Cleric\'s Duckbills',
             'Marine F Boots', 'Marine M Boots', 'River Gaiters', 'Enlil\'s Crackows',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Seer\'s Pumps',
             'Garrison Boots' },
    },
    -- Magic accuracy for enfeebles.
    ['Enfeebling_Priority'] = {
        Head  = { 'Nashira Turban', 'Shadow Hat', 'Valkyrie\'s Hat', 'Opo-opo Crown',
             'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon', 'T.M. Hat +1',
             'Storm Zucchetto', 'Rain Hat', 'Sinister Mask', 'Enlil\'s Tiara',
             'Eld. Horn Hairpin', 'Seer\'s Crown', 'Seer\'s Crown +1', 'Ea\'s Tiara',
             'Garrison Sallet', 'Traveler\'s Hat', 'Eld. Bone Hairpin' },
        Neck  = { 'Prudence Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Lieut. Gorget', 'Enfeebling Torque', 'Spider Torque', 'Stoneskin Torque',
             'Torque', 'Torque +1', 'Yinyang Lorgnette', 'Mohbwa Scarf', 'Mohbwa Scarf +1',
             'Holy Phial', 'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Abyssal Earring', 'Celestial Earring', 'Cmn. Earring',
             'Diabolos\'s Earring', 'Ryakho\'s Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Harvest Earring', 'Boroka Earring', 'Heims Earring',
             'Geist Earring', 'Enfeebling Earring', 'Morion Earring', 'Cunning Earring' },
        Ear2  = { 'Static Earring', 'Abyssal Earring', 'Celestial Earring', 'Cmn. Earring',
             'Diabolos\'s Earring', 'Ryakho\'s Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Harvest Earring', 'Boroka Earring', 'Heims Earring',
             'Geist Earring', 'Enfeebling Earring', 'Morion Earring', 'Cunning Earring' },
        Body  = { 'Nashira Manteel', 'Shadow Coat', 'Valkyrie\'s Coat', 'Black Cotehardie',
             'Healer\'s Bliaut', 'Shaman\'s Cloak', 'C.C. Cloak +1',
             'C.C. Cloak +2', 'Cmb.Cst. Cloak', 'Bishop\'s Robe',
             'Bishop\'s Robe +1', 'Enlil\'s Gambison', 'Ea\'s Doublet', 'Baron\'s Saio',
             'Black Tunic', 'Priest\'s Robe', 'Anu\'s Doublet', 'Kingdom Tunic' },
        Hands = { 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Goliard Cuffs',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Silk Cuffs +1', 'Ivory Mitts', 'Engineer\'s Gloves', 'Sennight Bangles',
             'Enlil\'s Kolluks', 'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Devotee\'s Mitts',
             'Anu\'s Gages', 'Zealot\'s Mitts' },
        Ring1 = { 'Dark Ring', 'Flame Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Aquamarine Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 9', 'Kshama Ring No. 5', 'Vilma\'s Ring', 'Malflood Ring',
             'Solace Ring', 'Tamas Ring', 'Carect Ring', 'Lapis Lazuli Ring',
             'Tranquility Ring', 'Saintly Ring' },
        Ring2 = { 'Dark Ring', 'Flame Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Aquamarine Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 9', 'Kshama Ring No. 5', 'Vilma\'s Ring', 'Malflood Ring',
             'Solace Ring', 'Tamas Ring', 'Carect Ring', 'Lapis Lazuli Ring',
             'Tranquility Ring', 'Saintly Ring' },
        Back  = { 'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Sapient Cape',
             'Miraculous Cape', 'Ryl. Army Mantle', 'Fed. Army Mantle', 'Gramary Cape',
             'Red Cape', 'Red Cape +1', 'White Cape', 'White Cape +1', 'Black Cape',
             'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt', 'Bitter Corset',
             'Penitent\'s Rope', 'Twinthread Obi', 'Jungle Stone', 'Ocean Stone',
             'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deduct. Gold Obi', 'Mrc.Cpt. Belt', 'Shaman\'s Belt',
             'Friar\'s Rope' },
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews',
             'T.M. Slops +1', 'T.M. Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth', 'Seer\'s Slacks', 'Seer\'s Slacks +1', 'Mage\'s Slacks' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Healer\'s Duckbills',
             'T.M. Pigaches +1', 'T.M. Pigaches +2',
             'Inferno Sabots', 'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps',
             'Enlil\'s Crackows', 'Custom F Boots', 'Custom M Boots', 'Seer\'s Pumps',
             'Garrison Boots' },
    },
    -- Divine magic -- Banish and Holy.
    ['Divine_Priority'] = {
        Head  = { 'Marduk\'s Tiara', 'Elite Beret', 'Elite Beret +1', 'Aristocrat\'s Crown',
             'Noble\'s Crown', 'Opo-opo Crown', 'Healer\'s Cap', 'Magi Hat', 'Storm Zucchetto',
             'Rain Hat', 'Sinister Mask', 'Bastokan Circlet', 'Republic Circlet', 'Ea\'s Tiara',
             'Garrison Sallet', 'Traveler\'s Hat', 'Eld. Bone Hairpin' },
        Neck  = { 'Jeweled Collar +1', 'Morgana\'s Choker', 'Divine Torque',
             'Lieut. Gorget', 'Enlightened Chain', 'Ajari Necklace', 'Stoneskin Torque',
             'Torque', 'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Holy Phial',
             'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Novio Earring', 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Diabolos\'s Earring', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Divine Earring' },
        Ear2  = { 'Novio Earring', 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Diabolos\'s Earring', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Divine Earring' },
        Body  = { 'Nashira Manteel', 'Shadow Coat', 'Oracle\'s Robe', 'Black Cotehardie',
             'Flora Cotehardie', 'Healing Jstcorps', 'C.C. Cloak +1',
             'C.C. Cloak +2', 'Cmb.Cst. Cloak', 'Bishop\'s Robe',
             'Bishop\'s Robe +1', 'Enlil\'s Gambison', 'Ea\'s Doublet', 'Baron\'s Saio',
             'Priest\'s Robe', 'Anu\'s Doublet' },
        Hands = { 'Goliard Cuffs', 'Nashira Gages', 'Shadow Cuffs',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Silk Cuffs +1', 'Ivory Mitts', 'Sennight Bangles', 'Enlil\'s Kolluks',
             'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Anu\'s Gages',
             'Zealot\'s Mitts' },
        Ring1 = { 'Pi Ring', 'Aqua Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Aquamarine Ring', 'Serenity Ring', 'Balrahn\'s Ring',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring', 'Tamas Ring',
             'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring', 'Saintly Ring' },
        Ring2 = { 'Pi Ring', 'Aqua Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Aquamarine Ring', 'Serenity Ring', 'Balrahn\'s Ring',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring', 'Tamas Ring',
             'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring', 'Saintly Ring' },
        Back  = { 'Altruistic Cape', 'Solitaire Cape', 'Prism Cape', 'Miraculous Cape',
             'Sapient Cape', 'Ryl. Army Mantle', 'Gramary Cape', 'Red Cape', 'Red Cape +1',
             'White Cape', 'White Cape +1', 'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt',
             'Deduct. Broc. Obi', 'Bitter Corset', 'Twinthread Obi', 'Twinthread Obi +1',
             'Forest Belt', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deduct. Gold Obi', 'Mrc.Cpt. Belt', 'Friar\'s Rope' },
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews',
             'Healer\'s Pantaln.', 'T.M. Slops +1',
             'T.M. Slops +2', 'Magic Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'Templar Sabatons', 'Enlil\'s Crackows', 'Mannequin Pumps',
             'Custom F Boots', 'Custom M Boots', 'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Melee, worn while engaged.
    ['TP_Priority'] = {
        Head  = { 'Nashira Turban', 'Walahra Turban', 'Pineal Hat', 'Green Beret',
             'Green Beret +1', 'Corsair\'s Tricorne', 'Super Ribbon', 'Storm Zucchetto',
             'Jester\'s Headband', 'Voyager Sallet', 'Spelunker\'s Hat', 'Fed. Headgear',
             'Dandy Spectacles', 'Fancy Spectacles', 'Emperor Hairpin', 'Empress Hairpin' },
        Neck  = { 'Diabolos\'s Torque', 'Chanoix\'s Gorget', 'Wivre Gorget', 'Sniper\'s Collar',
             'Grand T.K. Collar', 'Chivalrous Chain', 'Spectacles',
             'Ashura Necklace', 'Storm Gorget', 'Peacock Amulet', 'Peacock Charm',
             'Tiger Stole', 'Fang Necklace', 'Spike Necklace', 'Feather Collar +1' },
        Ear1  = { 'Beta Earring', 'Hollow Earring', 'Beastly Earring', 'Diabolos\'s Earring',
             'Magnifying Earring', 'Minuet Earring', 'Bitter Earring', 'Accurate Earring',
             'Vision Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Mythril Earring +1', 'Reraise Earring', 'Beetle Earring', 'Bone Earring',
             'Bone Earring +1', 'Optical Earring' },
        Ear2  = { 'Beta Earring', 'Hollow Earring', 'Beastly Earring', 'Diabolos\'s Earring',
             'Magnifying Earring', 'Minuet Earring', 'Bitter Earring', 'Accurate Earring',
             'Vision Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Mythril Earring +1', 'Reraise Earring', 'Beetle Earring', 'Bone Earring',
             'Bone Earring +1', 'Optical Earring' },
        Body  = { 'Nashira Manteel', 'Commodore Frac', 'Corsair\'s Frac +1', 'Tabin Jupon',
             'Tabin Jupon +1', 'Battle Jupon', 'Black Cotehardie', 'Flora Cotehardie',
             'Corsair\'s Frac', 'Irn.Msk.Gmbsn. +1',
             'Irn.Msk.Gmbsn. +2', 'Irn.Msk. Gambison',
             'Fed. Doublet', 'Win. Doublet', 'Magna Bodice', 'Garrison Tunica' },
        Hands = { 'Nashira Gages', 'Goliard Cuffs', 'Pantin Dastanas +1', 'Tabin Bracers',
             'Tabin Bracers +1', 'Battle Bracers', 'T.M. Cuffs +1',
             'T.M. Cuffs +2', 'Aiming Bracelets', 'C.C. Mitts +1',
             'C.C. Mitts +2', 'Cmb.Cst. Mitts', 'Sennight Bangles',
             'Federation Gloves', 'Win. Gloves', 'Custom F Gloves', 'Custom M Gloves',
             'Magna Gauntlets', 'Battle Gloves', 'Linen Cuffs +1' },
        Ring1 = { 'Bellona\'s Ring', 'Mars\'s Ring', 'Iota Ring', 'Marid Ring', 'Marid Ring +1',
             'Lightning Ring', 'Toreador\'s Ring', 'Jalzahn\'s Ring', 'Ulthalam\'s Ring',
             'Kshama Ring No. 2', 'Kshama Ring No. 8', 'Carapace Ring', 'Horn Ring',
             'Horn Ring +1', 'Jaeger Ring', 'Bowyer Ring', 'Beetle Ring', 'Beetle Ring +1',
             'Bone Ring', 'Bone Ring +1', 'Vision Ring' },
        Ring2 = { 'Bellona\'s Ring', 'Mars\'s Ring', 'Iota Ring', 'Marid Ring', 'Marid Ring +1',
             'Lightning Ring', 'Toreador\'s Ring', 'Jalzahn\'s Ring', 'Ulthalam\'s Ring',
             'Kshama Ring No. 2', 'Kshama Ring No. 8', 'Carapace Ring', 'Horn Ring',
             'Horn Ring +1', 'Jaeger Ring', 'Bowyer Ring', 'Beetle Ring', 'Beetle Ring +1',
             'Bone Ring', 'Bone Ring +1', 'Vision Ring' },
        Back  = { 'Gunner\'s Mantle', 'Rep. Army Mantle', 'Bellicose Mantle',
             'Gramary Cape', 'Rearguard Mantle' },
        Waist = { 'Ninurta\'s Sash', 'Buccaneer\'s Belt', 'Sprinter\'s Belt', 'Mithran Stone',
             'Bitter Corset', 'Potent Belt', 'Swift Belt', 'Ocean Belt', 'Desert Belt',
             'Life Belt', 'Tilt Belt', 'Corsette', 'Mrc.Cpt. Belt' },
        Legs  = { 'Nashira Seraweels', 'Blessed Trousers', 'Bls. Trousers +1', 'Tabin Hose',
             'Tabin Hose +1', 'C.C. Slacks +1', 'C.C. Slacks +2',
             'Cmb.Cst. Slacks', 'Custom Pants', 'Custom Slacks', 'Magna F Chausses',
             'Garrison Hose' },
        Feet  = { 'Nashira Crackows', 'Goliard Clogs', 'Blessed Pumps', 'Marine F Boots',
             'Marine M Boots', 'Templar Sabatons', 'Tabin Boots', 'Tabin Boots +1',
             'Storm Gambieras', 'Mountain Gaiters', 'Federation Gaiters', 'Win. Gaiters',
             'Custom F Boots', 'Custom M Boots', 'Savage Gaiters' },
    },
    -- Club and shield for soloing.
    ['Weapon_Priority'] = {
        Main  = { 'Mjollnir', 'Yagrush', 'Ultima\'s Left Arm', 'Brise-os', 'Ramuh\'s Mace',
             'Rsv.Cpt. Mace', 'Snr.Msk. Rod', 'Seawolf Cudgel',
             'Sea Rob. Cudgel', 'Darksteel Maul', 'Curse Wand', 'Sloth Wand', 'Kingdom Mace',
             'San d\'Orian Mace', 'Ryl.Sqr. Mace', 'Pixie Mace', 'Bastokan Hammer',
             'Republic Hammer' },
        Sub   = { 'Tariqah', 'Tariqah +1', 'Viking Shield', 'Strike Shield' },
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
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias /whm /lac fwd');

    -- Lock appearance a few seconds after loading
    common.RequestLockStyle(1);
end

profile.OnUnload = function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /whm');
end

profile.HandleCommand = function(args)
    -- Handle utility settings
    utility.SetOptions(args[1]);

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

	if (action.Skill == 'Healing Magic') then
		gFunc.EquipSet(sets.Cure);
	elseif (action.Skill == 'Enhancing Magic') then
		gFunc.EquipSet(sets.Enhancing);
	elseif (action.Skill == 'Enfeebling Magic') then
		gFunc.EquipSet(sets.Enfeebling);
	elseif (action.Skill == 'Divine Magic') then
		gFunc.EquipSet(sets.Divine);
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
