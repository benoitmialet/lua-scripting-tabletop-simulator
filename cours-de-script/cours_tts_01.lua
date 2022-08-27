----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /01
-- MAJ 07/08/2022
-- Objectifs:
    -- Comprendre la fonction onLoad()
    -- Utilisation des boutons : Créer un bouton, créer une fonction déclenchée par ce bouton
    -- Déplacer un objet avec la fonction setPositionSmooth()
----------------------------------------------------------------------------------------------------

--quelques bonnes habitudes
    --1) rendre le code lisible : bien indenter, revenir à la ligne souvent
    --2) nommer les variables et fonctions en anglais
        -- écrire les fonctions en "camelCase" : countNumberOfTiles()
        -- écrire les variables en "lower case" : my_variable,  nb_tiles,...
    --3) la page (API) contenant toutes les fonctions et attributs rattachés aux objets
        -- BIEN NOTER : VOUS NE POURREZ PAS CODER SUR TTS SANS CONSULTER CE SITE !
        -- https://api.tabletopsimulator.com/object/


-- NOTIONS A VOIR ABSOLUMENT AVANT DE COMMENCER A CODER ! (au moins en prendre connaissance):
    -- qu'est ce qu'une variable, une fonction (ou méthode), des arguments (ou paramètres). 
        -- regarder quelques exemples en LUA.
    -- qu'est ce que le langage orienté objet. Qu'est ce qu'un objet, un attribut ou une fonction de l'objet.
    -- qu'est ce qu'une boucle "for" et un test "if"
    -- qu'est ce qu'une table, un index


-- La fonction ONLOAD :
    -- La fonction onLoad() est obligatoire et se déclenche à chaque chargement de partie, ou chaque retour arrière ("annuler")
    -- Elle contient la déclaration des objets et sert aussi à déclencher toutes les fonctions nécessaires 
    -- lors du chargement de la partie
-- Le GUID : 
    -- Tout élément physique est un objet qui est identifié par son GUID unique. 
    -- Le GUID est une chaîne de caractère, entre '' ou "" : 'abc124' 
    -- Dans onLoad, on déclare tous les objets que l'on va utiliser plus tard dans le code, grâce à leur GUID
-- ici on déplace la création de bouton setup dans une fonction à part (on verra dans le cours 06 pourquoi)
function onLoad()
    cube_bleu = getObjectFromGUID('afa021')
    cube_rouge = getObjectFromGUID('939c55')
    activateButtonMenu()
end


-- Les BOUTONS :
    -- les boutons servent à activer des fonctions avec un clic souris.
    -- Ils sont en général sous la forme de carré blanc ou coloré, placé sur un objet.
    -- Tous les paramètres du bouton sont contenus dans une "table" (entre {}) et ils sont tous "nommés"
    -- On créée ici un bouton cliquable sur un objet, pour qu'il appatraisse au chargement.
    -- En génnéral, on cache l'objet qui porte le bouton sous la surface de la table et on le lock.
function activateButtonMenu()
    cube_rouge.createButton({
        click_function = "moveCube", -- ce paramètre définit la fonction qui va être déclenchée en cliquant sur le bouton
        function_owner = Global, --où se trouve cette fonction (ici, dans l'environnement global, la table de jeu)
        label          = "Démarrer",
        height          = 500,
        width           = 600,
        font_size       = 130,
        color           = {0.5, 1, 0.5, 1}, -- premiere façon d'écrire une couleur {r,g,b, opacité}, valeurs de 0 à 1
        -- color           = {163/255, 255/255, 100/255, 1},-- la même façon, en utilisant des fractions
        -- color           = 'Green', -- deuxième façon, sous forme de chaine de caractères ('Yellow', 'Red', 'Blue'...)
        position        = {0, 0.5, 0},
        rotation        = {0, 0, 0},
        size = {1,1,1}
    })
end


-- La fonction moveCube sera donc déclenchée en cliquant sur le bouton. 
    -- Elle déplace simplement le cube bleu et affiche un message 
-- LOCAL / GLOBAL = portée des variables
    -- la portée d'une variable définit où elle peut être appelée dans le code.
    -- par défaut toute variable est "globale" : on peut l'appeler dans tout le code une fois déclarée
    -- préciser "local" avant de la déclarer sert à limiter la portée d'une variable à la fonction ou à la  
    -- boucle dans laquelle elle est déclarée (ici, en dehors de setup(), nb_cards n'existera plus)
    -- Gérer la portée d'une variable est une habitude à prendre pour éviter les conflits de noms. 
-- La fonction PRINT :
    -- print() est une fonction capitale, et sert à écrire dans la console de chat.
    -- On s'en servira surtout pour débuguer le code.
-- CONCATENER du texte : 
    -- On peut "concaténer" (assembler) du texte et des variables (qui ne sont pas du texte) avec 2 points ".."
-- La fonction BROADCASTTOALL : 
    -- broadcastToAll() afficher un message à tous les joueurs. 2 paramètres : le texte et la couleur
-- DEPLACER UN OBJET :
    --Pour déplacer un objet, plusieurs méthodes possibles (ici commentés dans le code):
        -- setPositionSmooth() est un déplacement animé, on donne la position d'arrivée.
        -- l'associer à SetRotationSmooth() pour gérer l'orientation de l'objet
        -- setPosition() est la même chose mais instantanée.
        -- on en verra d'autres plus tard, ces deux sont largement suffisantes.
function moveCube()
    local nb_cubes = 2
    print('Il y a : ' .. nb_cubes .. ' cubes sur la table.')
    broadcastToAll('Bienvenue !', 'Yellow')
    cube_bleu.setPositionSmooth({0, 3, 0})
    cube_bleu.setRotationSmooth({0, 180, 0})
    -- cube_bleu.setPosition({0, 3, 0})
    -- cube_bleu.setRotation({0, 180, 0})
end

-- COMMENTER DU CODE :
    -- "commenter" du code sera très utile pour le désactiver, ou écrire des commentaires.
    -- un commentaire commence par --
    -- pour désactiver une ou plusieurs lignes à la fois sous VSCode, surlignez les lignes, puis CTRL + /