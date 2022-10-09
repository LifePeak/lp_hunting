------------------------------------| Variable Declaration |---------------------------------
ESX = nil
local msgpipe = {} -- in need this pipe sync msg's from server to client and client to server [source] = msg
------------------------------------| Initial ESX |------------------------------------------
TriggerEvent("esx:getSharedObject",function(obj) ESX = obj end)
------------------------------------| Usfull Functions |-------------------------------------
function GetCoordZ(x, y, src)
    if x == nil or y == nil or src == nil then
        print("GetCoordZ: x,y,z or src is nil")
        return false
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.triggerEvent("lp_hunting:client:calculateZCordinate",x,y)
    while msgpipe[src] == nil do -- waiting for client msg to arive
        Citizen.Wait(1)
    end
    if msgpipe[source] == false then
        print("Error while calculating Z Cordinate")
        return false
    end
    
    local tmp_msg = msgpipe[src]
    print("Printing Msg pipe:")
    print(tmp_msg)
    msgpipe[src] = nil -- resetting msg pipe
    return tmp_msg
end
function generateAnimalSpawnLocation(nearestHuntingAreaCoord, areaRange,src)
    local xPlayer = ESX.GetPlayerFromId(src)
    local plyCoords = xPlayer.getCoords(true)
    local dist = #(plyCoords - nearestHuntingAreaCoord)
    if dist < 500 then	-- prevent if map not loaded

        math.randomseed(GetGameTimer())
        local ranX = nearestHuntingAreaCoord.x+(math.random(-areaRange, areaRange))

        Citizen.Wait(100)

        math.randomseed(GetGameTimer())
        local ranY = nearestHuntingAreaCoord.y+(math.random(-areaRange, areaRange))

        local ranZ = GetCoordZ(ranX, ranY,src)
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
    local src = source
    local peds = {}
    local xPlayer = ESX.GetPlayerFromId(src)
    local maxAnimalsInHuttingArea = nearestHuntingArea.radius*0.1
    while #(peds) < maxAnimalsInHuttingArea do
        for index,v in ipairs(Config.Animals) do
            local animal = Config.Animals[index]
            local spawnprobability = animal.probability
            if spawnprobability >= math.random() then
                local spawnLocation = generateAnimalSpawnLocation(nearestHuntingArea.coord,nearestHuntingArea.radius,src)
                if spawnLocation ~= false then
                    local AnimalPed = CreatePed(5, GetHashKey(animal.model), spawnLocation.x, spawnLocation.y, spawnLocation.z, 0.0, true, true)
                    table.insert(peds, {id = NetworkGetNetworkIdFromEntity(AnimalPed)})
                    if #(peds) < maxAnimalsInHuttingArea then
                        break
                    end
                end
               
            end
        end
    Citizen.Wait(1)
    print("Waiting for spawning peds..")
    end
    print("Send Animals BackToPlayer")
    xPlayer.triggerEvent("lp_hunting:pedsSpawned",peds)
end)


RegisterServerEvent('lp_hunting:server:sendcalculatedZCordinate')
AddEventHandler('lp_hunting:server:sendcalculatedZCordinate', function(z)
    msgpipe[source] = z -- set msg into the rigt msg pipe
end)


RegisterServerEvent('lp_hunting:removePed')
AddEventHandler('lp_hunting:removePed', function(AnimalId)
    DeleteEntity(NetworkGetEntityFromNetworkId(AnimalId))
end)
