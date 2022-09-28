-- 
-- Truck Deliveries by SeaLife
--

name "Truck Deliveries (ESX)"

description "Delivery Goods with a Truck."

author "SeaLife"

version "1.0.0-SNAPSHOT"

url "https://r3ktm8.de"

client_script {
    "@NativeUI/NativeUI.lua",
	"config.lua",
	"shared/functions.lua",
	"client/main.lua"
}

server_script {
	'@mysql-async/lib/MySQL.lua',
    "config.lua",
	"shared/functions.lua",
    "server/main.lua"
}

ui_page('assets/index.html')

files({
	'assets/index.html',
	'assets/listener.js',
	'assets/styles.css',
	'assets/font-face.css',
	'assets/dynamic.css'
})

fx_version 'cerulean'

lua54 'yes'

game "gta5"