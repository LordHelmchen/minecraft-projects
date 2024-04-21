require('common.util')
require('crafter.recipe')
require('crafter.recipe_collection')
require 'crafter.transforming_multi_crafter'

EnchantingApparatus = TransformingMultiCrafter:new()

function EnchantingApparatus:setup()
    self.crafters = { peripheral.find("ars_nouveau:arcane_pedestal") }
end

function EnchantingApparatus:get_name()
    return "Enchanting Apparatus"
end

return EnchantingApparatus