if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayer(id)
    return ESX.GetPlayerFromId(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('ox_lib:notify', src, { type = nType, description = text })
end

function GetPlyIdentifier(xPlayer)
    return xPlayer.identifier
end

function GetCharacterName(xPlayer)
    return xPlayer.getName()
end

function AddMoney(xPlayer, moneyType, amount)
    local account = moneyType == 'cash' and 'money' or moneyType
    xPlayer.addAccountMoney(account, amount)
end

function itemCount(xPlayer, item, amount)
    return exports.ox_inventory:GetItemCount(xPlayer.source, item)
end

function AddItem(xPlayer, item, amount)
    exports.ox_inventory:AddItem(xPlayer.source, item, amount)
end

AddEventHandler('esx:playerLoaded', function(source)
    PlayerHasLoaded(source)
end)