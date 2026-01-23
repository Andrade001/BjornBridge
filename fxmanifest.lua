fx_version "cerulean"
game "gta5"
lua54 "yes"
version "1.0.3"

author "Bjorn Ironside (bjorn_01)"
description "Discord: https://discord.gg/PJRRHQtavX"


ui_page "web/index.html"

shared_scripts {
    -- "@vrp/lib/utils.lua",           ----- Se utilizar vRP, vRPex ou Creative descomente esta linha. (If you use vRP, vRPex, or Creative, uncomment this line.)
    "config.lua",
    "language/*.lua",
    "utils/shared.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "utils/server/*.lua",
    "framework/**/server.lua"
}

client_scripts {
    "utils/client/*.lua",
    "framework/**/client.lua"
}

files {
    "web/*.html",
    "web/*.css",
    "web/*.js",
}
