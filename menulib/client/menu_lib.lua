local menulib = {}
local currentMenu = nil
local menus = {}
local isMenuOpen = false
local currentUI = GetResourceKvpString("menu_ui_theme") or "FUI"

function menulib.createMenu(id, title, subtitle, options)
    local menu = {
        id = id,
        title = title,
        subtitle = subtitle,
        options = options or {},
        items = {},
        parent = nil
    }
    menus[id] = menu
    return menu
end

function menulib.createSubmenu(id, parent, title, subtitle, options)
    local submenu = menulib.createMenu(id, title, subtitle, options)
    submenu.parent = parent
    return submenu
end

function menulib.addSeparator(label)
    table.insert(currentMenu.items, {id = #currentMenu.items + 1, type = "separator", label = label})
end

function menulib.addLine()
    table.insert(currentMenu.items, {id = #currentMenu.items + 1, type = "line"})
end

function menulib.addButton(label, options, action)
    local button = {
        id = #currentMenu.items + 1,
        type = "button",
        label = label,
        description = options.description,
        info = options.info,
        onSelected = action,
        condition = options.condition
    }
    
    table.insert(currentMenu.items, button)
    updateButtonDisplay(button)
end

function menulib.addList(label, list, options, action)
    table.insert(currentMenu.items, {
        id = #currentMenu.items + 1,
        type = "list",
        label = label,
        list = list,
        description = options.description,
        onSelected = action,
        currentSelect = 1
    })
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if currentMenu then
            for _, item in ipairs(currentMenu.items) do
                if item.type == "button" and item.condition then
                    updateButtonDisplay(item)
                end
            end
        end
    end
end)

function updateButtonDisplay(button)
    if not button.condition then return end

    local conditionMet = button.condition()
    local rightLabel = ""
    if not conditionMet then
        rightLabel = [[<svg width="16" height="16" viewBox="0 0 558 800" fill="none" xmlns="http://www.w3.org/2000/svg" transform="translate(-8, 0)">
            <path d="M36.5758 800H521.424C541.507 800 557.788 783.719 557.788 763.636V351.515C557.788 331.433 541.507 315.152 521.424 315.152H485.061V206.061C485.061 92.4388 392.622 0 279 0C165.378 0 72.9394 92.4388 72.9394 206.061V315.152H36.5758C16.4934 315.152 0.212158 331.433 0.212158 351.515V763.636C0.212158 783.719 16.4934 800 36.5758 800ZM315.364 569.663V618.182C315.364 638.264 299.082 654.545 279 654.545C258.918 654.545 242.636 638.264 242.636 618.182V569.663C227.926 558.596 218.394 540.999 218.394 521.212C218.394 487.794 245.582 460.606 279 460.606C312.418 460.606 339.606 487.794 339.606 521.212C339.606 540.999 330.074 558.596 315.364 569.663ZM145.667 206.061C145.667 132.541 205.48 72.7273 279 72.7273C352.52 72.7273 412.333 132.541 412.333 206.061V315.152H145.667V206.061Z" fill="currentColor"/>
        </svg>]]
    end
    
    SendNUIMessage({
        eventName = "update_button",
        metadata = {
            id = button.id,
            label = button.label,
            rightLabel = rightLabel
        }
    })
end

function menulib.addCheckbox(label, checked, options, onChecked, onUnchecked)
    table.insert(currentMenu.items, {
        id = #currentMenu.items + 1,
        type = "checkbox",
        label = label,
        checked = checked,
        description = options.description,
        onChecked = onChecked,
        onUnchecked = onUnchecked
    })
end

function menulib.openMenu(id)
    if menus[id] then
        currentMenu = menus[id]
        local itemsToSend = {}
        for i, item in ipairs(currentMenu.items) do
            local itemToSend = {
                id = item.id,
                type = item.type,
                label = item.label,
                rightLabel = item.rightLabel,
                description = item.description,
                list = item.list,
                checked = item.checked,
                info = item.info
            }
            table.insert(itemsToSend, itemToSend)
        end
        SendNUIMessage({
            eventName = "open_menu",
            metadata = {
                id = currentMenu.id,
                title = currentMenu.title,
                subtitle = currentMenu.subtitle,
                items = itemsToSend
            }
        })
        loadUITheme()
        SetNuiFocus(true, false)
        SetNuiFocusKeepInput(true)
        isMenuOpen = true
    else
        print("Le menu n'existe pas: " .. id)
    end
end

function menulib.closeMenu()
    if currentMenu then
        SendNUIMessage({eventName = "close_menu"})
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        isMenuOpen = false
        currentMenu = nil
    end
end

function menulib.openParentMenu()
    if currentMenu and currentMenu.parent then
        menulib.openMenu(currentMenu.parent)
    else
        menulib.closeMenu()
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if isMenuOpen then
            local scrollDirection = nil

            if IsControlJustPressed(0, 172) then
                scrollDirection = "up"
                PlaySound(Audio.UpDown.audioName, Audio.UpDown.audioRef)
            elseif IsControlJustPressed(0, 173) then
                scrollDirection = "down"
                PlaySound(Audio.UpDown.audioName, Audio.UpDown.audioRef)
            end

            if scrollDirection then
                SendNUIMessage({eventName = "start_accelerated_scroll", metadata = {direction = scrollDirection}})
            end
            
            if IsControlJustReleased(0, 172) or IsControlJustReleased(0, 173) then
                SendNUIMessage({eventName = "stop_accelerated_scroll"})
            end

            if IsControlJustPressed(0, 174) then 
                SendNUIMessage({eventName = "left_selection"})
                PlaySound(Audio.LeftRight.audioName, Audio.LeftRight.audioRef)
             end
            if IsControlJustPressed(0, 175) then 
                SendNUIMessage({eventName = "right_selection"})
                PlaySound(Audio.Select.audioName, Audio.Select.audioRef)
             end
            if IsControlJustPressed(0, 176) then 
                SendNUIMessage({eventName = "select_item"}) 
                SendNUIMessage({eventName = "play_custom_sound"})
            end
            if IsControlJustPressed(0, 177) then
                menulib.openParentMenu()
            end
        else
            Citizen.Wait(150)
        end
    end
end)

RegisterNUICallback("updateButtonDisplay", function(data, cb)
    local item = currentMenu.items[data.id]
    if item and item.type == "button" and item.condition then
        updateButtonDisplay(item)
    end
    cb('ok')
end)

RegisterNUICallback("onSelected", function(data, cb)
    local item = currentMenu.items[data.id]
    if item and item.onSelected then
        item.onSelected()
    end
    cb('ok')
end)

RegisterNUICallback("onListSelected", function(data, cb)
    local item = currentMenu.items[data.id]
    if item and item.onSelected then
        item.onSelected(data.itemId)
    end
    cb('ok')
end)

RegisterNUICallback("onCheckboxSelected", function(data, cb)
    local item = currentMenu.items[data.id]
    if item then
        item.checked = data.checked
        if data.checked and item.onChecked then
            item.onChecked()
        elseif not data.checked and item.onUnchecked then
            item.onUnchecked()
        end
        updateMenuDisplay()
    end
    cb('ok')
end)

function updateMenuDisplay()
    if currentMenu then
        local itemsToSend = {}
        for i, item in ipairs(currentMenu.items) do
            local itemToSend = {
                id = item.id,
                type = item.type,
                label = item.label,
                rightLabel = item.rightLabel,
                description = item.description,
                list = item.list,
                checked = item.checked,
                info = item.info
            }
            table.insert(itemsToSend, itemToSend)
        end
        SendNUIMessage({
            eventName = "update_menu",
            metadata = {
                id = currentMenu.id,
                title = currentMenu.title,
                subtitle = currentMenu.subtitle,
                items = itemsToSend
            }
        })
    end
end

function changeUi(ui)
    currentUI = ui
    SetResourceKvp("menu_ui_theme", ui)
    SendNUIMessage({
        eventName = "change_ui",
        metadata = {
            ui = ui
        }
    })
end
