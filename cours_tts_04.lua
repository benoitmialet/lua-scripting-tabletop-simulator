----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /04
-- Objectif:
    -- Comprendre les test If...then
----------------------------------------------------------------------------------------------------
-- un test "IF" sert à tester une condition et suit la logique du langage naturel:
    --"si [condition] alors..", "si [condition1] ou [condition2] alors.., sinon..."
-- Il existe plusieurs façons d'utiliser un IF (il y a un exemple de chaque dans le cours):
    -- en comparant avec une valeur numérique (attention aux notations) :  >10  <2  >=5  <= 6  ==5
    -- en comparant avec une chaîne de caractère : == 'le texte à comparer'
    -- avec un "booléen". C'est une variable qui ne peut prendre que 2 valeurs: 1 ou 0, true ou false, existe ou n'existe pas


--déclarer les guid des objets séparément permet de déclarer des objets à chaque fois que l'on en a besoin
-- et pas seulement dans la fonction onLoad()
-- suivant comment est organisé le script, cela peut être utile (on va s'en servir dans ce script)
button_deck_guid = '49df24'
button_setup_guid = '0926c8'
deck1_guid = 'c9c4c8'
bag_token_guid = '200cdb'


--la fonction onLoad est dans l'ensemble la même que dans le cours 03. On ajoute un bouton.
function onLoad()
    -- ici on utilise les guids déclarés plus haut (cela revient au même que de les inscrire directement)
    button_deck = getObjectFromGUID(button_deck_guid)
    button_setup = getObjectFromGUID(button_setup_guid)
    deck1 = getObjectFromGUID(deck1_guid)
    bag_token = getObjectFromGUID(bag_token_guid)

    -- ce bouton va distribuer des jetons devant les joueurs
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
    -- ce bouton va piocher une reine
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


-- NOUVEAU : Mise en place pour les joueurs avec des conditions
function setupPlayers()
    -- distribuer les cartes aux joueurs
    nb_cards_to_deal = {4, 3, 2, 2, 1}
    nb_players = #getSeatedPlayers()
    deck1.deal(nb_cards_to_deal[nb_players])

    --NOUVELLE CONDITION : "si" le nombre de joueurs est inférieur ou égal à 4, "alors" on défausse 3 cartes du deck.
    if nb_players <= 3 then
        for i = 1, 5 do
            takeCardFromDeck1() --voir plus bas pour cette fonction
        end
    -- ne jamais oublier de refermer un IF
    end
end

-- NOUVEAU : on modifie la fonction suivante pour vérifier d'abord si le deck existe
-- C'est une sécurité courante pour éviter de faire bugger un script
function takeCardFromDeck1()
    -- NOUVELLE CONDITION :
    -- Pour éviter un bug en cas d'absence de deck ou s'il reste 1 carte, on teste la présence du deck d'abord
        -- Pour cela, on teste si getObjectFromGUID() retourne "quelque chose":
            -- "si oui", on ne fait rien... La fonction continue son cours. C'est le rôle de "then else"
            -- "sinon", on l'interromp avec "return 0" (on retourne un résultat, peu importe lequel, cela stoppe la fonction)
        -- (cela peut porter à confusion, bien relire et s'habituer)
    if getObjectFromGUID(deck1_guid) then else return 0 end
    -- définir la position et la rotation de la carte piochée
    local params = {}
    params.position = deck1.getPosition()
    params.position[1] = params.position[1] + 3
    params.rotation = {0, 180, 0}
    --piocher la carte du deck avec ces paramètres
    deck1.takeObject(params)
end


-- NOUVEAU : fonction pour piocher une reine
-- DIFFICILE...
function pickQueenFromDeck1()
    -- on fait l'inventaire de tous les objets (les cartes) contenues dans le deck1
    -- REMARQUE : si le deck1 n'existe plus, le script ne bug pas, la table est simplement vide.
    local cards = deck1.getObjects() -- ceci renvoie une table listant les objets
    -- on va itérer (faire une boucle) sur toutes ces cartes et chercher les reines
    for index, object in ipairs(cards) do
        -- on teste à chaque fois si son nom correspond à "reine". On utilise l'attribut name
        if object.name == 'reine' then
            local params = {}
            -- on reprend le même principe que pour la fonction takeCardFromDeck1()
            -- mais on ajoute le GUID de la carte pour la piocher spécifiquement
            params.position = deck1.getPosition()
            params.position[1] = params.position[1] + 3
            params.rotation = {0, 180, 0}
            params.guid = object.guid
            -- cela marcherait aussi bien en prenant l'index de la carte dans la liste des objets détectés plutot que le guid
            -- params.index = object.index
            deck1.takeObject(params)
            -- Apres avoir pioché une carte, on doit interrompre de la boucle, sinon toutes les reines seront piochées
            -- C'est le rôle de "break"
            break
        end
    end
end