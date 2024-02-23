lib.locale()

Service = {
    -- [src] = available <bool>
}
local latestId = 1
local callers = {}
TaxiCalls = {
    --[[
        @param 
        [id] = {id= 1, caller=src, callerName="John Doe"}
    ]]
}

lib.callback.register('neyzz_taxijob:setDuty', function(src, toggle)
    if toggle then
        Service[src] = true
    else
        table.remove(service, src)
    end
end)


lib.callback.register('neyzz_taxijob:setAvailability', function(src, toggle)
    if lib.table.contains(Service, src) then
        Service[src] = toggle
    end
end)

lib.callback.register('neyzz_taxi:callTaxi', function(src)
    debugPrint('New taxi call from '..src)
    if lib.table.contains(callers, src) then
        TriggerClientEvent('ox_lib:notify', src, {
            title=locale('taxi_company_name'),
            icon="fas fa-taxi",
            type="error",
            description=locale('taxi_already_called')
        })
        return
    end
    TriggerClientEvent('ox_lib:notify', src, {
        title=locale('taxi_company_name'),
        icon="fas fa-taxi",
        description=locale('taxi_called_success')
    })
    table.insert(callers, src)
    TaxiCalls[latestId] = {
        id=latestId,
        caller=src,
        callerName = ESX.GetPlayerFromId(src).getName()
    }
    latestId += 1
    debugPrint(json.encode(TaxiCalls))
    SendTaxisNewcall()
end)

local function prepareNuiCalls(src)
    local taxiCalls = {
        ---- { id= 12, name= "John Doe", roadName= "Joshua Road", destination= "Vespucci", distance= 140.5 }
    }
    for k, v in pairs(TaxiCalls) do
        local xCaller = ESX.GetPlayerFromId(v.caller)
        local pos = xCaller.getCoords(true)
        table.insert(taxiCalls, {id = v.id, name = v.callerName, callerPos = pos, destination="Unknown", })
    end
    return taxiCalls
end

lib.callback.register('neyzz_taxi:getCalls', prepareNuiCalls)


function SendTaxisNewcall()
    for k, v in pairs(Service) do
        TriggerClientEvent('neyzz_taxi:refreshRides', k, prepareNuiCalls(k))
        TriggerClientEvent('ox_lib:notify', k, {
            title=locale('taxi_company_name'),
            icon="fas fa-taxi",
            description=locale('taxi_new_call')
        })
    end
end