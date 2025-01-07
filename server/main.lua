------------------------------------| Variable Declaration |---------------------------------
local msgpipe = {} -- in need this pipe sync msg's from server to client and client to server [source] = msg
local animals = {} -- lets save all Enentys to delete them on skript restart
------------------------------------| Initial ESX |------------------------------------------

if Config.UseOldESX then
	ESX = nil
    TriggerEvent("esx:getSharedObject",function(obj) ESX = obj end)
end




AddEventHandler('esx:playerLoaded', function (source)
    removeHuntingItems(source)
end)


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
    msgpipe[src] = nil -- resetting msg pipe
    return tmp_msg
end

function giveHuntingItems(source)
    exports.ox_inventory:AddItem(source, Config.HuntingWeapon, 1, { isHuntingItem = true })
    exports.ox_inventory:AddItem(source, "WEAPON_KNIFE", 1, { isHuntingItem = true })
    for _, item in pairs(Config.HuntingItems) do 
        exports.ox_inventory:AddItem(source, item.name, item.amount, { isHuntingItem = true })
    end
    return
end

function removeHuntingItems(source)
    Citizen.CreateThread(function()
        while exports.ox_inventory:GetInventory(source) == false do
            Citizen.Wait(500)
        end
        
        local inventory = exports.ox_inventory:GetInventory(source)
        for _, item in pairs(inventory.items) do
            if item.metadata then
                if item.metadata.isHuntingItem then
                    exports.ox_inventory:RemoveItem(source, item.name, item.count, item.metadata)
                end
            end
        end
    end)
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

function spawnAnimals(nearestHuntingArea,peds,src)
    if nearestHuntingArea == nil or peds == nil or src == nil then
        print("spawnAnimals: nearestHuntingArea, peds, src is nil")
        return false
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    local maxAnimalsInHuttingArea = nearestHuntingArea.radius*0.1
    while #(peds) < maxAnimalsInHuttingArea do
        for index,v in ipairs(Config.Animals) do
            local animal = Config.Animals[index]
            local spawnprobability = animal.probability
            if spawnprobability >= math.random() then
                local spawnLocation = generateAnimalSpawnLocation(nearestHuntingArea.coord,nearestHuntingArea.radius,src)
                if spawnLocation ~= false then
                    local AnimalPed = CreatePed(5, GetHashKey(animal.model), spawnLocation.x, spawnLocation.y, spawnLocation.z, 0.0, true, false)
                  
                    if AnimalPed ~= 0 then
                        local AnimalNetId =  NetworkGetNetworkIdFromEntity(AnimalPed)
                        if AnimalNetId ~= 0 then
                            table.insert(peds, {id = AnimalNetId})
                            table.insert(animals, {id = AnimalNetId})
                            if #(peds) < maxAnimalsInHuttingArea then
                                break
                            end
                        end
                    end
                end
               
            end
        end
        Citizen.Wait(10)
        --print("Spawning Animal...")
        --print(#peds-maxAnimalsInHuttingArea)
    end
    Citizen.Wait(5000)
    xPlayer.triggerEvent("lp_hunting:pedsSpawned",peds)
end
------------------------------------| Register Net Events |-------------------------------------
RegisterServerEvent('lp_hunting:reward')
AddEventHandler('lp_hunting:reward', function(Animal)
    local xPlayer = ESX.GetPlayerFromId(source)
    --print("reward1")
    local Entity = NetworkGetEntityFromNetworkId(Animal)
    if Entity ~=0 then
        local animalHash = GetEntityModel(Entity)
        --print("rewar2")

        if animalHash == nil or animalHash == false then
            print("Error in lp_hunting:reward: cant get animalHash")
        end
        for k,v in pairs(Config.Animals) do
            if GetHashKey(v.model) == animalHash then
                --print("reward3")

                for kk,vv in pairs(v.loot) do
                    local itemAmmount =  math.random(1, vv)
                    if xPlayer.canCarryItem(kk, itemAmmount) then
                        xPlayer.addInventoryItem(kk, itemAmmount)
                    else
                        xPlayer.showNotification(_U("cant_carry_item"))
                        break
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("lp_hunting:giveHuntingItems")
AddEventHandler("lp_hunting:giveHuntingItems", function()
    giveHuntingItems(source)
end)

RegisterNetEvent("lp_hunting:removeHuntingItems")
AddEventHandler("lp_hunting:removeHuntingItems", function()
    removeHuntingItems(source)
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
        local totalPrice = (LeatherPrice * LeatherQuantity + MeatPrice * MeatQuantity)
        local totalQuantity = (LeatherQuantity + MeatQuantity)
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('sell_items',totalQuantity,totalPrice))
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('no_meat_lether_in_inventory'))
    end
        
end)

-- Respawn Peds is unsed if an Animal run out of Range then a new gets spawnd in the aria
RegisterServerEvent('lp_hunting:respawnPed')
AddEventHandler('lp_hunting:respawnPed', function(nearestHuntingArea,peds)
    spawnAnimals(nearestHuntingArea,peds,source)
end)

RegisterServerEvent('lp_hunting:spawnPeds')
AddEventHandler('lp_hunting:spawnPeds', function(nearestHuntingArea)
    spawnAnimals(nearestHuntingArea,{},source)
end)


RegisterServerEvent('lp_hunting:server:sendcalculatedZCordinate')
AddEventHandler('lp_hunting:server:sendcalculatedZCordinate', function(z)
    msgpipe[source] = z -- set msg into the rigt msg pipe
end)


RegisterServerEvent('lp_hunting:removePed')
AddEventHandler('lp_hunting:removePed', function(AnimalId)
    local entity = NetworkGetEntityFromNetworkId(AnimalId)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end)

AddEventHandler('onResourceStarting', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    for index,v in ipairs(animals) do
        local Animal = NetworkGetEntityFromNetworkId(v.id)
        if DoesEntityExist(Animal) then
            DeleteEntity(Animal)
            table.remove(animals,index)
        end

    end

end)
