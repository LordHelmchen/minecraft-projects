require("util")

Combustor = {chamber = nil, input_inv = nil, block_inv_direction = "back", dropper = nil, redstone_integrator = nil, redstone_direction = "north", is_blocker = function(item) return (string.match(item.name, ".+nugget.*") and item.nbtHash ~= nil) end}

function Combustor:new(o, x, z, y, input_inv, block_inv_direction, dropper, redstone_integrator, redstone_direction)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    self:set_chamber(x, z, y)
    self:set_input_inv(input_inv)
    self:set_block_inv_direction(block_inv_direction)
    self:set_dropper(dropper)
    self:set_redstone_integrator(redstone_integrator)
    self:set_redstone_direction(redstone_direction)
    return o
end

function Combustor:set_chamber(x,z,y) 
    self.chamber = {x = x,z = z,y = y}
end
function Combustor:get_chamber() 
    return self.chamber
end

function Combustor:set_redstone_integrator(integrator) 
    self.redstone_integrator = integrator or nil
end
function Combustor:get_redstone_integrator() 
    return self.redstone_integrator
end

function Combustor:set_redstone_direction(direction)
    self.redstone_direction = direction or "north"
end
function Combustor:get_redstone_direction()
    return self.redstone_direction
end

function Combustor:set_dropper(dropper)
    self.dropper = dropper or nil
end
function Combustor:get_dropper()
    return self.dropper
end

function Combustor:set_input_inv(input_inv)
    self.input_inv = input_inv or nil
end
function Combustor:get_input_inv()
    return self.input_inv
end

function Combustor:set_block_inv_direction(block_inv_direction)
    self.block_inv_direction = block_inv_direction or "back"
end
function Combustor:get_set_block_inv_direction()
    return self.block_inv_direction
end

function Combustor:set_is_blocker(is_blocker)
    self.is_blocker = is_blocker or function(item) return (string.match(item.name, ".+nugget.*") and item.nbtHash ~= nil) end
end
function Combustor:get_is_blocker()
    return self.is_blocker
end

--send a redstone pulse to the combustion chamber
function Combustor:combust()
    print("redstone on")
    self.redstone_integrator.setOutput(self.redstone_direction, true)
    os.sleep(0.05)
    print("redstone off")
    self.redstone_integrator.setOutput(self.redstone_direction, false)
end

--suck blocker item from adjacent chest into input
function Combustor:block_input()
    print("block input")
    self.input_inv.pullItem(self.block_inv_direction)
end

--move the blocker item to the adjacent chest
function Combustor:free_input()
    print("free input")
    Util.move_items_predicate(self.input_inv, self.block_inv_direction, function(slot, item)
        return self.is_blocker(item)
    end)
    self.input_inv.pushItem(self.block_inv_direction)
end

--move all items except the blocker from input_inventory into the dropper
function Combustor:drop_items()
    print("drop items")
    Util.move_items_predicate(self.input_inv, self.dropper, function(slot, item)
        return not self.is_blocker(item)
    end)
end

--check the input chest. Compare with last check. If not empty and the same items, then return
function Combustor:wait_for_input()
    local last = {}
    local current = {}
    while true do
        print("save last input")
        last = current
        print("sleep")
        sleep(0.05)
        print("awake")
        coroutine.yield("combustor.wait_for_input")
        print("get input list from " , peripheral.getName(self.input_inv))
        current = self.input_inv.list()
        print("comparison")
        local eq = #last == #current and (#last == 0 or Util.recursive_compare(last, current))
        if eq and #current > 0 then
            return
        end
    end
end

return Combustor