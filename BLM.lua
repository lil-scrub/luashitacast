local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
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
    -- Out of combat: refresh and raw MP, ordered by how much MP each piece gives. The Earth staff goes on top.
    ['Idle_Priority'] = {
        Head  = { 'Wivre Hairpin +1', 'Wivre Hairpin', 'Oracle\'s Cap', 'Electrum Hairpin',
             'Coral Hairpin', 'Goliard Chapeau', 'Rain Hat', 'Kosshin', 'Magi Hat',
             'Silken Hat', 'Storm Turban', 'Trump Crown', 'Circe\'s Hat', 'Coven Hat',
             'Bonze\'s Circlet', 'Macha\'s Crown', 'Bodb\'s Crown', 'Nemain\'s Crown',
             'Yigit Turban', 'Jester\'s Headband', 'Blissful Chapeau' },
        Neck  = { 'Fenrir\'s Torque', 'Beak Necklace +1', 'Chi Necklace', 'Beak Necklace',
             'Merrow No. 17\'s Locket', 'Grandiose Chain', 'Spirit Torque', 'Holy Phial',
             'Mohbwa Scarf +1', 'Republican Iron Medal', 'Mohbwa Scarf',
             'Republican Bronze Medal', 'Morgana\'s Choker', 'Purgatory Collar',
             'Pachamac\'s Collar', 'Promise Badge', 'Shield Pendant', 'Tiger Stole',
             'Black Neckerchief', 'Bird Whistle', 'Green Scarf' },
        Ear1  = { 'Celestial Earring', 'Magnetic Earring', 'Esquire\'s Earring',
             'Insomnia Earring', 'Hades Earring +1', 'Rapture Earring', 'Mana Earring +1',
             'Aura Earring +1', 'Bat Earring', 'Energy Earring +1', 'Valor Earring',
             'Ethereal Earring', 'Relaxing Earring', 'Refresh Earring', 'Boroka Earring',
             'Intruder Earring', 'Warlock\'s Earring', 'Shield Earring', 'Mecurial Earring',
             'Cassie Earring' },
        Ear2  = { 'Celestial Earring', 'Magnetic Earring', 'Esquire\'s Earring',
             'Insomnia Earring', 'Hades Earring +1', 'Rapture Earring', 'Mana Earring +1',
             'Aura Earring +1', 'Bat Earring', 'Energy Earring +1', 'Valor Earring',
             'Ethereal Earring', 'Relaxing Earring', 'Refresh Earring', 'Boroka Earring',
             'Intruder Earring', 'Warlock\'s Earring', 'Shield Earring', 'Mecurial Earring',
             'Cassie Earring' },
        Body  = { 'Sorcerer\'s Coat', 'Royal Squire\'s Robe +1', 'Royal Squire\'s Robe +2',
             'Seer\'s Tunic +1', 'Pyro Robe', 'Seer\'s Tunic', 'Kingdom Tunic', 'Magna Bodice',
             'Magna Jerkin', 'San d\'Orian Tunic', 'Mage\'s Robe', 'Dalmatica', 'Dalmatica +1',
             'Black Cloak', 'Silk Cloak +1', 'Black Cotehardie', 'Flora Cotehardie',
             'Duende Cotehardie', 'Faerie Tunic', 'Mana Tunic' },
        Hands = { 'Dune Bracers', 'Wood Gauntlets', 'Sadhu Cuffs', 'Oracle\'s Gloves',
             'Storm Gages', 'Magical Mitts', 'Magi Cuffs', 'New Moon Armlets',
             'Devotee\'s Mitts', 'Zealot\'s Mitts', 'Custom F Gloves', 'Custom M Gloves',
             'Macha\'s Cuffs', 'Nemain\'s Cuffs', 'Zenith Mitts', 'Yigit Gages',
             'Turtle Bangles', 'Combat Caster\'s Mitts +1', 'Combat Caster\'s Mitts +2',
             'Mage\'s Cuffs', 'Scentless Armlets' },
        Ring1 = { 'Variable Ring', 'Dark Ring', 'Celestial Ring', 'Star Ring', 'Electrum Ring',
             'Water Ring', 'Fasting Ring', 'Mystic Ring +1', 'Aura Ring +1', 'Aura Ring',
             'Energy Ring +1', 'Black Ring', 'Bloodbead Ring', 'Vivian Ring', 'Peace Ring',
             'Balrahn\'s Ring', 'Gold Ring', 'Gold Ring +1', 'Mythril Ring', 'Mythril Ring +1',
             'Poisona Ring' },
        Ring2 = { 'Variable Ring', 'Dark Ring', 'Celestial Ring', 'Star Ring', 'Electrum Ring',
             'Water Ring', 'Fasting Ring', 'Mystic Ring +1', 'Aura Ring +1', 'Aura Ring',
             'Energy Ring +1', 'Black Ring', 'Bloodbead Ring', 'Vivian Ring', 'Peace Ring',
             'Balrahn\'s Ring', 'Gold Ring', 'Gold Ring +1', 'Mythril Ring', 'Mythril Ring +1',
             'Poisona Ring' },
        Back  = { 'Storm Cape', 'Blue Cape +1', 'Blue Cape', 'Aurora Mantle +1',
             'Talisman Cape', 'Prism Cape', 'Aurora Mantle', 'Esoteric Mantle', 'Lucent Cape',
             'Federal Army Mantle', 'Tundra Mantle', 'Invigorating Cape', 'Maledictor\'s Shawl',
             'Aries Mantle', 'Black Cape', 'Wizard\'s Mantle', 'Variable Cape', 'Cotton Cape',
             'Cotton Cape +1' },
        Waist = { 'Lambda Sash', 'Hierarch Belt', 'Desert Stone', 'Forest Stone',
             'Jungle Stone', 'Lieutenant\'s Sash', 'Qiqirn Sash +1', 'Qiqirn Sash',
             'Mohbwa Sash +1', 'Spectral Belt', 'Hojutsu Belt', 'Mohbwa Sash', 'Adept\'s Rope',
             'Oracle\'s Belt', 'Volunteer\'s Belt', 'Magic Belt +1', 'Friar\'s Rope',
             'Force Belt', 'Magic Belt', 'Penitent\'s Rope', 'Tathlum Belt' },
        Legs  = { 'Yigit Seraweels', 'Oracle\'s Braconi', 'Wizard\'s Tonban +1',
             'Combat Caster\'s Slacks +2', 'Combat Caster\'s Slacks +1', 'Magna F Chausses',
             'Magna M Chausses', 'Magi Slops', 'Silken Slops', 'Seer\'s Slacks +1',
             'Seer\'s Slacks', 'Sturdy Slacks', 'Federation Slops', 'Mage\'s Slops',
             'Aries Subligar', 'Nemain\'s Slops', 'Druid\'s Slops', 'Silk Slacks',
             'Silk Slacks +1', 'Magic Slacks', 'Baron\'s Slops' },
        Feet  = { 'Oracle\'s Pigaches', 'Ataractic Solea', 'Wizard\'s Sabots +1',
             'Wizard\'s Sabots', 'Magi Pigaches', 'Inferno Sabots +1', 'Silken Pigaches',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Inferno Sabots',
             'Kingdom Clogs', 'Macha\'s Pigaches', 'Nemain\'s Sabots', 'Yigit Crackows',
             'Creek F Clomps', 'Creek M Clomps', 'Combat Caster\'s Shoes +1', 'Ebony Sabots',
             'Garrison Boots', 'Power Sandals' },
    },
    -- Fast cast, worn during the precast phase of every spell.
    ['Precast_Priority'] = {
        Ear1  = { 'Loquacious Earring' },
        Ear2  = { 'Loquacious Earring' },
        Ring1 = { 'Pi Ring' },
        Ring2 = { 'Pi Ring' },
        Back  = { 'Warlock\'s Mantle' },
        Feet  = { 'Rostrum Pumps' },
    },
    -- Elemental magic -- magic attack, INT and elemental skill.
    ['Nuke_Priority'] = {
        Head  = { 'Morrigan\'s Coronal', 'Sorcerer\'s Petasos', 'Yigit Turban', 'Opo-opo Crown',
             'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon', 'Tactician Magician\'s Hat +1',
             'Tactician Magician\'s Hat +2', 'Neit\'s Crown', 'Macha\'s Crown',
             'Bastokan Circlet', 'Republic Circlet', 'Seer\'s Crown', 'Seer\'s Crown +1',
             'Bodb\'s Crown', 'Erudite\'s Headband', 'Sage\'s Circlet', 'Eldritch Bone Hairpin' },
        Neck  = { 'Prudence Torque', 'Uggalepih Pendant', 'Jeweled Collar +1',
             'Elemental Torque', 'Philomath Stole', 'Enlightened Chain', 'Stoneskin Torque',
             'Torque', 'Torque +1', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Black Neckerchief' },
        Ear1  = { 'Novio Earring', 'Static Earring', 'Abyssal Earring', 'Omniscient Earring',
             'Omniscient Earring +1', 'Phantom Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Boroka Earring', 'Heims Earring', 'Elemental Earring',
             'Wizard\'s Earring', 'Morion Earring', 'Cunning Earring' },
        Ear2  = { 'Novio Earring', 'Static Earring', 'Abyssal Earring', 'Omniscient Earring',
             'Omniscient Earring +1', 'Phantom Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Boroka Earring', 'Heims Earring', 'Elemental Earring',
             'Wizard\'s Earring', 'Morion Earring', 'Cunning Earring' },
        Body  = { 'Morrigan\'s Robe', 'Genie Weskit', 'Igqira Weskit', 'Black Cloak',
             'Black Cotehardie', 'Flora Cotehardie', 'Shaman\'s Cloak',
             'Combat Caster\'s Cloak +1', 'Combat Caster\'s Cloak +2',
             'Royal Squire\'s Robe +1', 'Mage\'s Robe', 'Macha\'s Coat', 'Custom Tunic',
             'Bodb\'s Robe', 'Baron\'s Saio', 'Black Tunic', 'Kingdom Tunic',
             'San d\'Orian Tunic', 'Royal Footman\'s Tunic' },
        Hands = { 'Genie Manillas', 'Igqira Manillas', 'Yigit Gages',
             'Master Caster\'s Bracelets', 'Dune Bracers', 'Marine F Gloves',
             'Wizard\'s Gloves', 'Mage\'s Mitts', 'Sly Gauntlets', 'Sennight Bangles',
             'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Epsilon Ring', 'Breeze Ring', 'Dark Ring', 'Serene Ring', 'Ice Ring',
             'Vivian Ring', 'Zoredonite Ring', 'Genius Ring', 'Balrahn\'s Ring',
             'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring', 'Malfrost Ring',
             'Tamas Ring', 'Clear Ring', 'Knowledge Ring', 'Knowledge Ring +1' },
        Ring2 = { 'Epsilon Ring', 'Breeze Ring', 'Dark Ring', 'Serene Ring', 'Ice Ring',
             'Vivian Ring', 'Zoredonite Ring', 'Genius Ring', 'Balrahn\'s Ring',
             'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring', 'Malfrost Ring',
             'Tamas Ring', 'Clear Ring', 'Knowledge Ring', 'Knowledge Ring +1' },
        Back  = { 'Maledictor\'s Shawl', 'Merciful Cape', 'Solitaire Cape', 'Sapient Cape',
             'Federal Army Mantle', 'Gramary Cape', 'Red Cape', 'Red Cape +1', 'Black Cape',
             'Black Cape +1' },
        Waist = { 'Ksi Sash', 'Theta Sash', 'Immortal\'s Sash', 'Arachne Obi', 'Arachne Obi +1',
             'Bitter Corset', 'Desert Belt', 'Desert Stone', 'Forest Stone', 'Reverend Sash',
             'Druid\'s Rope', 'Mantra Belt', 'Sagacious Gold Obi', 'Mercenary Captain\'s Belt',
             'Wizard\'s Belt', 'Shaman\'s Belt' },
        Legs  = { 'Morrigan\'s Slops', 'Shadow Trews', 'Valkyrie\'s Trews', 'Druid\'s Slops',
             'Magic Slacks', 'Macha\'s Slops', 'Elder\'s Braguette', 'Seer\'s Slacks',
             'Seer\'s Slacks +1', 'Bodb\'s Slops' },
        Feet  = { 'Morrigan\'s Pigaches', 'Nashira Crackows', 'Yigit Crackows',
             'Creek F Clomps', 'Creek M Clomps', 'Marine F Boots',
             'Tactician Magician\'s Pigaches +1', 'Tactician Magician\'s Pigaches +2',
             'Wizard\'s Sabots', 'Inferno Sabots', 'Inferno Sabots +1', 'Mountain Gaiters',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Elder\'s Sandals',
             'Garrison Boots' },
    },
    -- Magic accuracy and INT for sleeps and binds.
    ['Enfeebling_Priority'] = {
        Head  = { 'Morrigan\'s Coronal', 'Nashira Turban', 'Shadow Hat', 'Opo-opo Crown',
             'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon', 'Tactician Magician\'s Hat +1',
             'Storm Zucchetto', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Macha\'s Crown',
             'Eldritch Horn Hairpin', 'Seer\'s Crown', 'Seer\'s Crown +1', 'Bodb\'s Crown',
             'Erudite\'s Headband', 'Sage\'s Circlet', 'Eldritch Bone Hairpin' },
        Neck  = { 'Phi Necklace', 'Prudence Torque', 'Jeweled Collar +1',
             'Lieutenant\'s Gorget', 'Enfeebling Torque', 'Spider Torque', 'Stoneskin Torque',
             'Torque', 'Torque +1', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Yinyang Lorgnette',
             'Holy Phial', 'Fang Necklace', 'Black Neckerchief', 'Justice Badge' },
        Ear1  = { 'Abyssal Earring', 'Static Earring', 'Omniscient Earring',
             'Omniscient Earring +1', 'Diabolos\'s Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Ryakho\'s Earring', 'Boroka Earring', 'Heims Earring',
             'Harvest Earring', 'Enfeebling Earring', 'Morion Earring', 'Morion Earring +1',
             'Cunning Earring' },
        Ear2  = { 'Abyssal Earring', 'Static Earring', 'Omniscient Earring',
             'Omniscient Earring +1', 'Diabolos\'s Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Ryakho\'s Earring', 'Boroka Earring', 'Heims Earring',
             'Harvest Earring', 'Enfeebling Earring', 'Morion Earring', 'Morion Earring +1',
             'Cunning Earring' },
        Body  = { 'Nashira Manteel', 'Shadow Coat', 'Valkyrie\'s Coat', 'Black Cloak',
             'Black Cotehardie', 'Flora Cotehardie', 'Shaman\'s Cloak',
             'Combat Caster\'s Cloak +1', 'Combat Caster\'s Cloak +2', 'Combat Caster\'s Cloak',
             'Mage\'s Robe', 'Macha\'s Coat', 'Custom Tunic', 'Bodb\'s Robe', 'Baron\'s Saio',
             'Black Tunic', 'Kingdom Tunic', 'San d\'Orian Tunic', 'Royal Footman\'s Tunic' },
        Hands = { 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Goliard Cuffs',
             'Master Caster\'s Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Mage\'s Mitts', 'Sly Gauntlets', 'Sennight Bangles', 'Seer\'s Mitts',
             'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Epsilon Ring', 'Opuntia Hoop', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Patriarch Protector\'s Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 9', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malfrost Ring', 'Tamas Ring', 'Carect Ring', 'Clear Ring', 'Knowledge Ring',
             'Knowledge Ring +1' },
        Ring2 = { 'Epsilon Ring', 'Opuntia Hoop', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Patriarch Protector\'s Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 9', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malfrost Ring', 'Tamas Ring', 'Carect Ring', 'Clear Ring', 'Knowledge Ring',
             'Knowledge Ring +1' },
        Back  = { 'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Sapient Cape',
             'Miraculous Cape', 'Federal Army Mantle', 'Royal Army Mantle', 'Gramary Cape',
             'Red Cape', 'Red Cape +1', 'Black Cape', 'Black Cape +1', 'White Cape',
             'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Arachne Obi', 'Bitter Corset',
             'Penitent\'s Rope', 'Jungle Stone', 'Ocean Stone', 'Storm Sash', 'Reverend Sash',
             'Druid\'s Rope', 'Mantra Belt', 'Sagacious Gold Obi', 'Mercenary Captain\'s Belt',
             'Wizard\'s Belt', 'Shaman\'s Belt', 'Friar\'s Rope' },
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews',
             'Tactician Magician\'s Slops +1', 'Tactician Magician\'s Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Macha\'s Slops', 'Elder\'s Braguette',
             'Custom Pants', 'Seer\'s Slacks', 'Seer\'s Slacks +1', 'Bodb\'s Slops' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Tactician Magician\'s Pigaches +1',
             'Tactician Magician\'s Pigaches +2', 'Wizard\'s Sabots', 'Inferno Sabots',
             'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Elder\'s Sandals', 'Garrison Boots' },
    },
    -- Dark magic -- Drain, Aspir, Bio.
    ['Dark_Priority'] = {
        Head  = { 'Morrigan\'s Coronal', 'Nashira Turban', 'Shadow Hat', 'Opo-opo Crown',
             'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon', 'Tactician Magician\'s Hat +1',
             'Tactician Magician\'s Hat +2', 'Neit\'s Crown', 'Sinister Mask', 'Macha\'s Crown',
             'Eldritch Horn Hairpin', 'Seer\'s Crown', 'Seer\'s Crown +1', 'Bodb\'s Crown',
             'Erudite\'s Headband', 'Sage\'s Circlet', 'Eldritch Bone Hairpin' },
        Neck  = { 'Prudence Torque', 'Jeweled Collar +1', 'Dark Torque', 'Lieutenant\'s Gorget',
             'Philomath Stole', 'Stoneskin Torque', 'Torque', 'Torque +1', 'Mohbwa Scarf',
             'Mohbwa Scarf +1', 'Black Neckerchief' },
        Ear1  = { 'Abyssal Earring', 'Omniscient Earring', 'Omniscient Earring +1',
             'Diabolos\'s Earring', 'Desamilion Earring', 'Gayanj\'s Earring', 'Boroka Earring',
             'Heims Earring', 'Dark Earring', 'Morion Earring', 'Morion Earring +1',
             'Cunning Earring' },
        Ear2  = { 'Abyssal Earring', 'Omniscient Earring', 'Omniscient Earring +1',
             'Diabolos\'s Earring', 'Desamilion Earring', 'Gayanj\'s Earring', 'Boroka Earring',
             'Heims Earring', 'Dark Earring', 'Morion Earring', 'Morion Earring +1',
             'Cunning Earring' },
        Body  = { 'Nashira Manteel', 'Morrigan\'s Robe', 'Shadow Coat', 'Black Cloak',
             'Black Cotehardie', 'Flora Cotehardie', 'Healing Justaucorps',
             'Combat Caster\'s Cloak +1', 'Combat Caster\'s Cloak +2',
             'Royal Squire\'s Robe +1', 'Mage\'s Robe', 'Macha\'s Coat', 'Custom Tunic',
             'Bodb\'s Robe', 'Baron\'s Saio', 'Black Tunic', 'Kingdom Tunic',
             'San d\'Orian Tunic', 'Royal Footman\'s Tunic' },
        Hands = { 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Sorcerer\'s Gloves',
             'Master Caster\'s Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Mage\'s Mitts',
             'Sly Gauntlets', 'Sennight Bangles', 'Seer\'s Mitts', 'Seer\'s Mitts +1',
             'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Epsilon Ring', 'Opuntia Hoop', 'Breeze Ring', 'Serene Ring',
             'Diabolos\'s Ring', 'Vivian Ring', 'Zoredonite Ring', 'Genius Ring',
             'Balrahn\'s Ring', 'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malfrost Ring', 'Tamas Ring', 'Clear Ring', 'Knowledge Ring', 'Knowledge Ring +1' },
        Ring2 = { 'Epsilon Ring', 'Opuntia Hoop', 'Breeze Ring', 'Serene Ring',
             'Diabolos\'s Ring', 'Vivian Ring', 'Zoredonite Ring', 'Genius Ring',
             'Balrahn\'s Ring', 'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malfrost Ring', 'Tamas Ring', 'Clear Ring', 'Knowledge Ring', 'Knowledge Ring +1' },
        Back  = { 'Merciful Cape', 'Prism Cape', 'Rainbow Cape', 'Sapient Cape',
             'Federal Army Mantle', 'Gramary Cape', 'Red Cape', 'Red Cape +1', 'Black Cape',
             'Black Cape +1', 'Killer Mantle' },
        Waist = { 'Theta Sash', 'Ksi Sash', 'Immortal\'s Sash', 'Arachne Obi', 'Arachne Obi +1',
             'Ice Belt', 'Desert Belt', 'Desert Stone', 'Forest Stone', 'Reverend Sash',
             'Druid\'s Rope', 'Mantra Belt', 'Sagacious Gold Obi', 'Mercenary Captain\'s Belt',
             'Wizard\'s Belt', 'Shaman\'s Belt' },
        Legs  = { 'Morrigan\'s Slops', 'Nashira Seraweels', 'Wizard\'s Tonban +1',
             'Wizard\'s Tonban', 'Magic Slacks', 'Macha\'s Slops', 'Elder\'s Braguette',
             'Seer\'s Slacks', 'Seer\'s Slacks +1', 'Bodb\'s Slops' },
        Feet  = { 'Goliard Clogs', 'Genie Huaraches', 'Igqira Huaraches', 'Creek F Clomps',
             'Creek M Clomps', 'Marine F Boots', 'Tactician Magician\'s Pigaches +1',
             'Tactician Magician\'s Pigaches +2', 'Wizard\'s Sabots', 'Inferno Sabots',
             'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Elder\'s Sandals', 'Garrison Boots' },
    },
    -- Enhancing magic skill -- Stoneskin and Blink.
    ['Enhancing_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Morrigan\'s Coronal', 'Magus Keffiyeh +1',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1',
             'Super Ribbon', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Circe\'s Hat',
             'Eldritch Horn Hairpin', 'Garrison Sallet', 'Traveler\'s Hat',
             'Eldritch Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Enhancing Torque', 'Enlightened Chain', 'Stoneskin Torque', 'Torque', 'Torque +1',
             'Promise Badge', 'Yinyang Lorgnette', 'Mohbwa Scarf', 'Holy Phial',
             'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Communion Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augmenting Earring' },
        Ear2  = { 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Communion Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augmenting Earring' },
        Body  = { 'Morrigan\'s Robe', 'Errant Houppelande', 'Mahatma Houppelande',
             'Black Cotehardie', 'Flora Cotehardie', 'Healing Justaucorps',
             'Combat Caster\'s Cloak +1', 'Combat Caster\'s Cloak +2', 'Combat Caster\'s Cloak',
             'Bishop\'s Robe', 'Bishop\'s Robe +1', 'Macha\'s Coat', 'Baron\'s Saio',
             'Priest\'s Robe' },
        Hands = { 'Yigit Gages', 'Master Caster\'s Bracelets', 'Dune Bracers',
             'Marine F Gloves', 'Magi Cuffs', 'Silk Cuffs +1', 'Seer\'s Mitts',
             'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring',
             'Solace Ring +1', 'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring',
             'Saintly Ring' },
        Ring2 = { 'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring',
             'Solace Ring +1', 'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring',
             'Saintly Ring' },
        Back  = { 'Merciful Cape', 'Prism Cape', 'Rainbow Cape', 'Miraculous Cape',
             'Sapient Cape', 'Royal Army Mantle', 'Red Cape', 'Red Cape +1', 'White Cape',
             'White Cape +1', 'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt',
             'Deductive Brocade Obi', 'Penitent\'s Rope', 'Twinthread Obi', 'Twinthread Obi +1',
             'Forest Belt', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deductive Gold Obi', 'Mercenary Captain\'s Belt', 'Friar\'s Rope' },
        Legs  = { 'Morrigan\'s Slops', 'Zenith Slacks', 'Zenith Slacks +1',
             'Tactician Magician\'s Slops +1', 'Tactician Magician\'s Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Macha\'s Slops', 'Custom Pants',
             'Custom Slacks' },
        Feet  = { 'Goliard Clogs', 'Genie Huaraches', 'Igqira Huaraches', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Cures from a healing subjob.
    ['Cure_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Morrigan\'s Coronal', 'Magus Keffiyeh +1',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1',
             'Super Ribbon', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Circe\'s Hat',
             'Eldritch Horn Hairpin', 'Garrison Sallet', 'Traveler\'s Hat',
             'Eldritch Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Phi Necklace', 'Jeweled Collar +1', 'Healing Torque',
             'Purgatory Collar', 'Enlightened Chain', 'Stoneskin Torque', 'Torque', 'Torque +1',
             'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Holy Phial', 'Fang Necklace',
             'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Magnetic Earring', 'Celestial Earring',
             'Communion Earring', 'Communion Earring +1', 'Ryakho\'s Earring',
             'Harvest Earring', 'Geist Earring', 'Healing Earring' },
        Ear2  = { 'Static Earring', 'Magnetic Earring', 'Celestial Earring',
             'Communion Earring', 'Communion Earring +1', 'Ryakho\'s Earring',
             'Harvest Earring', 'Geist Earring', 'Healing Earring' },
        Body  = { 'Nashira Manteel', 'Morrigan\'s Robe', 'Errant Houppelande',
             'Black Cotehardie', 'Flora Cotehardie', 'Healing Justaucorps',
             'Combat Caster\'s Cloak +1', 'Combat Caster\'s Cloak +2', 'Combat Caster\'s Cloak',
             'Bishop\'s Robe', 'Bishop\'s Robe +1', 'Macha\'s Coat', 'Baron\'s Saio',
             'Priest\'s Robe' },
        Hands = { 'Yigit Gages', 'Master Caster\'s Bracelets', 'Dune Bracers',
             'Marine F Gloves', 'Magi Cuffs', 'Silk Cuffs +1', 'Seer\'s Mitts',
             'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring',
             'Solace Ring +1', 'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring',
             'Saintly Ring' },
        Ring2 = { 'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring',
             'Solace Ring +1', 'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring',
             'Saintly Ring' },
        Back  = { 'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Miraculous Cape',
             'Sapient Cape', 'Royal Army Mantle', 'Red Cape', 'Red Cape +1', 'White Cape',
             'White Cape +1', 'Mist Silk Cape' },
        Waist = { 'Lambda Sash', 'Ksi Sash', 'Al Zahbi Sash', 'Water Belt',
             'Deductive Brocade Obi', 'Penitent\'s Rope', 'Twinthread Obi', 'Twinthread Obi +1',
             'Forest Belt', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deductive Gold Obi', 'Mercenary Captain\'s Belt', 'Friar\'s Rope' },
        Legs  = { 'Morrigan\'s Slops', 'Zenith Slacks', 'Zenith Slacks +1', 'Druid\'s Slops',
             'Tactician Magician\'s Slops +1', 'Tactician Magician\'s Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Macha\'s Slops', 'Custom Pants',
             'Custom Slacks' },
        Feet  = { 'Goliard Clogs', 'Morrigan\'s Pigaches', 'Rostrum Pumps', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Melee, worn while engaged.
    ['TP_Priority'] = {
        Head  = { 'Nashira Turban', 'Morrigan\'s Coronal', 'Pineal Hat', 'Qiqirn Hood',
             'Opo-opo Crown', 'Corsair\'s Tricorne', 'Super Ribbon', 'Storm Zucchetto',
             'Neit\'s Crown', 'Voyager Sallet', 'Spelunker\'s Hat', 'Macha\'s Crown',
             'Dandy Spectacles', 'Fancy Spectacles', 'Emperor Hairpin', 'Empress Hairpin' },
        Neck  = { 'Aqua Gorget', 'Breeze Gorget', 'Diabolos\'s Torque', 'Sniper\'s Collar',
             'Grand Temple Knight\'s Collar', 'Chivalrous Chain', 'Ashura Necklace',
             'Storm Gorget', 'Auditory Torque', 'Peacock Amulet', 'Peacock Charm',
             'Tiger Stole', 'Fang Necklace', 'Spike Necklace', 'Feather Collar +1' },
        Ear1  = { 'Beta Earring', 'Hollow Earring', 'Beastly Earring', 'Diabolos\'s Earring',
             'Magnifying Earring', 'Minuet Earring', 'Bitter Earring', 'Accurate Earring',
             'Vision Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Wyvern Earring', 'Beater\'s Earring', 'Killer Earring', 'Mythril Earring +1',
             'Reraise Earring', 'Beetle Earring', 'Bone Earring', 'Bone Earring +1',
             'Optical Earring' },
        Ear2  = { 'Beta Earring', 'Hollow Earring', 'Beastly Earring', 'Diabolos\'s Earring',
             'Magnifying Earring', 'Minuet Earring', 'Bitter Earring', 'Accurate Earring',
             'Vision Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Wyvern Earring', 'Beater\'s Earring', 'Killer Earring', 'Mythril Earring +1',
             'Reraise Earring', 'Beetle Earring', 'Bone Earring', 'Bone Earring +1',
             'Optical Earring' },
        Body  = { 'Nashira Manteel', 'Morrigan\'s Robe', 'Commodore Frac', 'Black Cotehardie',
             'Flora Cotehardie', 'Corsair\'s Frac', 'Combat Caster\'s Cloak +1',
             'Combat Caster\'s Cloak +2', 'Combat Caster\'s Cloak', 'Macha\'s Coat',
             'Magna Bodice', 'Magna Jerkin', 'Bodb\'s Robe', 'Garrison Tunica', 'Nemain\'s Robe' },
        Hands = { 'Nashira Gages', 'Goliard Cuffs', 'Morrigan\'s Cuffs', 'Creek F Mitts',
             'Creek M Mitts', 'Wood Gauntlets', 'Tactician Magician\'s Cuffs +1',
             'Tactician Magician\'s Cuffs +2', 'Aiming Bracelets', 'Combat Caster\'s Mitts +1',
             'Combat Caster\'s Mitts +2', 'Combat Caster\'s Mitts', 'Sennight Bangles',
             'Macha\'s Cuffs', 'Custom F Gloves', 'Custom M Gloves', 'Bodb\'s Cuffs',
             'Linen Cuffs +1' },
        Ring1 = { 'Bellona\'s Ring', 'Mars\'s Ring', 'Iota Ring', 'Marid Ring', 'Marid Ring +1',
             'Lightning Ring', 'Ulthalam\'s Ring', 'Jalzahn\'s Ring', 'Imperial Ring',
             'Kshama Ring No. 2', 'Kshama Ring No. 8', 'Carapace Ring', 'Horn Ring',
             'Horn Ring +1', 'Divisor Ring', 'Bowyer Ring', 'Beetle Ring', 'Beetle Ring +1',
             'Bone Ring', 'Bone Ring +1', 'Vision Ring' },
        Ring2 = { 'Bellona\'s Ring', 'Mars\'s Ring', 'Iota Ring', 'Marid Ring', 'Marid Ring +1',
             'Lightning Ring', 'Ulthalam\'s Ring', 'Jalzahn\'s Ring', 'Imperial Ring',
             'Kshama Ring No. 2', 'Kshama Ring No. 8', 'Carapace Ring', 'Horn Ring',
             'Horn Ring +1', 'Divisor Ring', 'Bowyer Ring', 'Beetle Ring', 'Beetle Ring +1',
             'Bone Ring', 'Bone Ring +1', 'Vision Ring' },
        Back  = { 'Gunner\'s Mantle', 'Republican Army Mantle', 'Bellicose Mantle',
             'Gramary Cape', 'Rearguard Mantle' },
        Waist = { 'Ninurta\'s Sash', 'Buccaneer\'s Belt', 'Sprinter\'s Belt', 'Mithran Stone',
             'Bitter Corset', 'Potent Belt', 'Flagellant\'s Rope', 'Swift Belt', 'Ocean Belt',
             'Life Belt', 'Tilt Belt', 'Corsette', 'Wyvern Belt', 'Pilferer\'s Belt',
             'Mercenary Captain\'s Belt' },
        Legs  = { 'Nashira Seraweels', 'Morrigan\'s Slops', 'Shadow Trews',
             'Combat Caster\'s Slacks +1', 'Combat Caster\'s Slacks +2',
             'Combat Caster\'s Slacks', 'Custom Pants', 'Custom Slacks', 'Magna F Chausses',
             'Garrison Hose' },
        Feet  = { 'Nashira Crackows', 'Goliard Clogs', 'Vampiric Boots', 'Marine F Boots',
             'Marine M Boots', 'Creek F Clomps', 'Storm Gambieras', 'Mountain Gaiters',
             'Macha\'s Pigaches', 'Custom F Boots', 'Custom M Boots', 'Savage Gaiters' },
    },
    -- Club, dagger and shield for soloing.
    ['Weapon_Priority'] = {
        Main  = { 'Thanatos Baselard', 'Titan\'s Baselarde', 'Reserve Captain\'s Mace',
             'Senior Gold Musketeer\'s Rod', 'Daylight Dagger', 'Palladium Dagger', 'Rune Rod',
             'Garuda\'s Dagger', 'Curse Wand', 'Sloth Wand', 'Lust Dagger', 'Triple Dagger',
             'Kingdom Dagger', 'San d\'Orian Dagger', 'Royal Squire\'s Dagger',
             'Bastokan Dagger', 'Decurion\'s Dagger', 'Piercing Dagger' },
        Sub   = { 'Wyvern Targe', 'Genin Aspis', 'Healer\'s Shield', 'Wizard\'s Shield' },
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

    common.EvalLevel(level);
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias /blm /lac fwd');

    AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. Settings.MacroBook);
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
