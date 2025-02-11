return {

    dropCheaters = false,
    policeJob = 'police',
    coords = vector3(2208.68, 5591.96, 53.85),

    interaction = {
        markerColor = {r = 12, g = 94, b = 199, a = 190}, -- RGBA color of the interaction markers.

        
        textUI = {
            position = "right-center"
        },
    },

    tasks = {
        {
            name = "Picking Weeds Out",
            coords = vector3(2185.05, 5554.55, 53.83),
            scenario = "WORLD_HUMAN_GARDENER_PLANT",
            duration = 7000,
        },
        {
            name = "Shovelling Soil",
            coords = vector3(2222.82, 5564.38, 53.65),
            animation = {
                dict = "amb@world_human_gardener_plant@male@idle_a",
                clip = "idle_a"
            },
            prop = {
                model = "prop_tool_shovel2"
            },
            duration = 7000,
        },
    },

    switchOutfit = false,
    Uniforms = {
        [0] = {
            ['arms'] = 5,
            ['tshirt_1'] = 15, 
            ['tshirt_2'] = 0,
            ['torso_1'] = 5, 
            ['torso_2'] = 0,
            ['bproof_1'] = 0,
            ['bproof_2'] = 0,
            ['decals_1'] = 0, 
            ['decals_2'] = 0,
            ['chain_1'] = 0,
            ['chain_2'] = 0,
            ['pants_1'] = 5, 
            ['pants_2'] = 7,
            ['shoes_1'] = 6, 
            ['shoes_2'] = 0,
            ['helmet_1'] = 104, 
            ['helmet_2'] = 21,
        },
        [1] = {
            ['arms'] = 4,
            ['tshirt_1'] = 15, 
            ['tshirt_2'] = 0,
            ['torso_1'] = 5, 
            ['torso_2'] = 0,
            ['bproof_1'] = 0,
            ['bproof_2'] = 0,
            ['decals_1'] = 0, 
            ['decals_2'] = 0,
            ['chain_1'] = 0,
            ['chain_2'] = 0,
            ['pants_1'] = 66, 
            ['pants_2'] = 6,
            ['shoes_1'] = 5, 
            ['shoes_2'] = 0,
            ['helmet_1'] = 103, 
            ['helmet_2'] = 21,
        }
    },
    
    teleportBack = true,
    returnLocation = vector3(168.45, -1010.46, 29.33)
}

