----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /07
-- MAJ 07/08/2022
-- Objectifs:
    -- Utiliser des fonctionnalités avancées sur les boutons
        -- les modifier avec editButton(), les supprimer avec clearButtons()
        -- reconnaître le joueur ayant cliqué et l'objet cliqué
----------------------------------------------------------------------------------------------------


button_setup_guid = '0926c8'
button_deck_guid = '49df24'
deck1_guid = 'c9c4c8'
zone_game_guid = 'acc4c5'

function onLoad()
    button_setup = getObjectFromGUID(button_setup_guid)
    button_deck = getObjectFromGUID(button_deck_guid)
    deck1 = getObjectFromGUID(deck1_guid)
    zone_game = getObjectFromGUID(zone_game_guid)
    activateButtonMenu()
end

-- BOUTONS DECORATIFS
    -- on peut créer des boutons "décoratifs" (juste du texte affiché) qui renvoient vers une fonction vide
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

    button_deck.createButton({
        click_function = "takeCardFromDeck1",
        function_owner = Global,
        label          = "Défausser",
        height          = 600,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 1.2},
        rotation        = {0, 180, 0}
    })

    button_deck.createButton({ -- bouton décoratif
        click_function = "doNothing",
        function_owner = Global,
        label          = "Texte décoratif :)",
        height          = 0,
        width           = 0,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        font_color      = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
end

--fonction reliée au bouton décoratif, qui ne fait rien
function doNothing()
end

-- IDENTIFIER LE JOUEUR AYANT CLIQUE SUR UN BOUTON ET QUEL OBJET EST CLIQUE
    -- TOUTE fonction lancée de puis un bouton inclut part défaut deux arguments. On les nomme comme on veut :
        -- Le 1er est l'objet sur lequel le bouton cliqué se situe (on ne va pas l'utiliser)
        -- Le 2e est la couleur du joueur ayant cliqué. On va l'utiliser pour savoir à qui envoyer la carte
    -- on peut ajouter autant d'arguments que l'on veut ensuite (ici pas besoin)
function pickFromDeck(object, color)
    deck1.dealToColor(1, color)
    broadcastToAll("Le joueur "..color.." a pioché une carte", color)
end


-- On va modifier la fonction de mise en place (cours 03) pour générer et éditer des boutons
-- AJOUTER UN BOUTON SUR CHAQUE CARTE PIOCHEE
    -- on créée une fonction addPickButton() pour cela, c'est plus facile à lire et à digérer
    -- on ajoute évidemment card en argument, pour préciser sur quelle carte la fonction doit agir
-- EDITER UN BOUTON
    -- on utilise editButton(). L'index du bouton est le seul paramètre obligatoire.
    -- l'index du bouton correspond au n° du bouton sur l'objet qui les porte, par ordre de création
    -- ATTENTION : contrairement à une table, l'index d'un bouton commence à 0. C'est comme ça !
    -- ici par exemple, on change le 3e bouton sur button_deck. Son idex sera donc 2
    -- Ensuite on renseigne uniquement les paramètres du bouton à changer, les autres sont conservés.
function setupTable()
    local position_card = {
            {-13.49, 1.04, 3.5},
            {-10.5, 1.04, 3.5},
            {-7.51, 1.04, 3.5},
            {-4.5, 1.04, 3.5},
            {-1.5, 1.04, 3.5},
            {1.5, 1.04, 3.5}
        }
    deck1.shuffle()
    for i, position in ipairs(position_card) do
        local params = {}
        params.position = position
        params.rotation = {0, 180, 0}
        local card = deck1.takeObject(params)

        addPickButton(card)

        button_deck.editButton({
            index           = 1,        -- (obligatoire)
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


-- la fonction cliquable issue de ce bouton, avec les 2 arguments : objet, couleur du joueur
-- on procède en 3 étapes
    -- 1) on sait quelle carte est cliquée, et qui a cliqué. On peut donc donner la carte à un joueur avec deal()
    -- NB : deal() marche aussi bien sur une carte seul que sur un deck, contrairement a takeObject()
    -- 2) on pense à retirer tout bouton de cette carte avant de l'envoyer en main avec clearButtons()
    -- 3) on ajoute par exemple une fonction qui va nettoyer l'offre de cartes une fois celle-ci choisie
        -- a) faire l'inventaire des objets de la zone et le parcourir
        -- b) identifier les cartes. pour chaque carte :  
            -- c) effacer tous les boutons
            -- d) la placer dans la défausse
function pickCard(card, color)
    card.deal(1,color)
    card.clearButtons()
    Wait.time(function ()
        local objects = zone_game.getObjects()
        -- local position = deck1.positionToWorld({3, 1, 0})
        local position = deck1.getPosition() + Vector({3, 1, 0})
        for index, obj in ipairs(objects) do
            if obj.type == 'Card' then
                obj.clearButtons()
                obj.setPositionSmooth(position)
            end
        end
    end,1)
end


-- (cf cours_tts_02.lua)
function takeCardFromDeck1()
    local params = {}
    params.position = deck1.getPosition()
    params.position = params.position + Vector({3, 1, 0})
    params.rotation = {0, 180, 0}
    deck1.takeObject(params)
end


-- cette petite fonction regroupe les cartes d'une zone dans un même deck, et renvoie la liste des cartes groupées
-- on ne s'en sert pas mais je voulais la montrer
-- attention, group() agit aussi sur les autres objets groupables (jetons, ...).
function groupCards(zone)
    local objects = zone.getObjects()
    local table_cards = objects.group()
    return table_cards
end