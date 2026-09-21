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
    -- Out of combat in caster mode, where the point is getting MP back.
    -- Maximum MP leads, and mitigation settles pieces carrying the same MP:
    -- the percentage of damage taken a piece removes, with defence counted
    -- at roughly fifteen points to the percent. Refresh breaks what is still
    -- level. The Earth staff goes on top, which is physical damage taken -20%.
    ['Idle_Priority'] = {
        Head  = { 'Zenith Crown +1', 'Faerie Hairpin', 'Zenith Crown', 'Wivre Hairpin +1',
             'Valkyrie\'s Hat', 'Wivre Hairpin', 'Shadow Hat', 'Gold Hairpin +1',
             'Walahra Turban', 'Carline Ribbon', 'Gold Hairpin', 'Magus Keffiyeh +1',
             'Curate\'s Hat', 'Electrum Hairpin', 'Merman\'s Hairpin', 'Mana Circlet',
             'Coral Hairpin', 'Reraise Hairpin', 'Magus Keffiyeh', 'Warlock\'s Chapeau',
             'Kosshin', 'Rain Hat', 'Magi Hat', 'Silken Hat', 'Storm Turban', 'Rival Ribbon',
             'Silver Hairpin +1', 'Silver Hairpin', 'Trump Crown', 'Horn Hairpin +1',
             'Eld. Horn Hairpin', 'Horn Hairpin', 'Brass Hairpin +1', 'Valkyrie\'s Mask',
             'Shell Hairpin +1', 'Brass Hairpin', 'Shell Hairpin', 'Republic Visor',
             'Circe\'s Hat', 'Copper Hairpin +1', 'Bastokan Visor', 'Lgn. Circlet',
             'Super Ribbon', 'Copper Hairpin', 'Bone Hairpin +1', 'Republic Cap',
             'Bodb\'s Crown', 'Dino Helm', 'Steel Visor +1', 'Raptor Helm', 'Steel Visor',
             'Wool Cap +1', 'Brass Mask +1', 'Brass Mask', 'Shade Tiara +1', 'Wool Hat +1' },
        Neck  = { 'Rep.Gold Medal', 'Morgana\'s Choker', 'Beak Necklace +1', 'Beak Necklace',
             'Chi Necklace', 'Uggalepih Pendant', 'Star Necklace', 'Rep.Mythril Medal',
             'M. No.17\'s Locket', 'Grandiose Chain', 'Spirit Torque', 'Holy Phial',
             'Jagd Gorget', 'Mohbwa Scarf +1', 'Rep.Iron Medal', 'Mohbwa Scarf',
             'Rep.Bronze Medal', 'Rho Necklace', 'Wivre Gorget +1', 'Ritter Gorget',
             'Tempered Chain', 'Wivre Gorget', 'Harmonia\'s Torque', 'Merman\'s Gorget',
             'Torama Gorget', 'Hateful Collar', 'Coeurl Gorget', 'Torque +1', 'Coral Gorget',
             'Auditory Torque', 'Blue Gorget', 'Ajase Beads', 'Chivalrous Chain',
             'Fortified Chain', 'Carapace Gorget', 'Clay Amulet', 'Stone Gorget',
             'Memento Muffler', 'Wolf Gorget +1', 'Promise Badge', 'Medieval Collar',
             'Wolf Gorget', 'Hemp Gorget +1', 'Green Gorget', 'Van Pendant', 'Tiger Stole',
             'Hemp Gorget', 'Beetle Gorget', 'Black Neckerchief', 'Scale Gorget',
             'Feather Collar +1', 'Leather Gorget +1', 'Green Scarf', 'Dog Collar',
             'Feather Collar', 'Bloodbead Amulet' },
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
        Body  = { 'Dalmatica +1', 'Dalmatica', 'Blue Cotehard. +1', 'Blood Scale Mail',
             'Goliard Saio', 'Crm. Scale Mail', 'Hydra Doublet', 'Blue Cotehardie',
             'Wlk. Tabard +1', 'Elder\'s Surcoat', 'Dls. Tabard +1', 'Flora Cotehardie',
             'Shaman\'s Cloak', 'Black Cotehardie', 'Magi Coat', 'Silken Coat', 'T.M. Coat +2',
             'T.M. Coat +1', 'Warlock\'s Tabard', 'Ryl.Sqr. Robe +2', 'Ryl.Sqr. Robe +1',
             'Ryl.Sqr. Robe', 'Pyro Robe', 'Frost Robe', 'Kingdom Tunic', 'Bishop\'s Robe +1',
             'Magna Bodice', 'Magna Jerkin', 'San d\'Orian Tunic', 'Mage\'s Robe',
             'Bishop\'s Robe', 'Republic Harness', 'Bastokan Harness', 'Dst. Harness +1',
             'Cor. Scale Mail +1', 'Darksteel Harness', 'Coral Scale Mail', 'Scp. Brstplate +1',
             'Silk Cloak +1', 'Stl. Scale Mail +1', 'Dino Jerkin', 'Steel Scale Mail',
             'Raptor Jerkin', 'Cuir Bouilli +1', 'Steam Scale Mail', 'Faerie Tunic',
             'Brs. Scale Mail +1', 'Brass Scale Mail', 'Shade Harness +1', 'Wool Robe +1',
             'Shade Harness', 'Mage\'s Tunic', 'Fine Jerkin', 'Garrison Tunica',
             'Lizard Jerkin', 'Bone Harness +1' },
        Hands = { 'Dune Bracers', 'Zenith Mitts +1', 'Wood Gauntlets', 'Wood Gloves',
             'Zenith Mitts', 'Marine F Gloves', 'Marine M Gloves', 'Elder\'s Bracers',
             'Dragon Kote', 'Morrigan\'s Cuffs', 'Mahatma Cuffs', 'Magna Gauntlets',
             'Magna Gloves', 'Dls. Gloves +1', 'Blood Fng. Gnt.', 'Storm Gages',
             'Crimson Fng. Gnt.', 'Errant Cuffs', 'Magical Mitts', 'Savage Gauntlets',
             'Magi Cuffs', 'Warlock\'s Gloves', 'Silken Cuffs', 'New Moon Armlets',
             'Devotee\'s Mitts', 'Zealot\'s Mitts', 'Custom F Gloves', 'Custom M Gloves',
             'Baron\'s Cuffs', 'Republic Mittens', 'Bastokan Mittens', 'Macha\'s Cuffs',
             'Nemain\'s Cuffs', 'Merman\'s Bangles', 'Dst. Mittens +1', 'Prt. Bangles',
             'Storm Manopolas', 'Light Gauntlets', 'Dino Gloves', 'Steel Fng. Gnt. +1',
             'Raptor Gloves', 'Steel Fng. Gnt.', 'Ogygos\'s Brc.', 'Wool Bracers +1',
             'Turtle Bangles +1', 'Cpc. Mittens +1', 'Cuir Gloves +1', 'Iron Fng. Gnt. +1',
             'Rep. F. Gauntlets', 'Rubious Mitts', 'Gigas Bracelets', 'Cuir Gloves',
             'Fine Gloves', 'Kingdom Gloves', 'Lizard Gloves', 'Bone Mittens +1' },
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
        Back  = { 'Mahatma Cape', 'Errant Cape', 'Birdman Cape', 'Intensifying Cape',
             'Storm Cape', 'Lamia Mantle +1', 'Altruistic Cape', 'Astute Cape', 'Merciful Cape',
             'Lamia Mantle', 'Lieutenant\'s Cape', 'Aslan Cape', 'Erato\'s Cape',
             'Empwr. Mantle +1', 'Miraculous Cape', 'Aurora Mantle +1', 'Talisman Cape',
             'Empwr. Mantle', 'Enhancing Mantle', 'Aurora Mantle', 'Lucent Cape',
             'Esoteric Mantle', 'Fed. Army Mantle', 'Tundra Mantle', 'Invigorating Cape',
             'Resentment Cape', 'Beak Mantle +1', 'Ryl. Army Mantle', 'Cvl. Mantle +1',
             'Beak Mantle', 'Cvl. Mantle', 'Lightning Mantle', 'Dino Mantle',
             'Volitional Mantle', 'Raptor Mantle', 'Bat Cape', 'Sentinel\'s Mantle',
             'High Brth. Mantle', 'Ram Mantle', 'Ram Mantle +1', 'Wolf Mantle +1',
             'Black Cape +1', 'Invisible Mantle', 'Wolf Mantle', 'Dhalmel Mantle +1',
             'Breath Mantle', 'Nomad\'s Mantle +1', 'Night Cape', 'Variable Mantle',
             'Cotton Cape +1', 'Dhalmel Mantle', 'Lizard Mantle +1', 'Mist Silk Cape',
             'Nomad\'s Mantle', 'Variable Cape', 'Cotton Cape' },
        Waist = { 'Forest Rope', 'Desert Rope', 'Lambda Sash', 'Hierarch Belt', 'Jungle Rope',
             'Ocean Rope', 'Desert Stone', 'Forest Stone', 'Steppe Rope', 'Jungle Stone',
             'Ocean Stone', 'Immortal\'s Sash', 'Grace Corset', 'Steppe Stone', 'Storm Sash',
             'Powerful Rope', 'Lieutenant\'s Sash', 'Astral Rope', 'Qiqirn Sash +1',
             'Qiqirn Sash', 'Mohbwa Sash +1', 'Talisman Obi', 'Spectral Belt', 'Hojutsu Belt',
             'Mohbwa Sash', 'Adept\'s Rope', 'Oracle\'s Belt', 'Magic Belt +1',
             'Shaman\'s Belt', 'Friar\'s Rope', 'Force Belt', 'Magic Belt', 'Kaiser Belt',
             'Czar\'s Belt', 'Koenigs Belt', 'Maharaja\'s Belt', 'Pendragon\'s Belt',
             'Sultan\'s Belt', 'Brocade Obi +1', 'Swordbelt +1', 'Corsette +1', 'Brocade Obi',
             'Gold Obi +1', 'Silver Belt +1', 'Survival Belt', 'Deduct. Gold Obi',
             'Enthrall. Gold Obi', 'Gold Obi', 'Silver Obi +1', 'Brave Belt', 'Lizard Belt +1',
             'Warrior\'s Belt +1', 'Silver Obi' },
        Legs  = { 'Zenith Slacks +1', 'Zenith Slacks', 'Custom Pants', 'Custom Slacks',
             'Savage Loincloth', 'Prince\'s Slops', 'Goliard Trews', 'Blood Cuisses',
             'Crimson Cuisses', 'Vendor\'s Slops', 'Yigit Seraweels', 'Frog Trousers',
             'Elder\'s Braguette', 'Warlock\'s Tights', 'Magna F Chausses', 'Magna M Chausses',
             'Magi Slops', 'Silken Slops', 'Scorpius Subligar', 'Sturdy Slacks',
             'Federation Slops', 'Freesword\'s Slops', 'Windurstian Slops', 'Mage\'s Slops',
             'Macha\'s Slops', 'Bodb\'s Slops', 'Nemain\'s Slops', 'Dst. Subligar +1',
             'Coral Cuisses +1', 'Darksteel Subligar', 'Coral Cuisses', 'Beak Trousers +1',
             'Akinji Salvars', 'Feral Trousers', 'Beak Trousers', 'Femina Subligar',
             'Tiger Trousers', 'Luna Subligar', 'Battle Hose +1', 'Dino Trousers',
             'Magic Cuisses', 'Ice Trousers', 'Raptor Trousers', 'Wool Hose +1',
             'Cpc. Subligar +1', 'Blaze Hose', 'Brass Cuisses +1', 'Brass Cuisses',
             'Shade Tights +1', 'Wool Slops +1', 'Kingdom Trousers', 'Shade Tights',
             'Wool Slops', 'Fine Trousers', 'Bone Subligar +1', 'Lizard Trousers' },
        Feet  = { 'Zenith Pumps +1', 'Zenith Pumps', 'River Gaiters', 'Wood F Ledelsens',
             'Wood M Ledelsens', 'Mahatma Pigaches', 'Ataractic Solea', 'Morrigan\'s Pgch.',
             'Errant Pigaches', 'Mgn. F Ledelsens', 'Mgn. M Ledelsens', 'Arborist Nails',
             'Blood Greaves', 'Wlk. Boots +1', 'Magi Pigaches', 'Inferno Sabots +1',
             'Silken Pigaches', 'Mannequin Pumps', 'Custom F Boots', 'Custom M Boots',
             'Elder\'s Sandals', 'Warlock\'s Boots', 'Inferno Sabots', 'Kingdom Clogs',
             'San d\'Orian Clogs', 'Baron\'s Pigaches', 'Republic Leggings', 'Bas. Leggings',
             'Macha\'s Pigaches', 'Nemain\'s Sabots', 'Dst. Leggings +1', 'Coral Greaves +1',
             'Dst. Leggings', 'Coral Greaves', 'Bk. Ledelsens +1', 'Akinji Nails',
             'Scp. Leggings +1', 'Battle Boots +1', 'Tabin Boots +1', 'Dino Ledelsens',
             'Steel Greaves +1', 'Raptor Ledelsens', 'Wool Socks +1', 'Steel Greaves',
             'Cpc. Leggings +1', 'Cuir Highboots +1', 'Powder Boots', 'Iron Greaves +1',
             'Republic Greaves', 'Cuir Highboots', 'Ebony Sabots +1', 'Kingdom Boots',
             'Fine Ledelsens', 'Bone Leggings +1', 'San d\'Orian Boots', 'Garrison Boots' },
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
