----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /12
-- Objectifs:
    -- Utiliser la fonction Physics.cast()
    -- Utiliser les Timers avec la fonction Wait.time()
----------------------------------------------------------------------------------------------------

-- La classe Physics possède une fonction bien utile permettant de détecter des objets où l'on veut : cast.
-- https://api.tabletopsimulator.com/physics
-- Ce cours montre deux exemples de détection d'objets avec Physics.cast sur une tuile.
-- Ces exemples peuvent être copiés dans des objets (des tuiles par exemple) et adapté en plaçant self aux endroits appropriés. 


button_setup_guid = '0926c8'
plateau_guid = '0b45fb'

function onLoad()
    button_setup = getObjectFromGUID(button_setup_guid)
    plateau = getObjectFromGUID(plateau_guid)
    activateButtonMenu()
    launchAutomaticResourceCounting(plateau)
end

function activateButtonMenu()
    button_setup.createButton({
        click_function = "drawCard",
        function_owner = Global,
        label          = "Piocher",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = 'Grey',
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
end


--EXEMPLE 1 : détection simple d'objets
--PHYSICS
    -- La classe physics possède quelques fonction, qui permettent par exemple de modifier la gravité de l'environnement
    -- https://api.tabletopsimulator.com/physics
--PHYSICS.CAST
    -- La fonction la plus utile de la classe Physics est cast().
    -- https://api.tabletopsimulator.com/physics/#cast
    -- Elle permet de créer pour une durée très courte une zone à une position et vers une direction données.
    -- Les informations sur les objets que la zone aura touchée seront renvoyés dans une liste, généralement appelée hitList
    -- C'est le même principe que getObjects(), sauf que cast() renvoie plus que des objets dans cette hitList.
    -- pour atteindre chaque objet, il faudra passer par l'attribut .hit_object de chaque entrée de la hitList.
    -- on peut renommer obj.hit_object en obj, ce qui permet de garder nos mêmes habitudes de traitement pour la suite du code.
function drawCard()
    local hitList = Physics.cast({
        origin = {7.00, 0, 5.00},
        direction = {0, 1, 0},
        type = 3,               --1 = Rayon, 2 = Sphère, 3= Box
        debug = true,           -- true permet d'apercevoir la zone une fraction de seconde
        size = {4,4,4},
        orientation = {0,0,0},
        max_distance = 0        -- si >0, la zone se déplace dans l'espace, dans sa direction
    })
    for _, obj in ipairs(hitList) do
        local obj = obj.hit_object
        if obj.type == 'Deck' then
            obj.takeObject({
                position = obj.getPosition() + Vector ({4, 1, 0}),
                rotation = {0, 180, 0}
            })
        end
    end
end


-- EXEMPLE 2 : Tuile de comptage de ressource
    -- On la construit en 2 étapes
        -- 1) activation de l'affichage du bouton de comptage de ressources
        -- 2) mise a jour régulière de l'affichage du bouton
    -- attention. Comme indiqué sur l'API, lancer de trop nombreuses fonctions cast en parallèle peut ralentir TTS
-- WAIT
    -- nous avons déja vu cette fonction au cours 06
    -- nous l'utilisons ici avec un 3e paramètre facultatif : le nombre de répétitions
    -- on peut inais créer des fonctions qui s'exécutent plusieurs fois et même indéfiniment 
function launchAutomaticResourceCounting(tile)
    activateCount(tile)
    Wait.time(
        function ()             -- la fonction à exécuter
            updateResources(tile)
        end,
        0.4,                    -- délais (secondes) entre les répétitions
        -1                      -- nombre de répétitions (-1 = infini)
    )
end

function activateCount(tile)
    tile.createButton({
        click_function = 'doNothing',
        function_owner = Global,
        label = 'Monnaie : '..'0',
        font_size = 180,
        scale = {0.3, 0.3, 0.3},
        font_color = {1,1,1},
        height = 0,
        width = 0,
        position = {0, 1, 0.3},
        rotation = {0, 180, 0}
    })
end

function doNothing()
end

function updateResources(tile)
    local nb_resource = countResource('monnaie', tile)
    tile.editButton({
        index = 0,
        label = 'Monnaie : '..nb_resource
    })
end

function countResource(resource_tag, tile)
    local hitList = Physics.cast({
        origin = tile.getPosition(),
        direction = {0, 1, 0},
        type = 3,
        debug = true,
        size = tile.getBounds().size + Vector({0, 2, 0}),
        orientation = tile.getRotation(),
        max_distance = 0,
    })
    local nb_ressource = 0
    for index, obj in ipairs(hitList) do
        local obj = obj.hit_object
        if obj.hasTag(resource_tag) then
            nb_ressource = nb_ressource + 1
        end
    end
    return nb_ressource
end