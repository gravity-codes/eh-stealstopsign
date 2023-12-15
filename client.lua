local stopsign
local closestObj

exports['qb-target']:AddTargetModel('prop_sign_road_01a', {
    options = {
        {
            type = "client",
            event = "stopsign:stealStopsign",
            icon = 'fa-regular fa-circle-stop',
            label = 'Steal the stop sign',
            targeticon = 'fas fa-example',
            canInteract = function(entity, distance, data)
                IsEntityUpright(entity, 45.0)
            end
        }
    },
    distance = 5.0,
})

exports["rz-interact"]:AddPeekEntryByModel(GetHashKey('prop_sign_road_01a'),
    { {
        event = "stopsign:stealStopsign",
        id = "stealstopsign",
        icon = "stop-circle",
        label = "Steal the stop sign"
    } },
    { distance = { radius = 3.5 }, isEnabled = function() return IsEntityUpright(
        GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 5.0, GetHashKey('prop_sign_road_01a'), false, false, false),
            45.0) end })

RegisterNetEvent('stopsign:stealStopsign', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    closestObj = GetClosestObjectOfType(playerCoords, 5.0, GetHashKey('prop_sign_road_01a'), false, false, false)

    loadAnimDict("amb@world_human_janitor@male@base")
    TaskPlayAnim(PlayerPedId(), "amb@world_human_janitor@male@base", "base", 5.0, -1, -1, 50, 0, false, false, false)
    stopsign = CreateObject(GetHashKey('prop_sign_road_01a'), playerCoords.x, playerCoords.y, playerCoords.z, true, false,
        false)
    SetEntityAsMissionEntity(stopsign, true, true)
    AttachEntityToEntity(stopsign, PlayerPedId(), GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422), -0.005, 0.0, 0.0,
        360.0, 360.0, 115.0, 1, 1, 0, 1, 0, 1)

    if DoesEntityExist(closestObj) then
        NetworkRequestControlOfEntity(closestObj)
        SetEntityAsMissionEntity(closestObj, true, true)
        DeleteEntity(closestObj)
    end

    TriggerEvent('stopsign:listenfordrop')
end)

RegisterNetEvent('stopsign:listenfordrop', function()
    Citizen.CreateThread(function()
        TriggerEvent('StayText', 'START', "[E] Drop stop sign", 1)

        while true do
            Wait(1)

            if IsControlJustReleased(0, 38) then --Pressed E
                TriggerEvent('stopsign:dropStopsign')
                return
            end
        end
    end)
end)

RegisterNetEvent('stopsign:dropStopsign', function(source)
    if IsEntityAttachedToEntity(stopsign, PlayerPedId()) then
        DetachEntity(stopsign, false, false)
        PlaceObjectOnGroundProperly(stopsign)
        NetworkRequestControlOfEntity(stopsign)
        SetEntityAsMissionEntity(stopsign, true, true)
        SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(stopsign), true)
        ClearPedTasks(PlayerPedId())
    end

    TriggerEvent('StayText', 'END')
end)

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end
