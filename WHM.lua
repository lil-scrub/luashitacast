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
    -- Out of combat: refresh and raw MP, ordered by how much MP each piece gives. The Earth staff goes on top.
    ['Idle_Priority'] = {
        Head  = { 'Wivre Hairpin +1', 'Wivre Hairpin', 'Oracle\'s Cap', 'Curate\'s Hat',
             'Electrum Hairpin', 'Goliard Chapeau', 'Rain Hat', 'Magi Hat', 'Silken Hat',
             'Trump Crown', 'Healer\'s Cap', 'Federation Headgear', 'Namru\'s Tiara',
             'Windurstian Headgear', 'Shell Hairpin', 'Enlil\'s Tiara', 'Ea\'s Tiara',
             'Bonze\'s Circlet', 'Anu\'s Tiara', 'Yigit Turban', 'Blissful Chapeau' },
        Neck  = { 'Fenrir\'s Torque', 'Chi Necklace', 'Beak Necklace',
             'Merrow No. 17\'s Locket', 'Grandiose Chain', 'Spirit Torque', 'Holy Phial',
             'Mohbwa Scarf +1', 'Republican Iron Medal', 'Mohbwa Scarf',
             'Republican Bronze Medal', 'Morgana\'s Choker', 'Purgatory Collar',
             'Star Necklace', 'Pachamac\'s Collar', 'Promise Badge', 'Shield Pendant',
             'Tiger Stole', 'Hemp Gorget', 'Bird Whistle', 'Green Scarf' },
        Ear1  = { 'Celestial Earring', 'Magnetic Earring', 'Insomnia Earring',
             'Hades Earring +1', 'Rapture Earring', 'Death Earring', 'Mana Earring +1',
             'Aura Earring +1', 'Bat Earring', 'Geist Earring', 'Aura Earring',
             'Energy Earring +1', 'Valor Earring', 'Ethereal Earring', 'Refresh Earring',
             'Astral Earring', 'Intruder Earring', 'Shield Earring', 'Mecurial Earring',
             'Cassie Earring' },
        Ear2  = { 'Celestial Earring', 'Magnetic Earring', 'Insomnia Earring',
             'Hades Earring +1', 'Rapture Earring', 'Death Earring', 'Mana Earring +1',
             'Aura Earring +1', 'Bat Earring', 'Geist Earring', 'Aura Earring',
             'Energy Earring +1', 'Valor Earring', 'Ethereal Earring', 'Refresh Earring',
             'Astral Earring', 'Intruder Earring', 'Shield Earring', 'Mecurial Earring',
             'Cassie Earring' },
        Body  = { 'Magi Coat', 'Aristocrat\'s Coat', 'Noble\'s Tunic',
             'Royal Squire\'s Robe +1', 'Royal Squire\'s Robe +2', 'Seer\'s Tunic +1',
             'Pyro Robe', 'Seer\'s Tunic', 'Marduk\'s Jubbah', 'Kingdom Tunic', 'Magna Bodice',
             'Magna Jerkin', 'San d\'Orian Tunic', 'Mage\'s Robe', 'Dalmatica', 'Dalmatica +1',
             'Silk Cloak +1', 'Black Cotehardie', 'Flora Cotehardie', 'Faerie Tunic',
             'Mana Tunic' },
        Hands = { 'Dune Bracers', 'Wood Gauntlets', 'Wood Gloves', 'Oracle\'s Gloves',
             'Magical Mitts', 'Magi Cuffs', 'Silken Cuffs', 'New Moon Armlets',
             'Devotee\'s Mitts', 'Zealot\'s Mitts', 'Custom F Gloves', 'Custom M Gloves',
             'Zenith Mitts', 'Yigit Gages', 'Wool Bracers', 'Combat Caster\'s Mitts +1',
             'Combat Caster\'s Mitts +2', 'Mage\'s Cuffs', 'Velvet Cuffs', 'Scentless Armlets',
             'Angler\'s Gloves' },
        Ring1 = { 'Variable Ring', 'Dark Ring', 'Celestial Ring', 'Star Ring', 'Electrum Ring',
             'Water Ring', 'Horizon Ring', 'Fasting Ring', 'Mystic Ring +1', 'Aura Ring +1',
             'Aura Ring', 'Energy Ring +1', 'Black Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Peace Ring', 'Gold Ring', 'Gold Ring +1', 'Mythril Ring', 'Mythril Ring +1',
             'Poisona Ring' },
        Ring2 = { 'Variable Ring', 'Dark Ring', 'Celestial Ring', 'Star Ring', 'Electrum Ring',
             'Water Ring', 'Horizon Ring', 'Fasting Ring', 'Mystic Ring +1', 'Aura Ring +1',
             'Aura Ring', 'Energy Ring +1', 'Black Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Peace Ring', 'Gold Ring', 'Gold Ring +1', 'Mythril Ring', 'Mythril Ring +1',
             'Poisona Ring' },
        Back  = { 'Blue Cape +1', 'Blue Cape', 'Aurora Mantle +1', 'Talisman Cape',
             'Prism Cape', 'Enhancing Mantle', 'Aurora Mantle', 'Esoteric Mantle',
             'Lucent Cape', 'Federal Army Mantle', 'Tundra Mantle', 'Invigorating Cape',
             'Maledictor\'s Shawl', 'Aries Mantle', 'Black Cape', 'Black Cape +1',
             'Variable Cape', 'Cotton Cape', 'Cotton Cape +1' },
        Waist = { 'Lambda Sash', 'Hierarch Belt', 'Desert Stone', 'Forest Stone',
             'Jungle Stone', 'Immortal\'s Sash', 'Lieutenant\'s Sash', 'Qiqirn Sash +1',
             'Qiqirn Sash', 'Mohbwa Sash +1', 'Spectral Belt', 'Hojutsu Belt', 'Mohbwa Sash',
             'Adept\'s Rope', 'Oracle\'s Belt', 'Magic Belt +1', 'Friar\'s Rope', 'Force Belt',
             'Magic Belt', 'Penitent\'s Rope', 'Survival Belt' },
        Legs  = { 'Yigit Seraweels', 'Oracle\'s Braconi', 'Frog Trousers',
             'Aristocrat\'s Slacks', 'Noble\'s Slacks', 'Combat Caster\'s Slacks +2',
             'Healer\'s Pantaloons', 'Combat Caster\'s Slacks +1', 'Magna F Chausses',
             'Magna M Chausses', 'Magi Slops', 'Silken Slops', 'Seer\'s Slacks +1',
             'Seer\'s Slacks', 'Sturdy Slacks', 'Federation Slops', 'Mage\'s Slops',
             'Ea\'s Brais', 'Anu\'s Brais', 'Zenith Slacks', 'Silk Slacks' },
        Feet  = { 'Oracle\'s Pigaches', 'Ataractic Solea', 'Healer\'s Duckbills +1',
             'Healer\'s Duckbills', 'Magi Pigaches', 'Inferno Sabots +1', 'Silken Pigaches',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Inferno Sabots',
             'Kingdom Clogs', 'Enlil\'s Crackows', 'Anu\'s Gaiters', 'Yigit Crackows',
             'Creek F Clomps', 'Creek M Clomps', 'Wool Socks', 'Ebony Sabots', 'Garrison Boots',
             'Power Sandals' },
    },
    -- Fast cast, worn during the precast phase of every spell.
    ['Precast_Priority'] = {
        Ear1  = { 'Loquacious Earring' },
        Ear2  = { 'Loquacious Earring' },
        Body  = { 'Marduk\'s Jubbah' },
        Feet  = { 'Rostrum Pumps' },
    },
    -- Cure potency, healing magic skill and MND.
    ['Cure_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Marduk\'s Tiara', 'Healer\'s Cap +1',
             'Aristocrat\'s Crown', 'Noble\'s Crown', 'Opo-opo Crown', 'Healer\'s Cap',
             'Magi Hat', 'Silk Hat +1', 'Rain Hat', 'Sinister Mask', 'Enlil\'s Tiara',
             'Circe\'s Hat', 'Ea\'s Tiara', 'Baron\'s Chapeau', 'Garrison Sallet',
             'Traveler\'s Hat', 'Eldritch Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Healing Torque', 'Purgatory Collar', 'Enlightened Chain', 'Ajari Necklace',
             'Stoneskin Torque', 'Torque', 'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1',
             'Holy Phial', 'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Delta Earring', 'Static Earring', 'Magnetic Earring', 'Celestial Earring',
             'Communion Earring', 'Communion Earring +1', 'Ryakho\'s Earring', 'Eris\' Earring',
             'Eris\' Earring +1', 'Harvest Earring', 'Nemesis Earring', 'Geist Earring',
             'Healing Earring' },
        Ear2  = { 'Delta Earring', 'Static Earring', 'Magnetic Earring', 'Celestial Earring',
             'Communion Earring', 'Communion Earring +1', 'Ryakho\'s Earring', 'Eris\' Earring',
             'Eris\' Earring +1', 'Harvest Earring', 'Nemesis Earring', 'Geist Earring',
             'Healing Earring' },
        Body  = { 'Nashira Manteel', 'Errant Houppelande', 'Mahatma Houppelande',
             'Aristocrat\'s Coat', 'Noble\'s Tunic', 'Black Cotehardie', 'Flora Cotehardie',
             'Healing Justaucorps', 'Combat Caster\'s Cloak +1', 'Combat Caster\'s Cloak +2',
             'Combat Caster\'s Cloak', 'Enlil\'s Gambison', 'Bishop\'s Robe',
             'Bishop\'s Robe +1', 'Ea\'s Doublet', 'Baron\'s Saio', 'Priest\'s Robe',
             'Anu\'s Doublet' },
        Hands = { 'Marduk\'s Dastanas', 'Healer\'s Mitts +1', 'Blessed Mitts',
             'Master Caster\'s Bracelets', 'Dune Bracers', 'Healer\'s Mitts', 'Magi Cuffs',
             'Silk Cuffs +1', 'Ivory Mitts', 'Concealing Cuffs', 'Enlil\'s Kolluks',
             'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Mycophile Cuffs', 'Anu\'s Gages',
             'Zealot\'s Mitts' },
        Ring1 = { 'Virology Ring', 'Pi Ring', 'Aqua Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Mermaid\'s Ring', 'Vilma\'s Ring', 'Malflood Ring',
             'Solace Ring', 'Tamas Ring', 'Carect Ring', 'Lapis Lazuli Ring',
             'Tranquility Ring', 'Saintly Ring' },
        Ring2 = { 'Virology Ring', 'Pi Ring', 'Aqua Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Mermaid\'s Ring', 'Vilma\'s Ring', 'Malflood Ring',
             'Solace Ring', 'Tamas Ring', 'Carect Ring', 'Lapis Lazuli Ring',
             'Tranquility Ring', 'Saintly Ring' },
        Back  = { 'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Peace Cape',
             'Miraculous Cape', 'Sapient Cape', 'Royal Army Mantle', 'Amity Cape',
             'Esoteric Mantle', 'Red Cape', 'Red Cape +1', 'White Cape', 'White Cape +1',
             'Talisman Cape', 'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt',
             'Deductive Brocade Obi', 'Penitent\'s Rope', 'Twinthread Obi', 'Twinthread Obi +1',
             'Forest Belt', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deductive Gold Obi', 'Mercenary Captain\'s Belt', 'Friar\'s Rope', 'Talisman Obi' },
        Legs  = { 'Marduk\'s Shalwar', 'Cleric\'s Pantaloons', 'Errant Slops', 'Druid\'s Slops',
             'Tactician Magician\'s Slops +1', 'Tactician Magician\'s Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth' },
        Feet  = { 'Marduk\'s Crackows', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Crow Gaiters', 'Raven Gaiters',
             'Enlil\'s Crackows', 'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots',
             'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Enhancing magic skill.
    ['Enhancing_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Marduk\'s Tiara', 'Healer\'s Cap +1',
             'Aristocrat\'s Crown', 'Noble\'s Crown', 'Opo-opo Crown', 'Healer\'s Cap',
             'Magi Hat', 'Silk Hat +1', 'Namru\'s Tiara', 'Rain Hat', 'Sinister Mask',
             'Enlil\'s Tiara', 'Circe\'s Hat', 'Ea\'s Tiara', 'Garrison Sallet',
             'Traveler\'s Hat', 'Eldritch Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Enhancing Torque', 'Enlightened Chain', 'Ajari Necklace', 'Stoneskin Torque',
             'Torque', 'Promise Badge', 'Yinyang Lorgnette', 'Mohbwa Scarf', 'Holy Phial',
             'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Communion Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augmenting Earring' },
        Ear2  = { 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Communion Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augmenting Earring' },
        Body  = { 'Marduk\'s Jubbah', 'Reverend Mail', 'Errant Houppelande', 'Black Cotehardie',
             'Flora Cotehardie', 'Healing Justaucorps', 'Combat Caster\'s Cloak +1',
             'Combat Caster\'s Cloak +2', 'Combat Caster\'s Cloak', 'Bishop\'s Robe',
             'Bishop\'s Robe +1', 'Enlil\'s Gambison', 'Ea\'s Doublet', 'Baron\'s Saio',
             'Priest\'s Robe', 'Anu\'s Doublet' },
        Hands = { 'Marduk\'s Dastanas', 'Healer\'s Mitts +1', 'Yigit Gages',
             'Master Caster\'s Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Silk Cuffs +1', 'Ivory Mitts', 'Enlil\'s Kolluks', 'Seer\'s Mitts',
             'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Anu\'s Gages', 'Zealot\'s Mitts' },
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
        Legs  = { 'Zenith Slacks', 'Zenith Slacks +1', 'Errant Slops',
             'Tactician Magician\'s Slops +1', 'Tactician Magician\'s Slops +2',
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
             'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon', 'Tactician Magician\'s Hat +1',
             'Storm Zucchetto', 'Rain Hat', 'Sinister Mask', 'Enlil\'s Tiara',
             'Eldritch Horn Hairpin', 'Seer\'s Crown', 'Seer\'s Crown +1', 'Ea\'s Tiara',
             'Garrison Sallet', 'Traveler\'s Hat', 'Eldritch Bone Hairpin' },
        Neck  = { 'Prudence Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Lieutenant\'s Gorget', 'Enfeebling Torque', 'Spider Torque', 'Stoneskin Torque',
             'Torque', 'Torque +1', 'Yinyang Lorgnette', 'Mohbwa Scarf', 'Mohbwa Scarf +1',
             'Holy Phial', 'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Abyssal Earring', 'Celestial Earring', 'Communion Earring',
             'Diabolos\'s Earring', 'Ryakho\'s Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Harvest Earring', 'Boroka Earring', 'Heims Earring',
             'Geist Earring', 'Enfeebling Earring', 'Morion Earring', 'Cunning Earring' },
        Ear2  = { 'Static Earring', 'Abyssal Earring', 'Celestial Earring', 'Communion Earring',
             'Diabolos\'s Earring', 'Ryakho\'s Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Harvest Earring', 'Boroka Earring', 'Heims Earring',
             'Geist Earring', 'Enfeebling Earring', 'Morion Earring', 'Cunning Earring' },
        Body  = { 'Nashira Manteel', 'Shadow Coat', 'Valkyrie\'s Coat', 'Black Cotehardie',
             'Healer\'s Bliaut', 'Shaman\'s Cloak', 'Combat Caster\'s Cloak +1',
             'Combat Caster\'s Cloak +2', 'Combat Caster\'s Cloak', 'Bishop\'s Robe',
             'Bishop\'s Robe +1', 'Enlil\'s Gambison', 'Ea\'s Doublet', 'Baron\'s Saio',
             'Black Tunic', 'Priest\'s Robe', 'Anu\'s Doublet', 'Kingdom Tunic' },
        Hands = { 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Goliard Cuffs',
             'Master Caster\'s Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Silk Cuffs +1', 'Ivory Mitts', 'Engineer\'s Gloves', 'Sennight Bangles',
             'Enlil\'s Kolluks', 'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Devotee\'s Mitts',
             'Anu\'s Gages', 'Zealot\'s Mitts' },
        Ring1 = { 'Dark Ring', 'Flame Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 9', 'Kshama Ring No. 5', 'Vilma\'s Ring', 'Malflood Ring',
             'Solace Ring', 'Tamas Ring', 'Carect Ring', 'Lapis Lazuli Ring',
             'Tranquility Ring', 'Saintly Ring' },
        Ring2 = { 'Dark Ring', 'Flame Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 9', 'Kshama Ring No. 5', 'Vilma\'s Ring', 'Malflood Ring',
             'Solace Ring', 'Tamas Ring', 'Carect Ring', 'Lapis Lazuli Ring',
             'Tranquility Ring', 'Saintly Ring' },
        Back  = { 'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Sapient Cape',
             'Miraculous Cape', 'Royal Army Mantle', 'Federal Army Mantle', 'Gramary Cape',
             'Red Cape', 'Red Cape +1', 'White Cape', 'White Cape +1', 'Black Cape',
             'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt', 'Bitter Corset',
             'Penitent\'s Rope', 'Twinthread Obi', 'Jungle Stone', 'Ocean Stone',
             'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deductive Gold Obi', 'Mercenary Captain\'s Belt', 'Shaman\'s Belt',
             'Friar\'s Rope' },
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews',
             'Tactician Magician\'s Slops +1', 'Tactician Magician\'s Slops +2',
             'White Slacks +1', 'Magic Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth', 'Seer\'s Slacks', 'Seer\'s Slacks +1', 'Mage\'s Slacks' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Healer\'s Duckbills',
             'Tactician Magician\'s Pigaches +1', 'Tactician Magician\'s Pigaches +2',
             'Inferno Sabots', 'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps',
             'Enlil\'s Crackows', 'Custom F Boots', 'Custom M Boots', 'Seer\'s Pumps',
             'Garrison Boots' },
    },
    -- Divine magic -- Banish and Holy.
    ['Divine_Priority'] = {
        Head  = { 'Marduk\'s Tiara', 'Elite Beret', 'Elite Beret +1', 'Aristocrat\'s Crown',
             'Noble\'s Crown', 'Opo-opo Crown', 'Healer\'s Cap', 'Magi Hat', 'Storm Zucchetto',
             'Rain Hat', 'Sinister Mask', 'Bastokan Circlet', 'Republic Circlet', 'Ea\'s Tiara',
             'Garrison Sallet', 'Traveler\'s Hat', 'Eldritch Bone Hairpin' },
        Neck  = { 'Jeweled Collar +1', 'Morgana\'s Choker', 'Divine Torque',
             'Lieutenant\'s Gorget', 'Enlightened Chain', 'Ajari Necklace', 'Stoneskin Torque',
             'Torque', 'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Holy Phial',
             'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Novio Earring', 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Diabolos\'s Earring', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Divine Earring' },
        Ear2  = { 'Novio Earring', 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Diabolos\'s Earring', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Divine Earring' },
        Body  = { 'Nashira Manteel', 'Shadow Coat', 'Oracle\'s Robe', 'Black Cotehardie',
             'Flora Cotehardie', 'Healing Justaucorps', 'Combat Caster\'s Cloak +1',
             'Combat Caster\'s Cloak +2', 'Combat Caster\'s Cloak', 'Bishop\'s Robe',
             'Bishop\'s Robe +1', 'Enlil\'s Gambison', 'Ea\'s Doublet', 'Baron\'s Saio',
             'Priest\'s Robe', 'Anu\'s Doublet' },
        Hands = { 'Goliard Cuffs', 'Nashira Gages', 'Shadow Cuffs',
             'Master Caster\'s Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Silk Cuffs +1', 'Ivory Mitts', 'Sennight Bangles', 'Enlil\'s Kolluks',
             'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Anu\'s Gages',
             'Zealot\'s Mitts' },
        Ring1 = { 'Pi Ring', 'Aqua Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Serenity Ring', 'Balrahn\'s Ring',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring', 'Tamas Ring',
             'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring', 'Saintly Ring' },
        Ring2 = { 'Pi Ring', 'Aqua Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Aquamarine Ring', 'Serenity Ring', 'Balrahn\'s Ring',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring', 'Tamas Ring',
             'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring', 'Saintly Ring' },
        Back  = { 'Altruistic Cape', 'Solitaire Cape', 'Prism Cape', 'Miraculous Cape',
             'Sapient Cape', 'Royal Army Mantle', 'Gramary Cape', 'Red Cape', 'Red Cape +1',
             'White Cape', 'White Cape +1', 'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt',
             'Deductive Brocade Obi', 'Bitter Corset', 'Twinthread Obi', 'Twinthread Obi +1',
             'Forest Belt', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deductive Gold Obi', 'Mercenary Captain\'s Belt', 'Friar\'s Rope' },
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews',
             'Healer\'s Pantaloons', 'Tactician Magician\'s Slops +1',
             'Tactician Magician\'s Slops +2', 'Magic Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'Templar Sabatons', 'Enlil\'s Crackows', 'Mannequin Pumps',
             'Custom F Boots', 'Custom M Boots', 'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Melee, worn while engaged.
    ['TP_Priority'] = {
        Head  = { 'Nashira Turban', 'Walahra Turban', 'Pineal Hat', 'Green Beret',
             'Green Beret +1', 'Corsair\'s Tricorne', 'Super Ribbon', 'Storm Zucchetto',
             'Jester\'s Headband', 'Voyager Sallet', 'Spelunker\'s Hat', 'Federation Headgear',
             'Dandy Spectacles', 'Fancy Spectacles', 'Emperor Hairpin', 'Empress Hairpin' },
        Neck  = { 'Diabolos\'s Torque', 'Chanoix\'s Gorget', 'Wivre Gorget', 'Sniper\'s Collar',
             'Grand Temple Knight\'s Collar', 'Chivalrous Chain', 'Spectacles',
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
             'Corsair\'s Frac', 'Iron Musketeer\'s Gambison +1',
             'Iron Musketeer\'s Gambison +2', 'Iron Musketeer\'s Gambison',
             'Federation Doublet', 'Windurstian Doublet', 'Magna Bodice', 'Garrison Tunica' },
        Hands = { 'Nashira Gages', 'Goliard Cuffs', 'Pantin Dastanas +1', 'Tabin Bracers',
             'Tabin Bracers +1', 'Battle Bracers', 'Tactician Magician\'s Cuffs +1',
             'Tactician Magician\'s Cuffs +2', 'Aiming Bracelets', 'Combat Caster\'s Mitts +1',
             'Combat Caster\'s Mitts +2', 'Combat Caster\'s Mitts', 'Sennight Bangles',
             'Federation Gloves', 'Windurstian Gloves', 'Custom F Gloves', 'Custom M Gloves',
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
        Back  = { 'Gunner\'s Mantle', 'Republican Army Mantle', 'Bellicose Mantle',
             'Gramary Cape', 'Rearguard Mantle' },
        Waist = { 'Ninurta\'s Sash', 'Buccaneer\'s Belt', 'Sprinter\'s Belt', 'Mithran Stone',
             'Bitter Corset', 'Potent Belt', 'Swift Belt', 'Ocean Belt', 'Desert Belt',
             'Life Belt', 'Tilt Belt', 'Corsette', 'Mercenary Captain\'s Belt' },
        Legs  = { 'Nashira Seraweels', 'Blessed Trousers', 'Blessed Trousers +1', 'Tabin Hose',
             'Tabin Hose +1', 'Combat Caster\'s Slacks +1', 'Combat Caster\'s Slacks +2',
             'Combat Caster\'s Slacks', 'Custom Pants', 'Custom Slacks', 'Magna F Chausses',
             'Garrison Hose' },
        Feet  = { 'Nashira Crackows', 'Goliard Clogs', 'Blessed Pumps', 'Marine F Boots',
             'Marine M Boots', 'Templar Sabatons', 'Tabin Boots', 'Tabin Boots +1',
             'Storm Gambieras', 'Mountain Gaiters', 'Federation Gaiters', 'Windurstian Gaiters',
             'Custom F Boots', 'Custom M Boots', 'Savage Gaiters' },
    },
    -- Club and shield for soloing.
    ['Weapon_Priority'] = {
        Main  = { 'Mjollnir', 'Yagrush', 'Ultima\'s Left Arm', 'Brise-os', 'Ramuh\'s Mace',
             'Reserve Captain\'s Mace', 'Senior Gold Musketeer\'s Rod', 'Seawolf Cudgel',
             'Sea Robber Cudgel', 'Darksteel Maul', 'Curse Wand', 'Sloth Wand', 'Kingdom Mace',
             'San d\'Orian Mace', 'Royal Squire\'s Mace', 'Pixie Mace', 'Bastokan Hammer',
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
