require('common.util')
require('crafter.recipe')
require('crafter.recipe_collection')
require 'crafter.redstone_crafter'

MechanicalCrafter = RedstoneCrafter:new()

function MechanicalCrafter:setup()
    self.crafters = { peripheral.find("create:mechanical_crafter") }
end

function MechanicalCrafter:get_name()
    return "Mechanical Crafter"
end

return MechanicalCrafter