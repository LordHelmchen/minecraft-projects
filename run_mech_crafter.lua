require 'crafter.mechanical_crafter'
require 'crafter.menu'
require 'crafter.recipe_collection'

--code to de/activate the clutch
local rs_clutch = peripheral.wrap("redstoneIntegrator_0")
local rs_clutch_dir = "south"

function unblockClutch()
    rs_clutch.setOutput(rs_clutch_dir, false)
end

function blockClutch()
    rs_clutch.setOutput(rs_clutch_dir, true)
end

--crafter setup
local input_inv = peripheral.wrap("ironchest:diamond_chest_0")
local output_inv = peripheral.wrap("minecraft:barrel_0")
local recipes = RecipeCollection:new(nil, "etc/ftb_sky_expert_mechanical_crafter.json")
recipes:load()
local crafter = MechanicalCrafter:new(nil, input_inv, output_inv, recipes, nil, "left", nil,  function() unblockClutch() end, function() blockClutch() end)
crafter:setup()

local menu = CrafterMenu:new(nil, crafter, recipes)
menu:run()

--local pretty = require('cc.pretty')
--local recipe = crafter:learn()

--pretty.pretty_print(recipes:get(1))
--crafter:craft(recipes:get(1), 2)
--print(input_inv)
--print(output_inv)
