require('common.util')
require('crafter.recipe')
require('crafter.recipe_collection')

MultiCrafter = {input_inv = nil, block_inv_direction = "back", redstone_integrator = nil, redstone_direction = "north", output_inv = nil, crafters = {}, recipes = {}, on_craft_start = function() end, on_craft_end = function() end}

function MultiCrafter:new(o, input_inv, output_inv, recipes, redstone_direction, redstone_integrator, on_craft_start, on_craft_end)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o:set_input_inv(input_inv)
    o:set_redstone_integrator(redstone_integrator)
    o:set_redstone_direction(redstone_direction)
    o:set_output_inv(output_inv)
    o:set_on_craft_start(on_craft_start)
    o:set_on_craft_end(on_craft_end)
    o.recipes = recipes or RecipeCollection:new({})
    return o
end

function MultiCrafter:get_name()
    return "Multi Crafter"
end

function MultiCrafter:set_redstone_integrator(integrator) 
    self.redstone_integrator = integrator or nil
end
function MultiCrafter:get_redstone_integrator() 
    return self.redstone_integrator
end

function MultiCrafter:set_redstone_direction(direction)
    self.redstone_direction = direction or "north"
end
function MultiCrafter:get_redstone_direction()
    return self.redstone_direction
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

--setup the MultiCrafter e.g. assign all crafters to self.crafters 
function MultiCrafter:setup()
    error("not implemented")
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
        for i, ingredient in pairs(recipe.ingredients) do
            local remaining = Util.push_items_by_name(self.input_inv, self.crafters[i], ingredient.name, ingredient.amount or 1)
            if remaining > 0 then
                self:display("missing " .. remaining .. " of " .. ingredient.name .. " in input inventory")
                return false
            end
        end
        --send redstone pulse to crafters
        self:send_redstone_pulse()
        --wait for resulting item to land in output_inv
        self:wait_for_output()
        item_count = item_count - 1
    end
    self:_fire_on_craft_end()
    --display 'done'
    self:display("done")
    return true
end

function MultiCrafter:activate_redstone()
    local rs_src
    if self.redstone_integrator then
        rs_src = self.redstone_integrator
    else
        rs_src = rs
    end
    --print("redstone on")
    rs_src.setOutput(self.redstone_direction, true)
end

function MultiCrafter:deactivate_redstone()
    local rs_src
    if self.redstone_integrator then
        rs_src = self.redstone_integrator
    else
        rs_src = rs
    end
    --print("redstone off")
    rs_src.setOutput(self.redstone_direction, false)
end

function MultiCrafter:send_redstone_pulse()
    self:activate_redstone()
    os.sleep(0.05)
    self:deactivate_redstone()
end

function MultiCrafter:learn()
    local recipe = Recipe:new({})
    --get the current item in all crafters -> table
    for i, c in ipairs(self.crafters) do
        local item = c.getItemDetail(1)
        if item then
            recipe.ingredients[i] = {name =item.name, count = item.count}
        else
            recipe.ingredients[i] = nil
        end
    end
    self:_fire_on_craft_start()
    --send redstone pulse
    self:send_redstone_pulse()
    --wait for item to land in output_inv
    local output = self:wait_for_output()
    self:_fire_on_craft_end()
    --get output item name
    local result = self.output_inv.getItemDetail(1)
    recipe.creates = result.name
    recipe.displayName = result.displayName
    --TODO might need NBT hash and damage
    --save recipe
    self.recipes:add(recipe)
    self:save_recipes()
    return recipe
end

function MultiCrafter:me_mode()
    while true do
        --wait for item to land in input_inv and store it as table
        local items = self:wait_for_input()
        --try to find a recipe where all items are used
        local recipe = self:find_recipe(items)
        --not found, display error and exit me_mode
        if not recipe then
            self:display("no recipe found")
            return false
        end
        self:craft(recipe, 1)
        --TODO transport item to me interface
    end
end

--check the input chest. Compare with last check. If not empty and the same items, then return
function MultiCrafter:wait_for_input()
    return Util.wait_until_inv_is_stable(self.input_inv)
end

--wait until something got added to the output inventory and it is stable
function MultiCrafter:wait_for_output()
    return Util.wait_until_inv_is_stable(self.output_inv, self.output_inv.list())
end


--item stacks in input chest
function MultiCrafter:input_count()
    return #(self.input_inv.list())
end

return MultiCrafter