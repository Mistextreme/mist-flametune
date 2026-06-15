local UseParticleFxAssetNextCall = UseParticleFxAssetNextCall
local StartParticleFxNonLoopedOnEntity = StartParticleFxNonLoopedOnEntity
local GetEntityCoords = GetEntityCoords
local PlayerPedId = PlayerPedId
local GetVehicleCurrentRpm = GetVehicleCurrentRpm
local GetVehicleThrottleOffset = GetVehicleThrottleOffset

local vehicles = {}
local pDict, pFx = "veh_sanctus", "veh_sanctus_backfire"
local sDict, sFx = "scr_sm_counter", "scr_sm_counter_chaff"

local colors = {
    {dict = 'veh_xs_vehicle_mods', fx = 'veh_nitrous'},
    {dict = 'veh_xs_vehicle_mods_red', fx = 'veh_nitrous2'},
    {dict = 'veh_xs_vehicle_mods_green', fx = 'veh_nitrous2'},
    {dict = 'veh_xs_vehicle_mods_blue', fx = 'veh_nitrous2'},
    {dict = 'veh_xs_vehicle_mods_pink', fx = 'veh_nitrous2'},
}


local function Flame(vehicle, offsets, bike)
    if bike then
        for i = 1, #offsets do
            if math.random(4) == 4 then
                UseParticleFxAssetNextCall(sDict)
                StartParticleFxNonLoopedOnEntity(sFx, vehicle, offsets[i].x, offsets[i].y, offsets[i].z, 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0)
            end
        end
    else
        for i = 1, #offsets do
            if math.random(4) == 4 then
                UseParticleFxAssetNextCall(sDict)
                StartParticleFxNonLoopedOnEntity(sFx, vehicle, offsets[i].x, offsets[i].y, offsets[i].z, 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0)
            end
        end
    end
end

local function FlameNos(vehicle, offsets, bike, color)

    local asset = colors[color]
    local particles = {}
    if bike then
        for i = 1, #offsets do
            UseParticleFxAssetNextCall(asset.dict)
            particles[#particles + 1] = StartParticleFxLoopedOnEntity(asset.fx, vehicle, offsets[i].x, offsets[i].y, offsets[i].z, 0.0, 0.0, 0.0, 0.7, 0.0, 0.0, 0.0)
        end
    else
        for i = 1, #offsets do
            UseParticleFxAssetNextCall(asset.dict)
            particles[#particles + 1] = StartParticleFxLoopedOnEntity(asset.fx, vehicle, offsets[i].x, offsets[i].y, offsets[i].z, 0.0, 0.0, 0.0, 1.2, 0.0, 0.0, 0.0)
        end
    end
    return particles
end

local function ClearNos(particles)
    if not particles or #particles == 0 then return end
    for i = 1, #particles do
        StopParticleFxLooped(particles[i], 0)
    end
end

local function Thread()
    for i = 1, #colors do
        RequestNamedPtfxAsset(colors[i].dict)
    end
    RequestNamedPtfxAsset(pDict)
    RequestNamedPtfxAsset(sDict)
    while #vehicles > 0 do
        Wait(250)
        local coords = GetEntityCoords(PlayerPedId())
        for i = 1, #vehicles do
            if vehicles[i] and vehicles[i].vehicle then

                local vehicle = vehicles[i].vehicle
                if not DoesEntityExist(vehicle) then
                    table.remove(vehicles, i)
                end

                if #(GetEntityCoords(vehicle) - coords) < 70 then
                    local revs = GetVehicleCurrentRpm(vehicle)
                    if GetVehicleThrottleOffset(vehicle) < 0.3 and revs > 0.70  then
                        if not vehicles[i].throttle then
                            vehicles[i].throttle = 1
                            vehicles[i].loopedParticles = FlameNos(vehicle, vehicles[i].offsets, vehicles[i].bike, vehicles[i].color)
                        end
                        vehicles[i].throttle += 1
                        if vehicles[i].throttle < 15 then
                            if Config.Crackling then
                                Flame(vehicle, vehicles[i].offsets, vehicles[i].bike)
                            end
                        else
                            vehicles[i].throttle = 1
                            ClearNos(vehicles[i].loopedParticles)
                        end

                    else
                        vehicles[i].throttle = nil
                        ClearNos(vehicles[i].loopedParticles)
                        vehicles[i].loopedParticles = nil
                    end
                end
            end
        end
    end
    for i = 1, #colors do
        RemoveNamedPtfxAsset(colors[i].dict)
    end
    RemoveNamedPtfxAsset(pDict)
    RemoveNamedPtfxAsset(sDict)
end


local function AddVehicle(vehicle, colorIndex)
    local isModelBike = IsThisModelABike(GetEntityModel(vehicle))
    local bones = {GetEntityBoneIndexByName(vehicle, 'exhaust'), GetEntityBoneIndexByName(vehicle, 'exhaust_2'), GetEntityBoneIndexByName(vehicle, 'exhaust_3'), GetEntityBoneIndexByName(vehicle, 'exhaust_4')}
    EnableVehicleExhaustPops(vehicle, true)
    local offsets = {}
    for i = 1, 4 do
        if bones[i] ~= -1 then
            local position = GetWorldPositionOfEntityBone(vehicle, bones[i])
            offsets[#offsets + 1] = GetOffsetFromEntityGivenWorldCoords(vehicle, position.x, position.y, position.z)
        end
    end

    if #vehicles == 0 then
        table.insert(vehicles, {vehicle = vehicle, offsets = offsets, bike = isModelBike, color = colorIndex})
        CreateThread(Thread)
        return
    end
    table.insert(vehicles, {vehicle = vehicle, offsets = offsets, bike = isModelBike, color = colorIndex})
end

local function RemoveVehicle(vehicle)
    for i = 1, #vehicles do
        if vehicles[i].vehicle == vehicle then
            ClearNos(vehicles[i].loopedParticles)
            table.remove(vehicles, i)
            return
        end
    end
end

AddStateBagChangeHandler('flameThrower', nil, function(bagName, key, value, _unused, replicated)
    local entNet = bagName:gsub('entity:', '')
    entNet = tonumber(entNet)
    local timer = GetGameTimer()
    while not NetworkDoesEntityExistWithNetworkId(entNet) do
        Wait(0)
        if GetGameTimer() - timer > 10000 then
            return
        end
    end
    local vehicle = NetToVeh(entNet)
    if value then
        AddVehicle(vehicle, value)
    else
        RemoveVehicle(vehicle)
    end
end)

--local function InstructionText(text)
--    SetTextFont(4)
--    SetTextProportional(1)
--    SetTextColour(255, 255, 255, 255)
--    SetTextEdge(2, 0, 0, 0, 200)
--    SetTextDropShadow()
--    SetTextEntry("STRING")
--    SetTextCentre(1)
--    SetTextScale(0.25, 0.25)
--    AddTextComponentString(text)
--    DrawText(0.525, 0.9525)
--end

RegisterNetEvent('mist-flametune:client:toggle', function()

    if busy then 
        return print('mist:flametune: busy')
    end
    busy = true
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local model = GetEntityModel(veh)
    if not DoesEntityExist(veh) then
        busy = false
        return print('mist:flametune: no vehicle')
    end

    if GetPedInVehicleSeat(veh, -1) ~= ped then
        busy = false
        return print('mist:flametune: not driver')
    end

    if not IsThisModelABike(model) and not IsThisModelACar(model) then
        busy = false
        return print('mist:flametune: unsupported vehicle')
    end
    local state = Entity(veh).state

    SetVehicleEngineOn(veh, false, false, true)
    Animation(state.flameThrower)

    if not DoesEntityExist(veh) then
        busy = false
        return print('mist:flametune: no vehicle')
    end

    SetVehicleEngineOn(veh, true, false, true)
    if not state.flameThrower then
        TriggerServerEvent('mist-flametune:server:setstate', 1, VehToNet(veh))
    else
        TriggerServerEvent('mist-flametune:server:setstate', nil, VehToNet(veh))
    end
    busy = false
end)

function Animation(state)
    inAnimation = true
    local ped = PlayerPedId()
    PlaySoundFrontend(-1 , 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET')
    
    local dict, name = 'misscarsteal2chad_holdup', 'chad_holdup_franklin'

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end

    local modelHash = `gr_prop_gr_laptop_01c`

    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash);
        while not HasModelLoaded(modelHash) do 
            Wait(0)
        end  
    end

    CreateThread(function()
        while inAnimation do
            Wait(0)
            DisableControlAction(0, 75, true)
            --InstructionText('Flashing tune...')
            TriggerEvent('jsx_progressBar:client:startProgressBar', 'Flashing tune...', 8500)
            --[[lib.progressCircle({
                duration = 8500,
                label = 'Flashing tune...',
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    car = true,
                    combat = true
                }
            })]]
        end
    end)
    
    local obj = CreateObject(modelHash, 0.0, 0.0, 0.0, true, false, false)
    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, 18905), 0.14, 0.03, 0.18, -92.8, -64.5, 16.05, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(modelHash) 

    TaskPlayAnim(ped, dict, name, 8.0, 8.0, 10000, 48, 0, false, 4127, false)

    Wait(8000)
    if not state then
        for i = 1, 5 do
            Wait(100)
            PlaySoundFrontend(-1 , 'CONFIRM_BEEP', 'HUD_MINI_GAME_SOUNDSET')
        end
    else
        PlaySoundFrontend(-1 , 'CANCEL', 'HUD_MINI_GAME_SOUNDSET')
        TriggerEvent('mist-notify:showNotify', 'FLAMES SYSTEM', 'Flashing tune complete', '<span class="material-icons">electric_car</span>', 4000)
    end
    DeleteEntity(obj)
    inAnimation = false
end

CreateThread(function()
    if Config.Usage == 'command' then
        TriggerEvent('chat:addSuggestion', '/flame', 'Enable/disable vehicle flame tune', {})
    end
    TriggerEvent('chat:addSuggestion', '/flamecolor', 'Change the vehicle flame color',{ { name = "color", help = "[default, red, green, blue, pink]" }})
end)
