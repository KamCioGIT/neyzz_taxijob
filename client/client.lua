lib.locale()
local activeCall = nil

local duty <const> = {on= false, available = false}

local function toggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end

RegisterCommand('show-nui', function()
    toggleNuiFrame(true)
    debugPrint('Show NUI frame')
end)

RegisterNUICallback('hideFrame', function(_, cb)
    toggleNuiFrame(false)
    debugPrint('Hide NUI frame')
    cb({})
end)

RegisterNUICallback('getClientData', function(data, cb)
    debugPrint('Data sent by React', json.encode(data))

    -- Lets send back client coords to the React frame for use
    local curCoords = GetEntityCoords(PlayerPedId())

    local retData <const> = { x = curCoords.x, y = curCoords.y, z = curCoords.z }
    cb(retData)
end)

RegisterNUICallback('fetchCourses', function(data, cb)
    debugPrint('Récupération des courses de taxi')
    cb({
        { id= 12, name= "John Doe", roadName= "Joshua Road", destination= "Vespucci", distance= 140.5 },
        { id= 13, name="John Doe", roadName="Joshua Road", destination= "Vespucci", distance= 140.5},
        { id= 14, name="John Doe", roadName="Joshua Road", destination= "Vespucci", distance= 140.5},
        { id= 15, name="John Doe", roadName="Joshua Road", destination= "Vespucci", distance= 140.5},
        { id= 16, name="John Doe", roadName="Joshua Road", destination= "Vespucci", distance= 140.5},
        { id= 17, name="John Doe", roadName="Joshua Road", destination= "Vespucci", distance= 140.5},
        { id= 18, name= "John Doe", roadName= "Joshua Road", destination= "Vespucci", distance= 140.5 },
    })
end)

lib.registerMenu({
    id= 'neyzz_taxi:jobMenu',
    title = locale('menu_title'),
    options = {
        {label= locale('menu_duty_on'), close=true, args={action="duty-on"}, icon="fas fa-taxi"},
        -- {label= locale('menu_rides_btn'), close=true, args={action="show-nui"}},
    }

}, function (selected, scrollIndex, args, checked)
    if args.action == "duty-on" then
        SetServiceForSelf(true)
    elseif args.action == "show-nui" then
        ReloadCalls()
        toggleNuiFrame(true)
        debugPrint('Show NUI frame')
    elseif args.action == "toggle_availability" then
        ToggleSelfAvailabitlity()
    elseif args.action == "duty-off" then
        SetServiceForSelf(false)
    end
end)

lib.addKeybind({
    name='neyzz_taxi:jobMenu',
    description=locale("keybind_description"),
    defaultKey=Config.menuKey,
    onPressed=function (self)
        local PlayerData = ESX.GetPlayerData()
        if PlayerData.job.name == Config.taxiJob then
            debugPrint('On affiche le menu taxi')
            lib.showMenu('neyzz_taxi:jobMenu')
        end
    end
})

function SetServiceForSelf(toggle)
    if toggle then
        lib.notify({
            title=locale('taxi_company_name'),
            icon='fas fa-taxi',
            description=locale('taxi_duty_on_success')
        })
        duty.available = true
        duty.on = true
        local options = {
            {label= locale('menu_rides_button'), close=true, args={action="show-nui"}, icon="fas fa-taxi"},
            {label= locale('menu_availability_toggle'), close=false, args={action="toggle_availability"}, icon="fas fa-user-slash"},
            {label= locale('menu_duty_off'), close=true, args={action="duty-off"}, icon="fas fa-power-off"},
        }

        lib.setMenuOptions('neyzz_taxi:jobMenu', options)
        lib.callback.await('neyzz_taxijob:setDuty', false, true)
    else
        lib.notify({
            title=locale('taxi_company_name'),
            icon='fas fa-taxi',
            description=locale('taxi_duty_off_success')
        })
        duty.available = false
        duty.on = false
        local options = {
            {label= locale('menu_duty_on'), close=true, args={action="duty-on"}, icon="fas fa-taxi"}
        }

        lib.setMenuOptions('neyzz_taxi:jobMenu', options)
        lib.callback.await('neyzz_taxijob:setDuty', false, false)
    end
end

function ToggleSelfAvailabitlity()
    local toggle = not duty.available
    if toggle then
        duty.available = toggle
        lib.notify({
            title=locale('taxi_company_name'),
            icon='fas fa-taxi',
            description=locale('taxi_available')
        })
        lib.callback.await('neyzz_taxijob:setAvailable', false, toggle)
    else
        duty.available = toggle
        lib.notify({
            title=locale('taxi_company_name'),
            icon='fas fa-taxi',
            description=locale('taxi_unavailable')
        })
        lib.callback.await('neyzz_taxijob:setAvailable', false, toggle)
    end
end

RegisterNetEvent('neyzz_taxi:refreshRides', function(rides)
    local courses = {
        ---- { id= 12, name= "John Doe", roadName= "Joshua Road", destination= "Vespucci", distance= 140.5 }
    }
    for k, ride in pairs(rides) do
        local pos = ride.callerPos
        local streetHash --[[ Hash ]], crossingRoad --[[ Hash ]] = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        local streetName = GetStreetNameFromHashKey(streetHash)
        local dist = GetDistanceBetweenCoords(pos, GetEntityCoords(PlayerPedId()))
        table.insert(courses, {id = ride.id, name = ride.name, roadName= streetName, destination="Unknown", distance = dist, selfId=cache.serverId, taxi=ride.taxi})

    end
    debugPrint(json.encode(courses))
    SendReactMessage('newCourse', courses)
end)

RegisterNUICallback('acceptRide', function(data, cb)
    local id = data.id
    if activeCall ~= nil then return lib.notify({
        title=locale('taxi_company_name'),
        description=locale('already_on_call'),
        icon="fas fa-taxi"
    }) end
    debugPrint("Vous acceptez l'appel "..id)
    local ret = lib.callback.await('neyzz_taxijob:acceptRide', false, id)
    if ret then
        lib.callback.await('neyzz_taxijob:setAvailable', false, true)
        activeCall = id
    end
end)

RegisterNUICallback('clearRide', function(data, cb)
    if activeCall then
        ClearCall()
    end
end)

function ClearCall()
    lib.callback.await('neyzz_taxijob:finishRide', false, activeCall)
    ReloadCalls()
    activeCall = nil
end

function ReloadCalls()
    TriggerServerEvent('neyzz_taxi:refreshUi')
end