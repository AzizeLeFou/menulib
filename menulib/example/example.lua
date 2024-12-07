Citizen.CreateThread(function()
    menulib.createMenu("main", "Club de striptease", "Bienvenue au club de striptease")
    menulib.createSubmenu("submenu", "main", "Sous-menu", "Options supplémentaires")
    menulib.createSubmenu("submenu2", "submenu", "Sous-menu", "Options supplémentaires")
    
    menulib.openMenu("main")
    
    menulib.addButton("Acheter une voiture", {
        description = "Acheter une voiture de luxe",
        condition = function() return IsPedSittingInAnyVehicle(PlayerPedId()) end,
        info = {
            title = "Informations sur le véhicule",
            image = "https://i.ibb.co/ZB0qzKy/Desktop-Screenshot2023-12-11-21-23-05-34.webp",
            items = {
                {left = "Modèle", right = "Supercar XL"},
                {left = "Prix", right = "$500,000"},
                {left = "Vitesse max", right = "320 km/h"},
                {left = "0-100 km/h", right = "3.2 secondes"}
            }
        }
    }, function()
        if IsPedSittingInAnyVehicle(PlayerPedId()) then
            print("Voiture achetée !")
        else
            print("Vous devez être dans un véhicule pour acheter une voiture!")
        end
    end)
    
    menulib.addSeparator("Actions")
    menulib.addLine()
    menulib.addList("Boire", {
        {id = 1, label = "Eau"},
        {id = 2, label = "Coca"},
        {id = 3, label = "Jus d'orange"}
    }, {description = "Choisissez votre boisson"}, function(itemId)
        print("Boisson sélectionnée: " .. itemId)
    end)
    menulib.addCheckbox("Change NUI", true, {description = "Activez ou désactivez cette option"},
        function()
            changeUi("RUI")
        end,
        function()
            changeUi("FUI")
        end
    )

    menulib.addCheckbox("Change NUI", true, {description = "Activez ou désactivez cette option"},
    function()
        changeUi("RUI")
    end,
    function()
        changeUi("FUI")
    end
)
menulib.addCheckbox("Change NUI", true, {description = "Activez ou désactivez cette option"},
function()
    changeUi("RUI")
end,
function()
    changeUi("FUI")
end
)
menulib.addCheckbox("Change NUI", true, {description = "Activez ou désactivez cette option"},
function()
    changeUi("RUI")
end,
function()
    changeUi("FUI")
end
)
menulib.addCheckbox("Change NUI", true, {description = "Activez ou désactivez cette option"},
function()
    changeUi("RUI")
end,
function()
    changeUi("FUI")
end
)
menulib.addCheckbox("Change NUI", true, {description = "Activez ou désactivez cette option"},
function()
    changeUi("RUI")
end,
function()
    changeUi("FUI")
end
)
menulib.addButton("Manger", {description = "Manger un hamburger"}, function()
    print("Manger sélectionné")
end)
menulib.addButton("Manger", {description = "Manger un hamburger"}, function()
    print("Manger sélectionné")
end)
menulib.addButton("Manger", {description = "Manger un hamburger"}, function()
    print("Manger sélectionné")
end)
menulib.addButton("Manger", {description = "Manger un hamburger"}, function()
    print("Manger sélectionné")
end)
menulib.addButton("Manger", {description = "Manger un hamburger"}, function()
    print("Manger sélectionné")
end)
menulib.addButton("Manger", {description = "Manger un hamburger"}, function()
    print("Manger sélectionné")
end)
    menulib.addButton("Ouvrir sous-menu", {description = "Accéder aux options supplémentaires"}, function()
        menulib.openMenu("submenu")
    end)

    menulib.openMenu("submenu")
    menulib.addButton("Option du sous-menu", {description = "Une option dans le sous-menu"}, function()
        print("Option du sous-menu sélectionnée")
    end)
    menulib.addButton("Ouvrir un autre sous-menu", {description = "Accéder aux options supplémentaires"}, function()
        menulib.openMenu("submenu2")
    end)

    menulib.openMenu("submenu2")
    menulib.addButton("submenu2 t'es dedans fdp", {description = "Une option dans le sous-menu"}, function()
        print("Option du sous-menu sélectionnée")
    end)

    RegisterCommand("openmenu", function()
        menulib.openMenu("main")
    end, false)

    RegisterKeyMapping('openmenu', "Menu F5", 'keyboard', 'G')

    RegisterCommand("closemenu", function()
        menulib.closeMenu()
    end, false)
end)

function loadUITheme()
SendNUIMessage({
    eventName = "change_ui",
    metadata = {
        ui = currentUI
    }
})
end