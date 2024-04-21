require 'crafter.recipe'
--require 'textutils'

RecipeCollection = {recipes = {}, filename = "recipes.json"}

function RecipeCollection:new(o, filename)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o.filename = filename or "recipes.json"
    o.recipes = {}
    return o
end

function RecipeCollection:get(index)
    return self.recipes[index]
end

function RecipeCollection:list()
    return self.recipes
end

function RecipeCollection:add(recipe)
    -- check if this recipe already exists
    for i, r in ipairs(self.recipes) do
        if Util.recursive_compare(r, recipe) then
            return false
        end
    end
    table.insert(self.recipes, recipe)
    return true
end

function RecipeCollection:remove(recipe)
    --TODO check if this recipe exists end remove it
    error("not implemented")
end

function RecipeCollection:save()
    --save to file
    local file = fs.open(self.filename, "w")
    file.write(textutils.serialise(self.recipes))
    file.close()
end

function RecipeCollection:load()
    --load from file
    local file = fs.open(self.filename, "r")
    self.recipes = {}
    if(file) then
        self.recipes = textutils.unserialise(file.readAll())
        file.close()
    end
end

function RecipeCollection:display(text)
    local pretty = require("cc.pretty")
    pretty.pretty_print(text)
end

--find a recipe by ingredients
function RecipeCollection:find_recipe(items)
    if not items or #items == 0 then
        return nil
    end
    for i, r in ipairs(self.recipes) do
        -- copy items for a checklist
        local check_list = Util.deep_copy(items)
        --self:display(check_list)
        local check_ingredients = Util.deep_copy(r.ingredients)
        --self:display(check_ingredients)
        for j, ingredient in pairs(r.ingredients) do
            for key, item in pairs(check_list) do
                local remaining = ingredient.count
                --self:display("ingredient " .. j)
                --self:display(ingredient)
                --self:display(remaining)
                if ingredient.name == item.name then
                    item.count = item.count - remaining
                    if item.count <= 0 then
                        remaining = math.abs(item.count)
                        --self:display(ingredient.name .. " remaining " .. remaining )
                        check_list[key] = nil
                    end
                    if remaining == 0 then
                        check_ingredients[j] = nil
                        --self:display("input item satisfied - break here")
                        break
                    end
                end
            end
            --self:display("continue here")
            --compact checklist
            local compacted_check_list = {}
            for key, value in pairs(check_list) do
                compacted_check_list[key] = value
            end
            check_list = compacted_check_list
            local all_ingredients_found = true
            for key, value in pairs(check_ingredients) do
                all_ingredients_found = false
                break
            end
            --check items
            if #check_list == 0 and all_ingredients_found then
                -- success, both lists are completely satisfied
                --self:display("recipe found")
                return r -- return recipe if all items are checked
            end
            if Util.xor(#check_list == 0, all_ingredients_found) then
                -- one list is done, the other is not
                --self:display("#check_list == 0 :" .. (#check_list == 0))
                --self:display("all_ingredients_found :" .. all_ingredients_found)
                break --next recipe
            end
            --self:display("next recipe (end)")
        end
    end
    return nil
end

return RecipeCollection
