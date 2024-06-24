
-- Variables
local ESX = exports["es_extended"]:getSharedObject()

-- Commands
--[[
RegisterCommand('taxi', function(source)
    TriggerClientEvent('citra-taxi:client:callOrCancelTaxi', source)
end)

RegisterCommand('taxigo', function(source)
    TriggerClientEvent('citra-taxi:client:setDestination', source)
end)

RegisterCommand('taxifast', function(source)
    TriggerClientEvent('citra-taxi:client:speedUp', source)
end)

RegisterCommand('taxislow', function(source)
    TriggerClientEvent('citra-taxi:client:speedDown', source)
end)
]]

---Function that controls IA taix behavior
---@param src any
---@param action 'call' | 'go' | 'fast' | 'slow'
lib.callback.register('neyzz_taxi:ia_taxi', function (src, action)
    if action == 'call' then
        TriggerClientEvent('citra-taxi:client:callOrCancelTaxi', source)
    elseif action == 'go' then
        TriggerClientEvent('citra-taxi:client:setDestination', source)
    elseif action == "fast" then
        TriggerClientEvent('citra-taxi:client:speedUp', source)
    else
        TriggerClientEvent('citra-taxi:client:speedDown', source)
    end
end)

-- Events
RegisterNetEvent('citra-taxi:server:payFare', function(time)
    local src = source
    local fare = math.ceil(Config.pnj.Fare.base + (Config.pnj.Fare.tick * (time / Config.pnj.Fare.tickTime)))

    if fare > 0 then
        local xPlayer = ESX.GetPlayerFromId(src)
        xPlayer.removeMoney(fare)
        TriggerClientEvent('citra-taxi:client:farePaid', src, fare)
    end
end)
