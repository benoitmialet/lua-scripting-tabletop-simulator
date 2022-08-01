----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /01
-- MAJ 27/07/2022
-- Objectifs:
    -- Comprendre la fonction onLoad()
    -- Utilisation des boutons : Créer un bouton, créer une fonction déclenchée par ce bouton
    -- Déplacer un objet avec la fonction setPositionSmooth()
----------------------------------------------------------------------------------------------------

--quelques bonnes habitudes
    --1) rendre le code lisible : bien indenter, revenir à la ligne souvent
    --2) nommer les variables et fonctions en anglais
        -- écrire les fonctions en "CamelCase" : countNumberOfTiles()
        -- écrire les variables en "lower case" : my_variable,  nb_tiles,...
    --3) la page (API) contenant toutes les fonctions et attributs rattachés aux objets
        -- N.B.: vous ne pourrez pas coder sur TTS sans consulter ce site !
        -- https://api.tabletopsimulator.com/object/


-- A VOIR ABSOLUMENT AVANT DE COMMENCER A CODER ! (au moins prendre connaissance):
    -- qu'est ce qu'une variable, une fonction (ou méthode), des parammètres (ou arguments). regarder quelques exemples en LUA.
    -- qu'est ce que le langage orienté objet. Qu'est ce qu'un objet, un attribut ou une fonction de l'objet.
    -- qu'est ce qu'une boucle "for" et est test "if"
    -- qu'est ce qu'une table, un index


--La fonction onLoad() est obligatoire et se déclenche à chaque chargement de partie, ou chaque retour arrière ("annuler")
--Elle contient la déclaration des objets et sert aussi à déclencher toutes les fonctions nécessaires 
--lors du chargement de la partie
function onLoad()
    -- Tout élément physique est un objet qui est identifié par son GUID unique. 
    -- Le GUID est une chaîne de caractère, entre '' ou "" : 'abc124' 
    -- Ici, on déclare tous les objets que l'on va utiliser plus tard dans le code, grâce à leur GUID 
    cube_bleu = getObjectFromGUID('afa021')
    cube_rouge = getObjectFromGUID('939c55')
    -- On créée ici un bouton cliquable, sur un objet. 
    -- Tous les paramètres du bouton sont contenus dans un "array" (ou "tableau", entre {}) et ils sont tous "nommés"
    cube_bleu.createButton({
        click_function = "setup", -- ce paramètre définit la fonction qui va être déclenchée en cliquant sur le bouton
        function_owner = Global, --où se trouve cette fonction (ici, dans l'environnement global, la table de jeu)
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

-- cette fonction sera déclenchée en cliquant sur le bouton donc
function setup()
    -- "local" sert à limiter la portée d'une variable à la fonction (en dehors de setup(), nb_cards n'existera plus)
    local nb_cards = 10
    --écrire du texte dans la console. On peut "concaténer" (assembler) du texte et des variables avec 2 points ".."
    print('Il y a : ' .. nb_cards .. ' cartes.')
    --afficher un message à tous les joueurs. 2 paramètres : le texte et la couleur
    broadcastToAll('Bienvenue !', 'Yellow')
    --Pour déplacer un objet, plusieurs méthodes possibles :
        -- un déplacement animé, on donne la position d'arrivée :
    cube_rouge.setPositionSmooth({0, 3, 0})
        -- une "téléportation" (instantanée) :
    -- cube2.setPosition({0, 3, 0})
        -- on décale l'objet suivant un vecteur (ici de 2 unités vers la droite et d'1 en hauteur), peu utilisé :
    -- cube_rouge.translate({2, 1, 0})
end

-- ASTUCE : "commenter" du code sera très utile pour le désactiver, ou écrire des commentaires.
-- un commentaire commence par --
-- pour désactiver une ou plusieurs lignes à la fois sous VSCode, surlignez les lignes, puis CTRL + /