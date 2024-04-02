local Server = lib.require('sv_config')
local currentLoc, currentRot, currentEntity

local function doShuffle(locs)
    local size = #locs
    for i = size, 1, -1 do
        local rand = math.random(size)
        locs[i], locs[rand] = locs[rand], locs[i]
    end
    return locs
end

local function isValid(pos)
    return DoesEntityExist(currentEntity) and #(pos - vec3(currentLoc.x, currentLoc.y, currentLoc.z)) < 3.0
end

lib.callback.register('randol_cache:server:foundCache', function(source)
    if not GlobalState.GsCacheActive then return false end

    local src = source
    local player = GetPlayer(src)
    local pos = GetEntityCoords(GetPlayerPed(src))

    if not player or not isValid(pos) then return false end

    GlobalState.GsCacheActive = false
    DeleteEntity(currentEntity) 
    currentEntity = nil
    currentLoc = nil
    currentRot = nil
    TriggerClientEvent('randol_cache:client:cleanupHunt', -1)

    Server.GiveRewards(player, src)
    return true
end)

function PlayerHasLoaded(source)
    local src = source
    SetTimeout(2000, function()
        if GlobalState.GsCacheActive then
            TriggerClientEvent('randol_cache:client:initHunt', src, currentLoc)
        end
    end)
end

local function initCacheHunt()
    if GlobalState.GsCacheActive then
        DeleteEntity(currentEntity) 
        currentEntity = nil
        currentLoc = nil 
        currentRot = nil
        TriggerClientEvent('randol_cache:client:cleanupHunt', -1)
        GlobalState.GsCacheActive = false
    end

    SetTimeout(2000, function()
        local model = Server.Models[math.random(1, #Server.Models)]
        local locs = doShuffle(Server.Locations)
        local index = locs[math.random(1, #locs)]
        currentLoc, currentRot = index.coords, index.rot

        if Server.Debug then
            print("Current Location:", currentLoc)
        end

        currentEntity = CreateObjectNoOffset(joaat(model), currentLoc.x, currentLoc.y, currentLoc.z, true, true, true)
        while not DoesEntityExist(currentEntity) do Wait(0) end
        FreezeEntityPosition(currentEntity, true)
        SetEntityRotation(currentEntity, currentRot.x, currentRot.y, currentRot.z, 2, true)

        GlobalState.GsCacheActive = true
        TriggerClientEvent('randol_cache:client:initHunt', -1, currentLoc)   
    end)
end

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end
    GlobalState.GsCacheActive = false
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end

    if GlobalState.GsCacheActive then
        DeleteEntity(currentEntity) 
        currentEntity = nil
        currentLoc = nil 
        currentRot = nil
        TriggerClientEvent('randol_cache:client:cleanupHunt', -1)
    end
end)

SetInterval(initCacheHunt, Server.CycleTimer * 60000)