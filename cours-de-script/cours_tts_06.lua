----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /06
-- MAJ 07/08/2022
-- Objectifs:
    -- Utiliser la sauvegarde de données
    -- Gérer le timing avec Wait.time()
----------------------------------------------------------------------------------------------------

button_setup_guid = '0926c8'
deck1_guid = 'c9c4c8'

-- SAUVEGARDE DE DONNEES
    -- La sauvegarde de données intervient à chaque chargement de partie ET à chaque retour arrière (CTRL+Z)
    -- ce qui suit est une façon de faire parmi d'autres.
    -- on peut sauvegarder n'importe quelle information que l'on souhaite conserver.
    -- on procède en 2 étapes : 
        -- 1) on définit les données à sauvegarder dans une table (game_data)
            -- on créé par exemple setup_done pour statuer si la mise en place a été faite ou non
        -- 2) on renseigne la fonction onSave(), qui interviendra à chaque sauvegarde automatique ou manuelle
            -- la table game_data sera sauvegardée dans le fichier JSON du module avec encode()
        -- 3) enfin, dans la fonction onLoad() on charge les données de la sauvegarde contenue dans le JSON
            -- à chaque fois que onLoad() est lancée
    -- on peut maintenant faire appel à la table game_data à tout moment
        -- ici on soumet l'apparition du bouton setup à une condition
        -- en effet, si la partie est déja mise en place, ce bouton n'a pas lieu d'apparaitre !
        -- faites le test : cliquez sur "installer la table", sauvegardez puis recharger la partie. 
game_data = {
    setup_done = false,
    round_nb = 1,
}

function onSave()
    saved_data = JSON.encode(game_data)
    return saved_data
end

function onLoad(saved_data)
    if saved_data ~= "" then
        game_data = JSON.decode(saved_data)
    end

    button_setup = getObjectFromGUID(button_setup_guid)
    deck1 = getObjectFromGUID(deck1_guid)

    if game_data.setup_done == false then
        activateButtonMenu()
    end
end

function activateButtonMenu()
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

-- GERER LE TIMING AVEC TIME
    -- gérer un timing permet de décaler l'exécution d'une fonction dans le temps
    -- ici on veut qu'un instaurer un petit délai entre chaque pioche de carte, juste pour l'esthétique 
    -- on procède en 2 étapes : 
        -- 1) on définit le delai en secondes entre chaque carte posée (delay_add)
        -- 2) on fixe un délai de départ (en secondes) pour la pose de la première carte (delay)
        -- 3) on utilise la fonction Wait.time(). Ne pas oublier la majuscule à Wait !
            -- la notation est étrange mais compréhensible : Wait.time(function() end, delay)
            -- tout ce qui concerne l'opération à intercaler dans le temps doit être contenue dans le Wait
            -- entre function() et end
            -- à la fin, on ferme la fonction Wait.time() et on applique le délai avant le prochain tour de boucle for
            -- Wait.time vient donc à l'INTERIEUR de la boucle for
        -- 4) enfin on incrémente le délai, pour que l'opération de la prochaine boucle
        -- soit légèrement décalée dans le temps
-- NB : A la fin de la mise en place, on donne l'information que la mise en place est faite. Elle sera sauvegardée
function setupTable()
    local position_card = {
        {-13.49, 1.04, 3.5},
        {-10.5, 1.04, 3.5},
        {-7.51, 1.04, 3.5},
        {-4.5, 1.04, 3.5},
        {-1.5, 1.04, 3.5},
        {1.5, 1.04, 3.5}
    }

    local delay_add = 0.15
    local delay = 0
    for i, position in ipairs(position_card) do
        Wait.time(function()
            local params = {}
            params.position = position
            params.rotation = {0, 180, 0}
            deck1.takeObject(params)
        end, delay)
        delay = delay + delay_add
    end

    button_setup.clearButtons()
    game_data.setup_done = true
end

-- NB: La fonction Wait.time() donne l'illusion que le code placé en paramètre va "attendre" avant d'être exécuté
-- En réalité il n'en est rien. Tout le bloc de code sera exécuté instantément. 
-- C'est son processus qui va être décalé dans le temps. Cela peut crééer des surprises inattendues.
-- Si vous cherchez a réellement décaler des processus dans le temps, utilisez un Timer (voir le cours 09)
-- Wait.time() est cependant parfait donner un joli rendu animé au positionnement d'objets.