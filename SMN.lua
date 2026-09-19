local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
local staves = gFunc.LoadFile('./staves.lua');

local Settings = {
    CurrentLevel = 0,
};

-- Gear candidates pulled from the HorizonXI wiki: every piece SMN can wear,
-- scored per set and spread across the level bands so each list resolves now
-- and upgrades itself while levelling. Levels are noted after each line.
-- Almost none of this applies at low level -- the sets fill in as the job
-- climbs. Resolution is ownership-aware, so unowned entries cost nothing.
sets = {
    -- Out of combat and while an avatar is out: perpetuation cost first, then refresh and MP. The Earth staff goes on top.
    ['Idle_Priority'] = {
        Head  = { 'Smn. Horn +1', 'Summoner\'s Horn', 'Wivre Hairpin +1',
             'Wivre Hairpin', 'Curate\'s Hat', 'Electrum Hairpin', 'Mana Circlet', 'Rain Hat',
             'Magi Hat', 'Silken Hat', 'Trump Crown', 'Fed. Headgear', 'Namru\'s Tiara',
             'Win. Headgear', 'Shell Hairpin', 'Enlil\'s Tiara', 'Ea\'s Tiara',
             'Bonze\'s Circlet', 'Anu\'s Tiara', 'Yigit Turban', 'Blissful Chapeau' },
        Neck  = { 'Fenrir\'s Torque', 'Chi Necklace', 'Beak Necklace',
             'Merrow No. 17\'s Locket', 'Grandiose Chain', 'Spirit Torque', 'Holy Phial',
             'Mohbwa Scarf +1', 'Rep.Iron Medal', 'Mohbwa Scarf',
             'Rep.Bronze Medal', 'Morgana\'s Choker', 'Purgatory Collar',
             'Star Necklace', 'Pch. Collar', 'Promise Badge', 'Shield Pendant',
             'Tiger Stole', 'Hemp Gorget', 'Bird Whistle', 'Green Scarf' },
        Ear1  = { 'Celestial Earring', 'Magnetic Earring', 'Gamma Earring', 'Insomnia Earring',
             'Hades Earring +1', 'Death Earring', 'Mana Earring +1', 'Aura Earring +1',
             'Bat Earring', 'Geist Earring', 'Aura Earring', 'Energy Earring +1',
             'Valor Earring', 'Ethereal Earring', 'Refresh Earring', 'Astral Earring',
             'Intruder Earring', 'Shield Earring', 'Mecurial Earring', 'Cassie Earring' },
        Ear2  = { 'Celestial Earring', 'Magnetic Earring', 'Gamma Earring', 'Insomnia Earring',
             'Hades Earring +1', 'Death Earring', 'Mana Earring +1', 'Aura Earring +1',
             'Bat Earring', 'Geist Earring', 'Aura Earring', 'Energy Earring +1',
             'Valor Earring', 'Ethereal Earring', 'Refresh Earring', 'Astral Earring',
             'Intruder Earring', 'Shield Earring', 'Mecurial Earring', 'Cassie Earring' },
        Body  = { 'Smn. Doublet +1', 'Summoner\'s Dblt.', 'Penance Robe',
             'Austere Robe', 'Ryl.Sqr. Robe +1', 'Ryl.Sqr. Robe +2',
             'Seer\'s Tunic +1', 'Pyro Robe', 'Seer\'s Tunic', 'Marduk\'s Jubbah',
             'Kingdom Tunic', 'Magna Bodice', 'Magna Jerkin', 'San d\'Orian Tunic',
             'Mage\'s Robe', 'Silk Cloak +1', 'Minstrel\'s Coat', 'Aketon', 'Duende Cotehardie',
             'Faerie Tunic', 'Mana Tunic' },
        Hands = { 'Nashira Gages', 'Dune Bracers', 'Wood Gauntlets', 'Wood Gloves',
             'Magical Mitts', 'Magi Cuffs', 'Silken Cuffs', 'New Moon Armlets',
             'Devotee\'s Mitts', 'Zealot\'s Mitts', 'Custom F Gloves', 'Custom M Gloves',
             'Zenith Mitts', 'Yigit Gages', 'Wool Bracers', 'C.C. Mitts +1',
             'C.C. Mitts +2', 'Mage\'s Cuffs', 'Velvet Cuffs', 'Scentless Armlets',
             'Angler\'s Gloves' },
        Ring1 = { 'Evoker\'s Ring', 'Dark Ring', 'Electrum Ring', 'Carect Ring', 'Water Ring',
             'Horizon Ring', 'Fasting Ring', 'Mystic Ring +1', 'Aura Ring +1', 'Aura Ring',
             'Energy Ring +1', 'Black Ring', 'Light Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Peace Ring', 'Gold Ring', 'Gold Ring +1', 'Mythril Ring', 'Mythril Ring +1',
             'Poisona Ring' },
        Ring2 = { 'Evoker\'s Ring', 'Dark Ring', 'Electrum Ring', 'Carect Ring', 'Water Ring',
             'Horizon Ring', 'Fasting Ring', 'Mystic Ring +1', 'Aura Ring +1', 'Aura Ring',
             'Energy Ring +1', 'Black Ring', 'Light Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Peace Ring', 'Gold Ring', 'Gold Ring +1', 'Mythril Ring', 'Mythril Ring +1',
             'Poisona Ring' },
        Back  = { 'Intensifying Cape', 'Storm Cape', 'Blue Cape +1', 'Blue Cape',
             'Aurora Mantle +1', 'Talisman Cape', 'Prism Cape', 'Aurora Mantle', 'Rainbow Cape',
             'Esoteric Mantle', 'Lucent Cape', 'Fed. Army Mantle', 'Tundra Mantle',
             'Aries Mantle', 'Black Cape', 'Black Cape +1', 'Variable Cape', 'Cotton Cape',
             'Cotton Cape +1' },
        Waist = { 'Lambda Sash', 'Desert Stone', 'Forest Stone', 'Jungle Stone',
             'Immortal\'s Sash', 'Powerful Rope', 'Al Zahbi Sash', 'Lieutenant\'s Sash',
             'Spectral Belt', 'Hojutsu Belt', 'Mohbwa Sash', 'Adept\'s Rope', 'Oracle\'s Belt',
             'Shaman\'s Belt', 'Magic Belt +1', 'Friar\'s Rope', 'Force Belt', 'Magic Belt',
             'Penitent\'s Rope', 'Mantra Belt', 'Tathlum Belt' },
        Legs  = { 'Yigit Seraweels', 'Frog Trousers', 'C.C. Slacks +2',
             'C.C. Slacks +1', 'Magna F Chausses', 'Magna M Chausses', 'Magi Slops',
             'Silken Slops', 'Seer\'s Slacks +1', 'Seer\'s Slacks', 'Sturdy Slacks',
             'Federation Slops', 'Mage\'s Slops', 'Ea\'s Brais', 'Anu\'s Brais',
             'Aries Subligar', 'Zenith Slacks', 'Zenith Slacks +1', 'Druid\'s Slops',
             'Silk Slacks', 'Silk Slacks +1' },
        Feet  = { 'Evk. Pigaches +1', 'Rostrum Pumps', 'Ataractic Solea',
             'Evoker\'s Pigaches', 'Magi Pigaches', 'Inferno Sabots +1', 'Silken Pigaches',
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
    -- Worn while calling an avatar -- summoning magic skill.
    ['Summon_Priority'] = {
        Head  = { 'Marduk\'s Tiara', 'Evk. Horn +1', 'Elite Beret', 'Curate\'s Hat',
             'Wivre Hairpin', 'Evoker\'s Horn', 'Magi Hat', 'Austere Hat', 'Penance Hat',
             'Namru\'s Tiara', 'Rain Hat', 'Electrum Hairpin', 'Enlil\'s Tiara',
             'Fed. Headgear', 'Win. Headgear', 'Ea\'s Tiara', 'Blissful Chapeau',
             'Silver Hairpin', 'Bonze\'s Circlet', 'Anu\'s Tiara', 'Shell Hairpin' },
        Neck  = { 'Chi Necklace', 'Fenrir\'s Torque', 'Morgana\'s Choker', 'Smn. Torque',
             'Merrow No. 17\'s Locket', 'Purgatory Collar', 'Star Necklace',
             'Rep.Mythril Medal', 'Pch. Collar', 'Mohbwa Scarf',
             'Mohbwa Scarf +1', 'Spirit Torque', 'Shield Pendant', 'Rep.Iron Medal',
             'Holy Phial', 'Rep.Bronze Medal' },
        Ear1  = { 'Gamma Earring', 'Loquac. Earring', 'Ethereal Earring',
             'Celestial Earring', 'Death Earring', 'Hades Earring', 'Bat Earring',
             'Desamilion Earring', 'Gayanj\'s Earring', 'Boroka Earring', 'Mana Earring',
             'Mana Earring +1', 'Geist Earring', 'Smn. Earring', 'Aura Earring',
             'Shield Earring', 'Valor Earring', 'Energy Earring', 'Energy Earring +1' },
        Ear2  = { 'Gamma Earring', 'Loquac. Earring', 'Ethereal Earring',
             'Celestial Earring', 'Death Earring', 'Hades Earring', 'Bat Earring',
             'Desamilion Earring', 'Gayanj\'s Earring', 'Boroka Earring', 'Mana Earring',
             'Mana Earring +1', 'Geist Earring', 'Smn. Earring', 'Aura Earring',
             'Shield Earring', 'Valor Earring', 'Energy Earring', 'Energy Earring +1' },
        Body  = { 'Smn. Doublet +1', 'Goliard Saio', 'Summoner\'s Dblt.',
             'Black Cotehardie', 'Austere Robe', 'Penance Robe', 'Pyro Robe',
             'Ryl.Sqr. Robe +1', 'Ryl.Sqr. Robe +2', 'Mage\'s Robe',
             'Bishop\'s Robe', 'Bishop\'s Robe +1', 'Seer\'s Tunic', 'Seer\'s Tunic +1',
             'Kingdom Tunic', 'San d\'Orian Tunic', 'Mana Tunic' },
        Hands = { 'Smn. Bracers +1', 'Carbuncle\'s Cuffs', 'Summoner\'s Brcr.',
             'Dune Bracers', 'Marine F Gloves', 'Marine M Gloves', 'Magical Mitts',
             'Austere Cuffs', 'Penance Cuffs', 'New Moon Armlets', 'Custom F Gloves',
             'Custom M Gloves', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Dark Ring', 'Light Ring', 'Evoker\'s Ring', 'Serene Ring', 'Ice Ring',
             'Orichalcum Ring', 'Peace Ring', 'Zoredonite Ring', 'Mystic Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 6', 'Kshama Ring No. 9', 'Aura Ring',
             'Aura Ring +1', 'Black Ring', 'Carect Ring', 'Mythril Ring', 'Mythril Ring +1',
             'Fasting Ring', 'Energy Ring', 'Energy Ring +1' },
        Ring2 = { 'Dark Ring', 'Light Ring', 'Evoker\'s Ring', 'Serene Ring', 'Ice Ring',
             'Orichalcum Ring', 'Peace Ring', 'Zoredonite Ring', 'Mystic Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 6', 'Kshama Ring No. 9', 'Aura Ring',
             'Aura Ring +1', 'Black Ring', 'Carect Ring', 'Mythril Ring', 'Mythril Ring +1',
             'Fasting Ring', 'Energy Ring', 'Energy Ring +1' },
        Back  = { 'Erato\'s Cape', 'Astute Cape', 'Altruistic Cape', 'Birdman Cape',
             'Blue Cape', 'Blue Cape +1', 'Fed. Army Mantle', 'Esoteric Mantle',
             'Storm Cape', 'Aurora Mantle', 'Aurora Mantle +1', 'Lucent Cape', 'Tundra Mantle',
             'Variable Cape', 'Talisman Cape' },
        Waist = { 'Lambda Sash', 'Immortal\'s Sash', 'Al Zahbi Sash', 'Lieutenant\'s Sash',
             'Spectral Belt', 'Desert Stone', 'Forest Stone', 'Jungle Stone', 'Powerful Rope',
             'Adept\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Hojutsu Belt', 'Shaman\'s Belt',
             'Force Belt', 'Mohbwa Sash', 'Magic Belt', 'Magic Belt +1', 'Friar\'s Rope' },
        Legs  = { 'Marduk\'s Shalwar', 'Goliard Trews', 'Oracle\'s Braconi', 'Magi Slops',
             'Austere Slops', 'Penance Slops', 'C.C. Slacks +1',
             'C.C. Slacks +2', 'Frog Trousers', 'Mage\'s Slops',
             'Enlil\'s Brayettes', 'Custom Pants', 'Seer\'s Slacks', 'Seer\'s Slacks +1',
             'Ea\'s Brais', 'Anu\'s Brais', 'Federation Slops', 'Windurstian Slops' },
        Feet  = { 'Marduk\'s Crackows', 'Nashira Crackows', 'Evk. Pigaches +1',
             'Ataractic Solea', 'Creek F Clomps', 'Creek M Clomps', 'Evoker\'s Pigaches',
             'Austere Sabots', 'Penance Sabots', 'Inferno Sabots', 'Inferno Sabots +1',
             'Enlil\'s Crackows', 'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots',
             'Elder\'s Sandals', 'Anu\'s Gaiters' },
    },
    -- Blood pacts -- summoning magic skill drives their potency.
    ['BloodPact_Priority'] = {
        Head  = { 'Marduk\'s Tiara', 'Evk. Horn +1', 'Elite Beret', 'Opo-opo Crown',
             'Mushroom Helm', 'Evoker\'s Horn', 'Super Ribbon', 'Austere Hat', 'Penance Hat',
             'Sinister Mask', 'Bastokan Circlet', 'Republic Circlet', 'Seer\'s Crown',
             'Seer\'s Crown +1', 'Baron\'s Chapeau', 'Erd. Headband', 'Sage\'s Circlet',
             'Eld. Bone Hairpin' },
        Neck  = { 'Prudence Torque', 'Jeweled Collar +1', 'Smn. Torque',
             'Enlightened Chain', 'Stoneskin Torque', 'Torque', 'Torque +1', 'Mohbwa Scarf',
             'Mohbwa Scarf +1', 'Black Neckerchief' },
        Ear1  = { 'Novio Earring', 'Abyssal Earring', 'Omn. Earring',
             'Omn. Earring +1', 'Phantom Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Boroka Earring', 'Heims Earring', 'Smn. Earring',
             'Morion Earring', 'Morion Earring +1', 'Cunning Earring' },
        Ear2  = { 'Novio Earring', 'Abyssal Earring', 'Omn. Earring',
             'Omn. Earring +1', 'Phantom Earring', 'Desamilion Earring',
             'Gayanj\'s Earring', 'Boroka Earring', 'Heims Earring', 'Smn. Earring',
             'Morion Earring', 'Morion Earring +1', 'Cunning Earring' },
        Body  = { 'Smn. Doublet +1', 'Evk. Doublet +1', 'Summoner\'s Dblt.',
             'Evoker\'s Doublet', 'Austere Robe', 'Penance Robe', 'C.C. Cloak +1',
             'C.C. Cloak +2', 'Ryl.Sqr. Robe +1', 'Mage\'s Robe',
             'Custom Tunic', 'Custom Vest', 'Baron\'s Saio', 'Black Tunic', 'Mage\'s Tunic',
             'Kingdom Tunic', 'San d\'Orian Tunic', 'Ryl.Ftm. Tunic' },
        Hands = { 'Smn. Bracers +1', 'Carbuncle\'s Cuffs', 'Summoner\'s Brcr.',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Austere Cuffs',
             'Penance Cuffs', 'Mage\'s Mitts', 'Engineer\'s Gloves', 'Seer\'s Mitts',
             'Seer\'s Mitts +1', 'Devotee\'s Mitts', 'Zealot\'s Mitts' },
        Ring1 = { 'Epsilon Ring', 'Breeze Ring', 'Evoker\'s Ring', 'Serene Ring', 'Vivian Ring',
             'Ptr.Prt. Ring', 'Zoredonite Ring', 'Genius Ring', 'Genius Ring +1',
             'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring', 'Malfrost Ring',
             'Wisdom Ring', 'Clear Ring', 'Knowledge Ring', 'Kldg. Ring +1' },
        Ring2 = { 'Epsilon Ring', 'Breeze Ring', 'Evoker\'s Ring', 'Serene Ring', 'Vivian Ring',
             'Ptr.Prt. Ring', 'Zoredonite Ring', 'Genius Ring', 'Genius Ring +1',
             'Kshama Ring No. 5', 'Vilma\'s Ring', 'Goshenite Ring', 'Malfrost Ring',
             'Wisdom Ring', 'Clear Ring', 'Knowledge Ring', 'Kldg. Ring +1' },
        Back  = { 'Astute Cape', 'Solitaire Cape', 'Prism Cape', 'Sapient Cape',
             'Fed. Army Mantle', 'Red Cape', 'Red Cape +1', 'Black Cape', 'Black Cape +1' },
        Waist = { 'Ksi Sash', 'Immortal\'s Sash', 'Al Zahbi Sash', 'Arachne Obi',
             'Arachne Obi +1', 'Ice Belt', 'Desert Belt', 'Desert Stone', 'Forest Stone',
             'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Sagac. Gold Obi',
             'Mrc.Cpt. Belt', 'Shaman\'s Belt' },
        Legs  = { 'Marduk\'s Shalwar', 'Smn. Spats +1', 'Oracle\'s Braconi',
             'Penance Slops', 'Austere Slops', 'Magic Slacks', 'Elder\'s Braguette',
             'Seer\'s Slacks', 'Seer\'s Slacks +1', 'Mage\'s Slacks' },
        Feet  = { 'Marduk\'s Crackows', 'Nashira Crackows', 'Smn. Pigaches +1',
             'Creek F Clomps', 'Creek M Clomps', 'Marine F Boots',
             'T.M. Pigaches +1', 'Austere Sabots', 'Penance Sabots',
             'Inferno Sabots', 'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps',
             'Custom F Boots', 'Custom M Boots', 'Elder\'s Sandals', 'Garrison Boots' },
    },
    -- Cures from a healing subjob.
    ['Cure_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Marduk\'s Tiara', 'Evk. Horn +1', 'Opo-opo Crown',
             'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1', 'Super Ribbon',
             'Rain Hat', 'Sinister Mask', 'Enlil\'s Tiara', 'Circe\'s Hat', 'Ea\'s Tiara',
             'Garrison Sallet', 'Traveler\'s Hat', 'Eld. Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Healing Torque', 'Enlightened Chain', 'Ajari Necklace', 'Stoneskin Torque',
             'Torque', 'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Holy Phial',
             'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Cmn. Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Healing Earring' },
        Ear2  = { 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Cmn. Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Healing Earring' },
        Body  = { 'Nashira Manteel', 'Marduk\'s Jubbah', 'Errant Hpl.',
             'Black Cotehardie', 'Flora Cotehardie', 'Evoker\'s Doublet',
             'C.C. Cloak +1', 'C.C. Cloak +2', 'Cmb.Cst. Cloak',
             'Bishop\'s Robe', 'Bishop\'s Robe +1', 'Enlil\'s Gambison', 'Ea\'s Doublet',
             'Baron\'s Saio', 'Priest\'s Robe', 'Anu\'s Doublet' },
        Hands = { 'Marduk\'s Dastanas', 'Yigit Gages', 'Mst.Cst. Bracelets',
             'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs', 'Silk Cuffs +1', 'Ivory Mitts',
             'Enlil\'s Kolluks', 'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Devotee\'s Mitts',
             'Anu\'s Gages', 'Zealot\'s Mitts' },
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
        Back  = { 'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Miraculous Cape',
             'Sapient Cape', 'Ryl. Army Mantle', 'Red Cape', 'Red Cape +1', 'White Cape',
             'White Cape +1', 'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt',
             'Deduct. Broc. Obi', 'Penitent\'s Rope', 'Twinthread Obi', 'Twinthread Obi +1',
             'Forest Belt', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deduct. Gold Obi', 'Mrc.Cpt. Belt', 'Friar\'s Rope' },
        Legs  = { 'Marduk\'s Shalwar', 'Zenith Slacks', 'Zenith Slacks +1', 'Druid\'s Slops',
             'T.M. Slops +1', 'T.M. Slops +2',
             'Austere Slops', 'Magic Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth' },
        Feet  = { 'Goliard Clogs', 'Marduk\'s Crackows', 'Rostrum Pumps', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Enlil\'s Crackows', 'Mannequin Pumps',
             'Custom F Boots', 'Custom M Boots', 'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Enhancing magic skill from a subjob.
    ['Enhancing_Priority'] = {
        Head  = { 'Goliard Chapeau', 'Marduk\'s Tiara', 'Evk. Horn +1', 'Opo-opo Crown',
             'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1', 'Super Ribbon',
             'Namru\'s Tiara', 'Rain Hat', 'Sinister Mask', 'Enlil\'s Tiara', 'Circe\'s Hat',
             'Ea\'s Tiara', 'Garrison Sallet', 'Traveler\'s Hat', 'Eld. Bone Hairpin' },
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
        Body  = { 'Marduk\'s Jubbah', 'Errant Hpl.', 'Mahatma Hpl.',
             'Black Cotehardie', 'Flora Cotehardie', 'Evoker\'s Doublet',
             'C.C. Cloak +1', 'C.C. Cloak +2', 'Cmb.Cst. Cloak',
             'Bishop\'s Robe', 'Bishop\'s Robe +1', 'Enlil\'s Gambison', 'Ea\'s Doublet',
             'Baron\'s Saio', 'Priest\'s Robe', 'Anu\'s Doublet' },
        Hands = { 'Marduk\'s Dastanas', 'Yigit Gages', 'Mst.Cst. Bracelets',
             'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs', 'Silk Cuffs +1', 'Ivory Mitts',
             'Enlil\'s Kolluks', 'Seer\'s Mitts', 'Seer\'s Mitts +1', 'Devotee\'s Mitts',
             'Anu\'s Gages', 'Zealot\'s Mitts' },
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
             'Austere Slops', 'Magic Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth' },
        Feet  = { 'Goliard Clogs', 'Marduk\'s Crackows', 'Rostrum Pumps', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Enlil\'s Crackows', 'Mannequin Pumps',
             'Custom F Boots', 'Custom M Boots', 'Seer\'s Pumps', 'Garrison Boots' },
    },
    -- Melee, worn while engaged.
    ['TP_Priority'] = {
        Head  = { 'Nashira Turban', 'Pineal Hat', 'Breeder Mask', 'Green Beret',
             'Green Beret +1', 'Corsair\'s Tricorne', 'Super Ribbon', 'Storm Zucchetto',
             'Voyager Sallet', 'Buffalo Helm', 'Spelunker\'s Hat', 'Fed. Headgear',
             'Dandy Spectacles', 'Fancy Spectacles', 'Emperor Hairpin', 'Empress Hairpin',
             'Shepherd\'s Bonnet' },
        Neck  = { 'Diabolos\'s Torque', 'Chanoix\'s Gorget', 'Wivre Gorget', 'Sniper\'s Collar',
             'Grand T.K. Collar', 'Chivalrous Chain', 'Ashura Necklace',
             'Storm Gorget', 'Peacock Amulet', 'Peacock Charm', 'Tiger Stole', 'Fang Necklace',
             'Spike Necklace', 'Feather Collar +1' },
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
             'Shepherd\'s Doublet', 'Fed. Doublet', 'Win. Doublet',
             'Garrison Tunica' },
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
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews', 'Tabin Hose',
             'Tabin Hose +1', 'Evoker\'s Spats', 'C.C. Slacks +1',
             'C.C. Slacks +2', 'Cmb.Cst. Slacks', 'Custom Pants',
             'Custom Slacks', 'Magna F Chausses', 'Garrison Hose' },
        Feet  = { 'Nashira Crackows', 'Goliard Clogs', 'Shadow Clogs', 'Marine F Boots',
             'Marine M Boots', 'Creek F Clomps', 'Tabin Boots', 'Tabin Boots +1',
             'Storm Gambieras', 'Mountain Gaiters', 'Federation Gaiters', 'Win. Gaiters',
             'Custom F Boots', 'Custom M Boots', 'Savage Gaiters' },
    },
    -- Club, dagger and shield for soloing.
    ['Weapon_Priority'] = {
        Main  = { 'Scepter', 'Scepter +1', 'Rsv.Cpt. Mace',
             'Snr.Msk. Rod', 'Misericorde', 'Daylight Dagger',
             'Palladium Dagger', 'Garuda\'s Dagger', 'Curse Wand', 'Sloth Wand', 'Lust Dagger',
             'Triple Dagger', 'Bastokan Dagger', 'Decurion\'s Dagger', 'Piercing Dagger' },
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
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias /smn /lac fwd');

    -- Lock appearance a few seconds after loading
    common.RequestLockStyle(1);
end

profile.OnUnload = function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /smn');
end

profile.HandleCommand = function(args)
    -- Handle utility settings
    utility.SetOptions(args[1]);

    -- Rescan the bags and re-resolve every gear set
    if (args[1] == 'gear') then
        common.EvaluateGear(profile.Sets, Settings.CurrentLevel, true);
        common.EvaluateGear(staves.Sets, Settings.CurrentLevel, true);
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

	-- Blood pacts are abilities rather than spells, so they never reach
	-- HandleMidcast. Both Rage and Ward scale with summoning magic skill.
	if (action ~= nil) and (type(action.Type) == 'string')
	   and (string.match(action.Type, 'Blood Pact')) then
		gFunc.EquipSet(sets.BloodPact);
	end
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

	if (action.Skill == 'Summoning') then
		gFunc.EquipSet(sets.Summon);
	elseif (action.Skill == 'Healing Magic') then
		gFunc.EquipSet(sets.Cure);
	elseif (action.Skill == 'Enhancing Magic') then
		gFunc.EquipSet(sets.Enhancing);
	end

	-- Avatars carry an element of their own, so the staff follows the summon.
	staves.EquipStaff(action);
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;
