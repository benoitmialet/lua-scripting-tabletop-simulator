
----------------------------------------------------------------------------------------------------
-- SCRIPTER POUR TABLETOP SIMULATOR /7 - Application
-- MAJ 08/12/2022
-- Objectifs:
    -- Créer un menu avec des options sélectionnables sur des boutons
----------------------------------------------------------------------------------------------------

-- Ici nous allons voir deux types de menus avec boutons de sélection
-- a) un menu détaillant chaque option sur un bouton différent. On clique sur le bouton de l'option choisie.
-- b) un menu avec un seul bouton par option. On clique sur 2 boutons à droite et à gauche pour changer l'option.
-- chacun a ses avantages et inconvénients. 
    -- Le a) permet de tout afficher, il est plus long mais plus facile à coder
    -- Le b) permet un affichage plus réduit, il prend moins de lignes mais légèrement plus complexe à coder.


-- On choisit une option par défaut pour chaque menu, afin d'initialiser les boutons au chargement de la partie.
selected_scenario = 1

function onLoad()
    --ATTENTION ! les GUID des 2 boutons n'existent pas dans la sauvegarde, 
    -- utilisez des jetons sortits des acs iinfinis bleus, par exemple 
    button_setup_a = getObjectFromGUID('d852b0')
    button_setup_b = getObjectFromGUID('22da6b')
    activateButtons_a()
    activateButtons_b()
end

------------------------------------------------------------------------------------------
--a) Menu avec 1 bouton pour chaque option
------------------------------------------------------------------------------------------

-- On commence par définir deux couleurs pour les boutons selon qu'il soit sléectionné ou pas
selected_color = {102/255, 205/255, 170/255, 1}
inactive_color = {241/255, 244/255, 252/255, 1}


function activateButtons_a()
    button_setup_a.createButton({ -- 0
        click_function  = "setScenario1",
        function_owner  = Global,
        label           = "Scénario 1",
        width           = 3600,
        height          = 600,
        font_size       = 300,
        color           = selected_color,
        position        = {-4, 0.5, -1},
    })
    button_setup_a.createButton({ -- 1
        click_function  = "setScenario2",
        function_owner  = Global,
        label           = "Scénario 2",
        width           = 3600,
        height          = 600,
        font_size       = 300,
        color           = inactive_color,
        position        = {4, 0.5, -1},
    })
    button_setup_a.createButton({ -- 2
        click_function  = "setScenario3",
        function_owner  = Global,
        label           = "Scénario 3",
        width           = 3600,
        height          = 600,
        font_size       = 300,
        color           = inactive_color,
        position        = {-4, 0.5,0.5},
    })
    button_setup_a.createButton({ -- 3
        click_function  = "setScenario4",
        function_owner  = Global,
        label           = "Scénario 4",
        width           = 3600,
        height          = 600,
        font_size       = 300,
        color           = inactive_color,
        position        = {4, 0.5, 0.5},
    })
    button_setup_a.createButton({ -- 4
        click_function  = "setScenario5",
        function_owner  = Global,
        label           = "Scénario 5",
        width           = 3600,
        height          = 600,
        font_size       = 300,
        color           = inactive_color,
        position        = {-4, 0.5,2},
    })
    button_setup_a.createButton({ -- 5
        click_function  = "setScenario6",
        function_owner  = Global,
        label           = "Scénario 6",
        width           = 3600,
        height          = 600,
        font_size       = 300,
        color           = inactive_color,
        position        = {4, 0.5, 2},
    })
    button_setup_a.createButton({ -- 6
        click_function  = "setup",
        function_owner  = Global,
        label           = "Démarrer",
        width           = 2000,
        height          = 800,
        font_size       = 300,
        color           = inactive_color,
        position        = {0, 0.5, 4},
    })
end

function setScenario1()    setScenario(1) end
function setScenario2()    setScenario(2) end
function setScenario3()    setScenario(3) end
function setScenario4()    setScenario(4) end
function setScenario5()    setScenario(5) end
function setScenario6()    setScenario(6) end

-- cette fonction simple met à jour le numéro du scénario choisi en Global, puis colorie les boutons
-- on vérifie pour chaque bouton s'il correspond au scénario choisi. Si oui il prend la couleur selected_color
-- attention : souvenez-vous que l'index des boutons commence à 0, il faut donc prendre i-1 
function setScenario(scenario)
    selected_scenario = scenario
    for i=1, 6 do
        local bgcolor = inactive_color
        if i == scenario then bgcolor = selected_color end
        button_setup_a.editButton({
            index = i-1,
            color = bgcolor,
        })
    end
end

function setup()
    -- mise en place du jeu
end



------------------------------------------------------------------------------------------
--a) Menu avec 1 seul bouton et des flèches de sélection droite et gauche
------------------------------------------------------------------------------------------

function activateButtons_b()
    button_setup_b.createButton({ -- 0
        click_function  = "doNothing",
        function_owner  = Global,
        label           = "Scénario 1",
        width           = 3600,
        height          = 600,
        font_size       = 300,
        color           = {1, 1, 1, 1},
        position        = {0, 0.5, 0},
    })
    button_setup_b.createButton({ -- 1
        click_function  = "scenarioLeft",
        function_owner  = Global,
        label           = "<",
        width           = 500,
        height          = 600,
        font_size       = 600,
        color           = {1, 1, 1, 1},
        position        = {-4.7, 0.5, 0},
    })
    button_setup_b.createButton({ -- 2
        click_function  = "scenarioRight",
        function_owner  = Global,
        label           = ">",
        width           = 500,
        height          = 600,
        font_size       = 600,
        color           = {1, 1, 1, 1},
        position        = {4.7, 0.5, 0},
    })
    button_setup_b.createButton({ -- 6
        click_function  = "setup",
        function_owner  = Global,
        label           = "Démarrer",
        width           = 2000,
        height          = 800,
        font_size       = 300,
        color           = inactive_color,
        position        = {0, 0.5, 2},
    })
end

function doNothing()
end

function scenarioLeft() toggleScenario(-1) end
function scenarioRight() toggleScenario(1) end

-- Cette fonction met à jour le numéro du scénario choisi en Global, puis met à jour le bouton menu
-- toggle signifie basculer, switcher, changer
-- 3 étapes
    -- on définit la table des labels dont l'index correspond au numéro du scénario (ex: [1] pour 'Scénario 1').
    -- on créée une règle logique pour modifier le numéro du scénario en fonction d ella flèche cliquée.
    -- on met à jour l'affichage du bouton.
function toggleScenario(value_change)
    scenario_list = {
        'Scénario 1',
        'Scénario 2',
        'Scénario 3',
        'Scénario 4',
        'Scénario 5',
        'Scénario 6',
    }

    if value_change > 0 and selected_scenario == #scenario_list then
        selected_scenario = 1
    elseif value_change < 0 and selected_scenario == 1 then
        selected_scenario = #scenario_list
    else
        selected_scenario = selected_scenario + value_change
    end

    label = scenario_list[selected_scenario]
    button_setup_b.editButton({index=0, label=label})
  end