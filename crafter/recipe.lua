Recipe = {ingredients = {}, creates = nil, displayName = nil}

function Recipe:new(o, creates, ingredients, displayName, shaped)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    o.creates = creates or nil
    o.displayName = displayName or nil
    o.ingredients = ingredients or {}
    return o
end

return Recipe