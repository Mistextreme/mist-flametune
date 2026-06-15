For command usage (Standalone/ESX/Qbcore) navigate to the config.lua file and set up Config.Usage to Config.Usage = 'command'.

----------------------------------------------------------------

For item usage (ESX/Qbcore):

QB-core: add it to the item to your item list in qbcore: 

    ['flametune']= {
        ['name'] = 'flametune', 
        ['label'] = 'Flame tune',
        ['weight'] = 1,
        ['type'] = 'item', 
        ['image'] = 'flametune.png',
        ['unique'] = false, 
        ['useable'] = true,
        ['shouldClose'] = true,
        ['combinable'] = nil,
        ['description'] = 'ECU flame tuning.'
    }

ESX with ox_inventory: add it to the item list:

    ['flametune'] = {
        label = 'Flame tune',
        weight = 1,
        stack = true,
        consume = 0,
        close = true,
        description = "ECU flame tuning.",
        server = {
            export = 'mist-flametune.flametune'
        }
    }

For older esx versions with the original item system add 'flametune' to your item database.

----------------------------------------------------------------

To enable plate allowlist navigate to the config.lua file and set the Permission.Plate to true and add the allowed plates in the Permission.Plates like the default examples.


