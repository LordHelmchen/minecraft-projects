require('common.util')
require('crafter.recipe')
require('crafter.recipe_collection')
require 'crafter.multi_crafter'

TransformingMultiCrafter = MultiCrafter:new()

function TransformingMultiCrafter:new(o, input_inv, output_inv, main_crafter, recipes, me_inv, on_craft_start, on_craft_end)
    self.__index = self
    setmetatable(TransformingMultiCrafter, {__index = MultiCrafter})
    o = o or MultiCrafter:new(o, input_inv, output_inv, recipes, me_inv, on_craft_start, on_craft_end)   -- create object if user does not provide one
    setmetatable(o, self)
    o:set_main_crafter(main_crafter)
    o.list_on_craft_start = nil
    o._main_crafter_ingredients = nil
    return o
end

function TransformingMultiCrafter:set_main_crafter(main_crafter) 
    self.main_crafter = main_crafter or nil
end
function TransformingMultiCrafter:get_main_crafter() 
    return self.main_crafter
end

-- does not work with ars, because the item in main crafter is never readable
-- function TransformingMultiCrafter:get_crafter_ipairs()
--     local all_crafters = { table.unpack(self.crafters) }
--     all_crafters[9] = self.main_crafter
--     return ipairs(all_crafters)
-- end

function TransformingMultiCrafter:push_into_crafter(i, name, amount)
    -- skip final item, that shall go into the enchanting apparatus
    if i > #self.crafters then
        return 0
    end
    return MultiCrafter.push_into_crafter(self, i, name, amount)
end

function TransformingMultiCrafter:move_items_to_output()
    Util.push_items_predicate(self:get_main_crafter(), self:get_output_inv())
end

function TransformingMultiCrafter:push_remaining_items_into_main_crafter()
    if Util.push_items_predicate(self:get_input_inv(), self:get_main_crafter()) == 0 then
        error("The final ingredients could not be moved into the main crafter.")
    end
end

function TransformingMultiCrafter:activate_craft(recipe)
    if not recipe then --call without recipe from learn()
        self:push_remaining_items_into_main_crafter()
        return
    end
    for key, ingredient_from_recipe in pairs(recipe.ingredients) do
        if key > self:crafter_count() then
            local remaining = Util.push_items_by_name(self:get_input_inv(), self:get_main_crafter(), ingredient_from_recipe.name, ingredient_from_recipe.amount)
            if remaining > 0 then
                error("Cannot transfer enough items to main crafter")
            end
        end
    end
    --save the final ingredient as table to compare against later
    self.list_on_craft_start = self:get_main_crafter().list()
end

function TransformingMultiCrafter:get_name()
    return "Transforming MultiCrafter"
end

function TransformingMultiCrafter:wait_for_output()
    --wait until final_ingredient is not equal to the item in enchanting_apparatus
    while true do
        local current_items = self:get_main_crafter().list()
        if #current_items > 0 and not Util.recursive_compare(self.final_ingredient, current_items) then
            self.final_ingredient = nil
            return current_items
        end
        sleep(0.1)
    end
end

function TransformingMultiCrafter:_fire_on_craft_end()
    self:move_items_to_output()
    MultiCrafter._fire_on_craft_end(self)
end

function TransformingMultiCrafter:_fire_on_recipe_learn(recipe)
    local i = self:crafter_count()
    for key, item in pairs(self._main_crafter_ingredients) do
        recipe.ingredients[i+1] = {name = item.name, count = item.count}
    end
    self._main_crafter_ingredients = nil
end

--wait for a stable set of items in the main crafter before learning the recipe
function TransformingMultiCrafter:learn()
    self:display("Fill crafters, then last ingr. in input_inv")
    self._main_crafter_ingredients = Util.wait_until_inv_is_stable(self:get_input_inv())
    local pretty = require("cc.pretty")
    pretty.pretty_print(self._main_crafter_ingredients)
    self:display("Crafting")
    local recipe = MultiCrafter.learn(self)
    pretty.pretty_print(recipe)
    return recipe
end

return TransformingMultiCrafter