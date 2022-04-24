----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /06
-- Objectif:
    -- Utiliser la sauvegarde de données
    -- Gérer le timing avec Wait.time()
----------------------------------------------------------------------------------------------------

button_setup_guid = '0926c8'
deck1_guid = 'c9c4c8'

-- NOUVEAU : sauvegarde de données
    -- La sauvegarde de données intervient à chaque chargement de partie ET à chaque retour arrière (CTRL+Z)
    -- ce qui suit est une façon de faire parmi d'autres. On peut sauvegarder n'importe quelle information que l'on souhaite.
    -- on commence à définir les données à sauvegarder
game_data = {
    -- setup_done sert par exemple à statuer si la partie a été mise en place ou non
    setup_done = false,
    round_nb = 1,
}

-- on définit la fonction onSave, qui interviendra à chaque sauvegarde automatique ou manuelle
function onSave()
    -- la table game_data est sauvegardée dans le JSON
    saved_data = JSON.encode(game_data)
    return saved_data
end

    -- enfin, on charge les données de la sauvegarde contenue dans le JSON, à chaque fois que onLoad() est lancée
    -- on peut maintenant faire appel à la table game_data à tout moment
function onLoad(saved_data)
    if saved_data ~= "" then
        game_data = JSON.decode(saved_data)
    end

    button_setup = getObjectFromGUID(button_setup_guid)
    deck1 = getObjectFromGUID(deck1_guid)

    -- NOUVEAU : utilisation de la donnée sauvegardée
    -- on déplace la création de bouton setup dans une fonction et on soumet son apparition à une condition
    -- en effet, si la partie est déja mise en place, ce boouton n'a pas lieu d'être !
    if game_data.setup_done == false then
        activateButtonSetup()
    end

    -- Position des cartes sur la table
    position_card = {
        {-13.49, 1.04, 3.5},
        {-10.5, 1.04, 3.5},
        {-7.51, 1.04, 3.5},
        {-4.5, 1.04, 3.5},
        {-1.5, 1.04, 3.5},
        {1.5, 1.04, 3.5}
    }
end

--activation du bouton de mise en place
function activateButtonSetup()
    button_setup.createButton({
        click_function = "setupTable",
        function_owner = Global,
        label          = "Installer\nla table",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
end

-- NOUVEAU : Timing
-- on garde la meme fonction de mise en place (voir cours 03) mais on ajoute du timing
function setupTable()
    --on définit le delai en secondes entre chaque carte posée
    local delay_add = 0.15
    -- on fixe un délai de départ (pour la pose de la première carte)
    local delay = delay_add
    for i, position in ipairs(position_card) do
        -- on utilise la fonction Wait.time(). Ne pas oublier la majuscule à Wait !
        -- tout ce qui concerne l'opération répétée à intercalée dans le temps doit être contenue à l'intérieur
        -- elle vient donc à l'intérieur de la boucle FOR
        Wait.time(function()
            local params = {}
            params.position = position
            params.rotation = {0, 180, 0}
            deck1.takeObject(params)
            -- on ferme la fonction Wait.time() et on applique le délai avant le prochain tour de boucle FOR
        end, delay)
        -- enfin on incrémente le délai, pour que l'opérattion de la prochaine boucle soit légèrement décalée dans le temps
        delay = delay + delay_add
    end
    -- NOUVEAU : Sauvegarder une donnée
    -- A la fin de la mise en place, je donne l'information que la mise en place est faite. Elle sera sauvegardée
    game_data.setup_done = true
end