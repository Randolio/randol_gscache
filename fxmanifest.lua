fx_version 'cerulean'
game 'gta5'

author 'Randolio'
description 'Gs Cache'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'bridge/client/**.lua',
    'config.lua',
    'cl_cache.lua'
}

server_scripts {
    'bridge/server/**.lua',
    'sv_cache.lua'
}
