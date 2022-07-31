----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /09
-- MAJ 30/07/2022
-- Objectifs:
    -- Créér un système de comptage de ressources
    -- Générer des objets (zone)
    -- Utiliser des fonctions d'évenement
----------------------------------------------------------------------------------------------------

-- On peut imaginer une infinité de méthodes pour créer un système de comptage de ressources.
-- Le système que l'on va utiliser consiste à créer une zone, surveiller les ressources
-- qui entrent ou qui sortent de cette zone, puis afficher les compteurs sur un bouton.
-- On va devoir pour cela :
    -- créer des boutons sur la tuile de comptage pour afficher la quantité de ressources 
    -- Générer une zone au dessus de la tuile de comptage pour détecter les ressources
    -- Utiliser des fonctions d'évenement (entrée / sortie des ressources dans la zone) pour augmenter
    -- ou diminuer le compteur de ressources
    -- mettre à jour les boutons d'affichage


counting_tile_guid = 'cf92d0' -- (notre tuile de comptage sera par exemple le plateau du joueur vert)

function onLoad()
-------------------------------------------------------------------------------------------------
-- TUILE DE COMPTAGE : PARAMETRES ( A INSERER DANS ONLOAD)
-------------------------------------------------------------------------------------------------
    counting_tile_object = getObjectFromGUID(counting_tile_guid)
    name_resource1 = 'monnaie1'    color_resource1 = 'Red'
    name_resource2 = 'monnaie2'    color_resource2 = 'Blue'
    activateCountingTile()
-------------------------------------------------------------------------------
end

-------------------------------------------------------------------------------------------------
-- TUILE DE COMPTAGE : FONCTIONS 
-------------------------------------------------------------------------------------------------
-- cette fonction initialise les boutons et la zone de comptage
function activateCountingTile()
    -- Ces boutons servent simplement à afficher le nombre de ressources (1 affichage par ressource)
    -- on pourrait créer une boucle pour initialiser ces boutons, mais le but ici est de faire simple,
    -- pour comprendre le principe général. Une boucle sera conseillé si le nombre de ressources est important.
    counting_tile_object.createButton({
        click_function='doNothing',
        function_owner=Global,
        label = name_resource1..' : '..'0',
        font_color = color_resource1,
        position = {0,0.5,0.4},
        rotation = {0,180,0},
        height=0,
        width=0,
        font_size = 50
    })
    counting_tile_object.createButton({
        click_function='doNothing',
        function_owner=Global,
        label = name_resource2..' : '..'0',
        font_color = color_resource2,
        position={0,0.5,0.2},
        rotation = {0,180,0},
        height=0, width=0,
        font_size = 50
    })

    --NOUVEAU : on va générer un objet de type zone de script au dessus de la tuile (et de même dimension sauf en hauteur)
    zone_capture = spawnObject({
        type              = "ScriptingTrigger", -- zone de script
        position          = counting_tile_object.getPosition() + Vector({0, 1, 0}),
        rotation          = counting_tile_object.getRotation(),
        scale             = counting_tile_object.getScale() + Vector({0, 3, 0}),
    })
    -- NB : spawnObject() permet de générer tout type d'objet, built-in ou custom,et même de leur donner des attributs
    -- https://api.tabletopsimulator.com/built-in-object/ 
end

function doNothing()
end

-- NOUVEAU : Les fonctions evenements se déclenchent sur un évenement (clic souris, collision entre deux objets, etc.)
-- Il en existe une grande quantité : https://api.tabletopsimulator.com/events/
-- onObjectEnterScriptingZone() se déclenchera à l'entrée de tout objet dans la zone en question.
function onObjectEnterScriptingZone(zone, enter_object)
    -- on ne s'intresse qu'à la zone de capture et non à toutes les zones de script
    if zone.guid == zone_capture.guid then
        -- NOUVEAU : ici on utilise les GMNotes des objets plutot que le nom. Les GMNotes sont un nom "caché" 
        -- que l'on peut donner à un objet uniquement en étant le joueur GM (noir) et en faisant clic droit sur l'objet.
        -- Cela permet de nommer discrètement des objets pour le script.
        local name = enter_object.getGMNotes()
        if name == name_resource1 or name == name_resource2 then
            CountResources(name)
        end
    end
end

-- on doit également prévoir la fonction équivalente quand l'objet quitte la zone
function onObjectLeaveScriptingZone(zone, enter_object)
    if zone.guid == zone_capture.guid then
        local name = enter_object.getGMNotes()
        if name == name_resource1 or name == name_resource2 then
            CountResources(name)
        end
    end
end

-- fonction de mise à jour des compteurs pour toutes les ressources.
function CountResources(name)
    local zoneObjects = zone_capture.getObjects()
    local resource1 = 0
    local resource2 = 0
    for i, object in ipairs(zoneObjects) do
        if object.getGMNotes() == name_resource1 then
            resource1 = resource1 + 1
        elseif object.getGMNotes() == name_resource2 then
            resource2 = resource2 + 1
        end
    end
    counting_tile_object.editButton({ index = 0, label = name_resource1..' : '..resource1 })
    counting_tile_object.editButton({ index = 1, label = name_resource2..' : '..resource2 })
end
-------------------------------------------------------------------------------------------------

-- NB : Scripter un objet
-- tout le code de cette page devrait plutôt être inséré dans un objet, et non dans l'environnement global
-- L'avantage de cette pratique et que l'objet pourra être exporté dans n'importe quel module et fonctionnera parfaitement
-- Pour réaliser cela :
    -- clic droit sur la tuile de comptage, ouvrir la fenêtre de script, copier le script
    -- remplacer    function_owner=Global    par     function_owner=self
    -- cela précise à quel objet la fonction est rattachée (ici la tuile de comptage)