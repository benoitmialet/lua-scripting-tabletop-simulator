----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /07
-- MAJ 07/08/2022
-- Objectifs:
    -- Créer quelques fonctions utiles soi-même :
        -- Contrôler que tous les joueurs soient assis avant de démarrer une partie
        -- Désigner aléatoirement un premier joueur
    -- Découvrir d'autres fonctions alternatives de positionnement et de déplacement d'objets 
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

    activateButtonMenu()

    cube_bleu.createButton({
        click_function = "moveCube",
        function_owner = Global,
        label          = "Boing!",
        height          = 300,
        width           = 800,
        font_size       = 120,
        color           = {1, 1, 1, 1},
        position        = {0, 1, 0},
        rotation        = {0, 180, 0}
    })
end

--activation du bouton de mise en place
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


-- la fonction setupTable() est tirée du cours 03. On va la modifier avec :
    -- une fonction testColors() pour vérifier que tous les joueurs soient assis avant de démarrer
        -- un false est retourné si au moins un joueur n'est pas assis (voir plus bas)
        -- la fonction setupTable est alors interrompue par le return 0
    -- un autre exemple de disposition de carte, basée sur le calcul
        -- c'est plus compliqué à faire mais ne nécessite pas de créer la table position_card au préalable
        -- c'est donc préférable s'il y a beaucoup de positions à couvrir avec des espacements réguliers.
        -- ici on distribue par exemple des cartes sur 3 rangée et 6 colonnes
        -- il faut pour cela créer une boucle (les colonnes) à l'intérieur d'une autre boucle (les lignes)
        -- on part de la position du deck décalée de 20 unités vers la gauche
        -- on décale de 3 vers la droite à chaque boucle sur la même ligne
        -- on revient à la ligne en décalant de 18 vers la gauche et 4 vers le bas
    -- une fonction firstPlayer() pour déterminer le premier joueur (voir plus bas)
-- POSITIONTOWORLD
    -- positionToWorld() définit une position
    -- elle prend la position de l'objet, et y ajoute un Vector
    -- c'est exactement comme additionner la position + un Vector (voir les cours précédents)
function setupTable()

    if testColors()==false then return 0 end

    -- mise en place

    button_setup.clearButtons()
    firstPlayer()
end



-- VERIFIER QUE TOUS LES JOUEURS SOIENT ASSIS
    -- on créé testColors() pour tester si tous les joueurs sont assis à une couleur valide, ou spectateurs
    -- cela évite que des scripts d'installation ne se lancent avant que tout les joueurs soient prêts
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

-- (voir cours_tts_05.lua)
function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end

-- DETERMINER ALEATOIREMENT LE PREMIER JOUEUR
    -- on créé firstPlayer() pour déterminer aléatoirement le 1er joueur
    -- l'information est stockée dans la variable globale first_player_color
function firstPlayer()
    local table_seated_players = getSeatedPlayers()
    local random = math.random(#table_seated_players)
    first_player_color = table_seated_players[random]
    Wait.time(function ()
        broadcastToAll(Player[first_player_color].steam_name..' joue en premier',first_player_color)
    end,3)
    return first_player_color
end

