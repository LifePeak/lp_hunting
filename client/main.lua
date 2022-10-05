------------------------------------| Variable Declaration |---------------------------------
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
ESX = nil
local AnimalPositions = {
	{ x=  -1201.4189453125, y = 4763.78515625,   z = 218.20310974121 },
	{ x = -913.37139892578, y = 4823.1943359375, z = 306.50598144531 },
	{ x = -1164.68, y = 4806.76, z = 223.11 },
	{ x = -1410.63, y = 4730.94, z = 44.0369 },
	{ x = -1377.29, y = 4864.31, z = 134.162 },
	{ x = -1259.99, y = 5002.75, z = 151.36 },
	{ x = -960.91, y = 5001.16, z = 183.0 },
}

local AnimalsInSession = {}

local Positions = {
	StartHunting = {
		blipId = nil,
		hint = "[E] Jagd starten", sprite = 442, label = "Jagdgrund",
		x = -1058.8522949219, y = 4915.3295898438, z = 211.81875610352
	},
	Sell = {
		blipId = nil,
		hint = "[E] Verkaufen", sprite = 467, label = "Wildhandel",
		x = 949.26916503906, y = -2102.3935546875, z = 30.675149917603
	},
	SpawnATV = {
		x = 0, y = 0, z = 0
	}
}
local Blips = {}
local HuntingAreaBlip = nil
local OnGoingHuntSession = false
local HuntCar = nil
------------------------------------| Initial ESX |------------------------------------------
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	PlayerData = ESX.GetPlayerData()
	while PlayerData == nil do
        Citizen.Wait(10)
    end
	ScriptLoaded()

end)
------------------------------------| Usfull Functions |-------------------------------------
function ScriptLoaded()
	Citizen.Wait(1000)
	LoadMarkers()

	local playerData = ESX.GetPlayerData()
	if Config.ReqireHuntingJob == true then
		if playerData.job.name == 'hunter' then
			LoadMapMarkers()
		end
	else
		LoadMapMarkers()
	end
end
-- notification Handler
function notificationHandler(icon,title,msg,color,sound)
	if Config.Notification.System ~= 'lp_notify' then
		ESX.ShowNotification(title..", "..msg)
	else
		TriggerEvent("lifepeak.notify",icon,title,msg,color,true,Config.Notification.Postion,Config.Notification.displaytime,sound)
	end
end

function LoadMapMarkers()
	Citizen.CreateThread(function()
		for index, v in pairs(Config.Mensions.StartHunting) do
			local label = "Jagdgrund"
			local blip = AddBlipForCoord(v.x, v.y, v.z)
			SetBlipSprite(blip, 442)
			SetBlipColour(blip, 75)
			SetBlipScale(blip, 0.7)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(label)
			EndTextCommandSetBlipName(blip)
			table.insert(Blips,Blip)
		end
		for index, v in pairs(Config.Mensions.Sell) do
			local label = "Wildhandel"
			local blip = AddBlipForCoord(v.x, v.y, v.z)
			SetBlipSprite(blip, v.sprite)
			SetBlipColour(blip, 467)
			SetBlipScale(blip, 0.7)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(label)
			EndTextCommandSetBlipName(blip)
			table.insert(Blips,Blip)
		end
	end)
end

function RemoveMapMarkers()
	Citizen.CreateThread(function()
		for index, v in pairs(Blips) do
			if index ~= 'SpawnATV' then
				RemoveBlip(v)
				v = nil
				talbe.remove(Blips,index)
			end
		end
	end)
end

function IsPlayerInHuntingArea()
	local plyCoords = GetEntityCoords(PlayerPedId())
	for k,v in pairs(Config.HuntingAreaRanges) do
		local huntingArea = v.coord
		local distance = #(plyCoords.xy-huntingArea.xy)
		if distance >= v.radius then
			return true
		end

	end
	return false
	--local distance = GetDistanceBetweenCoords(plyCoords, p.x, p.y, p.z, true)
end

function LoadMarkers()
	for _, ped in pairs(Config.Animals) do
		LoadModel(ped.model)
		while not HasModelLoaded(ped.model) do
			Citizen.Wait(100)
			print("Loading"..ped.model.."...")
		end
	end
	-- load Job Vehicle
	if Config.SpawnJobVehicle == true then
		LoadModel(Config.JobVehicle)
	end
	LoadAnimDict('amb@medic@standing@kneel@base')
	LoadAnimDict('anim@gangops@facility@servers@bodysearch@')

	Citizen.CreateThread(function()
		while true do
			local sleep = 500
			
			local plyCoords = GetEntityCoords(PlayerPedId())


			if OnGoingHuntSession and not IsPlayerInHuntingArea() then
				ESX.ShowNotification('~r~Deine Jagdsitzung wurde beendet! Du bist zuweit vom Jagdgebiet weg.')
				StartHuntingSession()
			end
			

			for index ,value in pairs(Config.Mensions.StartHunting) do
				local hint
				if OnGoingHuntSession then
					hint = '[E] Jagd beenden'
				end
				if not OnGoingHuntSession then
					hint = '[E] Jagd starten'
				end
				local distance = #(plyCoords-value)
				if distance < 5.0 then
					sleep = 5
					DrawM(hint, 27, value.x, value.y, value.z - 0.945, 255, 255, 255, 1.5, 15)
					if distance < 1.0 then
						if IsControlJustReleased(0, Keys['E']) then
							StartHuntingSession()
						end
					end
				end
			end
			for index ,value in pairs(Config.Mensions.Sell) do
				local distance = #(plyCoords-value)
				local hint = "[E] Verkaufe Items"
				if distance < 5.0 then
					sleep = 5
					DrawM(hint, 27, value.x, value.y, value.z - 0.945, 255, 255, 255, 1.5, 15)
					if distance < 1.0 then
						if IsControlJustReleased(0, Keys['E']) then
							SellItems()
						end
					end
				end
			end
			Citizen.Wait(sleep)
		end
	end)
end


function getNearestHuntingArea()
	local plyCoords = GetEntityCoords(PlayerPedId())
	local nearestHuntingArea = nil
	for index, v in ipairs(Config.HuntingAreaRanges) do
		if nearestHuntingArea == nil then
			nearestHuntingArea = index
		end
		if 	#(Config.HuntingAreaRanges[index].coord-plyCoords)	<	#(Config.HuntingAreaRanges[nearestHuntingArea].coord-plyCoords) then
			nearestHuntingArea = index
		end
	end
	print(Config.HuntingAreaRanges[nearestHuntingArea].coord)
	if nearestHuntingArea ~= nil then
		return Config.HuntingAreaRanges[nearestHuntingArea]

	else
		print("getNearestHuntingArea: nearestHuntingArea is nil")
		return false
	end
end
function StartHuntingSession()
	local plyCoords = GetEntityCoords(PlayerPedId())
	if OnGoingHuntSession then

		OnGoingHuntSession = false

		RemoveWeaponFromPed(PlayerPedId(), GetHashKey(Config.HuntingWeapon), true, true)
		RemoveWeaponFromPed(PlayerPedId(), GetHashKey("WEAPON_KNIFE"), true, true)

		RemoveBlip(HuntingAreaBlip)

		DeleteEntity(HuntCar)

		for index, value in pairs(AnimalsInSession) do
			if DoesEntityExist(value.id) then
				DeleteEntity(value.id)
				TriggerServerEvent('lp_hunting:removePed', NetworkGetNetworkIdFromEntity(value.id))
			end
		end

	else
		OnGoingHuntSession = true

		-- SpawnJobVehicle
		if Config.SpawnJobVehicle == true then
			HuntCar = CreateVehicle(GetHashKey(Config.JobVehicle), plyCoords.x,plyCoords.y,plyCoords.z, 169.79, true, false)
		end
 

		GiveWeaponToPed(PlayerPedId(), GetHashKey(Config.HuntingWeapon),45, true, false)
		GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_KNIFE"),0, true, false)

		-- Animals
		--[[
				local Positions = {
					StartHunting = {
						blipId = nil,
						hint = "[E] Jagd starten", sprite = 442, label = "Jagdgrund",
						x = -1058.8522949219, y = 4915.3295898438, z = 211.81875610352
					},
					Sell = {
						blipId = nil,
						hint = "[E] Verkaufen", sprite = 467, label = "Wildhandel",
						x = 949.26916503906, y = -2102.3935546875, z = 30.675149917603
					},
					SpawnATV = {
						x = 0, y = 0, z = 0
					}
				}
			--]]
		
		local nearestHuntingArea = getNearestHuntingArea()
		if nearestHuntingArea == false then
			print("Error while getting nearestHuntingArea: setting to 0")
			nearestHuntingArea = Config.HuntingAreaRanges[0]
		end
		HuntingAreaBlip = AddBlipForRadius(nearestHuntingArea.coord.x, nearestHuntingArea.coord.y, nearestHuntingArea.coord.z, nearestHuntingArea.radius)
		SetBlipHighDetail(HuntingAreaBlip, true)
		SetBlipColour(HuntingAreaBlip, 75)
		SetBlipAlpha(HuntingAreaBlip, 60)

		Citizen.CreateThread(function()

			TriggerServerEvent('lp_hunting:spawnPeds', nearestHuntingArea)

			-- wait for the server to create the peds and send them back to the client
			local spawnFailedTimer 	= 0
			while #AnimalPositions == 0 and spawnFailedTimer <= 10 do
				spawnFailedTimer = spawnFailedTimer + 1
				Citizen.Wait(200)
			end
			if spawnFailedTimer >= 10 then
				ESX.ShowNotification('~r~Es scheinen keine Tiere unterwegs zu sein! Versuche es später erneut.')
				OnGoingHuntSession()
				return
			end

			-- start hunting session
			ESX.ShowNotification('~g~Du hast eine neue Jagdsaison gestartet! Viel Glück!')

			while OnGoingHuntSession do
				local sleep = 500
				for index, value in ipairs(AnimalsInSession) do
					if DoesEntityExist(value.id) then
						local AnimalCoords = GetEntityCoords(value.id)
						local PlyCoords = GetEntityCoords(PlayerPedId())
						local AnimalHealth = GetEntityHealth(value.id)
						
						local PlyToAnimal = GetDistanceBetweenCoords(PlyCoords, AnimalCoords, true)

						if AnimalHealth <= 0 then
							SetBlipColour(value.Blipid, 3)
							if PlyToAnimal < 2.0 then
								sleep = 5

								ESX.Game.Utils.DrawText3D({x = AnimalCoords.x, y = AnimalCoords.y, z = AnimalCoords.z + 1}, '[E] Tier schlachten', 0.4)

								if IsControlJustReleased(0, Keys['E']) then
									if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('WEAPON_KNIFE')  then
										if DoesEntityExist(value.id) then
											table.remove(AnimalsInSession, index)
											SlaughterAnimal(value.id)
										end
									else
										ESX.ShowNotification('~r~Du benötigst ein Messer!')
									end
								end

							end
						end
					end
				end

				Citizen.Wait(sleep)

			end
				
		end)
	end
end

function SlaughterAnimal(AnimalId)

	TaskPlayAnim(PlayerPedId(), "amb@medic@standing@kneel@base" ,"base" ,8.0, -8.0, -1, 1, 0, false, false, false )
	TaskPlayAnim(PlayerPedId(), "anim@gangops@facility@servers@bodysearch@" ,"player_search" ,8.0, -8.0, -1, 48, 0, false, false, false )

	Citizen.Wait(5000)

	ClearPedTasksImmediately(PlayerPedId())

	local AnimalWeight = math.random(10, 160) / 10

	--ESX.ShowNotification('Du erhältst ' ..AnimalWeight.. 'kg Fleisch')

	TriggerServerEvent('lp_hunting:reward', AnimalWeight)
	TriggerServerEvent('lp_hunting:removePed', NetworkGetNetworkIdFromEntity(AnimalId))

	DeleteEntity(AnimalId)
end

function SellItems()
	TriggerServerEvent('lp_hunting:sell')
end

function LoadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(10)
    end
end

function LoadModel(model)
    while not HasModelLoaded(model) do
          RequestModel(model)
          Citizen.Wait(10)
    end
end

function DrawM(hint, type, x, y, z)
	ESX.Game.Utils.DrawText3D({x = x, y = y, z = z + 1.0}, hint, 0.4)
	DrawMarker(type, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 255, 255, 100, false, true, 2, false, false, false, false)
end



RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	if job.name == "hunter" then
		LoadMapMarkers()
	else
		RemoveMapMarkers()
	end
end)

RegisterNetEvent('esx_outlaw:isPositionWhitelisted')
AddEventHandler('esx_outlaw:isPositionWhitelisted', function(source, coords, cb)
	print("Is Player in Hunting Area?")
	cb(IsPlayerInHuntingArea() and OnGoingHuntSession)
end)

RegisterNetEvent('lp_hunting:pedsSpawned')
AddEventHandler('lp_hunting:pedsSpawned', function(PedPositions)
	for k, v in pairs(PedPositions) do
		local Animal = NetworkGetEntityFromNetworkId(v.id)
		TaskWanderStandard(Animal, true, true)
		SetEntityAsMissionEntity(Animal, true, true)

		local AnimalBlip = AddBlipForEntity(Animal)
		SetBlipSprite(AnimalBlip, 153)
		SetBlipColour(AnimalBlip, 1)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString('Reh')
		EndTextCommandSetBlipName(AnimalBlip)

		table.insert(AnimalPositions, {id = Animal, Blipid = AnimalBlip})
	end
end)
