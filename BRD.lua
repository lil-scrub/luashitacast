local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
local staves = gFunc.LoadFile('./staves.lua');

local Settings = {
	CurrentLevel = 0,
	HPSwapped = false,
	MacroBook = '2',
};

sets = {
    -- Standing and pulling gear. Two things are wanted here: as little
    -- hate as possible while pulling, and as little maximum HP as possible
    -- so the +HP swap before a song drops the HP percentage far enough to
    -- trip the Minstrel's Ring latent. Gear that adds enmity or adds HP is
    -- excluded outright. Terra's Staff is the HQ Earth Staff -- both give
    -- physical damage taken -20%.
    ['Pulling_NIN_Priority'] = {
        Main  = { 'Terra\'s Staff', 'Earth Staff' },
        Ammo  = { 'Pebble' },
        Head  = { 'Wivre Hairpin +1', 'Reikyo Hairpin', 'Wivre Hairpin', 'Faerie Hairpin',
             'Emperor Hairpin', 'Empress Hairpin', 'Hydra Beret', 'Raven Beret', 'Gold Hairpin',
             'Gold Hairpin +1', 'Electrum Hairpin', 'Patroclus\'s Helm', 'Silver Hairpin',
             'Eld. Horn Hairpin', 'Horn Hairpin', 'Horn Hairpin +1', 'Brass Hairpin',
             'Brass Hairpin +1', 'Shell Hairpin', 'Dino Helm', 'Raptor Helm' },
        Neck  = { 'Star Necklace', 'Checkered Scarf', 'Benign Necklace', 'Sniper\'s Collar',
             'Lieut. Gorget', 'Orochi Nodowa', 'Orochi Nodowa +1', 'Qiqirn Collar',
             'Grand T.K. Collar', 'Auditory Torque', 'Blue Gorget',
             'Carapace Gorget', 'Stone Gorget', 'Memento Muffler', 'Medieval Collar',
             'Holy Phial', 'Tiger Stole', 'Hemp Gorget', 'Van Pendant', 'Dog Collar',
             'Feather Collar' },
        Ear1  = { 'Astral Earring', 'Novia Earring', 'Delta Earring', 'Refresh Earring',
             'Chaotic Earring', 'Haten Earring', 'Priest\'s Earring', 'Bitter Earring',
             'Cel. Earring +1', 'Genius Earring +1', 'Alc. Earring +1',
             'Aura Earring +1', 'Deft Earring +1', 'Mecurial Earring', 'Blc. Earring +1',
             'Crg. Earring +1', 'Energy Earring +1' },
        Ear2  = { 'Astral Earring', 'Novia Earring', 'Delta Earring', 'Refresh Earring',
             'Chaotic Earring', 'Haten Earring', 'Priest\'s Earring', 'Bitter Earring',
             'Cel. Earring +1', 'Genius Earring +1', 'Alc. Earring +1',
             'Aura Earring +1', 'Deft Earring +1', 'Mecurial Earring', 'Blc. Earring +1',
             'Crg. Earring +1', 'Energy Earring +1' },
        Body  = { 'Akinji Peti', 'Jaridah Peti', 'Hydra Doublet', 'Raven Jupon',
             'Valkyrie\'s Coat', 'Shadow Coat', 'Enlil\'s Gambison', 'Assault Jerkin',
             'Northern Jerkin', 'Tundra Jerkin', 'Dino Jerkin', 'Raptor Jerkin',
             'Wool Gambison', 'Cuir Bouilli', 'Cuir Bouilli +1', 'Wool Robe', 'Wool Robe +1',
             'Ea\'s Doublet', 'Priest\'s Robe', 'Garrison Tunica', 'Fine Jerkin' },
        Hands = { 'Dune Bracers', 'Mahatma Cuffs', 'Errant Cuffs', 'Akinji Bazubands',
             'Jaridah Bazubands', 'Hydra Gloves', 'Raven Bracers', 'Concealing Cuffs',
             'Enlil\'s Kolluks', 'Scp. Gauntlets', 'Scp. Gnt. +1', 'Dino Gloves',
             'Raptor Gloves', 'Cuir Gloves', 'Cuir Gloves +1', 'Wool Cuffs', 'Wool Cuffs +1',
             'Devotee\'s Mitts', 'Fine Gloves', 'Lizard Gloves', 'Bone Mittens' },
        Ring1 = { 'Serket Ring', 'Ether Ring', 'Astral Ring', 'Dark Ring', 'Electrum Ring',
             'Fasting Ring', 'Earth Ring', 'Fire Ring', 'Lightning Ring', 'Tamas Ring',
             'Peace Ring', 'Balrahn\'s Ring', 'Bellona\'s Ring', 'Cerberus Ring',
             'Kshama Ring No. 4', 'Aegis Ring', 'Alacrity Ring +1', 'Armored Ring' },
        Ring2 = { 'Serket Ring', 'Ether Ring', 'Astral Ring', 'Dark Ring', 'Electrum Ring',
             'Fasting Ring', 'Earth Ring', 'Fire Ring', 'Lightning Ring', 'Tamas Ring',
             'Peace Ring', 'Balrahn\'s Ring', 'Bellona\'s Ring', 'Cerberus Ring',
             'Kshama Ring No. 4', 'Aegis Ring', 'Alacrity Ring +1', 'Armored Ring' },
        Back  = { 'Solitaire Cape', 'Aslan Cape', 'Bellicose Mantle', 'Mahatma Cape',
             'Peace Cape +1', 'Peace Cape', 'Amity Cape', 'Sapient Cape', 'Talisman Cape',
             'Esoteric Mantle', 'Dodge Cape', 'Volitional Mantle', 'Dino Mantle',
             'Tundra Mantle', 'Cvl. Mantle', 'Cvl. Mantle +1', 'Invisible Mantle',
             'Wolf Mantle', 'Wolf Mantle +1', 'Cotton Cape', 'Cotton Cape +1' },
        Waist = { 'Penitent\'s Rope', 'Quick Belt', 'Theta Sash', 'Buccaneer\'s Belt',
             'Spectral Belt', 'Talisman Obi', 'Immortal\'s Sash', 'Arachne Obi', 'Grace Corset',
             'Flagellant\'s Rope', 'R.K. Belt +1', 'Brocade Obi', 'Brocade Obi +1',
             'Oracle\'s Belt', 'Tathlum Belt', 'Deduct. Gold Obi', 'Shaman\'s Belt',
             'Mohbwa Sash', 'Mohbwa Sash +1', 'Magic Belt', 'Magic Belt +1' },
        Legs  = { 'Akinji Salvars', 'Jaridah Salvars', 'Hydra Brais', 'Raven Hose',
             'Goliard Trews', 'Marduk\'s Shalwar', 'Frog Trousers', 'Enlil\'s Brayettes',
             'Darksteel Subligar', 'Dst. Subligar +1', 'Druid\'s Slops', 'Blaze Hose',
             'Dino Trousers', 'Cuir Trousers', 'Cuir Trousers +1', 'Wool Slops',
             'Wool Slops +1', 'Bastokan Subligar', 'Fine Trousers', 'Lizard Trousers',
             'Bone Subligar' },
        Feet  = { 'Rostrum Pumps', 'Mahatma Pigaches', 'Errant Pigaches', 'Raven Gaiters',
             'Akinji Nails', 'Jaridah Nails', 'Enlil\'s Crackows', 'Rutter Sabatons',
             'Wulong Shoes', 'Wulong Shoes +1', 'Dino Ledelsens', 'Raptor Ledelsens',
             'Wool Socks', 'Cuir Highboots', 'Cuir Highboots +1', 'Elder\'s Sandals',
             'Mgn. F Ledelsens', 'Mgn. M Ledelsens', 'Garrison Boots', 'Power Sandals',
             'Fine Ledelsens' },
    },
    -- With a white mage subjob the chest is Gaudy Harness: its latent gives
    -- refresh while MP is under 49.
    ['Pulling_WHM_Priority'] = {
        Main  = { 'Terra\'s Staff', 'Earth Staff' },
        Ammo  = { 'Pebble' },
        Head  = { 'Wivre Hairpin +1', 'Reikyo Hairpin', 'Wivre Hairpin', 'Faerie Hairpin',
             'Emperor Hairpin', 'Empress Hairpin', 'Hydra Beret', 'Raven Beret', 'Gold Hairpin',
             'Gold Hairpin +1', 'Electrum Hairpin', 'Patroclus\'s Helm', 'Silver Hairpin',
             'Eld. Horn Hairpin', 'Horn Hairpin', 'Horn Hairpin +1', 'Brass Hairpin',
             'Brass Hairpin +1', 'Shell Hairpin', 'Dino Helm', 'Raptor Helm' },
        Neck  = { 'Star Necklace', 'Checkered Scarf', 'Benign Necklace', 'Sniper\'s Collar',
             'Lieut. Gorget', 'Orochi Nodowa', 'Orochi Nodowa +1', 'Qiqirn Collar',
             'Grand T.K. Collar', 'Auditory Torque', 'Blue Gorget',
             'Carapace Gorget', 'Stone Gorget', 'Memento Muffler', 'Medieval Collar',
             'Holy Phial', 'Tiger Stole', 'Hemp Gorget', 'Van Pendant', 'Dog Collar',
             'Feather Collar' },
        Ear1  = { 'Astral Earring', 'Novia Earring', 'Delta Earring', 'Refresh Earring',
             'Chaotic Earring', 'Haten Earring', 'Priest\'s Earring', 'Bitter Earring',
             'Cel. Earring +1', 'Genius Earring +1', 'Alc. Earring +1',
             'Aura Earring +1', 'Deft Earring +1', 'Mecurial Earring', 'Blc. Earring +1',
             'Crg. Earring +1', 'Energy Earring +1' },
        Ear2  = { 'Astral Earring', 'Novia Earring', 'Delta Earring', 'Refresh Earring',
             'Chaotic Earring', 'Haten Earring', 'Priest\'s Earring', 'Bitter Earring',
             'Cel. Earring +1', 'Genius Earring +1', 'Alc. Earring +1',
             'Aura Earring +1', 'Deft Earring +1', 'Mecurial Earring', 'Blc. Earring +1',
             'Crg. Earring +1', 'Energy Earring +1' },
        Body  = { 'Gaudy Harness', 'Akinji Peti', 'Jaridah Peti', 'Hydra Doublet', 'Raven Jupon',
             'Valkyrie\'s Coat', 'Shadow Coat', 'Enlil\'s Gambison', 'Assault Jerkin',
             'Northern Jerkin', 'Tundra Jerkin', 'Dino Jerkin', 'Raptor Jerkin',
             'Wool Gambison', 'Cuir Bouilli', 'Cuir Bouilli +1', 'Wool Robe', 'Wool Robe +1',
             'Ea\'s Doublet', 'Priest\'s Robe', 'Garrison Tunica', 'Fine Jerkin' },
        Hands = { 'Dune Bracers', 'Mahatma Cuffs', 'Errant Cuffs', 'Akinji Bazubands',
             'Jaridah Bazubands', 'Hydra Gloves', 'Raven Bracers', 'Concealing Cuffs',
             'Enlil\'s Kolluks', 'Scp. Gauntlets', 'Scp. Gnt. +1', 'Dino Gloves',
             'Raptor Gloves', 'Cuir Gloves', 'Cuir Gloves +1', 'Wool Cuffs', 'Wool Cuffs +1',
             'Devotee\'s Mitts', 'Fine Gloves', 'Lizard Gloves', 'Bone Mittens' },
        Ring1 = { 'Serket Ring', 'Ether Ring', 'Astral Ring', 'Dark Ring', 'Electrum Ring',
             'Fasting Ring', 'Earth Ring', 'Fire Ring', 'Lightning Ring', 'Tamas Ring',
             'Peace Ring', 'Balrahn\'s Ring', 'Bellona\'s Ring', 'Cerberus Ring',
             'Kshama Ring No. 4', 'Aegis Ring', 'Alacrity Ring +1', 'Armored Ring' },
        Ring2 = { 'Serket Ring', 'Ether Ring', 'Astral Ring', 'Dark Ring', 'Electrum Ring',
             'Fasting Ring', 'Earth Ring', 'Fire Ring', 'Lightning Ring', 'Tamas Ring',
             'Peace Ring', 'Balrahn\'s Ring', 'Bellona\'s Ring', 'Cerberus Ring',
             'Kshama Ring No. 4', 'Aegis Ring', 'Alacrity Ring +1', 'Armored Ring' },
        Back  = { 'Solitaire Cape', 'Aslan Cape', 'Bellicose Mantle', 'Mahatma Cape',
             'Peace Cape +1', 'Peace Cape', 'Amity Cape', 'Sapient Cape', 'Talisman Cape',
             'Esoteric Mantle', 'Dodge Cape', 'Volitional Mantle', 'Dino Mantle',
             'Tundra Mantle', 'Cvl. Mantle', 'Cvl. Mantle +1', 'Invisible Mantle',
             'Wolf Mantle', 'Wolf Mantle +1', 'Cotton Cape', 'Cotton Cape +1' },
        Waist = { 'Penitent\'s Rope', 'Quick Belt', 'Theta Sash', 'Buccaneer\'s Belt',
             'Spectral Belt', 'Talisman Obi', 'Immortal\'s Sash', 'Arachne Obi', 'Grace Corset',
             'Flagellant\'s Rope', 'R.K. Belt +1', 'Brocade Obi', 'Brocade Obi +1',
             'Oracle\'s Belt', 'Tathlum Belt', 'Deduct. Gold Obi', 'Shaman\'s Belt',
             'Mohbwa Sash', 'Mohbwa Sash +1', 'Magic Belt', 'Magic Belt +1' },
        Legs  = { 'Akinji Salvars', 'Jaridah Salvars', 'Hydra Brais', 'Raven Hose',
             'Goliard Trews', 'Marduk\'s Shalwar', 'Frog Trousers', 'Enlil\'s Brayettes',
             'Darksteel Subligar', 'Dst. Subligar +1', 'Druid\'s Slops', 'Blaze Hose',
             'Dino Trousers', 'Cuir Trousers', 'Cuir Trousers +1', 'Wool Slops',
             'Wool Slops +1', 'Bastokan Subligar', 'Fine Trousers', 'Lizard Trousers',
             'Bone Subligar' },
        Feet  = { 'Rostrum Pumps', 'Mahatma Pigaches', 'Errant Pigaches', 'Raven Gaiters',
             'Akinji Nails', 'Jaridah Nails', 'Enlil\'s Crackows', 'Rutter Sabatons',
             'Wulong Shoes', 'Wulong Shoes +1', 'Dino Ledelsens', 'Raptor Ledelsens',
             'Wool Socks', 'Cuir Highboots', 'Cuir Highboots +1', 'Elder\'s Sandals',
             'Mgn. F Ledelsens', 'Mgn. M Ledelsens', 'Garrison Boots', 'Power Sandals',
             'Fine Ledelsens' },
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
        common.EvaluateGear(profile.Sets, Settings.CurrentLevel, true);
        common.EvaluateGear(profile.Songs, Settings.CurrentLevel, true);
        common.ReportGear(profile.Sets, Settings.CurrentLevel);
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
