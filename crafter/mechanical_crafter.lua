require('common.util')
require('crafter.recipe')
require('crafter.recipe_collection')
require 'crafter.multi_crafter'

MechanicalCrafter = MultiCrafter:new()

function MechanicalCrafter:setup()
    self.crafters = { peripheral.find("create:mechanical_crafter") }
end

function MechanicalCrafter:get_name()
    return "Mechanical Crafter"
end

return MechanicalCrafter