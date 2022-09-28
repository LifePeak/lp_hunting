ESX                = nil

TriggerEvent('FIVELIFERPDEZXN4OmdldFNoYXJlZE9iamVjdAZICKZACKHD', function(obj) ESX = obj end)

RegisterServerEvent('esx-qalle-hunting:reward')
AddEventHandler('esx-qalle-hunting:reward', function(Weight)
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

RegisterServerEvent('esx-qalle-hunting:sell')
AddEventHandler('esx-qalle-hunting:sell', function()
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

RegisterServerEvent('esx_hunting:spawnPeds')
AddEventHandler('esx_hunting:spawnPeds', function(positions)
    local peds = {}

    for k, v in pairs(positions) do
        local Animal = CreatePed(5, GetHashKey('a_c_deer'), v.x, v.y, v.z, 0.0, true, true)

        table.insert(peds, {id = NetworkGetNetworkIdFromEntity(Animal)})
    end

    TriggerClientEvent('esx_hunting:pedsSpawned', source, peds)
end)

RegisterServerEvent('esx_hunting:deletePeds')
AddEventHandler('esx_hunting:spawnPeds', function(AnimalPositions)
    local peds = {}

    for k, v in pairs(AnimalPositions) do
        local Animal = CreatePed(5, GetHashKey('a_c_deer'), v.x, v.y, v.z, 0.0, true, true)

        table.insert(peds, {id = NetworkGetNetworkIdFromEntity(Animal)})
    end

    TriggerClientEvent('esx_hunting:pedsSpawned', source, peds)
end)

RegisterServerEvent('esx_hunting:removePed')
AddEventHandler('esx_hunting:removePed', function(AnimalId)
    DeleteEntity(NetworkGetEntityFromNetworkId(AnimalId))
end)

function sendNotification(xsource, message, messageType, messageTimeout)
    TriggerClientEvent('notification', xsource, message)
end