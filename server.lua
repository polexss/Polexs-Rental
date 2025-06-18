local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("qb-rental:rentVehicle", function(model)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        TriggerClientEvent('QBCore:Notify', src, "Oyuncu bulunamadı.", "error")
        return
    end

    if not model then
        TriggerClientEvent('QBCore:Notify', src, "Geçersiz araç modeli.", "error")
        return
    end

    -- Araç bilgisi config'ten alınır
    local vehicleData = nil
    for _, v in pairs(Config.Vehicles) do
        if v.model == model then
            vehicleData = v
            break
        end
    end

    if not vehicleData then
        TriggerClientEvent('QBCore:Notify', src, "Araç bulunamadı!", "error")
        return
    end

    -- Para kontrolü ve çekme
    local price = vehicleData.price
    if Player.Functions.RemoveMoney("cash", price) then
        -- Kiralama başarılı
        TriggerClientEvent("qb-rental:spawnVehicle", src, model)
        TriggerClientEvent('QBCore:Notify', src, vehicleData.label .. " kiralandı! $" .. price, "success")
    else
        -- Yetersiz para
        TriggerClientEvent('QBCore:Notify', src, "Yeterli paranız yok!", "error")
    end
end)
