require('common.util')
require('crafter.recipe')
require('crafter.recipe_collection')
require 'crafter.multi_crafter'

--A crafter that get's activated by a redstone pulse
RedstoneCrafter = MultiCrafter:new()

function RedstoneCrafter:new(o, input_inv, output_inv, recipes, me_inv, redstone_direction, redstone_integrator, on_craft_start, on_craft_end)
    self.__index = self
    setmetatable(RedstoneCrafter, {__index = MultiCrafter})
    o = o or MultiCrafter:new(o, input_inv, output_inv, recipes, me_inv, on_craft_start, on_craft_end)   -- create object if user does not provide one
    setmetatable(o, self)
    o:set_redstone_integrator(redstone_integrator)
    o:set_redstone_direction(redstone_direction)
    o:set_redstone_integrator(redstone_integrator)
    o:set_redstone_direction(redstone_direction)
    return o
end

function RedstoneCrafter:get_name()
    return "RedstoneCrafter (abstract)"
end

function RedstoneCrafter:set_redstone_integrator(integrator) 
    self.redstone_integrator = integrator or nil
end
function RedstoneCrafter:get_redstone_integrator() 
    return self.redstone_integrator
end

function RedstoneCrafter:set_redstone_direction(direction)
    self.redstone_direction = direction or "north"
end
function RedstoneCrafter:get_redstone_direction()
    return self.redstone_direction
end

function RedstoneCrafter:activate_redstone()
    local rs_src
    if self.redstone_integrator then
        rs_src = self.redstone_integrator
    else
        rs_src = rs
    end
    --print("redstone on")
    rs_src.setOutput(self.redstone_direction, true)
end

function RedstoneCrafter:deactivate_redstone()
    local rs_src
    if self.redstone_integrator then
        rs_src = self.redstone_integrator
    else
        rs_src = rs
    end
    --print("redstone off")
    rs_src.setOutput(self.redstone_direction, false)
end

function RedstoneCrafter:send_redstone_pulse()
    self:activate_redstone()
    os.sleep(0.05)
    self:deactivate_redstone()
end

function RedstoneCrafter:activate_craft(recipe)
    self:send_redstone_pulse()
end

return RedstoneCrafter