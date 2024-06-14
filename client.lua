---- GESTION DES CLEF VOITURE POUR FAIRE DES DOUBLES 

local function getUniqueCarKeys()
    -- Utiliser ox_inventory pour rechercher les clés de voiture
    local carKeys = exports.ox_inventory:Search('slots', 'carkey')
    local keysMap = {} -- Utiliser un tableau associatif pour éviter les doublons
    local uniqueKeys = {}

    for _, item in pairs(carKeys) do
        -- Construire l'identifiant unique de la clé basé sur les métadonnées
        local uniqueKeyId = item.label
        if item.metadata then
            uniqueKeyId = uniqueKeyId .. "-" .. (item.metadata.plate or "no-plate")
        end

        -- Ajouter l'item au tableau si ce n'est pas déjà présent
        if not keysMap[uniqueKeyId] then
            keysMap[uniqueKeyId] = true

            -- Construire le label complet avec item.label et les métadonnées
            local label = item.label
            if item.metadata then
                label = label .. " - " .. (item.metadata.plate or "Sans plaque")
            end

            table.insert(uniqueKeys, {
                name = item.name,
                label = label,
                slot = item.slot,
                metadata = item.metadata -- Inclure les métadonnées pour la duplication
            })
        end
    end

    return uniqueKeys
end

-- Fonction pour créer le menu des clés de voiture
local function openCarKeysMenu()
    local keys = getUniqueCarKeys()
    local options = {}

    -- Construire les options du menu à partir des clés de voiture trouvées
    for _, key in ipairs(keys) do
        table.insert(options, {
            title = key.label, -- Utiliser le label complet comme titre
            onSelect = function()
                local price = 500 -- Prix du double de clef
                -- Afficher une boîte de dialogue pour confirmer le prix
                local input = lib.inputDialog('Confirmation d\'achat', {
                    {type = 'input', label = 'Le prix de cet article est de $' .. price .. ' en liquide. Voulez-vous continuer ? (oui/non)', required = true}
                })
                if not input then 
                    lib.showContext('carkey_menu')
                    ESX.ShowNotification('Vous êtes sur de ce que vous voulez ?.')
                    return     
                end
                local response = input[1]:lower()
                if response == 'oui' then
                    -- Vérifier si le joueur a suffisamment d'argent
                    ESX.TriggerServerCallback('slashID:server:hasEnoughMoney', function(hasEnough)
                        if hasEnough then
                            -- Effectuer l'action si le joueur a suffisamment d'argent
                            local progressbar = lib.progressCircle({
                                duration = 5000,
                                label = "Vérification",
                                position = 'bottom',
                                disable = {
                                    car = true,
                                    combat = true,
                                    move = true,
                                },
                                anim = {
                                    dict = 'misscarsteal4@actor',
                                    clip = 'actor_berating_loop'
                                },
                            })
    
                            -- Après la vérification, retirer l'argent et ajouter l'item
                            if progressbar then
                                TriggerServerEvent('slashID:server:removeMoney', price)
                                TriggerServerEvent('slashcore:server:duplicateCarKey', key.metadata.plate)
                            end
                        else
                            ESX.ShowNotification('Vous n\'avez pas assez d\'argent.')
                            lib.showContext('carkey_menu')
                        end
                    end, price)
                else
                    ESX.ShowNotification('Vous êtes sur de ce que vous voulez ?.')
                    lib.showContext('carkey_menu')
                end
            end,
        })
    end

    -- Définir le contexte du menu avec les options construites
    lib.registerContext({
        id = 'carkey_menu',
        title = 'Gestion des clés de voiture',
        options = options
    })

    -- Afficher le contexte du menu pour ouvrir le menu des clés de voiture
    lib.showContext('carkey_menu')
end


local clevoiture = {
    coords = vec3(169.97021484375, -1799.517333984375, 29.68261528015136), -- Coordonnées de l'option
    rotation = 180.0,
    options = {
        { 
            icon = 'fa-solid fa-key', 
            label = "Faire un double de clef", -- Libellé pour l'emploi dans le pétrole
            canInteract = function(_, distance)
                return distance < 3
            end,
            onSelect = function()
                openCarKeysMenu()
            end,
        },
    }
}
exports.ox_target:addBoxZone(clevoiture)
