local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
local staves = gFunc.LoadFile('./staves.lua');

local Settings = {
	CurrentLevel = 0,
	MacroBook = '2',
};

sets = {
    -- Standing gear. Regenerated from the wiki; the Earth staff is the
    -- long-standing default for damage reduction.
    ['Pulling_NIN_Priority'] = {
        Main  = { 'Earth Staff' },
        Ammo  = { 'Pebble' },
        Head  = { 'Goliard Chapeau', 'Zenith Crown', 'Yigit Turban', 'Curate\'s Hat',
             'Scorpion Helm', 'Scorpion Helm +1', 'Scorpion Mask', 'Magi Hat', 'Silken Hat',
             'Namru\'s Tiara', 'Walkure Mask', 'Electrum Hairpin', 'Kosshin',
             'Eldritch Horn Hairpin', 'Horn Hairpin', 'Trump Crown', 'Silver Hairpin',
             'Silver Hairpin +1', 'Bastokan Cap', 'Republic Cap', 'Coven Hat' },
        Neck  = { 'Rho Necklace', 'Morgana\'s Choker', 'Ritter Gorget', 'Windurstian Scarf',
             'Grandiose Chain', 'Tempered Chain', 'Star Necklace', 'Checkered Scarf',
             'Pachamac\'s Collar', 'Promise Badge', 'Jagd Gorget', 'Mohbwa Scarf',
             'Stone Gorget', 'Shield Pendant', 'Paisley Scarf', 'Holy Phial', 'Tiger Stole',
             'Bloodbead Amulet', 'Bird Whistle', 'Green Scarf', 'Buffoon\'s Collar' },
        Ear1  = { 'Gamma Earring', 'Loquacious Earring', 'Ethereal Earring',
             'Heavens Earring +1', 'Hades Earring +1', 'Angel\'s Earring',
             'Morukaka\'s Earring', 'Refresh Earring', 'Insomnia Earring', 'Allure Earring +1',
             'Astral Earring', 'Intruder Earring', 'Loyalty Earring +1', 'Aura Earring +1',
             'Esquire\'s Earring', 'Shield Earring', 'Mecurial Earring', 'Valor Earring',
             'Hope Earring +1', 'Cassie Earring' },
        Ear2  = { 'Gamma Earring', 'Loquacious Earring', 'Ethereal Earring',
             'Heavens Earring +1', 'Hades Earring +1', 'Angel\'s Earring',
             'Morukaka\'s Earring', 'Refresh Earring', 'Insomnia Earring', 'Allure Earring +1',
             'Astral Earring', 'Intruder Earring', 'Loyalty Earring +1', 'Aura Earring +1',
             'Esquire\'s Earring', 'Shield Earring', 'Mecurial Earring', 'Valor Earring',
             'Hope Earring +1', 'Cassie Earring' },
        Body  = { 'Marduk\'s Jubbah', 'Dalmatica', 'Dalmatica +1', 'Assault Jerkin',
             'Silk Cloak +1', 'Minstrel\'s Coat', 'Black Cotehardie', 'Flora Cotehardie',
             'Gaudy Harness', 'Brigandine', 'Brigandine +1', 'High Healing Harness',
             'Magna Bodice', 'Magna Jerkin', 'Custom Tunic', 'Wool Robe', 'Wool Robe +1',
             'Faerie Tunic', 'Healing Harness', 'Bastokan Harness', 'Republic Harness' },
        Hands = { 'Zenith Mitts', 'Zenith Mitts +1', 'Yigit Gages', 'Dune Bracers',
             'Wood Gauntlets', 'Wood Gloves', 'Magical Mitts', 'Magi Cuffs', 'Silken Cuffs',
             'Combat Caster\'s Mitts +1', 'Combat Caster\'s Mitts +2', 'Ogygos\'s Bracelets',
             'Cuir Gloves', 'New Moon Armlets', 'Gigas Bracelets', 'Custom F Gloves',
             'Custom M Gloves', 'Wonder Mitts', 'Bastokan Mittens', 'Republic Mittens',
             'Kingdom Gloves' },
        Ring1 = { 'Dark Ring', 'Light Ring', 'Behemoth Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Demon\'s Ring', 'Peace Ring', 'Toreador\'s Ring', 'Balrahn\'s Ring', 'Gold Ring',
             'Gold Ring +1', 'Electrum Ring', 'Aegis Ring', 'Aura Ring +1', 'Sattva Ring',
             'Carect Ring', 'Mythril Ring', 'Mythril Ring +1', 'Bomb Ring', 'Fasting Ring',
             'Poisona Ring' },
        Ring2 = { 'Dark Ring', 'Light Ring', 'Behemoth Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Demon\'s Ring', 'Peace Ring', 'Toreador\'s Ring', 'Balrahn\'s Ring', 'Gold Ring',
             'Gold Ring +1', 'Electrum Ring', 'Aegis Ring', 'Aura Ring +1', 'Sattva Ring',
             'Carect Ring', 'Mythril Ring', 'Mythril Ring +1', 'Bomb Ring', 'Fasting Ring',
             'Poisona Ring' },
        Back  = { 'Prism Cape', 'Rainbow Cape', 'Aries Mantle', 'Blue Cape', 'Blue Cape +1',
             'Empowering Mantle', 'Enhancing Mantle', 'Republican Army Mantle',
             'Bellicose Mantle', 'Aurora Mantle', 'Aurora Mantle +1', 'Lucent Cape',
             'Tundra Mantle', 'High Breath Mantle', 'Wizard\'s Mantle', 'Invisible Mantle',
             'Wolf Mantle', 'Variable Cape', 'Breath Mantle', 'Talisman Cape', 'Cotton Cape' },
        Waist = { 'Trance Belt', 'Marid Belt', 'Marid Belt +1', 'Czar\'s Belt', 'Kaiser Belt',
             'Lieutenant\'s Sash', 'Astral Rope', 'Desert Belt', 'Forest Belt', 'Powerful Rope',
             'Adept\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Survival Belt', 'Hojutsu Belt',
             'Shaman\'s Belt', 'Force Belt', 'Mohbwa Sash', 'Warrior\'s Belt',
             'Warrior\'s Belt +1', 'Augmenting Belt' },
        Legs  = { 'Zenith Slacks', 'Zenith Slacks +1', 'Yigit Seraweels', 'Darksteel Subligar',
             'Silk Slacks', 'Silk Slacks +1', 'Scorpion Subligar', 'Magi Slops', 'Silken Slops',
             'Combat Caster\'s Slacks +1', 'Combat Caster\'s Slacks +2', 'Frog Trousers',
             'Federation Brais', 'Magna F Chausses', 'Magna M Chausses', 'Wool Slops',
             'Ea\'s Brais', 'Baron\'s Slops', 'Anu\'s Brais', 'Sturdy Slacks', 'Sturdy Trousers' },
        Feet  = { 'Rostrum Pumps', 'Zenith Pumps', 'Yigit Crackows', 'Ataractic Solea',
             'Creek F Clomps', 'Creek M Clomps', 'Scorpion Leggings', 'Magi Pigaches',
             'Silken Pigaches', 'Dino Ledelsens', 'Inferno Sabots', 'Inferno Sabots +1',
             'Cuir Highboots', 'Enlil\'s Crackows', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Kingdom Clogs', 'Bastokan Leggings', 'Republic Leggings',
             'Kingdom Boots' },
    },
    ['Pulling_WHM_Priority'] = {
        Main  = { 'Earth Staff' },
        Ammo  = { 'Pebble' },
        Head  = { 'Goliard Chapeau', 'Zenith Crown', 'Yigit Turban', 'Curate\'s Hat',
             'Scorpion Helm', 'Scorpion Helm +1', 'Scorpion Mask', 'Magi Hat', 'Silken Hat',
             'Namru\'s Tiara', 'Walkure Mask', 'Electrum Hairpin', 'Kosshin',
             'Eldritch Horn Hairpin', 'Horn Hairpin', 'Trump Crown', 'Silver Hairpin',
             'Silver Hairpin +1', 'Bastokan Cap', 'Republic Cap', 'Coven Hat' },
        Neck  = { 'Rho Necklace', 'Morgana\'s Choker', 'Ritter Gorget', 'Windurstian Scarf',
             'Grandiose Chain', 'Tempered Chain', 'Star Necklace', 'Checkered Scarf',
             'Pachamac\'s Collar', 'Promise Badge', 'Jagd Gorget', 'Mohbwa Scarf',
             'Stone Gorget', 'Shield Pendant', 'Paisley Scarf', 'Holy Phial', 'Tiger Stole',
             'Bloodbead Amulet', 'Bird Whistle', 'Green Scarf', 'Buffoon\'s Collar' },
        Ear1  = { 'Gamma Earring', 'Loquacious Earring', 'Ethereal Earring',
             'Heavens Earring +1', 'Hades Earring +1', 'Angel\'s Earring',
             'Morukaka\'s Earring', 'Refresh Earring', 'Insomnia Earring', 'Allure Earring +1',
             'Astral Earring', 'Intruder Earring', 'Loyalty Earring +1', 'Aura Earring +1',
             'Esquire\'s Earring', 'Shield Earring', 'Mecurial Earring', 'Valor Earring',
             'Hope Earring +1', 'Cassie Earring' },
        Ear2  = { 'Gamma Earring', 'Loquacious Earring', 'Ethereal Earring',
             'Heavens Earring +1', 'Hades Earring +1', 'Angel\'s Earring',
             'Morukaka\'s Earring', 'Refresh Earring', 'Insomnia Earring', 'Allure Earring +1',
             'Astral Earring', 'Intruder Earring', 'Loyalty Earring +1', 'Aura Earring +1',
             'Esquire\'s Earring', 'Shield Earring', 'Mecurial Earring', 'Valor Earring',
             'Hope Earring +1', 'Cassie Earring' },
        Body  = { 'Marduk\'s Jubbah', 'Dalmatica', 'Dalmatica +1', 'Assault Jerkin',
             'Silk Cloak +1', 'Minstrel\'s Coat', 'Black Cotehardie', 'Flora Cotehardie',
             'Gaudy Harness', 'Brigandine', 'Brigandine +1', 'High Healing Harness',
             'Magna Bodice', 'Magna Jerkin', 'Custom Tunic', 'Wool Robe', 'Wool Robe +1',
             'Faerie Tunic', 'Healing Harness', 'Bastokan Harness', 'Republic Harness' },
        Hands = { 'Zenith Mitts', 'Zenith Mitts +1', 'Yigit Gages', 'Dune Bracers',
             'Wood Gauntlets', 'Wood Gloves', 'Magical Mitts', 'Magi Cuffs', 'Silken Cuffs',
             'Combat Caster\'s Mitts +1', 'Combat Caster\'s Mitts +2', 'Ogygos\'s Bracelets',
             'Cuir Gloves', 'New Moon Armlets', 'Gigas Bracelets', 'Custom F Gloves',
             'Custom M Gloves', 'Wonder Mitts', 'Bastokan Mittens', 'Republic Mittens',
             'Kingdom Gloves' },
        Ring1 = { 'Dark Ring', 'Light Ring', 'Behemoth Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Demon\'s Ring', 'Peace Ring', 'Toreador\'s Ring', 'Balrahn\'s Ring', 'Gold Ring',
             'Gold Ring +1', 'Electrum Ring', 'Aegis Ring', 'Aura Ring +1', 'Sattva Ring',
             'Carect Ring', 'Mythril Ring', 'Mythril Ring +1', 'Bomb Ring', 'Fasting Ring',
             'Poisona Ring' },
        Ring2 = { 'Dark Ring', 'Light Ring', 'Behemoth Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Demon\'s Ring', 'Peace Ring', 'Toreador\'s Ring', 'Balrahn\'s Ring', 'Gold Ring',
             'Gold Ring +1', 'Electrum Ring', 'Aegis Ring', 'Aura Ring +1', 'Sattva Ring',
             'Carect Ring', 'Mythril Ring', 'Mythril Ring +1', 'Bomb Ring', 'Fasting Ring',
             'Poisona Ring' },
        Back  = { 'Prism Cape', 'Rainbow Cape', 'Aries Mantle', 'Blue Cape', 'Blue Cape +1',
             'Empowering Mantle', 'Enhancing Mantle', 'Republican Army Mantle',
             'Bellicose Mantle', 'Aurora Mantle', 'Aurora Mantle +1', 'Lucent Cape',
             'Tundra Mantle', 'High Breath Mantle', 'Wizard\'s Mantle', 'Invisible Mantle',
             'Wolf Mantle', 'Variable Cape', 'Breath Mantle', 'Talisman Cape', 'Cotton Cape' },
        Waist = { 'Trance Belt', 'Marid Belt', 'Marid Belt +1', 'Czar\'s Belt', 'Kaiser Belt',
             'Lieutenant\'s Sash', 'Astral Rope', 'Desert Belt', 'Forest Belt', 'Powerful Rope',
             'Adept\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Survival Belt', 'Hojutsu Belt',
             'Shaman\'s Belt', 'Force Belt', 'Mohbwa Sash', 'Warrior\'s Belt',
             'Warrior\'s Belt +1', 'Augmenting Belt' },
        Legs  = { 'Zenith Slacks', 'Zenith Slacks +1', 'Yigit Seraweels', 'Darksteel Subligar',
             'Silk Slacks', 'Silk Slacks +1', 'Scorpion Subligar', 'Magi Slops', 'Silken Slops',
             'Combat Caster\'s Slacks +1', 'Combat Caster\'s Slacks +2', 'Frog Trousers',
             'Federation Brais', 'Magna F Chausses', 'Magna M Chausses', 'Wool Slops',
             'Ea\'s Brais', 'Baron\'s Slops', 'Anu\'s Brais', 'Sturdy Slacks', 'Sturdy Trousers' },
        Feet  = { 'Rostrum Pumps', 'Zenith Pumps', 'Yigit Crackows', 'Ataractic Solea',
             'Creek F Clomps', 'Creek M Clomps', 'Scorpion Leggings', 'Magi Pigaches',
             'Silken Pigaches', 'Dino Ledelsens', 'Inferno Sabots', 'Inferno Sabots +1',
             'Cuir Highboots', 'Enlil\'s Crackows', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Kingdom Clogs', 'Bastokan Leggings', 'Republic Leggings',
             'Kingdom Boots' },
    },
    -- Singing skill and CHR, worn for every song. The instrument for the
    -- song family goes on top of this.
    ['Songs_Priority'] = {
        Head  = { 'Marduk\'s Tiara', 'Demon Helm', 'Demon Helm +1', 'Lamia Garland',
             'Opo-opo Crown', 'Choral Roundlet', 'Super Ribbon', 'Jester\'s Headband',
             'Juggler\'s Headband', 'Rain Hat', 'Alluring Headband', 'Enlil\'s Tiara',
             'Trump Crown', 'Garrison Sallet', 'Noble\'s Ribbon', 'Entrancing Ribbon' },
        Neck  = { 'Temperance Torque', 'Oscar Scarf', 'String Torque', 'Wind Torque',
             'Star Necklace', 'Stoneskin Torque', 'Torque', 'Flower Necklace', 'Bird Whistle',
             'Dog Collar' },
        Ear1  = { 'Delta Earring', 'Epsilon Earring', 'Musical Earring', 'Melody Earring',
             'Melody Earring +1', 'Heims Earring', 'Singing Earring', 'String Earring',
             'Wind Earring' },
        Ear2  = { 'Delta Earring', 'Epsilon Earring', 'Musical Earring', 'Melody Earring',
             'Melody Earring +1', 'Heims Earring', 'Singing Earring', 'String Earring',
             'Wind Earring' },
        Body  = { 'Kirin\'s Osode', 'Marduk\'s Jubbah', 'Choral Justaucorps +1',
             'Minstrel\'s Coat', 'Black Cotehardie', 'Flora Cotehardie', 'Choral Justaucorps',
             'Brigandine +1', 'Argent Coat', 'Ceremonial Dress', 'Enlil\'s Gambison',
             'Federation Doublet', 'Windurstian Doublet', 'Ea\'s Doublet', 'Garrison Tunica' },
        Hands = { 'Marduk\'s Dastanas', 'Pantin Dastanas +1', 'Choral Cuffs +1',
             'Marine F Gloves', 'Marine M Gloves', 'Choral Cuffs', 'Enlil\'s Kolluks',
             'Ea\'s Dastanas' },
        Ring1 = { 'Epsilon Ring', 'Dark Ring', 'Light Ring', 'Serene Ring', 'Allure Ring',
             'Nereid Ring', 'Trumpet Ring', 'Kshama Ring No. 6', 'Vilma\'s Ring',
             'Loyalty Ring', 'Loyalty Ring +1', 'Maldust Ring', 'Hope Ring', 'Opal Ring' },
        Ring2 = { 'Epsilon Ring', 'Dark Ring', 'Light Ring', 'Serene Ring', 'Allure Ring',
             'Nereid Ring', 'Trumpet Ring', 'Kshama Ring No. 6', 'Vilma\'s Ring',
             'Loyalty Ring', 'Loyalty Ring +1', 'Maldust Ring', 'Hope Ring', 'Opal Ring' },
        Back  = { 'Erato\'s Cape', 'Astute Cape', 'Prism Cape', 'Birdman Cape',
             'Miraculous Cape', 'Jester\'s Cape', 'Jester\'s Cape +1', 'Lucent Cape' },
        Waist = { 'Lambda Sash', 'Al Zahbi Sash', 'Moon Sash', 'Czar\'s Belt', 'Kaiser Belt',
             'Koenigs Belt', 'Royal Knight\'s Belt +1', 'Royal Knight\'s Belt +2',
             'Desert Stone', 'Reverend Sash', 'Corsette', 'Corsette +1', 'Enthralling Gold Obi',
             'Mercenary Captain\'s Belt' },
        Legs  = { 'Marduk\'s Shalwar', 'Galliard Trousers', 'Zenith Slacks', 'Luna Subligar',
             'Choral Cannions', 'Ceremonial Hose', 'Platino Hose', 'Enlil\'s Brayettes',
             'Custom Pants', 'Custom Slacks', 'Ea\'s Brais' },
        Feet  = { 'Marduk\'s Crackows', 'Goliard Clogs', 'Oracle\'s Pigaches', 'Marine F Boots',
             'Marine M Boots', 'Ceremonial Boots', 'Savage Gaiters' },
    },
    -- Enfeebling songs get resisted, so Lullaby and Elegy take magic
    -- accuracy instead, plus the element staff from staves.lua.
    ['SongAcc_Priority'] = {
        Head  = { 'Shadow Hat', 'Valkyrie\'s Hat', 'Carline Ribbon', 'Lamia Garland',
             'Opo-opo Crown', 'Choral Roundlet', 'Super Ribbon', 'Storm Zucchetto',
             'Jester\'s Headband', 'Juggler\'s Headband', 'Rain Hat', 'Alluring Headband',
             'Enlil\'s Tiara', 'Trump Crown', 'Garrison Sallet', 'Noble\'s Ribbon',
             'Entrancing Ribbon' },
        Neck  = { 'Temperance Torque', 'Oscar Scarf', 'Lieutenant\'s Gorget', 'Star Necklace',
             'Stoneskin Torque', 'Torque', 'Flower Necklace', 'Bird Whistle', 'Dog Collar' },
        Ear1  = { 'Delta Earring', 'Epsilon Earring', 'Beastly Earring', 'Diabolos\'s Earring',
             'Melody Earring', 'Melody Earring +1', 'Heims Earring', 'Singing Earring',
             'Trimmer\'s Earring' },
        Ear2  = { 'Delta Earring', 'Epsilon Earring', 'Beastly Earring', 'Diabolos\'s Earring',
             'Melody Earring', 'Melody Earring +1', 'Heims Earring', 'Singing Earring',
             'Trimmer\'s Earring' },
        Body  = { 'Shadow Coat', 'Valkyrie\'s Coat', 'Oracle\'s Robe', 'Black Cotehardie',
             'Flora Cotehardie', 'Healing Justaucorps', 'Brigandine +1', 'Argent Coat',
             'Ceremonial Dress', 'Enlil\'s Gambison', 'Federation Doublet',
             'Windurstian Doublet', 'Ea\'s Doublet', 'Garrison Tunica' },
        Hands = { 'Goliard Cuffs', 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Marine F Gloves',
             'Marine M Gloves', 'Choral Cuffs', 'Sennight Bangles', 'Enlil\'s Kolluks',
             'Ea\'s Dastanas' },
        Ring1 = { 'Epsilon Ring', 'Dark Ring', 'Insect Ring', 'Serene Ring', 'Allure Ring',
             'Allure Ring +1', 'Balrahn\'s Ring', 'Kshama Ring No. 6', 'Vilma\'s Ring',
             'Loyalty Ring', 'Loyalty Ring +1', 'Tamas Ring', 'Hope Ring', 'Opal Ring' },
        Ring2 = { 'Epsilon Ring', 'Dark Ring', 'Insect Ring', 'Serene Ring', 'Allure Ring',
             'Allure Ring +1', 'Balrahn\'s Ring', 'Kshama Ring No. 6', 'Vilma\'s Ring',
             'Loyalty Ring', 'Loyalty Ring +1', 'Tamas Ring', 'Hope Ring', 'Opal Ring' },
        Back  = { 'Astute Cape', 'Prism Cape', 'Rainbow Cape', 'Birdman Cape',
             'Miraculous Cape', 'Jester\'s Cape', 'Jester\'s Cape +1', 'Gramary Cape',
             'Lucent Cape' },
        Waist = { 'Al Zahbi Sash', 'Moon Sash', 'Czar\'s Belt', 'Kaiser Belt', 'Bitter Corset',
             'Royal Knight\'s Belt +1', 'Royal Knight\'s Belt +2', 'Desert Stone',
             'Reverend Sash', 'Corsette', 'Corsette +1', 'Enthralling Gold Obi',
             'Mercenary Captain\'s Belt' },
        Legs  = { 'Shadow Trews', 'Valkyrie\'s Trews', 'Mercenary\'s Trousers', 'Luna Subligar',
             'Ceremonial Hose', 'Platino Hose', 'Enlil\'s Brayettes', 'Custom Pants',
             'Custom Slacks', 'Ea\'s Brais' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'Ceremonial Boots', 'Savage Gaiters' },
    },
    -- Minstrel's Ring cuts song cast time by 25%, but only while HP is
    -- under 76% and TP under 100%. Equipping max-HP gear raises max HP
    -- without raising current HP, which drops the percentage and can trip
    -- the latent. Ring1 is left free for the ring itself.
    ['MinstrelHP_Priority'] = {
        Head  = { 'Genbu\'s Kabuto', 'Curate\'s Hat', 'Goliard Chapeau', 'Kosshin',
             'Mirage Keffiyeh', 'Walkure Mask', 'Kingdom Bandana', 'Scorpion Mask +1',
             'Scorpion Mask', 'Republic Cap', 'Bastokan Cap', 'Wivre Hairpin',
             'Wivre Hairpin +1', 'Akinji Khud', 'Electrum Hairpin', 'Eldritch Horn Hairpin',
             'Horn Hairpin', 'Emperor Hairpin', 'Empress Hairpin', 'Silver Hairpin' },
        Neck  = { 'Chanoix\'s Gorget', 'Rho Necklace', 'Shield Pendant', 'Bloodbead Amulet',
             'Promise Badge', 'Paisley Scarf', 'Evasion Torque', 'Guarding Torque',
             'Parrying Torque', 'Bird Whistle', 'Green Scarf', 'Buffoon\'s Collar',
             'Morgana\'s Choker', 'Star Necklace', 'Checkered Scarf', 'Pachamac\'s Collar' },
        Ear1  = { 'Morukaka\'s Earring', 'Pigeon Earring +1', 'Pigeon Earring',
             'Ethereal Earring', 'Insomnia Earring', 'Heavens Earring +1', 'Heavens Earring',
             'Angel\'s Earring', 'Ryakho\'s Earring', 'Allure Earring +1', 'Shield Earring',
             'Allure Earring', 'Moon Earring', 'Bull Earring', 'Hope Earring +1',
             'Valor Earring', 'Hope Earring' },
        Ear2  = { 'Morukaka\'s Earring', 'Pigeon Earring +1', 'Pigeon Earring',
             'Ethereal Earring', 'Insomnia Earring', 'Heavens Earring +1', 'Heavens Earring',
             'Angel\'s Earring', 'Ryakho\'s Earring', 'Allure Earring +1', 'Shield Earring',
             'Allure Earring', 'Moon Earring', 'Bull Earring', 'Hope Earring +1',
             'Valor Earring', 'Hope Earring' },
        Body  = { 'Goliard Saio', 'Custom Tunic', 'Custom Vest', 'Magna Bodice',
             'Choral Justaucorps +1', 'Minstrel\'s Coat', 'Brigandine +1', 'Silk Cloak +1',
             'Choral Justaucorps', 'Brigandine', 'Marduk\'s Jubbah', 'Faerie Tunic',
             'Kingdom Vest', 'Bastokan Harness', 'Assault Jerkin', 'Black Cotehardie',
             'Flora Cotehardie', 'High Healing Harness', 'Healing Harness' },
        Hands = { 'Seiryu\'s Kote', 'Pantin Dastanas +1', 'Ogygos\'s Bracelets',
             'Fencing Bracers', 'Marid Mittens +1', 'Combat Caster\'s Mitts +2',
             'Marid Mittens', 'Light Gauntlets', 'Gigas Bracelets', 'Choral Cuffs +1',
             'Combat Caster\'s Mitts +1', 'Custom F Gloves', 'Custom M Gloves', 'Wonder Mitts',
             'Kingdom Gloves', 'Scorpion Mittens +1', 'Scorpion Mittens', 'Republic Mittens',
             'Bastokan Mittens' },
        Ring2 = { 'Bomb Queen Ring', 'Light Ring', 'Sattva Ring', 'Bomb Ring', 'Behemoth Ring',
             'Toreador\'s Ring', 'Gold Ring +1', 'Gold Ring', 'Mythril Ring +1', 'Mythril Ring',
             'Poisona Ring', 'Dark Ring', 'Serene Ring', 'Earth Ring', 'Fire Ring',
             'Peace Ring', 'Electrum Ring', 'Fasting Ring' },
        Back  = { 'High Breath Mantle', 'Breath Mantle', 'Prism Cape', 'Empowering Mantle',
             'Enhancing Mantle', 'Lucent Cape', 'Marid Mantle +1', 'Republican Army Mantle',
             'Marid Mantle', 'Blue Cape', 'Blue Cape +1', 'Bellicose Mantle' },
        Waist = { 'Kaiser Belt', 'Marid Belt +1', 'Marid Belt', 'Czar\'s Belt', 'Koenigs Belt',
             'Desert Belt', 'Forest Belt', 'Powerful Rope', 'Survival Belt', 'Trance Belt',
             'Adept\'s Rope', 'Warrior\'s Belt +1', 'Force Belt', 'Warrior\'s Belt',
             'Astral Rope', 'Quick Belt', 'Augmenting Belt' },
        Legs  = { 'Galliard Trousers', 'Hecatomb Subligar +1', 'Hecatomb Subligar',
             'Choral Cannions', 'Federation Brais', 'Magna F Chausses', 'Windurstian Brais',
             'Sturdy Trousers', 'Silk Slacks +1', 'Silk Slacks', 'Sturdy Slacks',
             'Scorpion Subligar +1', 'Scorpion Subligar', 'Frog Trousers' },
        Feet  = { 'Root Sabots', 'Ataractic Solea', 'Marid Leggings', 'Savage Gaiters',
             'Choral Slippers +1', 'Hecatomb Leggings', 'Kingdom Boots', 'Scorpion Leggings +1',
             'Custom F Boots', 'Custom M Boots', 'Scorpion Leggings', 'Republic Leggings',
             'Bastokan Leggings', 'Rostrum Pumps', 'Akinji Nails' },
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
             'Royal Spearman\'s Horn' },
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
        Range = { 'Cythara Anglica +1', 'Cythara Anglica' },
    },
    -- Used when a song has no instrument of its own.
    ['General_Priority'] = {
        Range = { 'Cythara Anglica +1', 'San d\'Orian Horn', 'Kingdom Horn', 'Royal Spearman\'s Horn', 'Cythara Anglica', 'Hamelin Flute' },
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
    common.EvaluateGear(profile.Songs, level);
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
end

profile.OnUnload = function()
	AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /brd');
end

profile.HandleCommand = function(args)
    -- Handle utility settings
    utility.SetOptions(args[1], Settings.MacroBook);

    -- Rescan the bags and re-resolve every gear set
    if (args[1] == 'gear') then
        common.EvaluateGear(profile.Sets, Settings.CurrentLevel, true);
        common.EvaluateGear(profile.Songs, Settings.CurrentLevel, true);
        common.ReportGear(profile.Sets, Settings.CurrentLevel);
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();

	gFunc.EquipSet(common.Sets.Dream);

	if (player.SubJob == 'WHM') then
		gFunc.EquipSet(profile.Sets.Pulling_WHM);
	else
		gFunc.EquipSet(profile.Sets.Pulling_NIN);
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

	-- Song cast time. Max HP goes on first: it raises maximum HP without
	-- raising current HP, which drops the percentage and can trip the
	-- Minstrel's Ring latent (HP under 76% and TP under 100%). The ring
	-- itself goes on last so it keeps Ring1.
	if (action ~= nil) and (action.Type == 'Bard Song') then
		gFunc.EquipSet(profile.Sets.MinstrelHP);
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
