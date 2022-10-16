----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /10
-- MAJ 16/10/2022
-- Objectifs:
    -- Comprendre comment scripter dans des objets
----------------------------------------------------------------------------------------------------


-- Placer votre code dans la fenêtre Global ou bien dans des objets ? Là est la question... 
    -- Scripter dans Global permet d'atteindre toute votre table facilement.
    -- Scripter dans un objet permet d'automatiser un objet et de le rendre transportable facilement d'un module à un autre.
    -- Scripter dans un objet demande un peu plus de concentration et de manipulation pour atteindre le reste
        -- du code (situé dans Global ou dans d'autres objets).

--Un aperçu subjectif des POUR et des CONTRE :
-- scripter dans Global :
    --GROS POUR   : tout le code est dans une même fenêtre, un ctr+F permet de retrouver son code facilement
    --CONTRE      : tout le code est dans une même fenêtre, cela fait beaucoup de code et encombre la page
-- scripter dans ds objets :
    --GROS POUR   : permet de créer des objets automatisés et de les utiliser dans vos modules sans intervenir.  
    --POUR        : permet d'alléger la fenetre Global en répartissant votre code.
    --GROS CONTRE : L'utilisation est fastidieuse :
        -- Il faut ouvrir/fermer chaque fenetre de code de chaque objet.
        -- Pour faire appel à une fonction ou des variables, il faut utilser des call et savoir parfaitement où se trouve chaque bloc de code
        -- Vos fonctions appelées dans des objets depuis Global DOIVENT UNIQUEMENT recevoir une table comme paramètre
        -- le code est dispersé dans vos objets. Si vous perdez de vue une fonction ou des variables, bon courage !
            --(heureusement, VSCode regroupe toutes les pages de code dans votre workspace)

-- Les fontions qui permettent de communiquer entre les objets et Globa : https://api.tabletopsimulator.com/object/#global-function


button_setup_guid = '0926c8'
zone_deck_guid = 'ae31a0'
zone_game_guid = 'acc4c5'
cube_fonctions_guid = '939c55'
rectangle_bleu_guid = 'afa021'

function onLoad()

    -- déclaration des objets
    zone_deck = getObjectFromGUID(zone_deck_guid)
    zone_game = getObjectFromGUID(zone_game_guid)
    button_setup = getObjectFromGUID(button_setup_guid)
    cube_fonctions = getObjectFromGUID(cube_fonctions_guid)
    rectangle_bleu = getObjectFromGUID(rectangle_bleu_guid)

    activateButtonMenu()

end

--activation du bouton de mise en place
function activateButtonMenu()
    button_setup.createButton({ --1
        click_function = "doIt",
        function_owner = Global,
        label          = "Piocher\n10",
        width           = 2000,
        height          = 1000,
        font_size       = 400,
        color			= {1, 1, 1, 1},
        position        = {0, 1, 0},
        rotation        = {0,180,0}
    })
end

function doIt()
    -- takeObjectsFromZone(zone_deck, 10, {-4.00, 2, 5.00}, {0,180,0})
    -- cube_fonctions.call("test")
    zone_game.call("listObjects")
    -- local params = {
    --     guid = 'ae31a0',
    --     nb_to_take = 10,
    --     position = {-4.00, 2, 5.00},
    --     rotation = {0,180,0}
    -- }
    -- cube_fonctions.call("takeObjectsFromZone", params)
    -- totalVeget()
end

function totalVeget()
    local total_poireaux = 0
    local total_champignons = 0
    local total_potimarrons = 0
    local total_carottes = 0

    local objects = zone_game.getObjects()
    for _, obj in ipairs(objects) do
        -- total_poireaux = total_poireaux + (obj.getVar("poireaux") or 0)
        -- total_champignons = total_champignons + (obj.getVar("champignons") or 0)
        -- total_potimarrons = total_potimarrons + (obj.getVar("potimarrons") or  0)
        -- total_carottes = total_carottes + (obj.getVar("carottes") or  0)
        local legumes = obj.getTable("legumes")
        total_poireaux = total_poireaux + (legumes.poireaux or 0)
        total_champignons = total_champignons + (legumes.champignons or 0)
        total_potimarrons = total_potimarrons + (legumes.potimarrons or 0)
        total_carottes = total_carottes + (legumes.carottes or 0)
    end
    print(
        "\ntotal_poireaux : ", total_poireaux,
        "\ntotal_champignons : ", total_champignons,
        "\ntotal_potimarrons : ", total_potimarrons,
        "\ntotal_carottes : ", total_carottes
    )
end


-----------------------------------------------------------------------------------------

-- Une fonction générique pour piocher un nombre d'objets voulu dans une zone 
    -- Le premier conteneur (deck, bag, infinite bag) trouvé dans la zone servira de pioche
    -- Sinon la fonction piochera les premiers objets non lockés trouvés dans la zone.   
-- Arguments:
    -- zone: objet zone dans laquelle se trouve le conteneur ou la carte à piocher
    -- nb_to_take: nombre d'objets à piocher dans le container
    -- position: {0,0,0}. position de la destination
    -- Rotation: {0,0,0} (optionnel) rotation de la destination
-- retourne une table contenant la liste des objets piochés
function takeObjectsFromZone(zone, nb_to_take, position, rotation)
    -- local zone = table.zone
    -- local nb_to_take = table.nb_to_take
    -- local position = table.position
    -- local rotation = table.rotation
    local objects = zone.getObjects()
    local container = nil
    local table_obj_dealt = {}
    local nb_left
    local function moveObj(obj_dealt, i)
        local jump = Vector({0, obj_dealt.getBoundsNormalized().size.y, 0}) * (i+1) -- jump between objects
        obj_dealt.setPositionSmooth(Vector(position) + jump)
        obj_dealt.setRotationSmooth(Vector(rotation))
        table.insert(table_obj_dealt, obj_dealt)
    end
    for _, obj in ipairs(objects) do
        if obj.type == 'Infinite' or obj.type == 'Bag' or obj.type == 'Deck' then
            container = obj
            break
        end
    end
    if container ~= nil then
        container.shuffle()
        local rotation = rotation or container.getRotation()
        nb_left = container.getQuantity()
        if  container.type == 'Infinite' then nb_left = nb_to_take end
        for i = 1, math.min(nb_left, nb_to_take)     do
            local obj_dealt = container.takeObject()
            moveObj(obj_dealt, i)
        end
    else
        nb_left = 0
        local i = 1
        for _, obj in ipairs(objects) do
            if nb_to_take > 0 then
                if obj.getLock() == false then
                    local rotation = rotation or obj.getRotation()
                    local obj_dealt = obj
                    moveObj(obj_dealt, i)
                    nb_to_take = nb_to_take - 1
                    i = i + 1
                end
            else
                break
            end
        end

    end
    local nb_missing = nb_to_take - nb_left
    if nb_missing > 0 then
        broadcastToAll(nb_missing.." objects missing")
    end
    return table_obj_dealt
end