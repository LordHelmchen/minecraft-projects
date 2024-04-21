# Crafters

## Multi Crafter

There are two base variants in this folder, that derive from the generic MultiCrafter.

- The *RedstoneCrafter*, that starts on a redstone pulse and where all crafters are of the same type.
- And the *TransformationMultiCrafter*, where the item inserted into the main crafter block gets transformed by other items in the crafter block around it.

The base class *MultiCrafter* can learn recipes from manual input items in the crafters and comes with an ME mode, where it matches the items in the input chest exactly against it's *RecipeCollection*.

Recipes will change when your setup moves, because the order of the crafters matters.

It has a nice GUI and setup examples can be found in the parent folder (*run_mech_crafter.lua* and *run_enchanting_apparatus.lua*).

### Example Implementations

#### Create Mechanical Crafter

The Create *Mechanical Crafter* derives from RedstoneCrafter. It autmatically outputs into a defined inventory, which will then be monitored for change.

#### Ars Nouveau Enchanting Apparatus

The *Enchanting Apparatus* from Ars Nouveau is a block surrounded by Arcane Pedestals, which hold all but one ingredient.

The implementation needs a buffer chest as input, because the item in the main block is not accessible until it is successfully transformed or the craft gets interrupted.
The input buffer is, where the last item will have to be inserted, when learning a new recipe.

The transformed items stay inside the apparatus and will be moved to the specified output inventory by the program.

## Known Issues

The crafter menu might get stuck in the wrong color, when not enough ingredients are supplied.