-- Variables
local curTaxi = {}
local blip, skippedOnCab = nil, false
local ESX = exports['es_extended']:getSharedObject()
lib.locale()
GOING = false

-- Functions
local function notify(msg, type)
    type = type == 'primary' and 'info' or type
    lib.notify({
        title=locale('taxi_company_name'),
        type=type,
        description=locale(msg)
    })
end

local function resetTaxiData()
    curTaxi = {
        vehicle = 0,
        ped = 0,
        dest = vector3(0, 0, 0),
        style = Config.pnj.DrivingStyles.Normal,
        speed = 26.0,
    }
    GOING = false
end

local function getStoppingLocation(coords)
    local _, nCoords = GetClosestVehicleNode(coords.x, coords.y, coords.z, 1, 3.0, 0)
    return nCoords
end

local function getStartingLocation(coords)
    local dist, vector, nNode, heading = 0, vector3(0, 0, 0), math.random(10, 20), 0

    while dist < Config.pnj.MinSpawnDist do
        nNode = nNode + math.random(10, 20)
        _, vector, heading = GetNthClosestVehicleNodeWithHeading(coords.x, coords.y, coords.z, nNode, 9, 3.0, 2.5)
        dist = #(coords - vector)
    end

    return vector, heading
end

local function createBlip()
    blip = AddBlipForEntity(curTaxi.vehicle)
    SetBlipSprite(blip, 198)
    SetBlipColour(blip, 5)
    SetBlipDisplay(blip, 2)
    SetBlipFlashes(blip, true)
    SetBlipFlashInterval(blip, 750)
    BeginTextCommandSetBlipName('Taxi')
    AddTextComponentSubstringBlipName(blip)
    EndTextCommandSetBlipName(blip)
end

local function wanderOff()
    if curTaxi.vehicle ~= 0 then
        SetVehicleDoorsShut(curTaxi.vehicle, false)
        TaskVehicleDriveWander(curTaxi.ped, curTaxi.vehicle, 20.0, Config.pnj.DrivingStyles.Normal)
        SetPedKeepTask(curTaxi.ped, true)
        SetEntityAsNoLongerNeeded(curTaxi.ped)
        SetEntityAsNoLongerNeeded(curTaxi.vehicle)

        RemoveBlip(blip)
        blip = nil

        resetTaxiData()
    end
end

local function driveTo()
    local speed = (curTaxi.style == Config.pnj.DrivingStyles.Rush) and curTaxi.speed * Config.pnj.RushSpeedMultiplier or curTaxi.speed
    TaskVehicleDriveToCoordLongrange(curTaxi.ped, curTaxi.vehicle, curTaxi.dest.x, curTaxi.dest.y, curTaxi.dest.z,
        speed, curTaxi.style, 5.0)
    SetPedKeepTask(curTaxi.ped, true)
    SetDriverAggressiveness(curTaxi.ped, (curTaxi.style == Config.pnj.DrivingStyles.Rush) and 0.75 or 0.5)
    for i = 0, GetNumberOfVehicleDoors(curTaxi.vehicle) do
        if GetVehicleDoorAngleRatio(curTaxi.vehicle, i) > 0.0 then
            SetVehicleDoorsShut(curTaxi.vehicle, false)
            break
        end
    end

end

function HandleKeys()
    local keysTable = {
        { locale('npc_start'),     46 },
        { locale('npc_faster'),     52 },
    }
    CreateThread(function()
        while curTaxi.vehicle ~= 0 do
            local waitTime = 1
            if IsPedInVehicle(PlayerPedId(), curTaxi.vehicle) then
                waitTime = 0

                if curTaxi.speed == Config.pnj.DrivingStyles.Normal then keysTable[2][1] = locale('npc_faster') end
                if curTaxi.speed == Config.pnj.DrivingStyles.Rush then keysTable[2][1] = locale('npc_slower') end
                if not GOING then keysTable[1][1] = locale('npc_start') end
                if GOING then keysTable[1][1] = locale('npc_stop') end
                local fivemScaleform = makeFivemInstructionalScaleform(keysTable)

                DrawScaleformMovieFullscreen(fivemScaleform, 255, 255, 255, 255, 0)

                if IsControlJustReleased(0, 46) then
                    if GOING then
                        TriggerEvent('citra-taxi:client:callOrCancelTaxi')
                    else
                        TriggerEvent('citra-taxi:client:setDestination')
                    end
                end


                if IsControlJustReleased(0, 52) then
                    if curTaxi.style == Config.pnj.DrivingStyles.Rush  then
                        TriggerEvent('citra-taxi:client:speedDown')
                    else
                        TriggerEvent('citra-taxi:client:speedUp')
                    end
                end
                
            end
            Citizen.Wait(0)
        end
        --cleanup of the scaleform movie
        SetScaleformMovieAsNoLongerNeeded()
    end)
end

local function park(inTaxi)
    local speed = curTaxi.speed
    curTaxi.speed = Config.pnj.SlowdownSpeed

    while speed > curTaxi.speed do
        speed = speed - 1.0
        TaskVehicleDriveToCoord(curTaxi.ped, curTaxi.vehicle, curTaxi.dest.x, curTaxi.dest.y, curTaxi.dest.z,
            speed, 0, joaat(Config.pnj.TaxiModel), curTaxi.style, 10.0, 1)
        Wait(100)
    end

    if not inTaxi then
        StartVehicleHorn(curTaxi.vehicle, 5000, joaat("NORMAL"), false)
    end
end

local function taxiDone()
    local plyPed = PlayerPedId()
    GOING = false
    if IsPedInVehicle(plyPed, curTaxi.vehicle, true) then
        local coords = GetEntityCoords(curTaxi.vehicle)
        curTaxi.dest = getStoppingLocation(coords)
        curTaxi.style = Config.pnj.DrivingStyles.Normal
        park()
        ClearGpsPlayerWaypoint()
    else
        wanderOff()
    end
end



local function waitForTaxiDone()
    local inTaxi, inTime, taxiCoords = false, 0, GetEntityCoords(curTaxi.vehicle)

    Citizen.CreateThread(function() -- Enter / exit taxi
        while curTaxi.vehicle ~= 0 do
            if IsControlJustPressed(0, 23) and not skippedOnCab then
                local plyPed = PlayerPedId()

                if inTaxi then

                    for i = 0, 5 do
                        SetVehicleDoorOpen(curTaxi.vehicle, i, false, true) -- will open every door from 0-5
                    end

                    TaskLeaveVehicle(plyPed, curTaxi.vehicle, 1)
                    TriggerServerEvent('citra-taxi:server:payFare', GetGameTimer() - inTime)

                    
                elseif GetVehiclePedIsTryingToEnter(plyPed) == curTaxi.vehicle then
                    ClearPedTasks(plyPed)
                    for i = 2, 1, -1 do
                        if IsVehicleSeatFree(curTaxi.vehicle, i) then
                            TaskEnterVehicle(plyPed, curTaxi.vehicle, 5000, i, 1.0, 1, 0)
                            break
                        end
                    end
                end
            end
            Wait(1)
        end
    end)

    CreateThread(function() -- Handle menu, & driver voice lines
        local lastSpoke = 0

        while curTaxi.vehicle ~= 0 and not skippedOnCab do
            local dist = #(curTaxi.dest - taxiCoords)
            local nowInTaxi = IsPedInVehicle(PlayerPedId(), curTaxi.vehicle, true)

            if nowInTaxi ~= inTaxi then
                inTaxi = nowInTaxi

                if inTaxi then
                    PlayPedAmbientSpeechNative(curTaxi.ped, "TAXID_WHERE_TO", "SPEECH_PARAMS_FORCE_NORMAL")
                    if inTime == 0 then inTime = GetGameTimer() end
                    while dist < 15.0 do
                        Wait(100)
                        dist = #(curTaxi.dest - taxiCoords)
                    end
                end
            end

            if inTaxi then
                if IsVehicleStuckOnRoof(curTaxi.vehicle) then
                    SetVehicleOnGroundProperly(curTaxi.vehicle)
                    Wait(1000)
                end

                if dist < 25.0 and GetGameTimer() - lastSpoke >= 30000 then
                    PlayPedAmbientSpeechNative(curTaxi.ped, "TAXID_CLOSE_AS_POSS", "SPEECH_PARAMS_FORCE_NORMAL")
                    lastSpoke = GetGameTimer()
                end
            end
            Wait(500)
        end
    end)

    Citizen.CreateThread(function() -- Taxi speed
        while curTaxi.vehicle ~= 0 and not skippedOnCab do
            taxiCoords = GetEntityCoords(curTaxi.vehicle)
            local dist = #(curTaxi.dest - taxiCoords)

            if dist < Config.pnj.SlowdownDist then
                if curTaxi.speed ~= Config.pnj.SlowdownSpeed then
                    park(inTaxi)
                end
            else
                local newSpeed

                if GetResourceState(Config.pnj.SpeedLimitResource) == "started" then
                    newSpeed = exports[Config.pnj.SpeedLimitResource][Config.pnj.SpeedLimitExport]()
                else
                    local _, _, flags = GetVehicleNodeProperties(taxiCoords.x, taxiCoords.y, taxiCoords.z)
                    newSpeed = Config.pnj.SpeedLimitZones[flags]
                end

                if newSpeed then
                    newSpeed = newSpeed * 0.44704
                    if newSpeed ~= curTaxi.speed then
                        curTaxi.speed = newSpeed
                        driveTo()
                    end
                end
            end

            Wait(100)
        end
    end)
end

local function spawnTaxi()
    local model = joaat(Config.pnj.TaxiModel)

    if IsModelValid(model) and IsThisModelACar(model) then
        local plyCoords = GetEntityCoords(PlayerPedId())
        local spawnCoords, spawnHeading = getStartingLocation(plyCoords)
        curTaxi.dest = getStoppingLocation(plyCoords)
        curTaxi.style = Config.pnj.DrivingStyles.Normal

        RequestModel(model)
        while not HasModelLoaded(model) do Wait(1) end

        curTaxi.vehicle = CreateVehicle(model, spawnCoords, spawnHeading, true, true)

        while not DoesEntityExist(curTaxi.vehicle) do Wait(10) end
        SetVehicleEngineOn(curTaxi.vehicle, true, true, false)
        SetHornEnabled(curTaxi.vehicle, true)
        SetVehicleFuelLevel(curTaxi.vehicle, 100.0)
        DecorSetFloat(curTaxi.vehicle, '_FUEL_LEVEL', GetVehicleFuelLevel(curTaxi.vehicle))
        SetVehicleDoorLatched(curTaxi.vehicle, -1, true, true, true)
        SetVehicleNumberPlateText(curTaxi.vehicle, 'NPC TAXI')

        SetVehicleAutoRepairDisabled(curTaxi.vehicle, false)
        for extra, enabled in pairs(Config.pnj.TaxiExtras) do
            SetVehicleExtra(curTaxi.vehicle, extra, enabled and 0 or 1)
        end

        SetModelAsNoLongerNeeded(model)

        model = joaat(Config.pnj.DriverModel)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(1) end
        curTaxi.ped = CreatePed(1, model, spawnCoords, spawnHeading, true, true)
        while not DoesEntityExist(curTaxi.ped) do Wait(10) end

        SetPedIntoVehicle(curTaxi.ped, curTaxi.vehicle, -1)
        SetAmbientVoiceName(curTaxi.ped, Config.pnj.DriverVoice)
        SetBlockingOfNonTemporaryEvents(curTaxi.ped, true)
        SetDriverAbility(curTaxi.ped, 1.0)

        SetModelAsNoLongerNeeded(model)

        createBlip()
        notify('npc_on_his_way', 'success')
        HandleKeys()
        
        

        if GetResourceState('qb-vehiclekeys') == "started" then
            exports['qb-vehiclekeys']:addNoLockVehicles(Config.pnj.TaxiModel)
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', curTaxi.vehicle, 1)
        end

        driveTo()
        waitForTaxiDone()
    end
end

local function setDestination()
    local waypoint = GetFirstBlipInfoId(8)

    if DoesBlipExist(waypoint) then
        if curTaxi.dest then PlayPedAmbientSpeechNative(curTaxi.ped, "TAXID_CHANGE_DEST", "SPEECH_PARAMS_FORCE_NORMAL") end
        curTaxi.dest = getStoppingLocation(GetBlipCoords(waypoint))
        driveTo()
        PlayPedAmbientSpeechNative(curTaxi.ped, "TAXID_BEGIN_JOURNEY", "SPEECH_PARAMS_FORCE_NORMAL")
    else
        PlayPedAmbientSpeechNative(curTaxi.ped, "TAXID_WHERE_TO", "SPEECH_PARAMS_FORCE_NORMAL")
    end
end

local function callCab(cancelExisting)
    if skippedOnCab and curTaxi.vehicle ~= 0 then -- Waits until the skipped cab is cleared
        notify("npc_cab_skipped", 'error')
    elseif curTaxi.vehicle == 0 or not DoesEntityExist(curTaxi.vehicle) then
        skippedOnCab = false
        spawnTaxi()
    elseif cancelExisting then
        taxiDone()
    end
end

-- Events
RegisterNetEvent('citra-taxi:client:callOrCancelTaxi', function()
    callCab(true)
    GOING = false
    debugPrint('On arrête le taxi', GOING)
end)

RegisterNetEvent('citra-taxi:client:callTaxi', function()
    callCab(false)
end)

RegisterNetEvent('citra-taxi:client:cancelTaxi', function()
    if curTaxi.vehicle ~= 0 and not skippedOnCab then
        curTaxi.dest = getStoppingLocation(GetEntityCoords(curTaxi.vehicle))
        taxiDone()
    end
end)

RegisterNetEvent('citra-taxi:client:setDestination', function()
    if curTaxi.vehicle ~= 0 and IsPedInVehicle(PlayerPedId(), curTaxi.vehicle, true) then
        setDestination()
        GOING = true
        debugPrint('On lance le taxi', GOING)
    end
end)

RegisterNetEvent('citra-taxi:client:speedUp', function()
    if curTaxi.vehicle ~= 0 and IsPedInVehicle(PlayerPedId(), curTaxi.vehicle, true) then
        PlayPedAmbientSpeechNative(curTaxi.ped, "TAXID_SPEED_UP", "SPEECH_PARAMS_FORCE_NORMAL")
        curTaxi.style = Config.pnj.DrivingStyles.Rush
        driveTo()
    end
end)

RegisterNetEvent('citra-taxi:client:speedDown', function()
    if curTaxi.vehicle ~= 0 and IsPedInVehicle(PlayerPedId(), curTaxi.vehicle, true) then
        PlayPedAmbientSpeechNative(curTaxi.ped, "TAXID_BEGIN_JOURNEY", "SPEECH_PARAMS_FORCE_NORMAL")
        curTaxi.style = Config.pnj.DrivingStyles.Normal
        driveTo()
    end
end)

RegisterNetEvent('citra-taxi:client:farePaid', function(fare)
    notify('Fare of $' .. fare + 0.00 .. ' paid', 'success')
    Wait(2000)
    wanderOff()
end)

RegisterNetEvent('citra-taxi:client:alertPolice', function()
    local coords = GetEntityCoords(PlayerPedId())
    local alertMsg = 'Taxi Fare Theft'
    local taxiPed = curTaxi.ped
    skippedOnCab = true

    CreateThread(function()
        for i = 1, 60 do -- Keep cab around for 30 mins
            PlayPedAmbientSpeechNative(taxiPed, "TAXID_RUN_AWAY", "SPEECH_PARAMS_FORCE_NORMAL")
            Wait(30000)
        end
        wanderOff()
    end)

    if GetResourceState('ps-dispatch') == 'started' then
        exports['ps-dispatch']:CustomAlert({
            message = alertMsg,
            description = alertMsg,
            icon = 'fas fa-taxi',
            coords = coords,
            gender = true,
            sprite = 198,
            color = 1,
            scale = 1.0,
            length = 5,
        })
    elseif QBCore then
        TriggerServerEvent('police:server:policeAlert', alertMsg)
    elseif ESX then
        TriggerServerEvent('esx_service:notifyAllInService', alertMsg, 'police')
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        resetTaxiData()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        wanderOff()
    end
end)


--- Generates a instructional scaleform
---@param keysTable table
---@return integer scaleform
function makeFivemInstructionalScaleform(keysTable)
    local scaleform = RequestScaleformMovie("instructional_buttons")
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(10)
    end
    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    for btnIndex, keyData in ipairs(keysTable) do
        local btn = GetControlInstructionalButton(0, keyData[2], true)

        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(btnIndex - 1)
        ScaleformMovieMethodAddParamPlayerNameString(btn)
        BeginTextCommandScaleformString("STRING")
        AddTextComponentSubstringKeyboardDisplay(keyData[1])
        EndTextCommandScaleformString()
        EndScaleformMovieMethod()
    end

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()

    return scaleform
end