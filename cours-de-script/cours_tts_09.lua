----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /09
-- MAJ 15/10/2022
-- Objectifs:
    -- Utiliser les tags
----------------------------------------------------------------------------------------------------

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

function getScore()
    local nb_figures, score = getScoreInZone(zone_game)
    print("Figures :",nb_figures, "\nScore : ",score)
    -- exemple d'utilisation de splitText : 
    -- table_text = splitText("roi_10", "_")
    -- log(table_text)
end

-- CALCUL DE SCORE
function getScoreInZone(zone)
    local nb_figures = 0
    local score = 0
    local objects = zone.getObjects()
    for _, obj in ipairs(objects) do
        if obj.type == "Deck" or obj.type == "Bag" or obj.type == "Infinite" then
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