require("combustion_controller")

local cc = CombustionController:new(nil)
cc:add_combustor(-4, -1, -1, "minecraft:chest_0", "right", "skyresources:quickdroppertile_0", "redstone_integrator_0", "south")
cc:add_combustor(-2, -1, -1, "minecraft:chest_1", "right", "skyresources:quickdroppertile_1", "redstone_integrator_1", "south")
cc:add_combustor(0, -1, -1,  "minecraft:chest_2", "right", "skyresources:quickdroppertile_2", "redstone_integrator_2", "south")
cc:add_combustor(2, -1, -1,  "minecraft:chest_3", "right", "skyresources:quickdroppertile_3", "redstone_integrator_3", "south")
cc:add_combustor(4, -1, -1,  "minecraft:chest_4", "right", "skyresources:quickdroppertile_4", "redstone_integrator_4", "south")
cc:run()