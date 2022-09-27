----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /04
-- MAJ 07/08/2022
-- Objectif:
-- Comprendre les test if...then
-- Utiliser la fonction getObjects
----------------------------------------------------------------------------------------------------

-- TEST IF
-- un test "if" sert à tester une condition et suit la logique du langage naturel:
    --"si [condition] alors..", "si [condition1] ou [condition2] alors.., sinon..."
-- Il existe plusieurs façons d'utiliser un if (il y a un exemple de chaque dans ce cours):
    -- en comparant avec une valeur numérique (attention aux notations) :  >10  <2  >=5  <= 6  ==5
    -- en comparant avec une chaîne de caractère : == 'le texte à comparer'
    -- avec un "booléen". C'est une variable qui ne peut prendre que 2 valeurs: 1 ou 0, true ou false, existe ou n'existe pas
-- un test if peut combiner plusieurs conditions
    -- IF condition1 and condition2   : les 2 conditions doivent être vérifiées
    -- IF condition1 or condition2   : au moins une des 2 conditions doit être vérifiée
-- DECLARER DES GUID EN DEHORS DE ONLOAD
-- déclarer les guid des objets ici permet de déclarer des objets à chaque fois que l'on en a besoin
-- et pas seulement dans la fonction onLoad()
-- suivant comment est organisé le script, cela peut être utile (on va s'en servir dans ce script)
button_deck_guid = '49df24'
button_setup_guid = '0926c8'
deck1_guid = 'c9c4c8'
bag_token_guid = '200cdb'

--la fonction onLoad est dans l'ensemble la même que dans le cours 03.
    -- on utilise les guids déclarés plus haut (cela revient au même que de les inscrire directement)
    -- on ajoute un bouton. pickQueenFromDeck1 va piocher une reine
function onLoad()
    button_deck = getObjectFromGUID(button_deck_guid)
    button_setup = getObjectFromGUID(button_setup_guid)
    deck1 = getObjectFromGUID(deck1_guid)
    bag_token = getObjectFromGUID(bag_token_guid)
    activateButtonMenu()
end


function activateButtonMenu()
    button_setup.createButton({
        click_function = "setupPlayers",
        function_owner = Global,
        label          = "Distribuer",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 1},
        rotation        = {0, 180, 0}
    })

    button_deck.createButton({
        click_function = "pickQueenFromDeck1",
        function_owner = Global,
        label          = "Piocher\nune Reine",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
end

-- MISE EN PLACE AVEC DES CONDITIONS
    -- on distribue les cartes aux joueurs (voir cours_tts_03.lua)
    -- on ajoute maintenant une condition :
        -- "si" le nombre de joueurs est inférieur ou égal à 3, "alors" on défausse 5 cartes du deck.
        -- ne jamais oublier de refermer un if avec un end
function setupPlayers()
    nb_cards_to_deal = {4, 3, 2, 2, 1}
    nb_players = #getSeatedPlayers()
    deck1.deal(nb_cards_to_deal[nb_players])

    local message = nil
    if nb_players <= 3 then
        for i = 1, 5 do
            drawCardFromDeck(deck1) --voir plus bas pour cette fonction
        end
        message = "5 cartes ont été défaussées."
    elseif nb_players <= 5 then
        message = "Aucune carte n'a été défaussée."
    else
        message = ''
    end

    broadcastToAll(message)
end

-- takeCardFromDeck1() pioche une carte et la place dans la défausse (voir cours_tts_03.lua)
    -- on ajoute une condition pour vérifier que le deck existe bien d'abord.
-- TESTER SI UN OBJET EXISTE
    -- On a régulièrement besoin de savoir si un objet existe dans le jeu avant d'y faire appel
    -- Dans notre exemple, si un deck n'existe plus et qu'on veut piocher dedans, le script plantera !
    -- C'est une erreur de script très fréquente ! 
    -- IMPORTANT : s'il reste 1 carte dans le deck, l'objet n'est plus un deck mais une carte !
    -- takeObject sur 1 carte seule ne fonctionnera pas et renverra une erreur
    -- on vérifie donc d'abord si le deck existe
    -- c'est une sécurité courante pour éviter de faire bugger un script
    -- Pour cela, on teste si getObjectFromGUID() retourne "quelque chose":
        -- "si oui", on ne fait rien... La fonction continue son cours. C'est le rôle de "then else"
        -- "sinon", on l'interromp avec "return 0" (on retourne un résultat, peu importe lequel, cela stoppe la fonction)
        -- if getObjectFromGUID(deck1_guid) est la même chose que if getObjectFromGUID(deck1_guid) == true
        -- cela peut porter à confusion, bien relire ce qui suit et et s'y habituer !
function drawCardFromDeck(deck1)
    if not getObjectFromGUID(deck1_guid) then
        return
    end
    local params = {}
    params.position = deck1.getPosition() + Vector({3, 1, 0})
    params.rotation = {0, 180, 0}
    deck1.takeObject(params)
end


function pickQueenFromDeck1()
    pickQueenFromDeck(deck1)
end

-- CHERCHER UN OBJET PARTICULIER DANS UN CONTAINER
    -- on veut créer un fonction pickQueenFromDeck1() qui pioche une reine
    -- ATTENTION, DIFFICILE... 5 étapes
    -- 1) on fait l'inventaire de tous les objets (les cartes) contenues dans le deck1
        -- NB : si le deck1 n'existe plus, le script ne bug pas, la table est simplement vide.
    -- 2) on va itérer (faire une boucle) sur toutes ces cartes du deck
    -- 3) pour chaque carte, on teste si son nom correspond à "reine". On utilise l'attribut .name
    -- 4) si le nom est "reine", on tutilise takeObject()
        -- on ajoute le GUID de la carte pour piocher celle-ci spécifiquement (et pas la première venue)
        -- cela marcherait aussi bien en prenant l'index de la carte dans la liste des objets détectés plutot que le guid
        -- params.index = object.index
    -- 5) Apres avoir trouvé une reine, on interromp la boucle avec break, sinon toutes les reines seront piochées
-- La fonction GETOBJECTS
    -- getObjects() liste les objets contenus dans une zone ou un conteneur (sac, deck...)
    -- Elle retourne une table que l'on récupère pour la parcourir
-- BREAK
    -- break sert à interrompre une boucle for 
function pickQueenFromDeck(deck)
    local cards = deck1.getObjects()
    for index, object in ipairs(cards) do
        if object.name == 'reine' then
            local params = {}
            params.position = deck1.getPosition() + Vector({3, 1, 0})
            params.rotation = {0, 180, 0}
            params.guid = object.guid
            deck1.takeObject(params)
            break
        end
    end
end