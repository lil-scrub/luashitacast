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
             'Trump Crown', 'Healer\'s Cap', 'Fed. Headgear', 'Namru\'s Tiara',
             'Win. Headgear', 'Shell Hairpin', 'Enlil\'s Tiara', 'Ea\'s Tiara',
             'Bonze\'s Circlet', 'Anu\'s Tiara', 'Yigit Turban', 'Blissful Chapeau' },
        Neck  = { 'Fenrir\'s Torque', 'Chi Necklace', 'Beak Necklace',
             'Merrow No. 17\'s Locket', 'Grandiose Chain', 'Spirit Torque', 'Holy Phial',
             'Mohbwa Scarf +1', 'Rep.Iron Medal', 'Mohbwa Scarf',
             'Rep.Bronze Medal', 'Morgana\'s Choker', 'Purgatory Collar',
             'Star Necklace', 'Pch. Collar', 'Promise Badge', 'Shield Pendant',
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
             'Ryl.Sqr. Robe +1', 'Ryl.Sqr. Robe +2', 'Seer\'s Tunic +1',
             'Pyro Robe', 'Seer\'s Tunic', 'Marduk\'s Jubbah', 'Kingdom Tunic', 'Magna Bodice',
             'Magna Jerkin', 'San d\'Orian Tunic', 'Mage\'s Robe', 'Dalmatica', 'Dalmatica +1',
             'Silk Cloak +1', 'Black Cotehardie', 'Flora Cotehardie', 'Faerie Tunic',
             'Mana Tunic' },
        Hands = { 'Dune Bracers', 'Wood Gauntlets', 'Wood Gloves', 'Oracle\'s Gloves',
             'Magical Mitts', 'Magi Cuffs', 'Silken Cuffs', 'New Moon Armlets',
             'Devotee\'s Mitts', 'Zealot\'s Mitts', 'Custom F Gloves', 'Custom M Gloves',
             'Zenith Mitts', 'Yigit Gages', 'Wool Bracers', 'C.C. Mitts +1',
             'C.C. Mitts +2', 'Mage\'s Cuffs', 'Velvet Cuffs', 'Scentless Armlets',
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
             'Lucent Cape', 'Fed. Army Mantle', 'Tundra Mantle', 'Invigorating Cape',
             'Maledictor\'s Shawl', 'Aries Mantle', 'Black Cape', 'Black Cape +1',
             'Variable Cape', 'Cotton Cape', 'Cotton Cape +1' },
        Waist = { 'Lambda Sash', 'Hierarch Belt', 'Desert Stone', 'Forest Stone',
             'Jungle Stone', 'Immortal\'s Sash', 'Lieutenant\'s Sash', 'Qiqirn Sash +1',
             'Qiqirn Sash', 'Mohbwa Sash +1', 'Spectral Belt', 'Hojutsu Belt', 'Mohbwa Sash',
             'Adept\'s Rope', 'Oracle\'s Belt', 'Magic Belt +1', 'Friar\'s Rope', 'Force Belt',
             'Magic Belt', 'Penitent\'s Rope', 'Survival Belt' },
        Legs  = { 'Yigit Seraweels', 'Oracle\'s Braconi', 'Frog Trousers',
             'Aristo. Slacks', 'Noble\'s Slacks', 'C.C. Slacks +2',
             'Healer\'s Pantaln.', 'C.C. Slacks +1', 'Magna F Chausses',
             'Magna M Chausses', 'Magi Slops', 'Silken Slops', 'Seer\'s Slacks +1',
             'Seer\'s Slacks', 'Sturdy Slacks', 'Federation Slops', 'Mage\'s Slops',
             'Ea\'s Brais', 'Anu\'s Brais', 'Zenith Slacks', 'Silk Slacks' },
        Feet  = { 'Oracle\'s Pigaches', 'Ataractic Solea', 'Hlr. Duckbills +1',
             'Healer\'s Duckbills', 'Magi Pigaches', 'Inferno Sabots +1', 'Silken Pigaches',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Inferno Sabots',
             'Kingdom Clogs', 'Enlil\'s Crackows', 'Anu\'s Gaiters', 'Yigit Crackows',
             'Creek F Clomps', 'Creek M Clomps', 'Wool Socks', 'Ebony Sabots', 'Garrison Boots',
             'Power Sandals' },
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
