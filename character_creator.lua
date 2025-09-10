local IMG_PATH = spearmaster.modRoot .. "/graphics/"
local ARMOR_IMG_PATH = spearmaster.modRoot .. "/graphics/armor/"
local POWER_ARMOR_IMG_PATH = spearmaster.modRoot .. "/graphics/power_armor/"

local util = require("util")
local my_character = {}

local sprite_scale = 0.70;
local img_width = 480;
local img_height = 300;
local img_shift = { 0, 0}

function getAnimationWithHr(s)
    local hr = util.table.deepcopy(s)
    s.hr_version = hr
    return s
end

function getSeqPics(prefix, max)
    local s = {}
    for i = 1, max do
        table.insert(s, prefix .. i .. ".png")
    end
    return s
end

function getSeqPicsRange(prefix, min, max)
    local s = {}
    for i = min, max do
        table.insert(s, prefix .. i .. ".png")
    end
    return s
end


local function getHr(s)
    return getAnimationWithHr(s)
end

local function getIdlePics(min, max, IMG_PATH)
    local s = getSeqPicsRange(IMG_PATH, min, max)
    return s
end

local function getRunningPics(max, IMG_PATH)
    local s = {}
    for i = 1, max do
        table.insert(s, IMG_PATH .. i .. ".png")
    end
    return s
end

--we are going to pretend that we have more angles than we actually have :3
local function getRunningGunPics(max, IMG_PATH)
    local s = {}
    local t = {
        a1 = 1,
        a2 = 1,
        a3 = 1,
        a4 = 2,
        a5 = 2,
        a6 = 2,
        a7 = 2,
        a8 = 3,
        a9 = 3,
        a29 = 3,
        a28 = 3,
        a27 = 4,
        a26 = 4,
        a25 = 4,
        a24 = 4,
        a23 = 5,
        a22 = 5,
        a21 = 5,
    }
    for _, k in pairs(t) do
        for i = 1, max do
            local from = (k - 1) * max
            local name = i + from
            table.insert(s, IMG_PATH .. name .. ".png")
        end
    end
    return s
end

local function getDead(IMG_PATH)
    local s = {
        width = img_width,
        height = img_height,
        shift = img_shift,
        frame_count = 2,
        scale = 1,
        stripes = {
        --why would you hardcode this without ANY comments?
            {
                filename = IMG_PATH .. "113.png",
                width_in_frames = 1,
                height_in_frames = 1,
            },
            {
                filename = IMG_PATH .. "114.png",
                width_in_frames = 1,
                height_in_frames = 1,
            }, }
    }
    return getHr(s)
end

local function getRunning(IMG_PATH)
    local s = {
        filenames = getRunningPics(80, IMG_PATH),
        width = img_width,
        height = img_height,
        shift = img_shift,
        frame_count = 10,
        slice = 1,
        line_length = 1,
        lines_per_file = 1,
        direction_count = 8,
        animation_speed = 0.6,
        scale = sprite_scale,
    }
    return getHr(s)
end

local function getRunningGun(IMG_PATH)
    local s = {
        filenames = getRunningGunPics(10, IMG_PATH),
        width = img_width,
        height = img_height,
        slice = 1,
        shift = img_shift,
        frame_count = 10,
        line_length = 1,
        lines_per_file = 1,
        direction_count = 18,
        animation_speed = 1,
        scale = sprite_scale,

    }
    return getHr(s)

end

local function getIdle(IMG_PATH)
    local s = {
        filenames = getIdlePics(81, 112, IMG_PATH),
        slice = 1,
        width = img_width,
        height = img_height,
        shift = img_shift,
        frame_count = 8,
        line_length = 1,
        lines_per_file = 1,
        direction_count = 4,
        animation_speed = 0.1,
        scale = sprite_scale,
    }
    return getHr(s)
end

local function getMining(imgPath)
    return getIdle(imgPath)
end

local function get_mapping(x)
    return (not data.is_demo) and x or nil
end

-- Load up an animation set from image path.
local function create_animation(imgPath)
    return {
        idle = {
            layers = {
                getIdle(imgPath),
            }
        },
        idle_with_gun = {
            layers = {
                --characteranimations["level1"]["idle_gun"],
                getIdle(imgPath),
            }
        },
        mining_with_tool = {
            layers = {
                getMining(imgPath),
            }
        },
        running_with_gun = {
            layers = {
                getRunningGun(imgPath),
            }
        },
        running = {
            layers = {
                getRunning(imgPath),
            }
        }
    }
end

my_character.create = function(imgPath, name)

    -- Armorless
    local character_animation = create_animation(IMG_PATH);
    -- Light and heavy armor
    local character_armored_animation = create_animation(ARMOR_IMG_PATH);
    character_armored_animation.armors = {"light-armor", "heavy-armor"}
    -- Modular armor and above
    local character_power_armor_animation = create_animation(POWER_ARMOR_IMG_PATH);
    character_power_armor_animation.armors = {"modular-armor", "power-armor", "power-armor-mk2"}


    local animations_live = {
        character_animation,
        character_armored_animation,
        character_power_armor_animation,
    }

    local animations_dead = {
        {
            layers = {
                getDead(imgPath)
            }
        },
        {
            layers = {
                getDead(imgPath)
            }
        },
        {
            layers = {
                getDead(imgPath)
            }
        }
    }

    ------------------------------------------------------------------------------------
    --                                Character corpse                                --
    ------------------------------------------------------------------------------------
    -- We only store properties with values different from the defaults
    -- Copy the corpse
    --~ local corpse = table.deepcopy(data.raw["character-corpse"]["character-corpse"])
    local corpse = {}
    corpse.name = name .. "-corpse"
    corpse.localised_name = { "entity-name." .. corpse.name }
    corpse.localised_description = { "entity-description." .. corpse.name }
    corpse.icon = imgPath .. "corpse.png"
    corpse.icon_size = 480
    corpse.pictures = animations_dead

    corpse.armor_picture_mapping = {
        ["heavy-armor"] = 2,
        --~ ["light-armor"] = 2,
        --~ ["modular-armor"] = 3,
        --~ ["power-armor"] = 3,
        --~ ["power-armor-mk2"] = 3
        ["light-armor"] = get_mapping(2),
        ["modular-armor"] = get_mapping(3),
        ["power-armor"] = get_mapping(3),
        ["power-armor-mk2"] = get_mapping(3)
    }

    --~ -- Apply changed values to the copy
    --~ for p_name, property in pairs(corpse) do
    --~ corpse[p_name] = property
    --~ end

    --~ -- Create the corpse
    --~ data:extend({ corpse })



    ------------------------------------------------------------------------------------
    --                                    Character                                   --
    ------------------------------------------------------------------------------------
    -- We only store properties with values different from the defaults
    local character = {}
    character.name = name
    character.localised_name = { "entity-name." .. character.name }
    character.localised_description = { "entity-name." .. character.name }
    character.icon = imgPath .. "icon.png"
    character.icon_size = 480

    
    character.animations = animations_live

    -- Here I comment out overpowered changes.
    --character.build_distance = 100
    character.character_corpse = corpse.name
    --character.drop_item_distance = 100
    character.enter_vehicle_distance = 3
    --character.inventory_size = 100
    --haracter.item_pickup_distance = 10
    --character.loot_pickup_distance = 20
    character.mining_with_tool_particles_animation_positions = { 19 }
    --character.reach_distance = 100
    character.reach_resource_distance = 2.7
    character.running_sound_animation_positions = { 5, 16 }

    character.tool_attack_result = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = {
                type = "damage",
                damage = { amount = 8, type = "physical" }
            }
        }
    }
    character.footstep_particle_triggers = {
        {
            tiles = { "water-shallow" },
            type = "create-particle",
            repeat_count = 5,
            particle_name = "shallow-water-droplet-particle",
            initial_height = 0.2,
            speed_from_center = 0.01,
            speed_from_center_deviation = 0.05,
            initial_vertical_speed = 0.02,
            initial_vertical_speed_deviation = 0.05,
            offset_deviation = { { -0.2, -0.2 }, { 0.2, 0.2 } }
        },
        {
            tiles = { "water-mud" },
            type = "create-particle",
            repeat_count = 5,
            particle_name = "shallow-water-droplet-particle",
            initial_height = 0.2,
            speed_from_center = 0.01,
            speed_from_center_deviation = 0.05,
            initial_vertical_speed = 0.02,
            initial_vertical_speed_deviation = 0.05,
            offset_deviation = { { -0.2, -0.2 }, { 0.2, 0.2 } }
        }
    }
    character.water_reflection = {
        pictures = {
            filename = IMG_PATH .. "character-reflection.png",
            priority = "extra-high",
            -- flags = { "linear-magnification", "not-compressed" },
            -- default value: flags = { "terrain-effect-map" },
            width = 13,
            height = 19,
            shift = util.by_pixel(0, 67 * 0.5),
            scale = 5,
            variation_count = 1
        },
        rotate = false,
        orientation_to_variation = false
    }


    --~ -- Copy the default character
    --~ local char = table.deepcopy(data.raw.character.character)

    --~ -- Apply changed values to the copy
    --~ for p_name, property in pairs(character) do
    --~ char[p_name] = property
    --~ end

    --~ -- Create the character
    --~ data:extend({ char })

    return {
        character = character,
        corpse = corpse
    }

end

return my_character
