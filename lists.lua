-- Priority slot lists shared by more than one job.
--
-- These are the slots where two or more profiles had reached exactly the same
-- ordering: accessories and a few generic armour pieces that carry no job
-- restriction, so the best piece for the job is simply the best piece. They
-- lived as byte-identical copies in each file, which meant a re-ordering had
-- to be repeated everywhere or the jobs quietly drifted apart.
--
-- A job references a list by dropping it straight into its slot:
--
--     Ear1  = lists.TP.Ear,
--     Ear2  = lists.TP.Ear,
--
-- The framework only ever reads a _Priority list (gFunc.EvaluateLevels and
-- common.EvaluateOwned both build a fresh table and never touch the source),
-- so handing the same table to two slots, or to two jobs, is safe.
--
-- EDITING ONE OF THESE CHANGES EVERY JOB LISTED ABOVE IT. That is the point:
-- these orderings are job-independent. When one job genuinely wants a
-- different order, give that job its own inline list rather than bending the
-- shared one -- and drop the job from the comment here.

local lists = {};

-- Idle -- out of combat, where the point is getting MP back. Maximum MP
-- leads, and mitigation settles pieces carrying the same MP.
lists.Idle = {
    -- Used by: BLM, RDM, WHM
    Ear = {
        'Loquac. Earring', 'Zedoma\'s Earring', 'Astral Earring', 'Celestial Earring',
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
        'Stoic Earring', 'Ethereal Earring', 'Shield Earring'
    },

    -- Used by: RDM, WHM
    Ring = {
        'Vivian Ring', 'Serket Ring', 'Ether Ring', 'Variable Ring', 'Vilma\'s Ring',
        'Astral Ring', 'Dark Ring', 'Celestial Ring', 'Star Ring', 'Zoredonite Ring',
        'Carect Ring', 'Electrum Ring', 'Ebullient Ring', 'Mana Ring', 'Tamas Ring',
        'Serene Ring', 'Demon\'s Ring +1', 'Hades Ring +1', 'Demon\'s Ring', 'Poseidon\'s Ring',
        'Horizon Ring', 'Peace Ring', 'Fasting Ring', 'Mystic Ring +1', 'Hades Ring',
        'Manashell Ring', 'Death Ring', 'Aura Ring +1', 'Mystic Ring', 'Painite Ring',
        'Kshama Ring No.6', 'Energy Ring +1', 'Kshama Ring No.5', 'Kshama Ring No.9',
        'Aura Ring', 'Black Ring', 'Energy Ring', 'Windurstian Ring', 'Onyx Ring',
        'Defending Ring', 'Sattva Ring', 'Jelly Ring', 'Gobniu\'s Ring', 'Dragon Ring +1',
        'Aegis Ring', 'Gld.Msk. Ring', 'Kshama Ring No.4', 'Bomb Ring', 'Alacrity Ring +1',
        'Deft Ring +1', 'Mythril Ring', 'Mythril Ring +1'
    },
};

-- TP -- melee, worn while engaged.
lists.TP = {
    -- Used by: BLM, SMN
    Neck = {
        'Diabolos\'s Torque', 'Chanoix\'s Gorget', 'Wivre Gorget', 'Sniper\'s Collar',
        'Grand T.K. Collar', 'Chivalrous Chain', 'Ashura Necklace', 'Storm Gorget',
        'Peacock Amulet', 'Peacock Charm', 'Tiger Stole', 'Fang Necklace', 'Spike Necklace',
        'Feather Collar +1'
    },

    -- Used by: BLM, SMN, WHM
    Ear = {
        'Beta Earring', 'Hollow Earring', 'Beastly Earring', 'Diabolos\'s Earring',
        'Magnifying Earring', 'Minuet Earring', 'Bitter Earring', 'Accurate Earring',
        'Vision Earring', 'Gold Earring', 'Gold Earring +1', 'Tortoise Earring',
        'Mythril Earring +1', 'Reraise Earring', 'Beetle Earring', 'Bone Earring',
        'Bone Earring +1', 'Optical Earring'
    },

    -- Generic and crafted hands: neither job has melee hands of its own.
    -- Used by: SMN, WHM
    Hands = {
        'Nashira Gages', 'Goliard Cuffs', 'Pantin Dastanas +1', 'Tabin Bracers',
        'Tabin Bracers +1', 'Battle Bracers', 'T.M. Cuffs +1', 'T.M. Cuffs +2',
        'Aiming Bracelets', 'C.C. Mitts +1', 'C.C. Mitts +2', 'Cmb.Cst. Mitts',
        'Sennight Bangles', 'Federation Gloves', 'Win. Gloves', 'Custom F Gloves',
        'Custom M Gloves', 'Magna Gauntlets', 'Battle Gloves', 'Linen Cuffs +1'
    },

    -- Used by: BLM, SMN, WHM
    Ring = {
        'Bellona\'s Ring', 'Mars\'s Ring', 'Iota Ring', 'Marid Ring', 'Marid Ring +1',
        'Lightning Ring', 'Toreador\'s Ring', 'Jalzahn\'s Ring', 'Ulthalam\'s Ring',
        'Kshama Ring No. 2', 'Kshama Ring No. 8', 'Carapace Ring', 'Horn Ring', 'Horn Ring +1',
        'Jaeger Ring', 'Bowyer Ring', 'Beetle Ring', 'Beetle Ring +1', 'Bone Ring',
        'Bone Ring +1', 'Vision Ring'
    },

    -- Used by: BLM, SMN, WHM
    Back = {
        'Gunner\'s Mantle', 'Rep. Army Mantle', 'Bellicose Mantle', 'Gramary Cape',
        'Rearguard Mantle'
    },

    -- Used by: BLM, SMN, WHM
    Waist = {
        'Ninurta\'s Sash', 'Buccaneer\'s Belt', 'Sprinter\'s Belt', 'Mithran Stone',
        'Bitter Corset', 'Potent Belt', 'Swift Belt', 'Ocean Belt', 'Desert Belt', 'Life Belt',
        'Tilt Belt', 'Corsette', 'Mrc.Cpt. Belt'
    },
};

-- Cure -- cure midcast: cure potency, healing magic skill and MND.
lists.Cure = {
    -- Used by: BLM, SMN
    Ring = {
        'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring', 'Gnd.Kgt. Ring',
        'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1', 'Kshama Ring No. 9',
        'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring', 'Solace Ring +1', 'Carect Ring',
        'Lapis Lazuli Ring', 'Tranquility Ring', 'Saintly Ring'
    },

    -- Used by: BLM, SMN
    Back = {
        'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Miraculous Cape', 'Sapient Cape',
        'Ryl. Army Mantle', 'Red Cape', 'Red Cape +1', 'White Cape', 'White Cape +1',
        'Mist Silk Cape'
    },

    -- Used by: BLM, SMN
    Waist = {
        'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt', 'Deduct. Broc. Obi',
        'Penitent\'s Rope', 'Twinthread Obi', 'Twinthread Obi +1', 'Forest Belt',
        'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Deduct. Gold Obi',
        'Mrc.Cpt. Belt', 'Friar\'s Rope'
    },
};

-- Enhancing -- enhancing midcast: enhancing magic skill.
lists.Enhancing = {
    -- Used by: SMN, WHM
    Neck = {
        'Colossus\'s Torque', 'Jeweled Collar +1', 'Morgana\'s Choker', 'Enhancing Torque',
        'Enlightened Chain', 'Ajari Necklace', 'Stoneskin Torque', 'Torque', 'Promise Badge',
        'Yinyang Lorgnette', 'Mohbwa Scarf', 'Holy Phial', 'Fang Necklace', 'Spike Necklace',
        'Justice Badge'
    },

    -- Used by: BLM, RDM, SMN, WHM
    Ear = {
        'Static Earring', 'Celestial Earring', 'Cmn. Earring', 'Cmn. Earring +1',
        'Ryakho\'s Earring', 'Harvest Earring', 'Geist Earring', 'Augment. Earring'
    },

    -- Used by: BLM, RDM, SMN, WHM
    Ring = {
        'Pi Ring', 'Aqua Ring', 'Dark Ring', 'Serene Ring', 'Vivian Ring', 'Gnd.Kgt. Ring',
        'Aquamarine Ring', 'Serenity Ring', 'Serenity Ring +1', 'Kshama Ring No. 9',
        'Vilma\'s Ring', 'Malflood Ring', 'Solace Ring', 'Solace Ring +1', 'Carect Ring',
        'Lapis Lazuli Ring', 'Tranquility Ring', 'Saintly Ring'
    },

    -- Used by: BLM, RDM, SMN, WHM
    Back = {
        'Merciful Cape', 'Prism Cape', 'Rainbow Cape', 'Miraculous Cape', 'Sapient Cape',
        'Ryl. Army Mantle', 'Red Cape', 'Red Cape +1', 'White Cape', 'White Cape +1',
        'Mist Silk Cape'
    },

    -- Used by: BLM, SMN, WHM
    Waist = {
        'Ksi Sash', 'Al Zahbi Sash', 'Moon Sash', 'Water Belt', 'Deduct. Broc. Obi',
        'Penitent\'s Rope', 'Twinthread Obi', 'Twinthread Obi +1', 'Forest Belt',
        'Reverend Sash', 'Druid\'s Rope', 'Mantra Belt', 'Oracle\'s Belt', 'Deduct. Gold Obi',
        'Mrc.Cpt. Belt', 'Friar\'s Rope'
    },
};

-- Enfeebling -- enfeebling midcast: magic accuracy, MND/INT.
lists.Enfeebling = {
    -- Used by: BLM, RDM
    Back = {
        'Altruistic Cape', 'Prism Cape', 'Rainbow Cape', 'Sapient Cape', 'Miraculous Cape',
        'Fed. Army Mantle', 'Ryl. Army Mantle', 'Gramary Cape', 'Red Cape', 'Red Cape +1',
        'Black Cape', 'Black Cape +1', 'White Cape', 'Mist Silk Cape'
    },
};

return lists;
