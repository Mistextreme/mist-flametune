fx_version 'adamant'
games {'gta5'}

version '1.1'
lua54 'yes'

shared_scripts {"@ox_lib/init.lua"}

client_scripts {'config.lua', 'client/**.lua'}

server_scripts {'config.lua', '@oxmysql/lib/MySQL.lua', 'server/**.lua'}

escrow_ignore {'client/**.lua', 'server/**.lua', 'config.lua'}
