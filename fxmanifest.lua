-- Resource Metadata
fx_version 'cerulean'
games {'gta5'}
author 'ZickZackHD <ZickZackHD#4834>'
description 'Hunt animals'
version '1.0.0'
name 'lp_hunting'
url 'https://github.com/zickzackhd'
lua54 'yes'

shared_script {
	'config.lua',
}

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


dependencies {
	'es_extended'
}

