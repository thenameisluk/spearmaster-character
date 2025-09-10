spearmaster = require("__CharacterModHelper__.common")("spearmaster-character")

spearmaster.IMG_PATH = spearmaster.modRoot.."/graphics/"

local character_creator = require("character_creator")

spearmaster.new_characters = {}

local character_name = "Spearmaser_character_skin"

spearmaster.new_characters[character_name] = character_creator.create(spearmaster.IMG_PATH, character_name)


CharModHelper.create_prototypes(spearmaster.new_characters[character_name])

-- Work without a character selector mod (if there is no other working character mod)
CharModHelper.check_my_prototypes(spearmaster.new_characters[character_name])