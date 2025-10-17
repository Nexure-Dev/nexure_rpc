local RESOURCE_NAME = GetCurrentResourceName()
local CURRENT_VERSION = "1.0.0"

local CONFIG = {
    versionUrl = "https://raw.githubusercontent.com/Nexure-Dev/versions/main/nexure_rpc.txt",
    checkOnStartup = true,
    checkInterval = 3600000,
}

local colors = {
    red = "^1",
    green = "^2",
    yellow = "^3",
    cyan = "^5",
    white = "^7"
}

local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function checkVersion()
    PerformHttpRequest(CONFIG.versionUrl, function(statusCode, response, headers)
        if statusCode == 200 then
            local latestVersion = trim(response)
            
            print("\n" .. colors.cyan .. "==================================================" .. colors.white)
            print(colors.cyan .. "  " .. RESOURCE_NAME .. " - Version Check" .. colors.white)
            print(colors.cyan .. "==================================================" .. colors.white)
            print("  Aktuelle Version: " .. colors.yellow .. CURRENT_VERSION .. colors.white)
            print("  Neueste Version:  " .. colors.green .. latestVersion .. colors.white)
            
            if CURRENT_VERSION == latestVersion then
                print(colors.green .. "  ✓ Du verwendest die neueste Version!" .. colors.white)
            else
                print(colors.red .. "  ⚠ UPDATE VERFÜGBAR!" .. colors.white)
                print(colors.yellow .. "  Bitte lade die neueste Version herunter!" .. colors.white)
                print(colors.white .. "  Download: https://github.com/Nexure-Dev/nexure_rpc" .. colors.white)
            end
            
            print(colors.cyan .. "==================================================" .. colors.white .. "\n")
        else
            print(colors.red .. "[" .. RESOURCE_NAME .. "] Version Check fehlgeschlagen! (Status: " .. statusCode .. ")" .. colors.white)
        end
    end, 'GET')
end

if CONFIG.checkOnStartup then
    Citizen.CreateThread(function()
        Citizen.Wait(5000) 
        checkVersion()
    end)
end

if CONFIG.checkInterval > 0 then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(CONFIG.checkInterval)
            checkVersion()
        end
    end)
end