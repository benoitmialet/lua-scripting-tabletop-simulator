----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /05
-- MAJ 01/10/2022
-- Objectifs:
-- Utiliser les Zones de script
-- Tester les propriétés des objets (name, type, etc.)
----------------------------------------------------------------------------------------------------

-- ZONE DE SCRIPT
-- une zone de script va servir à détecter un ou plusieurs objets et permet d'agir dessus
-- elle est un objet comme les autres et se déclare avec getObjectFromGUID()
-- on l'utilise généralement avec les boucles for et les tests de condition if

button_setup_guid = '0926c8'
zone_deck_guid = 'ae31a0'
zone_game_guid = 'acc4c5'
button_zone_deck_guid = '1fb029'
deck1_guid = 'c9c4c8'

-- Dans la fonction onLoad(), on va ajouter des déclarations de zones et changer un ou deux boutons
    -- zone_deck servira à détecter un deck 
    -- zone_game au milieu de la table
    -- table_players définit une zone pour chaque joueur (recouvre ses plateaux, pions et cartes)
function onLoad()
    button_setup = getObjectFromGUID(button_setup_guid)
    button_zone_deck = getObjectFromGUID(button_zone_deck_guid)
    deck1 = getObjectFromGUID(deck1_guid)

    zone_deck = getObjectFromGUID(zone_deck_guid)
    zone_game = getObjectFromGUID(zone_game_guid)

    activateButtonMenu()

    table_players = {
        ['White'] = {
            zone = getObjectFromGUID('3ea23c')
        },
        ['Red'] = {
            zone = getObjectFromGUID('1580ff')
        },
        ['Blue'] = {
            zone = getObjectFromGUID('545c2b')
        },
        ['Green'] = {
            zone = getObjectFromGUID('5eaba1')
        }
    }
end

-- drawCardFromZoneDeck va piocher une carte dans zone_deck
function activateButtonMenu()
    button_setup.createButton({
        click_function = "setupTable",
        function_owner = Global,
        label          = "Installer\nla table", -- pour info, \n signifie "retour à la ligne"
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })

    button_zone_deck.createButton({
        click_function = "drawCardFromZoneDeck",
        function_owner = Global,
        label          = "Piocher\nune carte",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
end


-- cette fonction distribue 4 cartes sur la table (voir cours 03)
-- on ajoute l'appel d'une fonction qui va détruire les objets des joueurs absents (voir plus loin)
function setupTable()
    local position_card = {
        {-13.49, 1.04, 3.5},
        {-10.5, 1.04, 3.5},
        {-7.51, 1.04, 3.5},
        {-4.5, 1.04, 3.5},
        {-1.5, 1.04, 3.5},
        {1.5, 1.04, 3.5}
    }
    for i, position in ipairs(position_card) do
        local params = {}
        params.position = position
        params.rotation = {0, 180, 0}
        deck1.takeObject(params)
    end

    destructMissingPlayers()
end


--AJOUTER DES ARGUMENTS A UNE FONCTION DEPUIS UN BOUTON
    -- nous avons vu que ce n'était pas possible. Voici un moyen de le contourner
    -- il suffit de créer des fonctions intermédiaires qui renverront vers la fonction principale
    -- c'est aussi simple que cela
    -- l'avantage est que la fonction principale est générique et peut être réutilisée dans plusieurs contextes différents
function drawCardFromZoneDeck()
    drawCardFromZone(zone_deck)
end

-- PIOCHER DES ELEMENTS DEPUIS UNE ZONE
    -- on modifie la fonction de scours précédents pour piocher une carte depuis une zone.
    -- quelle utilité ?
        -- Elle fonctionnera à tous les coups, évitant de faire bugger un script de pioche si le deck est absent ou détruit.
        -- Cela arrive en général lorsqu'une pioche se vide.
    -- le principe :
        -- 1) on fait l'inventaire des objets contenus dans la zone
        -- 2) on recherche un deck (ou un sac)
        -- 3) on pioche depuis ce deck (ou ce sac)
-- TESTS IF SUR GETOBJECTS
    -- nous avons vu un exemple d'utilisation de getObjects avec une recherche basée sur le name dans le cours cours_tts_04.lua
    -- on peut en fait tester toutes les propriétés des objets listés (type, nom...)
    -- ici on va ici tester le type pour trouver un objet de type deck carte puis utiliser une fonction appropriée
    -- ATTENTION IMPORTANT, à retenir par coeur !!! :
        -- si on utilise getObjects() sur une ZONE, on créée une liste d'objets. 
        -- on accède donc directement à leurs propriétés.
        -- on doit donc utiliser majoritairement des FONCTIONS GET:
            -- getName() pour obtenir le nom de l'objet
            -- getGMNotes() pour obtenir le nom caché
            -- getPosition() pour obtenir la position
            -- getTags() pour obtenir la liste des tags. Ex : {'tag1', 'tag2', 'tag3'} 
            -- EXCEPTION : .type pour obtenir son type
            -- détail des fonctions get : https://api.tabletopsimulator.com/object/#get-functions
        -- si on utilise getObjects() sur un CONTENEUR, on créée une table avec des attributs (position =, size =, ...) 
        -- on n'accède donc pas directement aux objets et on ne eut pas utiliser de fonctions get.
        -- on doit donc utiliser des ATTRIBUTS:
            -- .name pour obtenir le nom de l'objet (si l'objet n'a aucun nom, .name renvoie le type d'objet)
            -- .gm_notes pour obtenir le nom caché
            -- .position pour obtenir la position
            -- .tags pour obtenir la liste des tags.
            -- ATTENTION: .type n'existe pas (retourne "nil"), utilisez .name si besoin
            -- le détail complet : https://api.tabletopsimulator.com/object/#getobjects-containers
        -- (la logique est difficile à accepter, mais vous règlerez beaucoup de problèmes en retenant cela)
-- TYPES D'OBJETS
    -- il existe énormément de types : 'Deck', 'Card', 'Token', 'Tile', 'Generic', 'Bag'...
    -- https://api.tabletopsimulator.com/built-in-object/#object-types.
    -- seuls quelques uns sont utilisés fréquemment
-- ELSEIF et ELSE
    -- elseif rajoute une condition si les conditons précédentes ne sont pas vérifiées.
    -- else finit un test if et indique ce qu'il faut faire si aucune condition n'est vérifiée
    -- si ... sinon si ... sinon ... alors
-- RETURN
    -- l'instruction return permet deux choses simultanées. On peut l'utiliser pour l'une ou pour les deux :
        -- 1) "renvoyer" une valeur (ou un objet, une table, etc.) à l'endroit du code ou la fonction a été appelée
        -- 2) mettre fin immédiatement à la fonction en cours.
    -- ici on va retourner l'objet "trouvé" dans la zone, car on pourrait en avoir besoin plus tard.
function drawCardFromZone(zone)
    local objects = zone.getObjects()
    for i, obj in ipairs(objects) do
        if obj.type == 'Deck' then
            local params = {}
            params.position = obj.getPosition() + Vector({3, 0.5, 0})
            params.rotation = {0, 180, 0}
            obj.takeObject(params)
            return obj
        elseif obj.type == 'Card' then
            obj.setRotationSmooth({0, 180, 0})
            obj.translate({3, 0.5, 0})
            return obj
        end
    end
end

-- on créé une fonction pour détruire tous les objets des joueurs absents. 4 étapes :
    -- 1) on parcourt les couleurs des joueurs assis
        -- rappel : on utilise une boucle pairs() car table_players est indexée par des clés alphabétiques (couleurs)
    -- 2)  on teste si la couleur fait partie des couleurs des joueurs présents, sinon on supprime ses objets.
        -- pour cela, on utilise une petite fonction customisée hasValue(), voir dessous
    -- 3) si la couleur est inoccupée, on récupère tous les objets de la zone du joueur
    -- 4) et on les détruit
-- La fonction DESTRUCT
    -- destruct() permet de détruire un objet. On ne pourra plus faire appel à lui.
function destructMissingPlayers(player_table)
    local seated_players = getSeatedPlayers()
    for color, _ in pairs(player_table) do
        if hasValue(seated_players, color) == false then
            local objects = player_table[color].zone.getObjects()
            for i, obj in ipairs(objects) do
                obj.destruct()
            end
        end
    end
end

-- une petite fonction très pratique pour vérifier si une valeur est contenue dans une table.
-- elle retourne l'index de la valeur le cas échéant, sinon false
function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end

-- une autre fonction très utile pour imprimer le contenu d'une table
-- par exemple, après avoir fait objects = getObjects(), affichez le contenu de la table avec print_r(objects)
-- (récupérée sur le site stackoverflow.com)
function print_r (t, indent, done)
    done = done or {}
    indent = indent or ' '
    local nextIndent -- Storage for next indentation value
    for key, value in pairs (t) do
    if type (value) == "table" and not done [value] then
        nextIndent = nextIndent or
            (indent .. string.rep(' ',string.len(tostring (key))+2))
            -- Shortcut conditional allocation
        done [value] = true
        print (indent .. "[" .. tostring (key) .. "] => Table {");
        print  (nextIndent .. "{");
        print_r (value, nextIndent .. string.rep(' ',2), done)
        print  (nextIndent .. "}");
    else
        print  (indent .. "[" .. tostring (key) .. "] => " .. tostring (value).."")
    end
    end
end