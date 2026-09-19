local profile = {};
local utility = gFunc.LoadFile('./utility.lua');
local common = gFunc.LoadFile('./common.lua');
local staves = gFunc.LoadFile('./staves.lua');

local Settings = {
    MacroBook = '1',
    CurrentLevel = 0,
    UseMelee = false,
};

-- Filling these in: gFunc.EvaluateLevels picks the first entry in a
-- _Priority list that your LEVEL allows. It does not check your job or your
-- inventory, so an item you cannot wear or do not own still wins its slot
-- and leaves it empty instead of falling through to the next entry. Only
-- list gear you actually have. The commented entries are era-standard
-- suggestions -- uncomment them as you acquire them.
-- Gear candidates pulled from the HorizonXI wiki: every piece RDM can wear,
-- scored per set and laddered down the level bands so each list resolves at
-- any level. The level of each entry is noted after the line.
--
-- PRUNE THESE TO GEAR YOU ACTUALLY OWN. gFunc.EvaluateLevels picks the first
-- entry your LEVEL allows; it checks neither job nor inventory. An item you do
-- not own still wins its slot, and that slot then silently keeps whatever was
-- already equipped rather than falling through to gear you do have.
-- Gear candidates pulled from the HorizonXI wiki: every piece RDM can wear,
-- scored per set and laddered down the level bands so each list resolves at
-- any level. The level of each entry is noted after the line.
--
-- PRUNE THESE TO GEAR YOU ACTUALLY OWN. gFunc.EvaluateLevels picks the first
-- entry your LEVEL allows; it checks neither job nor inventory. An item you do
-- not own still wins its slot, and that slot then silently keeps whatever was
-- already equipped rather than falling through to gear you do have.
sets = {
    -- Melee / TP, worn while engaged in melee mode.
    ['TP_Priority'] = {
        Head  = { 'Nashira Turban', 'Pahluwan Qalansuwa', 'Bowman\'s Mask', 'Torama Mask',
             'Qiqirn Hood', 'Corsair\'s Tricorne', 'Super Ribbon', 'Vampire Mask', 'Shock Mask',
             'Neit\'s Crown', 'Valkyrie\'s Mask', 'Spelunker\'s Hat', 'Macha\'s Crown',
             'Dandy Spectacles', 'Fancy Spectacles', 'Emperor Hairpin', 'Empress Hairpin' },
        Neck  = { 'Qiqirn Collar', 'Almah Torque', 'Diabolos\'s Torque', 'Sniper\'s Collar',
             'Grand Temple Knight\'s Collar', 'Chivalrous Chain', 'Spectacles', 'Coral Gorget',
             'Merman\'s Gorget', 'Auditory Torque', 'Jagd Gorget', 'Peacock Amulet',
             'Peacock Charm', 'Ajase Beads', 'Tiger Stole', 'Fang Necklace', 'Spike Necklace',
             'Feather Collar +1' },
        Ear1  = { 'Brutal Earring', 'Beta Earring', 'Hollow Earring', 'Haten Earring',
             'Diabolos\'s Earring', 'Minuet Earring', 'Bitter Earring', 'Accurate Earring',
             'Vision Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Wyvern Earring', 'Beater\'s Earring', 'Killer Earring', 'Mythril Earring +1',
             'Reraise Earring', 'Beetle Earring', 'Bone Earring', 'Bone Earring +1',
             'Optical Earring' },
        Ear2  = { 'Brutal Earring', 'Beta Earring', 'Hollow Earring', 'Haten Earring',
             'Diabolos\'s Earring', 'Minuet Earring', 'Bitter Earring', 'Accurate Earring',
             'Vision Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Wyvern Earring', 'Beater\'s Earring', 'Killer Earring', 'Mythril Earring +1',
             'Reraise Earring', 'Beetle Earring', 'Bone Earring', 'Bone Earring +1',
             'Optical Earring' },
        Body  = { 'Nashira Manteel', 'Morrigan\'s Robe', 'Commodore Frac', 'Assault Jerkin',
             'Tabin Jupon', 'Tabin Jupon +1', 'Akinji Peti', 'Jaridah Peti', 'Cerise Doublet',
             'Iron Musketeer\'s Gambison +1', 'Iron Musketeer\'s Gambison +2',
             'Iron Musketeer\'s Gambison', 'Macha\'s Coat', 'Federation Doublet',
             'Windurstian Doublet', 'Bodb\'s Robe', 'Garrison Tunica', 'Nemain\'s Robe' },
        Hands = { 'Nashira Gages', 'Dusk Gloves', 'Dusk Gloves +1', 'Tabin Bracers',
             'Tabin Bracers +1', 'Battle Bracers', 'Akinji Bazubands', 'Jaridah Bazubands',
             'Aiming Bracelets', 'Combat Caster\'s Mitts +1', 'Combat Caster\'s Mitts +2',
             'Combat Caster\'s Mitts', 'Sennight Bangles', 'Macha\'s Cuffs', 'Aiming Gloves',
             'Custom F Gloves', 'Custom M Gloves', 'Bodb\'s Cuffs', 'Bastokan Mittens',
             'Kingdom Gloves', 'Battle Gloves' },
        Ring1 = { 'Tau Ring', 'Bellona\'s Ring', 'Mars\'s Ring', 'Marid Ring', 'Marid Ring +1',
             'Lightning Ring', 'Ulthalam\'s Ring', 'Jalzahn\'s Ring', 'Imperial Ring',
             'Kshama Ring No. 2', 'Kshama Ring No. 8', 'Carapace Ring', 'Horn Ring',
             'Rajas Ring', 'Divisor Ring', 'Bowyer Ring', 'Beetle Ring', 'Beetle Ring +1',
             'Bone Ring', 'Bone Ring +1', 'Vision Ring' },
        Ring2 = { 'Tau Ring', 'Bellona\'s Ring', 'Mars\'s Ring', 'Marid Ring', 'Marid Ring +1',
             'Lightning Ring', 'Ulthalam\'s Ring', 'Jalzahn\'s Ring', 'Imperial Ring',
             'Kshama Ring No. 2', 'Kshama Ring No. 8', 'Carapace Ring', 'Horn Ring',
             'Rajas Ring', 'Divisor Ring', 'Bowyer Ring', 'Beetle Ring', 'Beetle Ring +1',
             'Bone Ring', 'Bone Ring +1', 'Vision Ring' },
        Back  = { 'Charger Mantle', 'Gunner\'s Mantle', 'Jaeger Mantle', 'Psilos Mantle',
             'Amemet Mantle', 'Bushido Cape', 'Republican Army Mantle', 'Bellicose Mantle',
             'Gramary Cape', 'Jaguar Mantle', 'Rearguard Mantle' },
        Waist = { 'Ninurta\'s Sash', 'Buccaneer\'s Belt', 'Corsair\'s Belt', 'Sonic Belt',
             'Sonic Belt +1', 'Bitter Corset', 'Speed Belt', 'Flagellant\'s Rope', 'Swift Belt',
             'Life Belt', 'Vanguard Belt', 'Quick Belt', 'Katana Obi', 'Wyvern Belt',
             'Pilferer\'s Belt', 'Acrobat\'s Belt', 'Barbarian\'s Belt', 'Brave belt' },
        Legs  = { 'Nashira Seraweels', 'Galliard Trousers', 'Armadillo Cuisses',
             'Feral Trousers', 'Tiger Trousers', 'Luna Subligar', 'Akinji Salvars',
             'Jaridah Salvars', 'War Hose', 'Combat Caster\'s Slacks +1',
             'Combat Caster\'s Slacks +2', 'Combat Caster\'s Slacks', 'Bastokan Cuisses',
             'Republic Cuisses', 'Custom Pants', 'Bastokan Subligar', 'Republic Subligar',
             'Garrison Hose' },
        Feet  = { 'Nashira Crackows', 'Dusk Ledelsens', 'Dusk Ledelsens +1', 'Rutter Sabatons',
             'Marid Leggings', 'Marid Leggings +1', 'Tabin Boots', 'Tabin Boots +1',
             'Akinji Nails', 'Bastokan Greaves', 'Republic Greaves', 'Federation Gaiters',
             'Custom F Boots', 'Custom M Boots', 'Savage Gaiters', 'Bounding Boots',
             'Leaping Boots' },
    },
    -- Out of combat in caster mode. The Earth staff goes on top.
    ['Idle_Priority'] = {
        Head  = { 'Duelist\'s Chapeau +1', 'Duelist\'s Chapeau', 'Yigit Turban',
             'Curate\'s Hat', 'Scorpion Helm', 'Scorpion Helm +1', 'Magi Hat', 'Silken Hat',
             'Shock Mask', 'Valkyrie\'s Mask', 'Walkure Mask', 'Electrum Hairpin',
             'Macha\'s Crown', 'Bastokan Visor', 'Republic Visor', 'Bodb\'s Crown',
             'Trump Crown', 'Blissful Chapeau', 'Bastokan Cap', 'Republic Cap', 'Coven Hat' },
        Neck  = { 'Rho Necklace', 'Morgana\'s Choker', 'Ritter Gorget',
             'Merrow No. 17\'s Locket', 'Windurstian Scarf', 'Grandiose Chain', 'Star Necklace',
             'Checkered Scarf', 'Pachamac\'s Collar', 'Promise Badge', 'Jagd Gorget',
             'Mohbwa Scarf', 'Shield Pendant', 'Ajase Beads', 'Paisley Scarf', 'Holy Phial',
             'Tiger Stole', 'Hemp Gorget', 'Bird Whistle', 'Van Pendant', 'Green Scarf' },
        Ear1  = { 'Gamma Earring', 'Loquacious Earring', 'Ethereal Earring', 'Chaotic Earring',
             'Hades Earring +1', 'Heavens Earring +1', 'Bat Earring', 'Refresh Earring',
             'Insomnia Earring', 'Allure Earring +1', 'Mana Earring +1', 'Intruder Earring',
             'Aura Earring +1', 'Loyalty Earring +1', 'Esquire\'s Earring', 'Shield Earring',
             'Mecurial Earring', 'Valor Earring', 'Energy Earring +1', 'Cassie Earring' },
        Ear2  = { 'Gamma Earring', 'Loquacious Earring', 'Ethereal Earring', 'Chaotic Earring',
             'Hades Earring +1', 'Heavens Earring +1', 'Bat Earring', 'Refresh Earring',
             'Insomnia Earring', 'Allure Earring +1', 'Mana Earring +1', 'Intruder Earring',
             'Aura Earring +1', 'Loyalty Earring +1', 'Esquire\'s Earring', 'Shield Earring',
             'Mecurial Earring', 'Valor Earring', 'Energy Earring +1', 'Cassie Earring' },
        Body  = { 'Dalmatica', 'Dalmatica +1', 'Hydra Doublet', 'Blue Cotehardie',
             'Blue Cotehardie +1', 'Assault Jerkin', 'Black Cotehardie', 'Flora Cotehardie',
             'Magi Coat', 'Brigandine', 'Brigandine +1', 'High Healing Harness', 'Mage\'s Robe',
             'Magna Bodice', 'Magna Jerkin', 'Wool Robe', 'Wool Robe +1', 'Faerie Tunic',
             'Healing Harness', 'Bastokan Harness', 'Republic Harness' },
        Hands = { 'Blood Finger Gauntlets', 'Crimson Finger Gauntlets', 'Yigit Gages',
             'Dragon Kote', 'Dune Bracers', 'Wood Gauntlets', 'Magical Mitts', 'Magi Cuffs',
             'Silken Cuffs', 'Combat Caster\'s Mitts +1', 'Combat Caster\'s Mitts +2',
             'Ogygos\'s Bracelets', 'New Moon Armlets', 'Macha\'s Cuffs', 'Gigas Bracelets',
             'Custom F Gloves', 'Custom M Gloves', 'Devotee\'s Mitts', 'Bastokan Mittens',
             'Republic Mittens', 'Kingdom Gloves' },
        Ring1 = { 'Dilation Ring', 'Dark Ring', 'Light Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Demon\'s Ring', 'Peace Ring', 'Toreador\'s Ring', 'Balrahn\'s Ring', 'Gold Ring',
             'Gold Ring +1', 'Electrum Ring', 'Aegis Ring', 'Aura Ring +1', 'Alacrity Ring +1',
             'Carect Ring', 'Mythril Ring', 'Mythril Ring +1', 'Bomb Ring', 'Fasting Ring',
             'Energy Ring +1' },
        Ring2 = { 'Dilation Ring', 'Dark Ring', 'Light Ring', 'Bloodbead Ring', 'Vivian Ring',
             'Demon\'s Ring', 'Peace Ring', 'Toreador\'s Ring', 'Balrahn\'s Ring', 'Gold Ring',
             'Gold Ring +1', 'Electrum Ring', 'Aegis Ring', 'Aura Ring +1', 'Alacrity Ring +1',
             'Carect Ring', 'Mythril Ring', 'Mythril Ring +1', 'Bomb Ring', 'Fasting Ring',
             'Energy Ring +1' },
        Back  = { 'Prism Cape', 'Rainbow Cape', 'Aries Mantle', 'Empowering Mantle',
             'Empowering Mantle +1', 'Intensifying Cape', 'Enhancing Mantle',
             'Federal Army Mantle', 'Republican Army Mantle', 'Aurora Mantle',
             'Aurora Mantle +1', 'Lucent Cape', 'Tundra Mantle', 'High Breath Mantle',
             'Wizard\'s Mantle', 'Invisible Mantle', 'Wolf Mantle', 'Variable Cape',
             'Breath Mantle', 'Talisman Cape', 'Cotton Cape' },
        Waist = { 'Lambda Sash', 'Immortal\'s Sash', 'Trance Belt', 'Czar\'s Belt',
             'Kaiser Belt', 'Lieutenant\'s Sash', 'Grace Corset', 'Astral Rope', 'Desert Belt',
             'Powerful Rope', 'Adept\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Survival Belt',
             'Hojutsu Belt', 'Shaman\'s Belt', 'Force Belt', 'Mohbwa Sash', 'Magic Belt',
             'Magic Belt +1', 'Warrior\'s Belt' },
        Legs  = { 'Blood Cuisses', 'Crimson Cuisses', 'Yigit Seraweels', 'Darksteel Subligar',
             'Silk Slacks', 'Silk Slacks +1', 'Scorpion Subligar', 'Magi Slops', 'Silken Slops',
             'Combat Caster\'s Slacks +1', 'Combat Caster\'s Slacks +2', 'Frog Trousers',
             'Mage\'s Slops', 'Magna F Chausses', 'Magna M Chausses', 'Wool Slops',
             'Bodb\'s Slops', 'Baron\'s Slops', 'Federation Slops', 'Nemain\'s Slops',
             'Sturdy Slacks' },
        Feet  = { 'Blood Greaves', 'Crimson Greaves', 'Yigit Crackows', 'Ataractic Solea',
             'Creek F Clomps', 'Creek M Clomps', 'Scorpion Leggings', 'Magi Pigaches',
             'Silken Pigaches', 'Dino Ledelsens', 'Inferno Sabots', 'Inferno Sabots +1',
             'Cuir Highboots', 'Macha\'s Pigaches', 'Mannequin Pumps', 'Custom F Boots',
             'Custom M Boots', 'Kingdom Clogs', 'Bastokan Leggings', 'Republic Leggings',
             'Kingdom Boots' },
    },
    -- Fast cast, worn during the precast phase of every spell.
    ['Precast_Priority'] = {
        Head  = { 'Warlock\'s Chapeau +1', 'Warlock\'s Chapeau' },
        Ear1  = { 'Loquacious Earring' },
        Ear2  = { 'Loquacious Earring' },
        Body  = { 'Duelist\'s Tabard +1', 'Duelist\'s Tabard' },
        Ring1 = { 'Pi Ring' },
        Ring2 = { 'Pi Ring' },
        Back  = { 'Warlock\'s Mantle' },
    },
    -- Enfeebling midcast (magic accuracy, MND/INT).
    ['Enfeebling_Priority'] = {
        Head  = { 'Morrigan\'s Coronal', 'Duelist\'s Chapeau +1', 'Duelist\'s Chapeau',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon',
             'Tactician Magician\'s Hat +1', 'Storm Zucchetto', 'Neit\'s Crown', 'Rain Hat',
             'Sinister Mask', 'Macha\'s Crown', 'Eldritch Horn Hairpin', 'Bodb\'s Crown',
             'Baron\'s Chapeau', 'Garrison Sallet', 'Bastokan Cap', 'Eldritch Bone Hairpin' },
        Neck  = { 'Phi Necklace', 'Prudence Torque', 'Jeweled Collar +1', 'Enfeebling Torque',
             'Lieutenant\'s Gorget', 'Spider Torque', 'Stoneskin Torque', 'Torque', 'Torque +1',
             'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Holy Phial', 'Fang Necklace',
             'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Abyssal Earring', 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Diabolos\'s Earring', 'Desamilion Earring', 'Gayanj\'s Earring',
             'Ryakho\'s Earring', 'Boroka Earring', 'Harvest Earring', 'Heims Earring',
             'Geist Earring', 'Enfeebling Earring', 'Morion Earring', 'Cunning Earring' },
        Ear2  = { 'Abyssal Earring', 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Diabolos\'s Earring', 'Desamilion Earring', 'Gayanj\'s Earring',
             'Ryakho\'s Earring', 'Boroka Earring', 'Harvest Earring', 'Heims Earring',
             'Geist Earring', 'Enfeebling Earring', 'Morion Earring', 'Cunning Earring' },
        Body  = { 'Nashira Manteel', 'Shadow Coat', 'Valkyrie\'s Coat', 'Blue Cotehardie',
             'Blue Cotehardie +1', 'Warlock\'s Tabard', 'Shaman\'s Cloak', 'Glamor Jupon',
             'Brigandine +1', 'Combat Caster\'s Cloak +1', 'Combat Caster\'s Cloak +2',
             'Mage\'s Robe', 'Macha\'s Coat', 'Bishop\'s Robe', 'Bodb\'s Robe', 'Baron\'s Saio',
             'Black Tunic', 'Priest\'s Robe', 'Kingdom Tunic', 'San d\'Orian Tunic' },
        Hands = { 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Goliard Cuffs',
             'Master Caster\'s Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Silk Cuffs +1', 'Mage\'s Mitts', 'Engineer\'s Gloves', 'Sennight Bangles',
             'Devotee\'s Mitts', 'Elder\'s Bracers', 'Magna Gauntlets', 'Zealot\'s Mitts' },
        Ring1 = { 'Epsilon Ring', 'Dark Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 9', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malflood Ring', 'Tamas Ring', 'Carect Ring', 'Clear Ring', 'Knowledge Ring',
             'Knowledge Ring +1' },
        Ring2 = { 'Epsilon Ring', 'Dark Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Grand Knight\'s Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 9', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malflood Ring', 'Tamas Ring', 'Carect Ring', 'Clear Ring', 'Knowledge Ring',
             'Knowledge Ring +1' },
        Back  = { 'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Sapient Cape',
             'Miraculous Cape', 'Federal Army Mantle', 'Royal Army Mantle', 'Gramary Cape',
             'Red Cape', 'Red Cape +1', 'Black Cape', 'Black Cape +1', 'White Cape',
             'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Arachne Obi', 'Bitter Corset',
             'Penitent\'s Rope', 'Royal Knight\'s Belt +1', 'Royal Knight\'s Belt +2',
             'Jungle Stone', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deductive Gold Obi', 'Mercenary Captain\'s Belt', 'Shaman\'s Belt',
             'Friar\'s Rope' },
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews', 'Warlock\'s Tights',
             'Tactician Magician\'s Slops +1', 'Tactician Magician\'s Slops +2',
             'Magic Cuisses', 'Macha\'s Slops', 'Custom Pants', 'Custom Slacks',
             'Bodb\'s Slops', 'Mage\'s Slacks' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Warlock\'s Boots',
             'Tactician Magician\'s Pigaches +1', 'Tactician Magician\'s Pigaches +2',
             'Inferno Sabots', 'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps',
             'Custom F Boots', 'Custom M Boots', 'Elder\'s Sandals', 'Garrison Boots' },
    },
    -- Enhancing midcast (enhancing magic skill).
    ['Enhancing_Priority'] = {
        Head  = { 'Duelist\'s Chapeau +1', 'Goliard Chapeau', 'Morrigan\'s Coronal',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1',
             'Super Ribbon', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Circe\'s Hat',
             'Eldritch Horn Hairpin', 'Garrison Sallet', 'Traveler\'s Hat',
             'Eldritch Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Enhancing Torque', 'Enlightened Chain', 'Stoneskin Torque', 'Torque', 'Torque +1',
             'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Holy Phial', 'Fang Necklace',
             'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Communion Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augmenting Earring' },
        Ear2  = { 'Static Earring', 'Celestial Earring', 'Communion Earring',
             'Communion Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augmenting Earring' },
        Body  = { 'Morrigan\'s Robe', 'Blood Scale Mail', 'Crimson Scale Mail',
             'Blue Cotehardie', 'Blue Cotehardie +1', 'Black Cotehardie', 'Flora Cotehardie',
             'Glamor Jupon', 'Brigandine +1', 'Combat Caster\'s Cloak +1',
             'Combat Caster\'s Cloak +2', 'Bishop\'s Robe', 'Bishop\'s Robe +1',
             'Macha\'s Coat', 'Baron\'s Saio', 'Priest\'s Robe' },
        Hands = { 'Duelist\'s Gloves +1', 'Warlock\'s Gloves +1', 'Duelist\'s Gloves',
             'Dragon Kote', 'Master Caster\'s Bracelets', 'Dune Bracers', 'Magi Cuffs',
             'Silk Cuffs +1', 'Devotee\'s Mitts', 'Savage Gauntlets', 'Baron\'s Cuffs',
             'Zealot\'s Mitts' },
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
             'Deductive Brocade Obi', 'Penitent\'s Rope', 'Grace Corset',
             'Royal Knight\'s Belt +1', 'Royal Knight\'s Belt +2', 'Reverend Sash',
             'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Deductive Gold Obi',
             'Mercenary Captain\'s Belt', 'Friar\'s Rope' },
        Legs  = { 'Galliard Trousers', 'Morrigan\'s Slops', 'Warlock\'s Tights +1',
             'Warlock\'s Tights', 'Tactician Magician\'s Slops +1',
             'Tactician Magician\'s Slops +2', 'Magic Cuisses', 'Macha\'s Slops',
             'Custom Pants', 'Custom Slacks' },
        Feet  = { 'Duelist\'s Boots +1', 'Goliard Clogs', 'Morrigan\'s Pigaches',
             'Marine F Boots', 'Marine M Boots', 'River Gaiters', 'Warlock\'s Boots',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Garrison Boots' },
    },
    -- Cure midcast (MND, healing magic skill).
    ['Cure_Priority'] = {
        Head  = { 'Duelist\'s Chapeau +1', 'Goliard Chapeau', 'Volunteer\'s Khud',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1',
             'Super Ribbon', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Circe\'s Hat',
             'Eldritch Horn Hairpin', 'Garrison Sallet', 'Traveler\'s Hat',
             'Eldritch Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Phi Necklace', 'Chi Necklace', 'Healing Torque',
             'Enlightened Chain', 'Stoneskin Torque', 'Torque', 'Torque +1', 'Promise Badge',
             'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Holy Phial', 'Fang Necklace', 'Spike Necklace',
             'Justice Badge' },
        Ear1  = { 'Magnetic Earring', 'Static Earring', 'Celestial Earring',
             'Communion Earring', 'Communion Earring +1', 'Ryakho\'s Earring',
             'Harvest Earring', 'Geist Earring', 'Healing Earring' },
        Ear2  = { 'Magnetic Earring', 'Static Earring', 'Celestial Earring',
             'Communion Earring', 'Communion Earring +1', 'Ryakho\'s Earring',
             'Harvest Earring', 'Geist Earring', 'Healing Earring' },
        Body  = { 'Duelist\'s Tabard +1', 'Nashira Manteel', 'Duelist\'s Tabard',
             'Blue Cotehardie', 'Blue Cotehardie +1', 'Black Cotehardie', 'Flora Cotehardie',
             'Healing Justaucorps', 'Brigandine +1', 'Combat Caster\'s Cloak +1',
             'Combat Caster\'s Cloak +2', 'Bishop\'s Robe', 'Bishop\'s Robe +1',
             'Macha\'s Coat', 'Baron\'s Saio', 'Priest\'s Robe' },
        Hands = { 'Warlock\'s Gloves +1', 'Wise Gloves', 'Wise Gloves +1', 'Dragon Kote',
             'Master Caster\'s Bracelets', 'Dune Bracers', 'Magi Cuffs', 'Silk Cuffs +1',
             'Devotee\'s Mitts', 'Savage Gauntlets', 'Baron\'s Cuffs', 'Zealot\'s Mitts' },
        Ring1 = { 'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Water Ring',
             'Vivian Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring',
             'Solace Ring +1', 'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring',
             'Saintly Ring' },
        Ring2 = { 'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Water Ring',
             'Vivian Ring', 'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1',
             'Kshama Ring No. 9', 'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring',
             'Solace Ring +1', 'Carect Ring', 'Lapis Lazuli Ring', 'Tranquility Ring',
             'Saintly Ring' },
        Back  = { 'Maledictor\'s Shawl', 'Altruistic Cape', 'Prism Cape', 'Miraculous Cape',
             'Sapient Cape', 'Royal Army Mantle', 'Red Cape', 'Red Cape +1', 'White Cape',
             'White Cape +1', 'Mist Silk Cape' },
        Waist = { 'Lambda Sash', 'Ksi Sash', 'Volunteer\'s Belt', 'Water Belt',
             'Deductive Brocade Obi', 'Penitent\'s Rope', 'Grace Corset',
             'Royal Knight\'s Belt +1', 'Royal Knight\'s Belt +2', 'Reverend Sash',
             'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Deductive Gold Obi',
             'Mercenary Captain\'s Belt', 'Friar\'s Rope' },
        Legs  = { 'Galliard Trousers', 'Morrigan\'s Slops', 'Warlock\'s Tights +1',
             'Druid\'s Slops', 'Warlock\'s Tights', 'Tactician Magician\'s Slops +1',
             'Tactician Magician\'s Slops +2', 'Magic Cuisses', 'Macha\'s Slops',
             'Custom Pants', 'Custom Slacks' },
        Feet  = { 'Duelist\'s Boots +1', 'Goliard Clogs', 'Morrigan\'s Pigaches',
             'Marine F Boots', 'Marine M Boots', 'River Gaiters', 'Warlock\'s Boots',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Garrison Boots' },
    },
    -- Melee weapon and shield for melee mode. Swords are weighted first:
    -- RDM's sword skill beats its club and dagger.
    ['Weapon_Priority'] = {
        Main  = { 'Excalibur', 'Murgleis', 'Mighty Talwar', 'Aquan Slayer', 'Insect Slayer',
             'Vermin Slayer', 'Nightmare Sword', 'Enhancing Sword', 'Epee', 'Epee +1',
             'Macuahuitl', 'Macuahuitl +1', 'Phantom Fleuret', 'Macuahuitl -1',
             'Aramis\'s Rapier', 'Cermet Sword', 'Cermet Sword +1', 'Royal Guard\'s Fleuret',
             'Wise Wizard\'s Anelace', 'Temple Knight Sword +1', 'Temple Knight Sword +2',
             'Crimson Blade', 'Knight\'s Sword', 'Knight\'s Sword +1', 'Ancient Sword',
             'Junior Musketeer\'s Tuck +1', 'Immortal\'s Scimitar', 'Buzzard Tuck',
             'Divine Sword', 'Divine Sword +1', 'Bastokan Sword', 'Republic Sword',
             'Centurion\'s Sword', 'Steel Kilij', 'Steel Kilij +1', 'Gladiator', 'Gladius',
             'Tuck', 'Tuck +1', 'Kaiser Sword', 'Degen', 'Degen +1', 'Auriga Xiphos',
             'Small Sword', 'Fire Sword', 'Flame Sword', 'Iron Sword', 'Bee Spatha +1',
             'Wax Sword +1' },
        Sub   = { 'Acheron Shield', 'Acheron Shield +1', 'Genbu\'s Shield', 'Muse Tariqah',
             'Tariqah', 'Tariqah +1', 'Tariqah -1', 'Dominus Shield', 'Numinous Shield',
             'Numinous Shield +1', 'Astral Aspis', 'Gilt Buckler', 'Gold Buckler',
             'Round Shield', 'Darksteel Buckler', 'Spiked Buckler', 'Astral Shield',
             'Flame Shield', 'Musketeer Commander\'s Shield', 'Hoplon', 'Sentinel Shield',
             'Hard Shield', 'Leather Shield', 'Leather Shield +1', 'Viking Shield', 'Buckler',
             'Balance Buckler', 'Strike Shield', 'Nymph Shield', 'Nymph Shield +1',
             'Coated Shield', 'Wyvern Targe', 'Genin Aspis', 'Healer\'s Shield',
             'Wizard\'s Shield', 'Faerie Shield', 'Frost Shield', 'Bastokan Targe',
             'Republic Targe', 'Turtle Shield', 'Turtle Shield +1', 'Decurion\'s Shield',
             'Lantern Shield', 'Tropical Shield', 'Fish Scale Shield', 'Elm Shield',
             'Elm Shield +1', 'Aspis', 'Aspis +1' },
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
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias /rdm /lac fwd');

    AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. Settings.MacroBook);
end

profile.OnUnload = function()
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias delete /rdm');
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

    -- Swap between meleeing for TP and staying on the staff to cast
    if (args[1] == 'melee') then
        Settings.UseMelee = not Settings.UseMelee;
        gFunc.Message('Melee mode: ' .. tostring(Settings.UseMelee));
    end
end

profile.HandleDefault = function()
	local player = gData.GetPlayer();

	evalLevel();

	gFunc.EquipSet(common.Sets.Dream);

	if (Settings.UseMelee) then
		common.EquipMelee();
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

	if (action.Skill == 'Enfeebling Magic') then
		gFunc.EquipSet(sets.Enfeebling);
	elseif (action.Skill == 'Enhancing Magic') then
		gFunc.EquipSet(sets.Enhancing);
	elseif (action.Skill == 'Healing Magic') then
		gFunc.EquipSet(sets.Cure);
	end

	-- Staff last so the element wins the Main slot over any set above.
	staves.EquipStaff(action);
end

profile.HandlePreshot = function()
end

profile.HandleMidshot = function()
end

profile.HandleWeaponskill = function()
end

return profile;
