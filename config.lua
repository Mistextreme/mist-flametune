Config = {}

Config.Usage = 'command' -- options: 'command', 'item'
Config.Command = 'flame' -- command to use if Config.Usage is set to 'command'

Config.Crackling = true -- enable/disable crackling particle

Permission = {}

Permission.Plate = false -- if true, only vehicles with a plate in the list below will be able to use the flame thrower.
Permission.Plates = {
    ['MAT 003'] = true,
    ['87IAI044'] = true,
    ['57PSH727'] = true,
}

