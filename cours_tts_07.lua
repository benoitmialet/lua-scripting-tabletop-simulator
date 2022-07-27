----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /07
-- MAJ 27/07/2022
-- Objectifs:
    -- Utiliser des fonctionnalités avancées sur les boutons
        -- les modifier avec editButton(), les supprimer avec clearButtons()
        -- reconnaître le joueur ayant cliqué et l'objet cliqué
----------------------------------------------------------------------------------------------------


button_setup_guid = '0926c8'
button_deck_guid = '49df24'
deck1_guid = 'c9c4c8'
zone_game_guid = 'acc4c5'

-- Dans la fonction onLoad(), on va ajouter des déclaration de zones et changer un ou deux boutons
function onLoad()
    button_setup = getObjectFromGUID(button_setup_guid)
    button_deck = getObjectFromGUID(button_deck_guid)
    deck1 = getObjectFromGUID(deck1_guid)
    zone_game = getObjectFromGUID(zone_game_guid)

    -- on garde le bouton de mise en place
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

    --on garde ces deux boutons (cours 02)
    button_deck.createButton({
        click_function = "shuffleDeck",
        function_owner = Global,
        label          = "Mélanger",
        height          = 600,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 1.2},
        rotation        = {0, 180, 0}
    })
    button_deck.createButton({
        click_function = "takeCardFromDeck1",
        function_owner = Global,
        label          = "Défausser",
        height          = 600,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
    --NOUVEAU : on peut créer des boutons "décoratifs" (juste du texte affiché)
    button_deck.createButton({
        click_function = "doNothing",
        function_owner = Global,
        label          = "Texte décoratif :)",
        height          = 0,
        width           = 0,
        font_size       = 300,
        font_color      = {1, 1, 1, 1},
        position        = {0, 0.3, -1.2},
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

--fonction reliée au bouton décoratif
function doNothing()
end

-- NOUVEAU : Identifier qui a cliqué et quel objet est cliqué
-- TOUTE fonction lancée de puis un bouton inclut part défaut deux arguments. On les nomme comme on veut :
    -- Le 1er est l'objet sur lequel le bouton cliqué se situe (ici, on ne se servira pas de cet argument, donc on le note "_")
    -- Le 2e est la couleur du joueur ayant cliqué. On va l'utiliser pour savoir à qui envoyer la carte
-- on peut ajouter autant d'arguments que l'on veut ensuite (ici pas besoin)
function pickFromDeck(_, color)
    deck1.dealToColor(1, color)
    broadcastToAll("Le joueur "..color.." a pioché une carte", color)
end


--  On va modifier la fonction de mise en place (cours 03) pour générer et éditer des boutons
function setupTable()
    for i, position in ipairs(position_card) do
        local params = {}
        params.position = position
        params.rotation = {0, 180, 0}
        local card = deck1.takeObject(params)
        --NOUVEAU : ajouter un bouton cliquable à chaque carte piochée au cours de la boucle
        -- on créée une fonction pour cela, c'est plus facile à lire et à digérer
        addPickButton(card)
        -- NOUVEAU : pour transformer un bouton en un autre, on utilise editButton()
            -- L'index est le seul paramètre obligatoire.
                -- il correspond à l'index des boutons situés sur l'objet par ordre de création
                -- ATTENTION : contrairement à une table, un objet, etc., l'index d'un bouton commence à 0. C'est comme ça !
                -- ici par exemple, on change le 3e bouton sur button_deck. Son idex sera donc 2
            -- Ensuite on renseigne uniquement les paramètres à changer, rien d'autre.
        button_deck.editButton({
            index           = 2,-- (obligatoire),
            click_function  = 'pickFromDeck',
            label           = 'Piocher',
            height          = 600,
            width           = 2000,
            font_size       = 300,
            color           = {1, 1, 1, 1},
            font_color      = {0, 0, 0, 1}
        })
    end
end


-- le bouton a générer automatiquement sur chaque carte
function addPickButton(card)
    card.createButton({
        click_function  = "pickCard",
        function_owner  = Global,
        label           = "V",
        position        = {0, 0.5, 2},
        rotation        = {0,180,0},
        width           = 300,
        height           = 20,
        font_size       = 150,
        color           = {0.15, 0.15, 0.15, 0.8},
        font_color      = {1,1,1,1},
        tooltip         = "Choisir",
    })
end


-- la fonction issue de ce bouton, avec les 2 arguments par défaut cités plus haut.
function pickCard(card, color)
    -- on sait quelle carte est cliquée, et qui a cliqué. Facile de l'attribuer à un joueur donc.
    card.deal(1,color)
    -- on pense à retirer tout bouton de cette carte avant de l'envoyer en main
    card.clearButtons()
    -- ici on ajoute par exemple une fonction qui va nettoyer l'offre de cartes une fois celle-ci choisie
    Wait.time(function ()
        local objects = zone_game.getObjects()
        local position = deck1.positionToWorld({3, 1, 0})
        for index, obj in ipairs(objects) do
            obj.clearButtons()
            obj.setPositionSmooth(position)
        end
    end,1)
end


-- (cours 02)
function shuffleDeck()
    deck1.shuffle()
end


-- (cours 02)
function takeCardFromDeck1()
    local params = {}
    params.position = deck1.getPosition()
    params.position[1] = params.position[1] + 3
    params.rotation = {0, 180, 0}
    deck1.takeObject(params)
end


--cette petite fonction regroupe les cartes d'une zone dans un même deck
-- on ne s'en sert pas mais je voulais la montrer
function groupCards(zone)
    local objects = zone.getObjects()
    objects.group()
end