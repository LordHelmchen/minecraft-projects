<div id="top"></div>

<!-- ABOUT THE PROJECT -->
## About The Project

![5 Combustor Setup Screen Shot](/combustion/images/5_combustors.png?raw=true)

This is for automating the Minecraft mod Skyresources 2.

Since the Skyresources 2 Smart Combustion Controller just combusts a single item at a time, I felt the need to make it faster and ME compatible. 
Using this code on a CC:Tweaked computer in combination with a Plethora Entity Sensor, you can combust anything with up to 5 stacks of output per combustion very very quickly.

### Prerequisites

The following Minecraft Mods are used:

Skyresources 2
CC:Tweaked
Plethora

### Setup

1. Build a combustor and add a Redstone Integrator to its back, a Wired Modem on top of the Quick Dropper, and two inventories (input and blocker chest) next to each other on top of the modem.
   ![unwired block setup](/combustion/images/unwired.png)
2. Add the modems and wires as needed. The computer needs a manipulator with an entity sensor in order to check, if items are in the chamber.
   ![wired block setup](/combustion/images/wired.png)
3. Add a single "Combust Blocker" named item into the blocker chest (the one not directly on top of the modem).
   ![combust blocker in mini chest](/combustion/images/blocker.png)
4. When using Applied Energistics for crafting set the ME interface to blocking mode.
   ![blocking mode on me interface](/combustion/images/blocking_mode.png)
5. Clone the repository on your computer or copy the files otherwise.
6. Edit run_cc.lua and configure your combustion setup.

   ```cc:add_combustor(x, z, y, input_inv, block_inv_direction, dropper, redstone_integrator, redstone_direction, collector, output_inv)```
   
   ```cc:add_combustor(-4, -1, -2, peripheral.wrap("minecraft:chest_0"), "north", peripheral.wrap("skyresources:quickdroppertile_0"), peripheral.wrap("redstone_integrator_0"), "south", peripheral.wrap("skyresources:combustioncollectortile_0"), peripheral.wrap("minecraft:chest_5"))```
   
   The coordinates describe the empty chamber of the combustor relative to the computer. The block_inv_direction is relative to the input chest and needs to be a cardinal direction.
   Same for the redstone_direction, which describes the position of the casing relative to the redstone integrator.
   The names are displayed as soon as the modem next to the peripheral is activated via right click.
7. Rename run_cc.lua to startup.lua.
