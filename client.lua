local QBCore = exports['qb-core']:GetCoreObject()
local rentalNPC = nil

RegisterNetEvent("qb-rental:openMenu", function()
    SetNuiFocus(true, true)

    local cars = {}
    local motorcycles = {}

    for _, vehicle in ipairs(Config.Vehicles) do
        if vehicle.category == "Araç" then
            table.insert(cars, vehicle)
        elseif vehicle.category == "Motor" then
            table.insert(motorcycles, vehicle)
        end
    end

    SendNUIMessage({
        action = "open",
        cars = cars,
        motorcycles = motorcycles
    })
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("rentVehicle", function(data, cb)
    TriggerServerEvent("qb-rental:rentVehicle", data.model, data.price)
    cb("ok")
end)

Citizen.CreateThread(function()
    RequestModel(GetHashKey(Config.NPCModel))
    while not HasModelLoaded(GetHashKey(Config.NPCModel)) do
        Citizen.Wait(10)
    end
    rentalNPC = CreatePed(4, GetHashKey(Config.NPCModel), Config.RentalNPC.x, Config.RentalNPC.y, Config.RentalNPC.z - 1.0, 270.0, false, true)
    SetBlockingOfNonTemporaryEvents(rentalNPC, true)
    SetPedDiesWhenInjured(rentalNPC, false)
    SetPedCanPlayAmbientAnims(rentalNPC, true)
    SetPedCanRagdollFromPlayerImpact(rentalNPC, false)
    FreezeEntityPosition(rentalNPC, true)
    TaskStartScenarioInPlace(rentalNPC, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)

    if Config.TargetSystem == "ox_target" then
        exports.ox_target:addEntity(rentalNPC, {
            {
                name = "open_rental_menu",
                icon = "fa-solid fa-car",
                label = "Araç Kirala",
                onSelect = function()
                    TriggerEvent("qb-rental:openMenu")
                end,
            }
        })
    elseif Config.TargetSystem == "qb-target" then
        exports['qb-target']:AddTargetEntity(rentalNPC, {
            options = {
                {
                    event = "qb-rental:openMenu",
                    icon = "fa-solid fa-car",
                    label = "Araç Kirala"
                }
            },
            distance = 2.5
        })
    end
end)

RegisterNetEvent("qb-rental:spawnVehicle", function(vehicleModel, deliveryCoords)
    local playerPed = PlayerPedId()
    local coords = deliveryCoords or Config.DeliveryPoint

    QBCore.Functions.SpawnVehicle(vehicleModel, function(vehicle)
        SetEntityCoords(vehicle, coords.x, coords.y, coords.z)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
        TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(vehicle))
        QBCore.Functions.Notify("Aracınız hazır, anahtarı aldınız!", "success")
    end, coords, true)
end)
