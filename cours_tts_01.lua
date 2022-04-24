----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /01
-- Objectifs:
    -- Comprendre la fonction onLoad()
    -- Utilisation des boutons : Créer un bouton, créer une fonction déclenchée par ce bouton
    -- Déplacer un objet
----------------------------------------------------------------------------------------------------

--quelques bonnes habitudes
    --1) rendre le code lisible : bien indenter, revenir à la ligne souvent
    --2) nommer les variables et fonctions en anglais
        -- écrire les fonctions en "CamelCase" : countNumberOfTiles()
        -- écrire les variables en "lower case" : my_variable,  nb_tiles,...
    --3) la page (API) contenant toutes les fonctions et attributs rattachés aux objets:
        -- https://api.tabletopsimulator.com/object/


--La fonction onLoad() est obligatoire et se déclenche à chaque chargement de partie, ou chaque retour arrière
--Elle contient la définition des objets et sert aussi à déclencher toutes les fonctions nécessaires 
--lors du chargement de la partie
function onLoad()
    --definir des objets avec leur GUID (chaine de caractères), que l'on va utiliser plus tard daans le code
    cube_bleu = getObjectFromGUID('afa021')
    cube_rouge = getObjectFromGUID('939c55')
    --créer un bouton cliquable sur un objet. Tous les paramètres sont contenus dans un "array" (= tableau = {}) et nommés
    cube_bleu.createButton({
        click_function = "setup", -- la fonction qui va être déclenchée en cliquant sur le bouton
        function_owner = Global, --où se trouve cette fonction (ici, dans l'environnement global)
        label          = "Démarrer",
        height          = 200,
        width           = 800,
        font_size       = 120,
        color           = {1, 1, 0.5, 1}, -- premiere façon d'écrire une couleur {r,g,b, opacité}, valeurs de 0 à 1
        -- color           = {163/255, 255/255, 100/255, 1}, la même façon, en utilisant des fractions
        -- color           = 'Red',  deuxième façon, sous forme de chaine de caractères ('Yellow', 'Green', 'Blue'...)
        position        = {0, 1, 0},
        rotation        = {0, 180, 0}
    })
end

function setup()
    -- local sert à limiter la portée d'une variable à la fonction (en dehors de setup, nb_cards n'existe plus)
    local nb_cards = 10
    --écrire du texte dans la console. On peut "concaténer" (assembler) du texte et des variables avec 2 points ..
    print('Il y a : ' .. nb_cards .. ' cartes.')
    --afficher un message à tous. 2 paramètres : le texte et la couleur
    broadcastToAll('Bienvenue !', 'Yellow')
    --déplacer un objet, plusieurs options :
        -- un déplacement animé, on donne la position d'arrivée :
    cube_rouge.setPositionSmooth({0, 3, 0})
        -- une "téléportation" (plus rapide) :
    -- cube2.setPosition({0, 3, 0})
        -- on décale l'objet suivant un vecteur (ici de 2 unités vers la droite et d'1 en hauteur):
    -- cube_rouge.translate({2, 1, 0})

end