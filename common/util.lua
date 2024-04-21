Util = {}

--Move all items from one inventory to another, that match a predicate function.
-- from_i and to_i are wrapped inventory peripherals
-- predicate(slot, item) => bool
function Util.push_items_predicate(from_i, to_i, predicate)
    if from_i == nil or to_i == nil then return end
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
        if predicate == nil or predicate(slot, from_i.getItemMeta(slot)) then
            if(from_i.pushItems(to_name, slot) > 0) then
                count = count + 1
            end
        end
    end
    return count
end

--Move count items with the given named from one inventory to another.
-- from_i and to_i are wrapped inventory peripherals
function Util.push_items_by_name(from_i, to_i, item_name, count)
    if from_i == nil or to_i == nil then return end
    if not count then count = 1 end
    local from_name = nil
    local to_name = nil
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
        if item.name == item_name then
            local moved_count = from_i.pushItems(to_name, slot, count)
            count = count -  moved_count
        end
        if count == 0 then return 0 end
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

--check the inventory. Compare with last check. If not empty and the same items, then return
-- inv is a wrapped inventory
function Util.wait_until_inv_is_stable(inv, start, continue_function)
    local last = {}
    local current = {}
    continue_function = continue_function or function() return true end
    while continue_function() do
        --print("save last input")
        last = current
        --print("sleep")
        sleep(0.05)
        --print("awake")
        --coroutine.yield("Util.wait_until_inv_is_stable")
        --print("get input list from " , peripheral.getName(inv))
        current = inv.list()
        --print("comparison " , last , " and " , current)
        local eq = #last == #current and (#last == 0 or Util.recursive_compare(last, current))
        local eq_start = false
        if start then
            eq_start = Util.recursive_compare(start, current)
        end 
        if eq and #current > 0 and not eq_start then
            return current
        end
    end
end

function Util.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function Util.deep_copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[Util.deep_copy(k, s)] = Util.deep_copy(v, s) end
    return res
end

function Util.xor(a, b)
    return (a and not b) or (not a and b)
end