local Config = lib.require('config')
local gsCache = {}
local delay = false
local showText = false
local startBeeps = false
local grabDict, grabAnim = 'anim@scripted@player@freemode@tun_prep_ig1_grab_low@male@', 'grab_low'

function clearCacheHunt()
    if DoesBlipExist(gsCache.blip) then RemoveBlip(gsCache.blip) end
    if DoesBlipExist(gsCache.blip2) then RemoveBlip(gsCache.blip2) end
    if gsCache.point then gsCache.point:remove() end
    delay = false
    startBeeps = false
    table.wipe(gsCache)
    local isOpen, currentText = lib.isTextUIOpen()
    if isOpen and currentText == Config.TextUIMessage then
        lib.hideTextUI()
        showText = false
    end
end

local function createRadius(coords)
    local offset = math.random(-100, 100)
    local blip = AddBlipForRadius(coords.x + offset, coords.y + offset, coords.z, 250.0)
    SetBlipAlpha(blip, Config.Blip.alpha)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipAsShortRange(blip, true)
    local blip2 = AddBlipForCoord(coords.x + offset, coords.y + offset, coords.z)
    SetBlipSprite(blip2, 478)
    SetBlipScale(blip2, 1.0)
    SetBlipColour(blip2, 7)
    SetBlipAsShortRange(blip2, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName("G's Cache")
    EndTextCommandSetBlipName(blip2)
    return blip, blip2
end

local function grabCache()
    local success = lib.callback.await('randol_cache:server:foundCache', false)
    if success then
        while not RequestScriptAudioBank('DLC_TUNER/DLC_Tuner_Collectibles', false, -1) do Wait(0) end
        lib.requestAnimDict(grabDict, 2000)
        TaskPlayAnim(cache.ped, grabDict, grabAnim, 8.0, -8.0, 1500, 01, 0.0, false, false, false)
        RemoveAnimDict(grabDict)
        PlaySoundFrontend(-1, 'Audio_Player_Shard_Final', 'Tuner_Collectables_General_Sounds', false)
    end
    Wait(2000)
    delay = false
    ReleaseNamedScriptAudioBank('DLC_TUNER/DLC_Tuner_Collectibles')
end

RegisterNetEvent('randol_cache:client:initHunt', function(coords)
    if GetInvokingResource() or not hasPlyLoaded() or not coords then return end
    DoNotification(Config.DropNotify, 'success')
    PlaySoundFrontend(-1, "Text_Arrive_Tone", "Phone_SoundSet_Default", 1)
    gsCache.coords = coords
    gsCache.blip, gsCache.blip2 = createRadius(gsCache.coords)
    gsCache.point = lib.points.new({ 
        coords = vec3(gsCache.coords.x, gsCache.coords.y, gsCache.coords.z), 
        distance = 30.0,
        onEnter = function()
            if DoesBlipExist(gsCache.blip2) then RemoveBlip(gsCache.blip2) end
            startBeeps = true
            CreateThread(function()
                while startBeeps do
                    PlaySoundFromCoord(-1, 'CONFIRM_BEEP', gsCache.coords.x, gsCache.coords.y, gsCache.coords.z, 'HUD_MINI_GAME_SOUNDSET', 0, 30.0, 0)
                    Wait(3000)
                end
            end)
        end,
        onExit = function()
            startBeeps = false
            lib.hideTextUI()
        end,
        nearby = function(point)
            if point.isClosest and point.currentDistance <= 1.5 then
                if not showText then
                    showText = true
                    lib.showTextUI(Config.TextUIMessage, {position = "left-center"})
                end

                if IsControlJustReleased(0, 38) then
                    if GlobalState.GsCacheActive and not delay then
                        delay = true
                        grabCache()
                    end
                end
            elseif showText then
                showText = false
                lib.hideTextUI()
            end
        end,
    })
end)

RegisterNetEvent('randol_cache:client:cleanupHunt', function()
    if GetInvokingResource() or not hasPlyLoaded() then return end
    clearCacheHunt()
end)