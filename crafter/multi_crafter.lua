require('common.util')
require('crafter.recipe')
require('crafter.recipe_collection')

MultiCrafter = {input_inv = nil, block_inv_direction = "back", output_inv = nil, crafters = {}, recipes = {}, me_inv = nil, on_craft_start = function() end, on_craft_end = function() end}

function MultiCrafter:new(o, input_inv, output_inv, recipes, me_inv, on_craft_start, on_craft_end)
    self.__index = self
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    o:set_input_inv(input_inv)
    o:set_output_inv(output_inv)
    o:set_on_craft_start(on_craft_start)
    o:set_on_craft_end(on_craft_end)
    o.recipes = recipes or RecipeCollection:new({})
    o:set_me_inv(me_inv)
    o._stop_me_mode = false
    return o
end

function MultiCrafter:get_name()
    return "Multi Crafter"
end

function MultiCrafter:set_input_inv(input_inv)
    self.input_inv = input_inv or nil
end
function MultiCrafter:get_input_inv()
    return self.input_inv
end

function MultiCrafter:set_output_inv(output_inv)
    self.output_inv = output_inv or nil
end
function MultiCrafter:get_output_inv()
    return self.output_inv
end

function MultiCrafter:set_me_inv(me_inv)
    self.me_inv = me_inv or nil
end
function MultiCrafter:get_me_inv()
    return self.me_inv
end

function MultiCrafter:set_on_craft_start(on_craft_start)
    self.on_craft_start = on_craft_start or nil
end
function MultiCrafter:_fire_on_craft_start()
    if(self.on_craft_start) then self.on_craft_start() end
end

function MultiCrafter:set_on_craft_end(on_craft_end)
    self.on_craft_end = on_craft_end or nil
end
function MultiCrafter:_fire_on_craft_end()
    if(self.on_craft_end) then self.on_craft_end() end
end

--setup the MultiCrafter e.g. assign all crafters to self.crafters using peripheral.find("crafter_name")
function MultiCrafter:setup()
    error("not implemented - set crafters with set_crafters manually")
end

function MultiCrafter:set_crafters(crafters)
    self.crafters = crafters or {}
end
function MultiCrafter:get_crafters()
    return self.crafters
end

function MultiCrafter:set_recipe(recipe)
    self.current_recipe = recipe
end

function MultiCrafter:delete_recipe(recipe)
    --delete recipe from list
    self.recipes:delete(recipe)
    --save list
    self:save_recipes()
end

function MultiCrafter:find_recipe(items)
    --check recipe list and find the one where the items match exactly
    return self.recipes:find_recipe(items)
end

function MultiCrafter:save_recipes()
    --store recipes to disk
    self.recipes:save()
end

function MultiCrafter:load_recipes()
    --load recipes from disk
    self.recipes:load()
end

function MultiCrafter:display(text)
    --TODO give messages/status to ui
    local basalt = require('common.basalt').debug(text)
end

function MultiCrafter:push_into_crafter(i, name, amount)
    return Util.push_items_by_name(self.input_inv, self.crafters[i], name, amount or 1)
end

function MultiCrafter:send_items_to_crafters(recipe)
    for i, ingredient in pairs(recipe.ingredients) do
        if i <= self:crafter_count() then
            local remaining = self:push_into_crafter(i, ingredient.name, ingredient.amount)
            if remaining == nil then
                return false
            end
            if remaining > 0 then
                self:display("missing " .. remaining .. " of " .. ingredient.name .. " in input inventory")
                return false
            end
        end
    end
end

function MultiCrafter:activate_craft(recipe)
end

function MultiCrafter:craft(recipe, item_count)
    recipe = recipe or self.current_recipe
    if not recipe then
        self:display("no recipe selected")
        return false
    end
    item_count = item_count or 1
    --loop, if item_count > 0
    self:_fire_on_craft_start()
    while item_count > 0 do
        --display current item being crafted (from recipe)
        self:display("crafting " .. item_count .. " " .. recipe.creates)
        --send items from input to crafters
        self:send_items_to_crafters(recipe)
        --activate the craft
        self:activate_craft(recipe)
        --wait for resulting item
        self:wait_for_output()
        item_count = item_count - 1
    end
    self:_fire_on_craft_end()
    --display 'done'
    self:display("done")
    return true
end

function MultiCrafter:get_crafter_ipairs()
    return ipairs(self.crafters)
end

function MultiCrafter:_fire_on_recipe_learn(recipe)
end

function MultiCrafter:learn()
    local recipe = Recipe:new(nil)
    --get the current item in all crafters -> table
    for i, c in self:get_crafter_ipairs() do
        local item = c.getItemDetail(1)
        if item then
            recipe.ingredients[i] = {name =item.name, count = item.count}
        else
            recipe.ingredients[i] = nil
        end
    end
    self:_fire_on_craft_start()
    --send redstone pulse
    self:activate_craft(nil) -- no complete recipe yet
    --wait for output
    local output = self:wait_for_output()
    self:_fire_on_craft_end()
    --get output item name
    local result = self.output_inv.getItemDetail(1)
    recipe.creates = result.name
    recipe.displayName = result.displayName
    --TODO might need NBT hash and damage
    self:_fire_on_recipe_learn(recipe)
    --save recipe
    self.recipes:add(recipe)
    self:save_recipes()
    return recipe
end

function MultiCrafter:stop_me_mode()
    self._stop_me_mode = true
    self:display("stop ME requested")
end

function MultiCrafter:me_mode()
    while not self._stop_me_mode do
        --wait for item to land in input_inv and store it as table
        self:display("wait for input")
        local items = self:wait_for_input(
            function ()
                return not self._stop_me_mode
            end
        ) -- devised an exit method
        --try to find a recipe where all items are used
        local recipe = self:find_recipe(items)
        --not found, 
        if not recipe then
            self:display("no recipe found")
            sleep(0.5)
        else
            self:display("crafting " .. recipe.displayName)
            self:craft(recipe, 1)
        --transport all items from output_inv to me_inv
            Util.push_items_predicate(self:get_output_inv(), self:get_me_inv())
        end
    end
    self._stop_me_mode = false
end

--check the input chest. Compare with last check. If not empty and the same items, then return
function MultiCrafter:wait_for_input(continue_function)
    return Util.wait_until_inv_is_stable(self.input_inv, nil, continue_function)
end

--wait until something got added to the output inventory and it is stable
function MultiCrafter:wait_for_output(continue_function)
    return Util.wait_until_inv_is_stable(self.output_inv, self.output_inv.list(), continue_function)
end


--item stacks in input chest
function MultiCrafter:input_count()
    return #(self.input_inv.list())
end

function MultiCrafter:crafter_count()
    return #(self.crafters)
end

return MultiCrafter