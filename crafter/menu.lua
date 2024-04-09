require 'crafter.mechanical_crafter'
require 'crafter.recipe_collection'

CrafterMenu = {crafter = nil, recipes = nil}

function CrafterMenu:new(o, crafter, recipes)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o.crafter = crafter or nil
    o.recipes = recipes or RecipeCollection:new()
    return o
end

function CrafterMenu:run()
    local basalt = require('common.basalt')
    local main = basalt.createFrame()
    if main == nil then return end

    local worker = main:addThread()

    local title = main:addLabel()
        :setText(self.crafter.get_name())
        :setPosition(2,1)

    local quitButton = main --> Basalt returns an instance of the object on most methods, to make use of "call-chaining"
        :addButton() --> This is an example of call chaining
        :setPosition('parent.w', 1)
        :setSize(1,1)
        :setText("x")
        :onClick(
            function()
                basalt.stopUpdate()
            end)

    local recipeFrame = main
        :addFlexbox()
        :setSize('parent.w/4*3', 'parent.h-2')
        :setWrap()
        :setPosition(1, 2)
        :setTheme({ListBG=colors.yellow, ListText=colors.black})

    local recipeList = recipeFrame:addList()
        :setScrollable(true)
        :setSize('parent.w-2', 'parent.h-2')
        :setPosition(2,2)
    for i, recipe in ipairs(self.recipes:list()) do
        recipeList:addItem(recipe.displayName or recipe.creates, nil, nil, recipe)
    end

    recipeList:onSelect(function(self, event, item)
        basalt.debug("Selected item: ", item.text)
    end)

    local buttonFrame = main
        :addFlexbox()
        :setSize('parent.w/4', 'parent.h-2')
        :setPosition('parent.w/4*3+1', 2)
        :setJustifyContent("space-between")
        :setDirection("row")
        :setWrap("wrap")
    buttonFrame:addBreak()
    
    local craftButton = buttonFrame --> Basalt returns an instance of the object on most methods, to make use of "call-chaining"
        :addButton() --> This is an example of call chaining
        :setText("craft")
        :setBackground(colors.blue)

    local amountInput = buttonFrame:addInput()
        :setInputType("number")
        :setDefaultText("amount")
        :setValue(1)

    craftButton:onClick(
        function()
            basalt.debug("craft got clicked!")
            if not worker:getStatus() or worker:getStatus() == "dead" then
                local recipe = recipeList:getValue().args[1]
                local amount = amountInput:getValue()
                craftButton:setBackground(colors.green)
                worker:start(function()
                    self.crafter:craft(recipe, amount)
                    amountInput:setValue(1)
                    craftButton:setBackground(colors.blue)
                end)
            end
        end)
    

    local learnButton = buttonFrame --> Basalt returns an instance of the object on most methods, to make use of "call-chaining"
        :addButton() --> This is an example of call chaining
        :setText("learn")
        :setBackground(colors.blue)
    learnButton:onClick(
        function()
            basalt.debug("learn got clicked! ")
            if not worker:getStatus() or worker:getStatus() == "dead" then
                learnButton:setBackground(colors.green)
                worker:start(function()
                    local new_recipe = self.crafter:learn()
                    if (new_recipe) then
                        recipeList:addItem(new_recipe.displayName or new_recipe.creates, nil, nil, new_recipe)
                    end
                    learnButton:setBackground(colors.blue)
                end)
            end
        end)
    
    
    local memodeButton = buttonFrame --> Basalt returns an instance of the object on most methods, to make use of "call-chaining"
        :addButton() --> This is an example of call chaining
        :setText("ME mode")
        :setBackground(colors.blue)
        :onClick(
            function()
                basalt.debug("me mode got clicked!")
            end)
    
    basalt:onEvent(function(event, key)
        --basalt.debug(event)
        if(event == "key") then
            if key == keys.up then
                --basalt.debug("up pressed")
                local newIndex = recipeList:getItemIndex() - 1
                if newIndex < 1 then newIndex = recipeList:getItemCount() end
                recipeList:selectItem(newIndex)
            elseif key == keys.down then
                --basalt.debug("down pressed")
                local newIndex = recipeList:getItemIndex() + 1
                if newIndex > recipeList:getItemCount() then newIndex = 1 end
                recipeList:selectItem(newIndex)
            end
        end
    end)
    
    basalt.autoUpdate()
end

return CrafterMenu
