ESX.RegisterServerCallback('slashID:server:hasEnoughMoney', function(source, cb, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getMoney() >= price then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('slashID:server:removeMoney')
AddEventHandler('slashID:server:removeMoney', function(price)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeMoney(price)
end)



---- Duplication de clef de voiture 

RegisterNetEvent('slashcore:server:duplicateCarKey', function(plate)
    Vehicles = exports.mVehicle:vehicle()
    local source = source -- Récupérer l'identifiant du joueur
    -- Ajouter la clé dupliquée avec les mêmes métadonnées à l'inventaire du joueur
    Vehicles.ItemCarKeys(source, 'add', plate)
    TriggerClientEvent('esx:showNotification', source, "Vous avez créé un double de la clé " ..plate.." avec succès.")
end)
