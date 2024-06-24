Config = {}

Config.menuKey = 'f6'
Config.taxiJob = 'taxi'

Config.npcMissions = true

Config.unit = 'km' -- Must be km or mi
Config.kmPrice = 2.25
Config.money = "$"


Config.taxiCommand = 'calltaxi'

-- Config des taxi pnj

Config.pnj = {}

Config.pnj.MinSpawnDist = 150.0 -- Min distance that a taxi will spawn from the player (in-game units)

Config.pnj.DrivingStyles = { -- See https://vespura.com/fivem/drivingstyle/
    Normal = 524731,
    Rush = 787263,
}
Config.pnj.RushSpeedMultiplier = 1.5 -- How much faster the cab will go when rushing
Config.pnj.SlowdownSpeed = 15 * 0.44704 -- The speed the cab will begin to pull over at
Config.pnj.SlowdownDist = 35.0 -- How far away the cab should slow down and honk

Config.pnj.Fare = {
    base = 1.0, -- Rate when entering the cab
    tick = 0.25, -- How much to charge per tick
    tickTime = 30 * 1000, -- How often to charge the tick rate (ie $0.25 per 30s)
}

Config.pnj.DriverModel = 'a_m_y_stlat_01' -- Driver model name
Config.pnj.DriverVoice = 'A_M_M_EASTSA_02_LATINO_FULL_01' -- Driver voice
Config.pnj.TaxiModel = 'taxi' -- Model of the taxis that spawn
Config.pnj.TaxiExtras = { -- Which vehicle extras to enable / disable on the cab
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = true,
    [7] = false,
    [8] = false,
    [9] = false,
    [10] = false,
    [11] = false,
    [12] = false,
    [13] = false,
    [14] = false,
}

--[[
    This sets the speed limit for the cabbie depending on which road they are on.
    The export must return the speed limit in MPH.

    Leave Config.pnj.SpeedLimitResource and Config.pnj.SpeedLimitExport as empty strings ('') to disable.
]]--
Config.pnj.SpeedLimitResource = '919-speedlimits'
Config.pnj.SpeedLimitExport = 'GetSpeedLimit'
Config.pnj.SpeedLimitZones = { -- Speeds in MPH
    [2] = 40, -- City / main roads
    [10] = 30, -- Slow roads
    [64] = 25, -- Off road
    [66] = 60, -- Freeway
    [82] = 60, -- Freeway tunnels
}
