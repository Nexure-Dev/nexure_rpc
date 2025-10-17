/*

    ███╗   ██╗███████╗██╗  ██╗██╗   ██╗██████╗ ███████╗
    ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔══██╗██╔════╝
    ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║██████╔╝█████╗
    ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║██╔══██╗██╔══╝
    ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝██║  ██║███████╗
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

    Made by Nexure - dsc.gg/nexure

 */

local appId = "DEINE_DISCORD_APP_ID" -- Erstelle eine Application auf https://discord.dev
                                     -- und ersetze dies mit deiner App ID

-- Konfiguration
local config = {
    updateInterval = 15000,
    showPlayerCount = true,
    showLocation = true,
    largeImageKey = "logo", -- Name deines Bildes in der Discord App
    largeImageText = "DEIN_SERVER_NAME",
}

local currentData = {
    details = "",
    state = "",
    startTimestamp = os.time()
}

function GetPlayerZone()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    local zoneName = GetLabelText(zone)
    
    if zoneName == "UNKNOWN" or zoneName == "" then
        zoneName = zone
    end
    
    return zoneName
end

function GetPlayerStreet()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    
    return streetName
end

function GetVehicleDisplayName()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local vehicleHash = GetEntityModel(vehicle)
        local vehicleName = GetDisplayNameFromVehicleModel(vehicleHash)
        local displayName = GetLabelText(vehicleName)
        
        if displayName == "NULL" or displayName == "" then
            displayName = vehicleName
        end
        
        return displayName
    end
    return nil
end

function UpdateDiscordPresence()
    local playerCount = #GetActivePlayers()
    local maxPlayers = GetConvarInt("sv_maxclients", 32)
    local playerName = GetPlayerName(PlayerId())
    local serverId = GetPlayerServerId(PlayerId())
    
    local details = playerName .. " (ID: " .. serverId .. ")"
    
    local state = ""
    if config.showLocation then
        local vehicle = GetVehicleDisplayName()
        if vehicle then
            state = "Fährt: " .. vehicle
        else
            local street = GetPlayerStreet()
            if street and street ~= "" then
                state = "In: " .. street
            else
                local zone = GetPlayerZone()
                state = "In: " .. zone
            end
        end
    end
    
    if config.showPlayerCount then
        state = state .. " | " .. playerCount .. "/" .. maxPlayers .. " Spieler"
    end
    
    SetDiscordAppId(appId)
    SetDiscordRichPresenceAsset(config.largeImageKey)
    SetDiscordRichPresenceAssetText(config.largeImageText)

    -- Buttons (optional, max 2)
    SetDiscordRichPresenceAction(0, "Verbinden", "fivem://connect/deine-server-ip:port")
    SetDiscordRichPresenceAction(1, "Discord", "https://discord.gg/dein-discord")
    
    if currentData.details ~= details or currentData.state ~= state then
        currentData.details = details
        currentData.state = state
        
        SetRichPresence(state)
    end
end

Citizen.CreateThread(function()
    while true do
        UpdateDiscordPresence()
        Citizen.Wait(config.updateInterval)
    end
end)

AddEventHandler('playerSpawned', function()
    UpdateDiscordPresence()
end)

RegisterNetEvent('discord:updateRPC')
AddEventHandler('discord:updateRPC', function()
    UpdateDiscordPresence()
end)
