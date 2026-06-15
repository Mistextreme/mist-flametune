ESX = exports["es_extended"]:getSharedObject()

---@diagnostic disable: missing-parameter
RegisterServerEvent('mist-flametune:server:setstate', function(state, net)
    local vehicle = NetworkGetEntityFromNetworkId(net)
    Entity(vehicle).state.flameThrower = state
end)

local function Trim(value)
    if value then
        return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
    else
        return nil
    end
end

CreateThread(function()
    if not Permission.Plate then
        return
    end
    for k, v in pairs(Permission.Plates) do
        Permission.Plates[Trim(k)] = v
    end
end)

local function ToggleClientState(source)
    if Permission.Plate then
        local plate = Trim(GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(source), false)))
        if Permission.Plates[plate] then
            TriggerClientEvent('mist-flametune:client:toggle', source)
        end
    else
        TriggerClientEvent('mist-flametune:client:toggle', source)
    end
end

if Config.Usage == 'command' then
    RegisterCommand(Config.Command, function(source, args, rawCommand)
        print('flame command')
        ToggleClientState(source)
    end)
else
    if GetResourceState('ox_inventory') == 'started' then
        exports('flametune', function(event, item, inventory, slot, data)
            if event == 'usingItem' then
                ToggleClientState(inventory.id)
            end
        end)
        return
    end

    if GetResourceState('es_extended') == 'started' then
        local ESX = nil
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        ESX.RegisterUsableItem('flametune', function(source)
            ToggleClientState(source)
        end)
    end

    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateUseableItem('flametune', function(source, item)
            ToggleClientState(source)
        end)
    end
end

RegisterCommand('flamecolor', function(source, args, rawCommand)
    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate = Trim(GetVehicleNumberPlateText(vehicle))

    if vehicle == 0 then
        return
    end

    if Entity(vehicle).state.flameThrower == nil then
        return
    end

    local colorIndex = args[1]
    if colorIndex == 'default' then
        colorIndex = 1
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `flame`= @flame WHERE `plate` = @plate", {["@flame"] = colorIndex, ["@plate"] = plate}, function() end)
    elseif colorIndex == 'red' then
        colorIndex = 2
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `flame`= @flame WHERE `plate` = @plate", {["@flame"] = colorIndex, ["@plate"] = plate}, function() end)
    elseif colorIndex == 'green' then
        colorIndex = 3
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `flame`= @flame WHERE `plate` = @plate", {["@flame"] = colorIndex, ["@plate"] = plate}, function() end)
    elseif colorIndex == 'blue' then
        colorIndex = 4
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `flame`= @flame WHERE `plate` = @plate", {["@flame"] = colorIndex, ["@plate"] = plate}, function() end)
    elseif colorIndex == 'pink' then
        colorIndex = 5
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `flame`= @flame WHERE `plate` = @plate", {["@flame"] = colorIndex, ["@plate"] = plate}, function() end)
    end

    if type(colorIndex) == 'number' then
        if Entity(vehicle).state.flameThrower ~= nil then
            Entity(vehicle).state.flameThrower = nil
        end
        Wait(500)
        Entity(vehicle).state.flameThrower = colorIndex
        MySQL.Async.execute("UPDATE `owned_vehicles` SET `flame`= @flame WHERE `plate` = @plate", {["@flame"] = colorIndex, ["@plate"] = plate}, function() end)
        TriggerClientEvent('jsx_progressBar:client:startProgressBar', source, 'Making changes for apply the ' .. args[1] .. ' Color', 5000)
        Wait(5500)
        TriggerClientEvent('mist-notify:showNotify', source, 'FLAMES SYSTEM', 'Color ' .. args[1] .. ' was applyed','<span class="material-icons">electric_car</span>', 3000)
    end
end)

ESX.RegisterServerCallback("mist-flametune:server:getFlameState", function(source, cb)
    local plate = Trim(GetVehicleNumberPlateText(GetVehiclePedIsIn(GetPlayerPed(source), false)))
    local flameState = false

    if plate then
        flameState = tonumber(MySQL.Sync.fetchScalar("SELECT `flame` FROM owned_vehicles WHERE plate = @plate ", {["@plate"] = plate}))
    end

    if flameState then
        cb(flameState)
    else
        cb(false)
    end
end)

function getFlameState(plate)
    local flameState = false

    if plate then
        flameState = tonumber(MySQL.Sync.fetchScalar("SELECT `flame` FROM owned_vehicles WHERE plate = @plate ", {["@plate"] = plate}))
    end


    return tonumber(flameState)
end

RegisterCommand('refreshFlame', function(source, args, rawCommand)
    local ped = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate = Trim(GetVehicleNumberPlateText(vehicle))

    if vehicle == 0 then
        return
    end

    local flameState = getFlameState(plate)


    if flameState and flameState ~= nil then
        if Entity(vehicle).state.flameThrower ~= nil then
            Entity(vehicle).state.flameThrower = nil
        end
        Wait(500)
        Entity(vehicle).state.flameThrower = flameState
        TriggerClientEvent('jsx_progressBar:client:startProgressBar', source, 'Making changes for apply the ' .. args[1] .. ' Color', 5000)
        Wait(5500)
        TriggerClientEvent('mist-notify:showNotify', source, 'FLAMES SYSTEM', 'Color ' .. args[1] .. ' was applyed','<span class="material-icons">electric_car</span>', 3000)
    end
end)