----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /04
-- Objectif:
    -- Comprendre les test If...then
----------------------------------------------------------------------------------------------------
-- un test "IF a été rajouté a plusieurs endroits du code". 
-- Il existe plusieurs façons d'utiliser un IF (il y a un exemple de chaque dans le cours):
    -- en comparant avec une valeur numérique (attention aux notations) :  >10  <2  >=5  <= 6  ==5
    -- en comparant avec une chaine de caractère : =='le texte à comparer'
    -- avec un booléen. C'est une variable qui ne peut prendre que 2 valeurs: 1 ou 0, true ou false, existe ou n'existe pas


--la fonction onLoad est dans l'ensemble la même que dans le cours 03. On ajoute un bouton.
function onLoad()
    button_deck = getObjectFromGUID('49df24')
    button_setup = getObjectFromGUID('0926c8')
    deck1 = getObjectFromGUID('c9c4c8')
    bag_token = getObjectFromGUID('200cdb')

    -- ce bouton va distribuer des jetons devant les joueurs
    button_setup.createButton({
        click_function = "setupPlayers",
        function_owner = Global,
        label          = "Distribuer",
        height          = 500,
        width           = 1000,
        font_size       = 150,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 1},
        rotation        = {0, 180, 0}
    })
    -- ce bouton va piocher une reine
    button_deck.createButton({
        click_function = "pickQueenFromDeck1",
        function_owner = Global,
        label          = "Piocher\nune Reine",
        height          = 500,
        width           = 1000,
        font_size       = 150,
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


end


-- NOUVEAU : on modifie cette fonction pour vérifier d'abord si le deck existe
-- C'est une sécurité courante pour éviter de faire bugger un script
function takeCardFromDeck1()
    -- NOUVELLE CONDITION : "si" le bouton button_setup existe, "alors" on poursuit la fonction, sinon on l'interromp
    -- cela peut porter à confusion. if deck1  revient à écrire if deck1 == true


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
    local cards = deck1.getObjects() -- ceci renvoie une table listant les objets
    -- on va itérer (faire une boucle) sur toutes ces cartes et chercher les reines


        -- on teste à chaque fois si son nom correspond à "reine". On utilise l'attribut name

            -- on reprend le même principe que pour la fonction takeCardFromDeck1()
            -- mais on ajoute le GUID de la carte pour la piocher spécifiquement

            -- Apres avoir pioché une carte, on doit interrompre de la boucle, sinon toutes les reines seront piochées
            -- C'est le rôle de "break"

end