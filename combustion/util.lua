Util = {}

--Move all items from one inventory to another, that match a predicate function.
-- from_i and to_i are wrapped inventory peripherals
-- predicate(slot, item) => bool
function Util.push_items_predicate(from_i, to_i, predicate)
    if from_i == nil or to_i == nil then return end
    if push == nil then push = true end
    local from_name = nil
    local to_name = nil
    local count = 0
    if type(from_i)=="string" then
        from_name = from_i
        from_i = peripheral.wrap(from_name)
    elseif(type(from_i) == "table") then
        from_name = peripheral.getName(from_i)
    else
        return -1
    end
    if type(to_i)=="string" then
        to_name = to_i
        to_i = peripheral.wrap(to_name)
    elseif(type(to_i) == "table") then
        to_name = peripheral.getName(to_i)
    else
        return -1
    end
    for slot, item in pairs(from_i.list()) do
        if predicate(slot, from_i.getItemMeta(slot)) then
            if(from_i.pushItems(to_name, slot) > 0) then
                count = count + 1
            end
        end
    end
    return count
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
    if( not Util.recursive_compare(mt1,mt2) ) then return false end

    -- Check each key-value pair
    -- We have to do this both ways in case we miss some.
    -- TODO: Could probably be smarter and not check those we've 
    -- already checked though!
    for k1,v1 in pairs(t1) do
        local v2 = t2[k1]
        if( not Util.recursive_compare(v1,v2) ) then return false end
    end
    for k2,v2 in pairs(t2) do
        local v1 = t1[k2]
        if( not Util.recursive_compare(v1,v2) ) then return false end
    end
    return true  
end