------------------------------------| Variable Declaration |---------------------------------
ESX = nil
------------------------------------| Initial ESX |------------------------------------------
TriggerEvent("esx:getSharedObject",function(obj) ESX = obj end)
------------------------------------| Usfull Functions |-------------------------------------
function GetCoordZ(x, y)
	--local groundCheckHeights = { 40.0, 41.0, 42.0, 43.0, 44.0, 45.0, 46.0, 47.0, 48.0, 49.0, 50.0, 100.0, 150.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0 }
    local groundCheck = 500.0
    local groundCheckmin = -500.0
    for height=groundCheck,groundCheckmin,-0.1 do
        local foundGround, z = GetGroundZFor_3dCoord(x, y, height)
        if foundGround then
			return z
		end
    end
    return false
    --[[
    for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)
		if foundGround then
			return z
		end
	end
	return nil
    --]]

end
function generateAnimalSpawnLocation(HuntingArea, areaRange)
    local xPlayer = ESX.GetPlayerFromId(source)
    local nearestHuntingAreaCorrd = HuntingArea.coord
    local plyCoords = xPlayer.getCoords(true)
    local dist = #(plyCoords - nearestHuntingAreaCorrd)
    if dist < 500 then	-- prevent if map not loaded

        math.randomseed(GetGameTimer())
        local ranX = HuntingArea.x+(math.random(-areaRange, areaRange))

        Citizen.Wait(100)

        math.randomseed(GetGameTimer())
        local ranY = HuntingArea.y+(math.random(-areaRange, areaRange))

        local ranZ = GetCoordZ(ranX, ranY)
        if ranZ ~= false then
            return vector3(ranX,ranY,ranZ)
        else
            print("not found ground coord Z")
            return false
        end
    else
        print("player is to far to spawn a Animal")
        return false
    end
	
end
------------------------------------| Register Net Events |-------------------------------------
RegisterServerEvent('lp_hunting:reward')
AddEventHandler('lp_hunting:reward', function(Weight)
    local xPlayer = ESX.GetPlayerFromId(source)

    if Weight >= 1 then
        xPlayer.addInventoryItem('meat', 1)
    elseif Weight >= 9 then
        xPlayer.addInventoryItem('meat', 2)
    elseif Weight >= 15 then
        xPlayer.addInventoryItem('meat', 3)
    end

    xPlayer.addInventoryItem('leather', math.random(1, 4))
        
end)

RegisterServerEvent('lp_hunting:sell')
AddEventHandler('lp_hunting:sell', function()
    local xPlayer = ESX.GetPlayerFromId(source)

    local MeatPrice    = 400
    local LeatherPrice = 170

    local MeatQuantity = xPlayer.getInventoryItem('meat').count
    local LeatherQuantity = xPlayer.getInventoryItem('leather').count

    if MeatQuantity > 0 or LeatherQuantity > 0 then
        xPlayer.addMoney(MeatQuantity * MeatPrice)
        xPlayer.addMoney(LeatherQuantity * LeatherPrice)

        xPlayer.removeInventoryItem('meat', MeatQuantity)
        xPlayer.removeInventoryItem('leather', LeatherQuantity)
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Du verkaufst ' .. LeatherQuantity + MeatQuantity .. 'kg und erhältst ~g~' .. LeatherPrice * LeatherQuantity + MeatPrice * MeatQuantity..'$')
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, '~r~Du hast weder Fleisch noch Leder dabei.')
    end
        
end)


RegisterServerEvent('lp_hunting:spawnPeds')
AddEventHandler('lp_hunting:spawnPeds', function(nearestHuntingArea)
    local peds = {}
    local maxAnimalsInHuttingArea = nearestHuntingArea.radius*0.1
    while #(peds) < maxAnimalsInHuttingArea do
        for index,v in ipairs(Config.Animals) do
            local animal = Config.Animals[index]
            local spawnprobability = animal.probability
            if spawnprobability >= math.random() then
                local spawnLocation = generateAnimalSpawnLocation()
                if spawnLocation ~= false then
                    local AnimalPed = CreatePed(5, GetHashKey(animal.model), spawnLocation.x, spawnLocation.y, spawnLocation.z, 0.0, true, true)
                    table.insert(peds, {id = NetworkGetNetworkIdFromEntity(AnimalPed)})
                    if #(peds) < maxAnimalsInHuttingArea then
                        break
                    end
                end
               
            end
        end
    end
    TriggerClientEvent('lp_hunting:pedsSpawned', source, peds)
end)

--[[
RegisterServerEvent('lp_hunting:deletePeds')
AddEventHandler('lp_hunting:spawnPeds', function(AnimalPositions)
    local peds = {}

    for k, v in pairs(AnimalPositions) do
        local Animal = CreatePed(5, GetHashKey('a_c_deer'), v.x, v.y, v.z, 0.0, true, true)

        table.insert(peds, {id = NetworkGetNetworkIdFromEntity(Animal)})
    end

    TriggerClientEvent('lp_hunting:pedsSpawned', source, peds)
end)
--]]

RegisterServerEvent('lp_hunting:removePed')
AddEventHandler('lp_hunting:removePed', function(AnimalId)
    DeleteEntity(NetworkGetEntityFromNetworkId(AnimalId))
end)
