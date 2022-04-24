----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /07
-- Objectif:
    -- Créer quelques fonctions utiles soi-même :
        -- Contrôler que tous les joueurs soient assis avant de démarrer une partie
        -- Désigner aléatoirement un premier joueur
    -- Utiliser des fonctions de déplacement d'objets avancées
----------------------------------------------------------------------------------------------------

button_setup_guid = '0926c8'
deck1_guid = 'c9c4c8'
cube_bleu_guid = 'afa021'
cube_rouge_guid = '939c55'

function onLoad()

    button_setup = getObjectFromGUID(button_setup_guid)
    deck1 = getObjectFromGUID(deck1_guid)
    cube_bleu = getObjectFromGUID(cube_bleu_guid)
    cube_rouge = getObjectFromGUID(cube_rouge_guid)

    -- NOUVEAU : pour info, on peut tester la présence d'un objet sans passer par la donnée sauvegardée
    -- C'est un raccourci qui ne marchera que dans onLoad()
    if button_setup then
        activateButtonSetup()
    end

    -- NOUVEAU : on créé ce bouton pour déplacer le cube (gadget)
    cube_bleu.createButton({
        click_function = "moveCube", -- la fonction qui va être déclenchée en cliquant sur le bouton
        function_owner = Global, --où se trouve cette fonction (ici, dans l'environnement global)
        label          = "Boing!",
        height          = 300,
        width           = 800,
        font_size       = 120,
        color           = {1, 1, 1, 1},
        position        = {0, 1, 0},
        rotation        = {0, 180, 0}
    })

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


-- NOUVEAU : Deux fonctions customisées, d'autres fonctions de déplacement
    --cette fonction est tirée du cours 03. On va la compléter.
function setupTable()
    -- NOUVEAU : avant de lancer la partie, on veut vérifier que tous les joueuses et joueurs soient assis
    -- on créée pour cela nous même une fonction qui renvoie un résultat :
        -- true si tout le monde est assis
        -- false si au moins un joueur n'est pas assis. La fonction setupTable est alors interrompue par le return
    if testColors()==false then return 0 end

    -- Jusqu'ici on utilisait l'écriture suivante pour placer les cartes
    -- Elle nécessite de créer la table position_card au préalable
    for i, position in ipairs(position_card) do
        local params = {}
        params.position = position
        params.rotation = {0, 180, 0}
        -- on commente cette ligne pour la désactiver.
        -- deck1.takeObject(params)
    end

    -- NOUVEAU : Voici un autre exemple de disposition de carte, basée sur le calcul, qui fonctionne toute seule
    -- on part de la position du deck que l'on va décaler de 20 unités vers la gauche à chaque boucle
    -- positionToWorld() prend la position de l'objet, et y ajoute un vecteur de position
    -- ici on veut partir de 20 unités à gauche du paquet de cartes:
    local pos = deck1.positionToWorld({-20, 0, -7})
    -- on distribue par exemple des cartes sur 3 rangée et 6 colonnes
        -- il faut pour cela créer une boucle (les colonnes) à l'intérieur d'une autre boucle (les lignes)
    for i = 1, 3 do
        for i = 1, 6 do
            local params = {}
            params.position = pos
            params.rotation = {0, 180, 0}
            deck1.takeObject(params)
            -- Vector() est une fonction qui transforme une table de 3 valeurs en vecteur
            -- on peut ainsi additionner, soustraire des vecteurs entre eux
            pos = pos + Vector({3, 0, 0})
        end
        pos = pos + Vector({-18, 0, -4})
    end

    -- NOUVEAU : On détermine le premier joueur
    firstPlayer()
end


-- NOUVEAU : cette fonction fait juste retourner et déplacer un cube mais elle montre d'autres moyens de le faire
function moveCube()
    -- flip() est simple d'utilisation, mais elle met fin à tout mouvement si elle est placée après lui
    cube_rouge.flip()

    -- translate() déplace un objet par rapport à sa position initiale. Très pratique
    -- on donne un vecteur en paramètre et le déplacement résultera de l'addition de ce vecteur à la position initiale de l'objet.
    cube_bleu.translate({-3, 2, 0})
end


-- NOUVEAU : tester que tous les joueurs soient assis à une couleur valide, ou spectateurs
-- cela éviter que des scripts d'installation échouent leur exécution
-- renvoie une valeur true ou false
-- requiert la fonction hasValue()
function testColors()
    for key, color in pairs(getSeatedPlayers()) do
        if hasValue(Player.getAvailableColors(),color) then
        else
            broadcastToAll(Player[color].steam_name..' ('..color..') doit choisir une couleur disponible ou être spectateur')
            return false
        end
    end
    return true
end

-- (voir cours 05)
function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end

-- NOUVEAU : déterminer aléatoirement le 1er joueur (et stocker l'information dans la variable first_player_color)
function firstPlayer()
    local table_seated_players = getSeatedPlayers()
    local random = math.random(#table_seated_players)
    first_player_color = table_seated_players[random]
    Wait.time(function ()
        broadcastToAll(Player[first_player_color].steam_name..' joue en premier',first_player_color)
    end,3)
end

