require("combustion.combustion_controller")

local cc = CombustionController:new({})
cc:add_combustor(-4, -1, -2, peripheral.wrap("minecraft:chest_0"), "north", peripheral.wrap("skyresources:quickdroppertile_0"), peripheral.wrap("redstone_integrator_0"), "south", peripheral.wrap("skyresources:combustioncollectortile_0"), peripheral.wrap("minecraft:chest_5"))
cc:add_combustor(-2, -1, -2, peripheral.wrap("minecraft:chest_1"), "north", peripheral.wrap("skyresources:quickdroppertile_1"), peripheral.wrap("redstone_integrator_1"), "south", peripheral.wrap("skyresources:combustioncollectortile_1"), peripheral.wrap("minecraft:chest_5"))
cc:add_combustor(0, -1, -2,  peripheral.wrap("minecraft:chest_2"), "north", peripheral.wrap("skyresources:quickdroppertile_2"), peripheral.wrap("redstone_integrator_2"), "south", peripheral.wrap("skyresources:combustioncollectortile_2"), peripheral.wrap("minecraft:chest_5"))
cc:add_combustor(2, -1, -2,  peripheral.wrap("minecraft:chest_3"), "north", peripheral.wrap("skyresources:quickdroppertile_3"), peripheral.wrap("redstone_integrator_3"), "south", peripheral.wrap("skyresources:combustioncollectortile_3"), peripheral.wrap("minecraft:chest_5"))
cc:add_combustor(4, -1, -2,  peripheral.wrap("minecraft:chest_4"), "north", peripheral.wrap("skyresources:quickdroppertile_4"), peripheral.wrap("redstone_integrator_4"), "south", peripheral.wrap("skyresources:combustioncollectortile_4"), peripheral.wrap("minecraft:chest_5"))
cc:run()