Util = {}

--Move all items from one inventory to another, that match a predicate function.
-- from_i and to_i are wrapped inventory peripherals
-- predicate(slot, item) => bool
function Util.move_items_predicate(from_i, to_i, predicate)
    if from_i == nil or to_i == nil then return end
    for slot, item in pairs(from_i.list()) do
        if predicate(slot, item) then
            from_i.pushItems(peripheral.getName(to_i), slot)
        end
    end 
end

--checks tables for equality
function Util.recursive_compare(t1,t2)
    -- Use usual comparison first.
    if t1==t2 then return true end
    -- We only support non-default behavior for tables
    if (type(t1)~="table") then return false end
    -- They better have the same metatables
    local mt1 = getmetatable(t1)
    local mt2 = getmetatable(t2)
    if( not recursive_compare(mt1,mt2) ) then return false end

    -- Check each key-value pair
    -- We have to do this both ways in case we miss some.
    -- TODO: Could probably be smarter and not check those we've 
    -- already checked though!
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if( not recursive_compare(v1,v2) ) then return false end
    end
    for k2,v2 in pairs(t2) do
        local v1 = t1[k2]
        if( not recursive_compare(v1,v2) ) then return false end
    end
    return true  
end