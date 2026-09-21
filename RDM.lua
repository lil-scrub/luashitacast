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
        Head  = { 'Nashira Turban', 'Morrigan\'s Coron.', 'Pln. Qalansuwa', 'Torama Mask',
             'Green Beret', 'Corsair\'s Tricorne', 'Super Ribbon', 'Shock Mask',
             'Storm Zucchetto', 'Neit\'s Crown', 'Valkyrie\'s Mask', 'Spelunker\'s Hat',
             'Macha\'s Crown', 'Dandy Spectacles', 'Fancy Spectacles', 'Emperor Hairpin',
             'Empress Hairpin' },
        Neck  = { 'Qiqirn Collar', 'Almah Torque', 'Diabolos\'s Torque', 'Sniper\'s Collar',
             'Grand T.K. Collar', 'Chivalrous Chain', 'Spectacles', 'Coral Gorget',
             'Merman\'s Gorget', 'Jagd Gorget', 'Peacock Amulet', 'Peacock Charm',
             'Ajase Beads', 'Tiger Stole', 'Fang Necklace', 'Spike Necklace',
             'Feather Collar +1' },
        Ear1  = { 'Brutal Earring', 'Beta Earring', 'Hollow Earring', 'Diabolos\'s Earring',
             'Magnifying Earring', 'Minuet Earring', 'Bitter Earring', 'Accurate Earring',
             'Vision Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Mythril Earring +1', 'Reraise Earring', 'Beetle Earring', 'Bone Earring',
             'Bone Earring +1', 'Optical Earring' },
        Ear2  = { 'Brutal Earring', 'Beta Earring', 'Hollow Earring', 'Diabolos\'s Earring',
             'Magnifying Earring', 'Minuet Earring', 'Bitter Earring', 'Accurate Earring',
             'Vision Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
             'Mythril Earring +1', 'Reraise Earring', 'Beetle Earring', 'Bone Earring',
             'Bone Earring +1', 'Optical Earring' },
        Body  = { 'Nashira Manteel', 'Morrigan\'s Robe', 'Commodore Frac', 'Assault Jerkin',
             'Tabin Jupon', 'Tabin Jupon +1', 'Akinji Peti', 'Jaridah Peti', 'Cerise Doublet',
             'Irn.Msk.Gmbsn. +1', 'Irn.Msk.Gmbsn. +2',
             'Irn.Msk. Gambison', 'Macha\'s Coat', 'Fed. Doublet',
             'Win. Doublet', 'Bodb\'s Robe', 'Garrison Tunica', 'Nemain\'s Robe' },
        Hands = { 'Nashira Gages', 'Dusk Gloves', 'Dusk Gloves +1', 'Tabin Bracers',
             'Tabin Bracers +1', 'Battle Bracers', 'Akinji Bazubands', 'Jaridah Bazubands',
             'Aiming Bracelets', 'C.C. Mitts +1', 'C.C. Mitts +2',
             'Cmb.Cst. Mitts', 'Sennight Bangles', 'Macha\'s Cuffs', 'Aiming Gloves',
             'Custom F Gloves', 'Custom M Gloves', 'Bodb\'s Cuffs', 'Bastokan Mittens',
             'Kingdom Gloves', 'Battle Gloves' },
        Ring1 = { 'Bellona\'s Ring', 'Mars\'s Ring', 'Dilation Ring', 'Marid Ring',
             'Marid Ring +1', 'Lightning Ring', 'Toreador\'s Ring', 'Jalzahn\'s Ring',
             'Ulthalam\'s Ring', 'Kshama Ring No. 2', 'Kshama Ring No. 8', 'Carapace Ring',
             'Horn Ring', 'Horn Ring +1', 'Rajas Ring', 'Bowyer Ring', 'Beetle Ring',
             'Beetle Ring +1', 'Bone Ring', 'Bone Ring +1', 'Vision Ring' },
        Ring2 = { 'Bellona\'s Ring', 'Mars\'s Ring', 'Dilation Ring', 'Marid Ring',
             'Marid Ring +1', 'Lightning Ring', 'Toreador\'s Ring', 'Jalzahn\'s Ring',
             'Ulthalam\'s Ring', 'Kshama Ring No. 2', 'Kshama Ring No. 8', 'Carapace Ring',
             'Horn Ring', 'Horn Ring +1', 'Rajas Ring', 'Bowyer Ring', 'Beetle Ring',
             'Beetle Ring +1', 'Bone Ring', 'Bone Ring +1', 'Vision Ring' },
        Back  = { 'Charger Mantle', 'Gunner\'s Mantle', 'Jaeger Mantle', 'Psilos Mantle',
             'Amemet Mantle', 'Bushido Cape', 'Rep. Army Mantle', 'Bellicose Mantle',
             'Gramary Cape', 'Jaguar Mantle', 'Rearguard Mantle' },
        Waist = { 'Ninurta\'s Sash', 'Buccaneer\'s Belt', 'Corsair\'s Belt', 'Sonic Belt',
             'Sonic Belt +1', 'Bitter Corset', 'Speed Belt', 'R.K. Belt +1',
             'Swift Belt', 'Life Belt', 'Vanguard Belt', 'Quick Belt',
             'Mrc.Cpt. Belt', 'Acrobat\'s Belt', 'Barbarian\'s Belt', 'Brave belt' },
        Legs  = { 'Nashira Seraweels', 'Galliard Trousers', 'Armadillo Cuisses',
             'Feral Trousers', 'Tiger Trousers', 'Tabin Hose', 'Akinji Salvars',
             'Jaridah Salvars', 'War Hose', 'C.C. Slacks +1',
             'C.C. Slacks +2', 'Cmb.Cst. Slacks', 'Bastokan Cuisses',
             'Republic Cuisses', 'Custom Pants', 'Bastokan Subligar', 'Republic Subligar',
             'Garrison Hose' },
        Feet  = { 'Nashira Crackows', 'Dusk Ledelsens', 'Dusk Ledelsens +1', 'Rutter Sabatons',
             'Marid Leggings', 'Marid Leggings +1', 'Tabin Boots', 'Tabin Boots +1',
             'Akinji Nails', 'Bastokan Greaves', 'Republic Greaves', 'Federation Gaiters',
             'Custom F Boots', 'Custom M Boots', 'Savage Gaiters', 'Bounding Boots',
             'Leaping Boots' },
    },
    -- Out of combat in caster mode. Ordered for mitigation: the percentage of
    -- damage taken that a piece removes comes first, with defence counted at
    -- roughly fifteen points to the percent, and maximum HP breaking ties.
    -- The Earth staff goes on top, which is another physical damage taken -20%.
    ['Idle_Priority'] = {
        Head  = { 'Darksteel Cap +1', 'Coral Visor +1', 'Darksteel Cap', 'Blood Mask',
             'Crimson Mask', 'Coral Visor', 'Dusk Mask +1', 'Dusk Mask', 'Zenith Crown +1',
             'Zenith Crown', 'Elite Beret +1', 'Mahatma Hat', 'Carapace Helm +1',
             'Scorpion Helm +1', 'Dartorgor\'s Coif', 'Troll Coif', 'Beak Helm +1',
             'Akinji Khud', 'Scorpion Mask +1', 'Beak Helm', 'Jaridah Khud', 'Scorpion Mask',
             'T.M. Hat +2', 'Shock Mask', 'Dino Helm', 'Steel Visor +1', 'Raptor Helm',
             'Steel Visor', 'Wool Cap +1', 'Carapace Mask +1', 'Wool Cap', 'Carapace Mask',
             'Cuir Bandana +1', 'Iron Visor +1', 'Cuir Bandana', 'Iron Visor', 'Republic Visor',
             'Mage\'s Hat', 'Red Cap +1', 'Strong Cap', 'Brass Mask +1', 'Brass Mask',
             'Shade Tiara +1', 'Trump Crown', 'Wool Hat +1', 'Shade Tiara', 'Great Headgear',
             'Beetle Mask +1', 'Lizard Helm +1', 'Bone Mask +1', 'Kingdom Bandana',
             'Republic Cap', 'Bonze\'s Circlet', 'Lizard Helm', 'Bone Mask', 'San. Bandana' },
        Neck  = { 'Rho Necklace', 'Wivre Gorget +1', 'Ritter Gorget', 'Tempered Chain',
             'Wivre Gorget', 'Harmonia\'s Torque', 'Merman\'s Gorget', 'Torama Gorget',
             'Hateful Collar', 'Coeurl Gorget', 'Torque +1', 'Coral Gorget', 'Reraise Gorget',
             'Beak Necklace +1', 'Auditory Torque', 'Blue Gorget', 'Ajase Beads',
             'Brisingamen +1', 'Chivalrous Chain', 'Fortified Chain', 'Stoneskin Torque',
             'Torque', 'Carapace Gorget', 'Clay Amulet', 'Stone Gorget', 'Memento Muffler',
             'Wolf Gorget +1', 'Promise Badge', 'Qiqirn Collar', 'Brisingamen', 'Agile Gorget',
             'Medieval Collar', 'Wolf Gorget', 'Holy Phial', 'Hemp Gorget +1', 'Green Gorget',
             'Van Pendant', 'Paisley Scarf', 'M. No.17\'s Locket', 'Jagd Gorget',
             'Mohbwa Scarf +1', 'Tiger Stole', 'Hemp Gorget', 'Beetle Gorget',
             'Black Neckerchief', 'Scale Gorget', 'Feather Collar +1', 'Leather Gorget +1',
             'Green Scarf', 'Dog Collar', 'Feather Collar', 'Justice Badge', 'Shield Pendant',
             'Windurstian Scarf', 'Bloodbead Amulet', 'Grandiose Chain' },
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
        Body  = { 'Dst. Harness +1', 'Blood Scale Mail', 'Crm. Scale Mail',
             'Cor. Scale Mail +1', 'Darksteel Harness', 'Coral Scale Mail', 'Dusk Jerkin',
             'Vishnu\'s Vest', 'Dls. Tabard +1', 'Narasimha\'s Vest', 'Scp. Brstplate +1',
             'Dalmatica +1', 'Silk Cloak +1', 'Commodore Frac', 'Scp. Breastplate',
             'Cpc. Brstplate +1', 'Warlock\'s Tabard', 'Beak Jerkin +1', 'Shaman\'s Cloak',
             'Akinji Peti', 'Corsair\'s Frac', 'Beak Jerkin', 'R.K. Cloak +2', 'Jaridah Peti',
             'Stl. Scale Mail +1', 'Dino Jerkin', 'Steel Scale Mail', 'Raptor Jerkin',
             'C.C. Cloak +2', 'Brigandine +1', 'C.C. Cloak +1', 'Brigandine', 'Cuir Bouilli +1',
             'Iron Scale Mail +1', 'Cuir Bouilli', 'Iron Scale Mail', 'Cloak +1', 'Cloak',
             'Mana Cloak', 'Mage\'s Robe', 'Steam Scale Mail', 'Faerie Tunic',
             'Brs. Scale Mail +1', 'Brass Scale Mail', 'Shade Harness +1', 'Wool Robe +1',
             'Shade Harness', 'Mage\'s Tunic', 'Fine Jerkin', 'Garrison Tunica',
             'Lizard Jerkin', 'Bone Harness +1', 'Priest\'s Robe', 'Bone Harness',
             'Healing Harness', 'Kingdom Tunic' },
        Hands = { 'Merman\'s Bangles', 'Dst. Mittens +1', 'Coral Fng. Gnt. +1', 'Prt. Bangles',
             'Darksteel Mittens', 'Blood Fng. Gnt.', 'Crimson Fng. Gnt.', 'Coral Fng. Gnt.',
             'Dusk Gloves +1', 'Dusk Gloves', 'Mrc. Dastanas', 'Zenith Mitts +1',
             'Coral Bangles', 'Zenith Mitts', 'Barb. Moufles', 'Dragon Kote',
             'Cpc. Gauntlets +1', 'Magical Mitts', 'Warlock\'s Gloves', 'Storm Manopolas',
             'Light Gauntlets', 'Beak Gloves +1', 'Akinji Bazubands', 'Enkelados\'s Brc.',
             'Dino Gloves', 'Steel Fng. Gnt. +1', 'Raptor Gloves', 'Steel Fng. Gnt.',
             'Ogygos\'s Brc.', 'Wool Bracers +1', 'Turtle Bangles +1', 'Cpc. Mittens +1',
             'Cuir Gloves +1', 'Iron Fng. Gnt. +1', 'Rep. F. Gauntlets', 'Rubious Mitts',
             'Gigas Bracelets', 'Cuir Gloves', 'Mage\'s Cuffs', 'Iron Fng. Gnt.',
             'Brass Fng. Gnt. +1', 'Shade Mittens +1', 'Wool Cuffs +1', 'Brass Fng. Gnt.',
             'Shade Mittens', 'Great Gloves', 'Beetle Mittens +1', 'Custom F Gloves',
             'Fine Gloves', 'Kingdom Gloves', 'Republic Mittens', 'Lizard Gloves',
             'Bone Mittens +1', 'San. Gloves', 'Bastokan Mittens', 'Bone Mittens' },
        Ring1 = { 'Defending Ring', 'Sattva Ring', 'Jelly Ring', 'Gobniu\'s Ring',
             'Phalanx Ring', 'Unyielding Ring', 'Dragon Ring +1', 'Unfettered Ring',
             'Aegis Ring', 'Dragon Ring', 'Cerberus Ring +1', 'Adroit Ring +1', 'Cmn. Ring +1',
             'Hades Ring +1', 'Heavens Ring +1', 'Gld.Msk. Ring', 'Demon\'s Ring +1',
             'Tiger Ring', 'Allure Ring +1', 'Celerity Ring +1', 'Genius Ring +1',
             'Grace Ring +1', 'Kshama Ring No.4', 'Bloodbead Ring', 'Bomb Ring',
             'Demon\'s Ring', 'Marid Ring +1', 'Earth Ring', 'Marksman\'s Ring',
             'Alacrity Ring +1', 'Aura Ring +1', 'Deft Ring +1', 'Loyalty Ring +1',
             'Puissance Ring +1', 'Solace Ring +1', 'Leather Ring +1', 'Safeguard Ring',
             'San d\'Orian Ring', 'Armored Ring', 'Balance Ring +1', 'Courage Ring +1',
             'Energy Ring +1', 'Gold Ring +1', 'Gold Ring', 'Mythril Ring +1', 'Mythril Ring' },
        Ring2 = { 'Defending Ring', 'Sattva Ring', 'Jelly Ring', 'Gobniu\'s Ring',
             'Phalanx Ring', 'Unyielding Ring', 'Dragon Ring +1', 'Unfettered Ring',
             'Aegis Ring', 'Dragon Ring', 'Cerberus Ring +1', 'Adroit Ring +1', 'Cmn. Ring +1',
             'Hades Ring +1', 'Heavens Ring +1', 'Gld.Msk. Ring', 'Demon\'s Ring +1',
             'Tiger Ring', 'Allure Ring +1', 'Celerity Ring +1', 'Genius Ring +1',
             'Grace Ring +1', 'Kshama Ring No.4', 'Bloodbead Ring', 'Bomb Ring',
             'Demon\'s Ring', 'Marid Ring +1', 'Earth Ring', 'Marksman\'s Ring',
             'Alacrity Ring +1', 'Aura Ring +1', 'Deft Ring +1', 'Loyalty Ring +1',
             'Puissance Ring +1', 'Solace Ring +1', 'Leather Ring +1', 'Safeguard Ring',
             'San d\'Orian Ring', 'Armored Ring', 'Balance Ring +1', 'Courage Ring +1',
             'Energy Ring +1', 'Gold Ring +1', 'Gold Ring', 'Mythril Ring +1', 'Mythril Ring' },
        Back  = { 'Umbra Cape', 'Hexerei Cape', 'Cheviot Cape', 'Resentment Cape',
             'Shadow Mantle', 'Behem. Mantle +1', 'Cerb. Mantle +1', 'Behemoth Mantle',
             'Cerberus Mantle', 'Marid Mantle +1', 'Empwr. Mantle +1', 'Marid Mantle',
             'Mahatma Cape', 'Black Mantle +1', 'Feral Mantle', 'Desert Mantle +1',
             'Errant Cape', 'Beak Mantle +1', 'Ryl. Army Mantle', 'Cvl. Mantle +1',
             'Enhancing Mantle', 'Beak Mantle', 'Cvl. Mantle', 'Lightning Mantle',
             'Dino Mantle', 'Rep. Army Mantle', 'Fed. Army Mantle', 'Jester\'s Cape +1',
             'Volitional Mantle', 'Raptor Mantle', 'Bat Cape', 'Aurora Mantle +1',
             'Sentinel\'s Mantle', 'High Brth. Mantle', 'Lucent Cape', 'Aurora Mantle',
             'Ram Mantle', 'Ram Mantle +1', 'Wolf Mantle +1', 'Tundra Mantle', 'Black Cape +1',
             'Invisible Mantle', 'Wolf Mantle', 'Dhalmel Mantle +1', 'Breath Mantle',
             'Nomad\'s Mantle +1', 'Night Cape', 'Variable Mantle', 'Cotton Cape +1',
             'Dhalmel Mantle', 'Lizard Mantle +1', 'Mist Silk Cape', 'Nomad\'s Mantle',
             'Variable Cape', 'Cotton Cape', 'Talisman Cape' },
        Waist = { 'Lieutenant\'s Sash', 'Forest Rope', 'Kaiser Belt', 'Marid Belt +1',
             'Star Sash', 'Desert Sash', 'Forest Sash', 'Marid Belt', 'Czar\'s Belt',
             'Koenigs Belt', 'Maharaja\'s Belt', 'Pendragon\'s Belt', 'Sultan\'s Belt',
             'Anrin Obi', 'Dorin Obi', 'R.K. Belt +2', 'Earth Belt', 'R.K. Belt +1',
             'Desert Belt', 'Forest Belt', 'Twinthread Obi +1', 'Ryl.Kgt. Belt',
             'Brocade Obi +1', 'Swordbelt +1', 'Corsette +1', 'Qiqirn Sash +1', 'Astral Rope',
             'Jungle Belt', 'Brocade Obi', 'Swordbelt', 'Corsette', 'Qiqirn Sash',
             'Gold Obi +1', 'Silver Belt +1', 'Survival Belt', 'Force Belt', 'Oracle\'s Belt',
             'Deduct. Gold Obi', 'Enthrall. Gold Obi', 'Gold Obi', 'Sagac. Gold Obi',
             'Mohbwa Sash +1', 'Silver Obi +1', 'Brave Belt', 'Magic Belt +1', 'Lizard Belt +1',
             'Warrior\'s Belt +1', 'Shaman\'s Belt', 'Mohbwa Sash', 'Silver Obi',
             'Acrobat\'s Belt', 'Barbarian\'s Belt', 'Magic Belt' },
        Legs  = { 'Goliard Trews', 'Dst. Subligar +1', 'Coral Cuisses +1', 'Darksteel Subligar',
             'Coral Cuisses', 'Bahamut\'s Hose', 'Dusk Trousers +1', 'Dusk Trousers',
             'Blood Cuisses', 'Crimson Cuisses', 'Zenith Slacks +1', 'Prince\'s Slops',
             'Warlock\'s Tights', 'Beak Trousers +1', 'Akinji Salvars', 'Feral Trousers',
             'Beak Trousers', 'Femina Subligar', 'Vir Subligar', 'Jaridah Salvars',
             'Scp. Subligar +1', 'Tiger Trousers', 'Luna Subligar', 'Battle Hose +1',
             'Dino Trousers', 'Magic Cuisses', 'Ice Trousers', 'Raptor Trousers',
             'Wool Hose +1', 'Cpc. Subligar +1', 'Blaze Hose', 'Wool Hose', 'Cuir Trousers +1',
             'Cuir Trousers', 'Mage\'s Slops', 'Hose +1', 'Iron Subligar +1',
             'Republic Cuisses', 'Velvet Slops', 'Hose', 'Brass Cuisses +1', 'Brass Cuisses',
             'Shade Tights +1', 'Wool Slops +1', 'Kingdom Trousers', 'Shade Tights',
             'Wool Slops', 'Republic Subligar', 'Fine Trousers', 'Bone Subligar +1',
             'Lizard Trousers', 'Bone Subligar', 'Angler\'s Hose', 'Nomad\'s Hose',
             'Rider\'s Hose', 'Worker Hose' },
        Feet  = { 'Dst. Leggings +1', 'Coral Greaves +1', 'Dst. Leggings', 'Blood Greaves',
             'Dusk Ledelsens +1', 'Crimson Greaves', 'Coral Greaves', 'Dusk Ledelsens',
             'Zenith Pumps +1', 'Zenith Pumps', 'Goliard Clogs', 'Mahatma Pigaches',
             'Root Sabots', 'Rutter Sabatons', 'Marid Leggings +1', 'Ataractic Solea',
             'Bk. Ledelsens +1', 'Warlock\'s Boots', 'Akinji Nails', 'Scp. Leggings +1',
             'Battle Boots +1', 'Tabin Boots +1', 'Beak Ledelsens', 'Jaridah Nails',
             'Dino Ledelsens', 'Steel Greaves +1', 'Raptor Ledelsens', 'Wool Socks +1',
             'Steel Greaves', 'Cpc. Leggings +1', 'Wool Socks', 'Cpc. Leggings',
             'Cuir Highboots +1', 'Powder Boots', 'Iron Greaves +1', 'Republic Greaves',
             'Cuir Highboots', 'Ebony Sabots +1', 'Iron Greaves', 'Socks +1', 'Kingdom Clogs',
             'Brass Greaves +1', 'Shade Leggings +1', 'San d\'Orian Clogs', 'Air Solea +1',
             'Chs. Sabots +1', 'Brass Greaves', 'Shade Leggings', 'Kingdom Boots',
             'Fine Ledelsens', 'Bone Leggings +1', 'San d\'Orian Boots', 'Republic Leggings',
             'Garrison Boots', 'Lizard Ledelsens', 'Bone Leggings' },
    },
    -- Fast cast, worn during the precast phase of every spell.
    ['Precast_Priority'] = {
        Head  = { 'Wlk. Chapeau +1', 'Warlock\'s Chapeau' },
        Ear1  = { 'Loquac. Earring' },
        Ear2  = { 'Loquac. Earring' },
        Body  = { 'Dls. Tabard +1', 'Duelist\'s Tabard' },
    },
    -- Enfeebling midcast (magic accuracy, MND/INT).
    ['Enfeebling_Priority'] = {
        Head  = { 'Morrigan\'s Coron.', 'Dls. Chapeau +1', 'Duelist\'s Chapeau',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Super Ribbon',
             'T.M. Hat +1', 'Storm Zucchetto', 'Neit\'s Crown', 'Rain Hat',
             'Sinister Mask', 'Macha\'s Crown', 'Eld. Horn Hairpin', 'Bodb\'s Crown',
             'Baron\'s Chapeau', 'Garrison Sallet', 'Bastokan Cap', 'Eld. Bone Hairpin' },
        Neck  = { 'Prudence Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Enfeebling Torque', 'Lieut. Gorget', 'Spider Torque', 'Stoneskin Torque',
             'Torque', 'Torque +1', 'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1',
             'Holy Phial', 'Fang Necklace', 'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Abyssal Earring', 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Diabolos\'s Earring', 'Desamilion Earring', 'Gayanj\'s Earring',
             'Ryakho\'s Earring', 'Boroka Earring', 'Harvest Earring', 'Heims Earring',
             'Geist Earring', 'Enfeebling Earring', 'Morion Earring', 'Cunning Earring' },
        Ear2  = { 'Abyssal Earring', 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Diabolos\'s Earring', 'Desamilion Earring', 'Gayanj\'s Earring',
             'Ryakho\'s Earring', 'Boroka Earring', 'Harvest Earring', 'Heims Earring',
             'Geist Earring', 'Enfeebling Earring', 'Morion Earring', 'Cunning Earring' },
        Body  = { 'Nashira Manteel', 'Shadow Coat', 'Valkyrie\'s Coat', 'Blue Cotehardie',
             'Blue Cotehard. +1', 'Warlock\'s Tabard', 'Shaman\'s Cloak', 'Glamor Jupon',
             'Brigandine +1', 'C.C. Cloak +1', 'C.C. Cloak +2',
             'Mage\'s Robe', 'Macha\'s Coat', 'Bishop\'s Robe', 'Bodb\'s Robe', 'Baron\'s Saio',
             'Black Tunic', 'Priest\'s Robe', 'Kingdom Tunic', 'San d\'Orian Tunic' },
        Hands = { 'Shadow Cuffs', 'Valkyrie\'s Cuffs', 'Goliard Cuffs',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Marine F Gloves', 'Magi Cuffs',
             'Silk Cuffs +1', 'Mage\'s Mitts', 'Engineer\'s Gloves', 'Sennight Bangles',
             'Devotee\'s Mitts', 'Elder\'s Bracers', 'Magna Gauntlets', 'Zealot\'s Mitts' },
        Ring1 = { 'Dark Ring', 'Flame Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 9', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malflood Ring', 'Tamas Ring', 'Carect Ring', 'Clear Ring', 'Knowledge Ring',
             'Kldg. Ring +1' },
        Ring2 = { 'Dark Ring', 'Flame Ring', 'Insect Ring', 'Serene Ring', 'Vivian Ring',
             'Gnd.Kgt. Ring', 'Zoredonite Ring', 'Balrahn\'s Ring', 'Hale Ring',
             'Kshama Ring No. 5', 'Kshama Ring No. 9', 'Vilma\'s Ring', 'Goshenite Ring',
             'Malflood Ring', 'Tamas Ring', 'Carect Ring', 'Clear Ring', 'Knowledge Ring',
             'Kldg. Ring +1' },
        Back  = { 'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Sapient Cape',
             'Miraculous Cape', 'Fed. Army Mantle', 'Ryl. Army Mantle', 'Gramary Cape',
             'Red Cape', 'Red Cape +1', 'Black Cape', 'Black Cape +1', 'White Cape',
             'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Arachne Obi', 'Bitter Corset',
             'Penitent\'s Rope', 'R.K. Belt +1', 'R.K. Belt +2',
             'Jungle Stone', 'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt',
             'Deduct. Gold Obi', 'Mrc.Cpt. Belt', 'Shaman\'s Belt',
             'Friar\'s Rope' },
        Legs  = { 'Nashira Seraweels', 'Shadow Trews', 'Valkyrie\'s Trews', 'Warlock\'s Tights',
             'T.M. Slops +1', 'T.M. Slops +2',
             'Magic Cuisses', 'Macha\'s Slops', 'Custom Pants', 'Custom Slacks',
             'Bodb\'s Slops', 'Mage\'s Slacks' },
        Feet  = { 'Goliard Clogs', 'Shadow Clogs', 'Valkyrie\'s Clogs', 'Marine F Boots',
             'Marine M Boots', 'River Gaiters', 'Warlock\'s Boots',
             'T.M. Pigaches +1', 'T.M. Pigaches +2',
             'Inferno Sabots', 'Inferno Sabots +1', 'Mountain Gaiters', 'Mannequin Pumps',
             'Custom F Boots', 'Custom M Boots', 'Elder\'s Sandals', 'Garrison Boots' },
    },
    -- Enhancing midcast (enhancing magic skill).
    ['Enhancing_Priority'] = {
        Head  = { 'Dls. Chapeau +1', 'Goliard Chapeau', 'Morrigan\'s Coron.',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1',
             'Super Ribbon', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Circe\'s Hat',
             'Eld. Horn Hairpin', 'Garrison Sallet', 'Traveler\'s Hat',
             'Eld. Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Enhancing Torque', 'Enlightened Chain', 'Stoneskin Torque', 'Torque', 'Torque +1',
             'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Holy Phial', 'Fang Necklace',
             'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Cmn. Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augment. Earring' },
        Ear2  = { 'Static Earring', 'Celestial Earring', 'Cmn. Earring',
             'Cmn. Earring +1', 'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring',
             'Augment. Earring' },
        Body  = { 'Morrigan\'s Robe', 'Blood Scale Mail', 'Crm. Scale Mail',
             'Blue Cotehardie', 'Blue Cotehard. +1', 'Black Cotehardie', 'Flora Cotehardie',
             'Glamor Jupon', 'Brigandine +1', 'C.C. Cloak +1',
             'C.C. Cloak +2', 'Bishop\'s Robe', 'Bishop\'s Robe +1',
             'Macha\'s Coat', 'Baron\'s Saio', 'Priest\'s Robe' },
        Hands = { 'Dls. Gloves +1', 'Wlk. Gloves +1', 'Duelist\'s Gloves',
             'Dragon Kote', 'Mst.Cst. Bracelets', 'Dune Bracers', 'Magi Cuffs',
             'Silk Cuffs +1', 'Devotee\'s Mitts', 'Savage Gauntlets', 'Baron\'s Cuffs',
             'Zealot\'s Mitts' },
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
             'Deduct. Broc. Obi', 'Penitent\'s Rope', 'Grace Corset',
             'R.K. Belt +1', 'R.K. Belt +2', 'Reverend Sash',
             'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Deduct. Gold Obi',
             'Mrc.Cpt. Belt', 'Friar\'s Rope' },
        Legs  = { 'Galliard Trousers', 'Morrigan\'s Slops', 'Wlk. Tights +1',
             'Warlock\'s Tights', 'T.M. Slops +1',
             'T.M. Slops +2', 'Magic Cuisses', 'Macha\'s Slops',
             'Custom Pants', 'Custom Slacks' },
        Feet  = { 'Dls. Boots +1', 'Goliard Clogs', 'Morrigan\'s Pgch.',
             'Marine F Boots', 'Marine M Boots', 'River Gaiters', 'Warlock\'s Boots',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Garrison Boots' },
    },
    -- Cure midcast (MND, healing magic skill).
    ['Cure_Priority'] = {
        Head  = { 'Dls. Chapeau +1', 'Goliard Chapeau', 'Morrigan\'s Coron.',
             'Opo-opo Crown', 'Mushroom Helm', 'Magus Keffiyeh', 'Magi Hat', 'Silk Hat +1',
             'Super Ribbon', 'Neit\'s Crown', 'Rain Hat', 'Sinister Mask', 'Circe\'s Hat',
             'Eld. Horn Hairpin', 'Garrison Sallet', 'Traveler\'s Hat',
             'Eld. Bone Hairpin' },
        Neck  = { 'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker',
             'Healing Torque', 'Enlightened Chain', 'Stoneskin Torque', 'Torque', 'Torque +1',
             'Promise Badge', 'Mohbwa Scarf', 'Mohbwa Scarf +1', 'Holy Phial', 'Fang Necklace',
             'Spike Necklace', 'Justice Badge' },
        Ear1  = { 'Magnetic Earring', 'Static Earring', 'Celestial Earring',
             'Cmn. Earring', 'Cmn. Earring +1', 'Ryakho\'s Earring',
             'Harvest Earring', 'Geist Earring', 'Healing Earring' },
        Ear2  = { 'Magnetic Earring', 'Static Earring', 'Celestial Earring',
             'Cmn. Earring', 'Cmn. Earring +1', 'Ryakho\'s Earring',
             'Harvest Earring', 'Geist Earring', 'Healing Earring' },
        Body  = { 'Dls. Tabard +1', 'Nashira Manteel', 'Duelist\'s Tabard',
             'Blue Cotehardie', 'Blue Cotehard. +1', 'Black Cotehardie', 'Flora Cotehardie',
             'Healing Jstcorps', 'Brigandine +1', 'C.C. Cloak +1',
             'C.C. Cloak +2', 'Bishop\'s Robe', 'Bishop\'s Robe +1',
             'Macha\'s Coat', 'Baron\'s Saio', 'Priest\'s Robe' },
        Hands = { 'Wlk. Gloves +1', 'Wise Gloves', 'Wise Gloves +1', 'Dragon Kote',
             'Mst.Cst. Bracelets', 'Dune Bracers', 'Magi Cuffs', 'Silk Cuffs +1',
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
             'Sapient Cape', 'Ryl. Army Mantle', 'Red Cape', 'Red Cape +1', 'White Cape',
             'White Cape +1', 'Mist Silk Cape' },
        Waist = { 'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt',
             'Deduct. Broc. Obi', 'Penitent\'s Rope', 'Grace Corset',
             'R.K. Belt +1', 'R.K. Belt +2', 'Reverend Sash',
             'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Deduct. Gold Obi',
             'Mrc.Cpt. Belt', 'Friar\'s Rope' },
        Legs  = { 'Galliard Trousers', 'Morrigan\'s Slops', 'Wlk. Tights +1',
             'Druid\'s Slops', 'Warlock\'s Tights', 'T.M. Slops +1',
             'T.M. Slops +2', 'Magic Cuisses', 'Macha\'s Slops',
             'Custom Pants', 'Custom Slacks' },
        Feet  = { 'Dls. Boots +1', 'Goliard Clogs', 'Morrigan\'s Pgch.',
             'Marine F Boots', 'Marine M Boots', 'River Gaiters', 'Warlock\'s Boots',
             'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots', 'Garrison Boots' },
    },
    -- Melee weapon and shield for melee mode. Swords are weighted first:
    -- RDM's sword skill beats its club and dagger.
    ['Weapon_Priority'] = {
        Main  = { 'Excalibur', 'Murgleis', 'Mighty Talwar', 'Aquan Slayer', 'Insect Slayer',
             'Vermin Slayer', 'Nightmare Sword', 'Enhancing Sword', 'Epee', 'Epee +1',
             'Macuahuitl', 'Macuahuitl +1', 'Phantom Fleuret', 'Macuahuitl -1',
             'Aramis\'s Rapier', 'Cermet Sword', 'Cermet Sword +1', 'Ryl.Grd. Fleuret',
             'Wis.Wiz. Anelace', 'Temple Knight Sword +1', 'Temple Knight Sword +2',
             'Crimson Blade', 'Knight\'s Sword', 'Knight\'s Sword +1', 'Ancient Sword',
             'Jr.Msk. Tuck +1', 'Immortal\'s Scimitar', 'Buzzard Tuck',
             'Divine Sword', 'Divine Sword +1', 'Bastokan Sword', 'Republic Sword',
             'Centurion\'s Sword', 'Steel Kilij', 'Steel Kilij +1', 'Gladiator', 'Gladius',
             'Tuck', 'Tuck +1', 'Kaiser Sword', 'Degen', 'Degen +1', 'Auriga Xiphos',
             'Small Sword', 'Fire Sword', 'Flame Sword', 'Iron Sword', 'Bee Spatha +1',
             'Wax Sword +1' },
        Sub   = { 'Acheron Shield', 'Acheron Shield +1', 'Genbu\'s Shield', 'Muse Tariqah',
             'Tariqah', 'Tariqah +1', 'Tariqah -1', 'Dominus Shield', 'Numinous Shield',
             'Nms. Shield +1', 'Astral Aspis', 'Gilt Buckler', 'Gold Buckler',
             'Round Shield', 'Darksteel Buckler', 'Spiked Buckler', 'Astral Shield',
             'Flame Shield', 'Msk.Cmd. Shield', 'Hoplon', 'Sentinel Shield',
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
    common.EvaluateGear(staves.Sets, level);

    common.EvalLevel(level);
end

profile.OnLoad = function()
    gSettings.AllowAddSet = true;
    AshitaCore:GetChatManager():QueueCommand(-1, '/alias /rdm /lac fwd');

    AshitaCore:GetChatManager():QueueCommand(-1, '/macro book ' .. Settings.MacroBook);

    -- Lock appearance a few seconds after loading
    common.RequestLockStyle(1);
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
