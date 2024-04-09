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
    --TODO check if this recipe already exists
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

--find a recipe by ingredients
function RecipeCollection:find_recipe(items)
    error("not implemented")
    for i, r in ipairs(self.recipes) do
        -- TODO copy items for a checklist
        for j, ingredient in ipairs(r) do
            --TODO check items
            -- if not found continue next recipe
        end
        -- return recipe if all items are checked
    end
end

return RecipeCollection
