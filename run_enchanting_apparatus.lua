require 'crafter.enchanting_apparatus'
require 'crafter.menu'
require 'crafter.recipe_collection'

--crafter setup
local input_inv = peripheral.wrap("minecraft:barrel_2")
local me_inv = peripheral.wrap("ae2:pattern_provider_1")
local enchanting_apparatus = peripheral.wrap("ars_nouveau:enchanting_apparatus_0")
local recipes = RecipeCollection:new(nil, "etc/ftb_sky_expert_enchanting_apparatus.json")
recipes:load()
local crafter = EnchantingApparatus:new(nil, input_inv, me_inv, enchanting_apparatus, recipes, me_inv)
crafter:setup()

local menu = CrafterMenu:new(nil, crafter, recipes)
menu:run()

--local pretty = require('cc.pretty')
--local recipe = recipes:find_recipe(input_inv.list())
--pretty.pretty_print(recipe)
--local recipe = crafter:learn()

--pretty.pretty_print(recipes:get(1))
--crafter:craft(recipes:get(1), 2)
--print(input_inv)

