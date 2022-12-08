----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /09
-- MAJ 15/10/2022
-- Objectifs:
    -- Utiliser les tags
----------------------------------------------------------------------------------------------------

-- Les tags sont un attribut plus complet que les autres (name, GM_notes, description, ...) car
-- ils permettent plus de possibilités et de flexibilité avec vos scripts.
-- Cependant, il faudra bien sûr tagguer ses objets au préalablle sur votre module.
-- Tout comme pour les autres attributs, on n'accède pas de la même façon aux tags des objets situés
-- dans l'environnement global ("extérieurs") qu'aux tags des objets contenus dans des conteneurs:
    -- depuis l'environnement global : https://api.tabletopsimulator.com/object/#tag-functions
    -- depuis un conteneur : https://api.tabletopsimulator.com/object/#tag-functions
-- Ce cours prend comme exemple un calculateur de score mais les tags s'utilsent pour tout.
--


-- un dictionnaire permettant de convertir des tags en chiffres (score)
tag_to_points = {
    ["as"]      = 1,
    ["deux"]    = 2,
    ["trois"]   = 3,
    ["quatre"]  = 4,
    ["cinq"]    = 5,
    ["six"]     = 6,
    ["sept"]    = 7,
    ["huit"]    = 8,
    ["neuf"]    = 9,
    ["dix"]     = 10,
    ["valet"]   = 20,
    ["reine"]    = 30,
    ["roi"]     = 40
}

button_setup_guid = '0926c8'
zone_game_guid = 'acc4c5'

function onLoad()
    button_setup = getObjectFromGUID(button_setup_guid)
    zone_game = getObjectFromGUID(zone_game_guid)
    activateButtonMenu()
end

function activateButtonMenu()
    button_setup.createButton({
        click_function = "getScore",
        function_owner = Global,
        label          = "Compter les\npoints",
        height          = 1000,
        width           = 2000,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.3, 0},
        rotation        = {0, 180, 0}
    })
end

-- une fonction intermédiaire pour appeler la fonction getScoreInZone
function getScore()
    local nb_figures, score = getScoreInZone(zone_game)
    print("Figures :",nb_figures, "\nScore : ",score)
    -- exemple d'utilisation de splitText (voir fin du cours): 
    -- table_text = splitText("roi_10", "_")
    -- log(table_text)
end


-- CALCUL DE SCORE
    -- getScoreInZone calcule le score dans une zone ainsi que le nombre de figures (roi, valet...)
    -- on parcourt les objets, puis pour chaque objet :
        -- on vérifie s'il possède un tag de figure
        -- on parcourt les tags à la recherche de tags de score (cf le dictionnaire en début de cours)
-- HASTAG
    -- vérifie la présence d'un tag parmi les tags de l'objet. C'st l'équivalent de == name
-- GETTAGS
    -- renvoie tous les tags de l'objet sous forme de table
-- RETOURNER PLUSIEURS VALEURS AVEC RETURN
    -- il est possible de le faire !
function getScoreInZone(zone)
    local nb_figures = 0
    local score = 0
    local objects = zone.getObjects()
    for _, obj in ipairs(objects) do
        if obj.type == "Deck" or obj.type == "Bag" then
            local nb_figures_cont, score_cont = getScoreInContainer(obj)
            nb_figures = nb_figures + nb_figures_cont
            score = score + score_cont
        else
            --objet extérieur
            -- incrémentation du nombre de figures
            if obj.hasTag("valet") or obj.hasTag("reine") or obj.hasTag("roi") then
                nb_figures = nb_figures + 1
            end
            -- incrémentation du score
            local obj_tags = obj.getTags()
            for _, tag in ipairs(obj_tags) do
                if hasIndex(tag_to_points, tag) then
                    score = score + tag_to_points[tag]
                end
            end
        end
    end
    return nb_figures, score
end

-- getScoreInContainer calcule le score des objets contenus dans un conteneur (deck, sac)
-- ATTENTION, ici on ne peut que récupérer tous les tags d'un objet avec l'attribut .TAGS
function getScoreInContainer(container)
    local nb_figures = 0
    local score = 0
    local objects = container.getObjects()
    for _, obj in ipairs(objects) do
        --objet dans un conteneur
        -- incrémentation du nombre de figures
        if hasValue(obj.tags, "valet") or hasValue(obj.tags, "reine") or hasValue(obj.tags, "roi") then
            nb_figures = nb_figures + 1
        end
        -- incrémentation du score
        local obj_tags = obj.tags
        for _, tag in ipairs(obj_tags) do
            if hasIndex(tag_to_points, tag) then
                score = score + tag_to_points[tag]
            end
        end
    end
    return nb_figures, score
end



-- -- (voir cours_tts_05.lua)
function hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end
    return false
end

-- Une fonction pour tester si une table contient un index 
-- Fonctionne avec les index numériques ou alphabétiques grace à pairs()
function hasIndex (tab, val)
    for index, value in pairs(tab) do
        if index == val then
            return index
        end
    end
    return false
end


--[Auteur ?] Une fonction qui sépare une chaine de caractère en plusieurs lots.
    -- paramètres
        -- input_string: chaine de caractère
        -- separator : élément séparateur de chaînes (chaîne de caractère)
    -- retourne une table de chaines de caractères séparées {chaîne1, chaîne2, etc.}
    -- pratique pour "insérer" des chiffres dans vos tags
    -- vous trouverez un exemple d'utilisation dans la fonction getScore
function splitText (input_string, separator)
    if separator == nil then
        separator = "%s"
    end
    local t={}
    for str in string.gmatch(input_string, "([^"..separator.."]+)") do
        table.insert(t, str)
    end
    return t
end