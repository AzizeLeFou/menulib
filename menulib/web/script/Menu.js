function getResourceName() {
    return GetParentResourceName();
}

function registerEvent(eventName, eventHandler) {
    window.addEventListener("message", function(event) {
        if (event.data.eventName === eventName) {
            eventHandler(event.data.metadata);
        }
    });
}

let ITEMS = {};
let CURRENT_SELECTED = 0;
const VISIBLE_ITEMS = 10;
let MenuId = 0;
let startIndex = 1;
let scrollInterval;
let scrollSpeed = 100;
const minScrollSpeed = 200;

function toggleVisibility(boolean) {
    if (boolean) {
        $("#menu").css("display", "flex");
    } else {
        $("#menu").css("display", "none");
    }
}

function startAcceleratedScroll(direction) {
    if (scrollInterval) clearInterval(scrollInterval);
    function scroll() {
        if (direction === 'up') {
            scrollUp();
        } else {
            scrollDown();
        }
        scrollSpeed = Math.max(minScrollSpeed, scrollSpeed - 10);
    }
    scroll();
    scrollInterval = setInterval(scroll, scrollSpeed);
}

function scrollUp() {
    let newSelected = CURRENT_SELECTED - 1;
    const totalItems = Object.keys(ITEMS).length;
    if (newSelected < 1) {
        newSelected = totalItems;
    }
    while (ITEMS[newSelected].type === "separator" || ITEMS[newSelected].type === "line") {
        newSelected--;
        if (newSelected < 1) {
            newSelected = totalItems;
        }
    }
    setCurrentSelected(newSelected, 'up');
}

function scrollDown() {
    let newSelected = CURRENT_SELECTED + 1;
    const totalItems = Object.keys(ITEMS).length;
    if (newSelected > totalItems) {
        newSelected = 1;
    }
    while (ITEMS[newSelected].type === "separator" || ITEMS[newSelected].type === "line") {
        newSelected++;
        if (newSelected > totalItems) {
            newSelected = 1;
        }
    }
    setCurrentSelected(newSelected, 'down');
}

registerEvent("start_accelerated_scroll", function(data) {
    startAcceleratedScroll(data.direction);
});

registerEvent("stop_accelerated_scroll", function() {
    stopAcceleratedScroll();
});

function stopAcceleratedScroll() {
    if (scrollInterval) {
        clearInterval(scrollInterval);
        scrollInterval = null;
    }
    scrollSpeed = 10;
}

function setTitle(title) {
    $("#title h1").text(title);
}

function setSubtitle(subtitle) {
    $(".subtitle").text(subtitle);
}

function setItems(items) {
    var NewItems = {};
    for (let item of items) {
        NewItems[item.id] = {
            "id": item.id,
            "type": item.type,
            "label": item.label,
            "description": item.description,
            "rightLabel": item.rightLabel,
            "info": item.info,
            "list": item.list,
            "currentSelect": 1,
            "checked": item.checked
        };
    }
    ITEMS = NewItems;
    $('.maxItems').text(Object.keys(ITEMS).length);
}

function createButton(button) {
    let newButton = document.createElement('div');
    newButton.className = 'button item-' + button.id;
    if (button.disabled) {
        newButton.className += ' disabled';
    }

    let buttonLabel = document.createElement('h1');
    buttonLabel.textContent = button.label;
    newButton.appendChild(buttonLabel);

    if (button.rightLabel) {
        let rightLabel = document.createElement('div');
        rightLabel.className = 'right-label';
        rightLabel.innerHTML = button.rightLabel;
        newButton.appendChild(rightLabel);
    }

    document.getElementById('container').appendChild(newButton);
}

function updateButtonDisplay(data) {
    let buttonElement = document.querySelector('.item-' + data.id);
    if (buttonElement) {
        let buttonLabel = buttonElement.querySelector('h1');
        if (buttonLabel && data.label) {
            buttonLabel.textContent = data.label;
        }

        let rightLabelElement = buttonElement.querySelector('.right-label');
        if (data.rightLabel) {
            if (!rightLabelElement) {
                rightLabelElement = document.createElement('div');
                rightLabelElement.className = 'right-label';
                buttonElement.appendChild(rightLabelElement);
            }
            rightLabelElement.innerHTML = data.rightLabel;
        } else if (rightLabelElement) {
            buttonElement.removeChild(rightLabelElement);
        }
    }
}

registerEvent("update_button", function(data) {
    let button = document.querySelector('.item-' + data.id);
    if (button) {
        let buttonLabel = button.querySelector('h1');
        if (buttonLabel) {
            buttonLabel.textContent = data.label;
        }
        updateButtonDisplay(data);
    }
});

function createSeparator(separator) {
    let newSeparator = document.createElement('div');
    newSeparator.className = 'separator';

    let separatorLabel = document.createElement('h1');
    separatorLabel.textContent = separator.label;

    newSeparator.appendChild(separatorLabel);
    document.getElementById('container').appendChild(newSeparator);
}

function createLine() {
    let newLineContainer = document.createElement('div');
    newLineContainer.className = 'line-container';

    let newLine = document.createElement('div');
    newLine.className = 'line';

    newLineContainer.appendChild(newLine);
    document.getElementById('container').appendChild(newLineContainer);
}

function createList(list) {
    let newList = document.createElement('div');
    newList.className = 'list item-' + list.id;

    let listLabel = document.createElement('h1');
    listLabel.textContent = list.label;

    let listContent = document.createElement('h1');
    listContent.innerHTML = '< <span>' + list.list[0].label + '</span> >';

    newList.appendChild(listLabel);
    newList.appendChild(listContent);

    document.getElementById('container').appendChild(newList);
    updateListDisplay(list);
}

function createCheckbox(checkbox) {
    let newCheckbox = document.createElement('div');
    newCheckbox.className = 'checkbox item-' + checkbox.id;

    let checkboxLabel = document.createElement('h1');
    checkboxLabel.textContent = checkbox.label;

    let checkboxContainer = document.createElement('div');
    checkboxContainer.className = 'checkbox-container';

    let checkImage = document.createElement('img');
    checkImage.src = 'assets/check.png';
    checkImage.style.display = checkbox.checked ? 'block' : 'none';

    checkboxContainer.appendChild(checkImage);
    newCheckbox.appendChild(checkboxLabel);
    newCheckbox.appendChild(checkboxContainer);

    document.getElementById('container').appendChild(newCheckbox);
}

function renderItems() {
    $("#container").empty();
    const endIndex = Math.min(startIndex + VISIBLE_ITEMS - 1, Object.keys(ITEMS).length);

    for (let i = startIndex; i <= endIndex; i++) {
        const item = ITEMS[i];
        if (item) {
            if (item.type === "button") createButton(item);
            if (item.type === "separator") createSeparator(item);
            if (item.type === "line") createLine();
            if (item.type === "list") createList(item);
            if (item.type === "checkbox") createCheckbox(item);
        }
    }
}

function updateListDisplay(item) {
    $(".ui-info").css("display", "none");

    let listContent = document.querySelector(".item-" + item.id + " h1 span");
    listContent.textContent = item.list[item.currentSelect - 1].label;

    let info = item.list[item.currentSelect - 1].info;
    if (info) {
        displayInfo(info);
    }

    info = item.info;
    if (info) {
        displayInfo(info);
    }
}

function displayInfo(info) {
    $(".ui-info .bottom").empty();
    $(".ui-info .top h1").text(info.title);

    if (info.image) {
        let imageContainer = document.createElement("div");
        imageContainer.className = "image-container";
        let image = document.createElement("img");
        image.src = info.image;
        image.alt = "Info Image";
        imageContainer.appendChild(image);
        $(".ui-info .bottom").append(imageContainer);
    }

    for (let item of info.items) {
        let text = document.createElement("div");
        text.className = "text";

        let left = document.createElement("h1");
        left.className = "left";
        left.textContent = item.left;

        let right = document.createElement("h1");
        right.className = "right";
        right.textContent = item.right;

        text.appendChild(left);
        text.appendChild(right);

        $(".ui-info .bottom").append(text);
    }

    $(".ui-info").css("display", "flex");
}

let audio = new Audio('selected.35a21fdd.mp3');
audio.volume = 0.3;

window.addEventListener('message', function(event) {
    if (event.data.eventName === 'play_custom_sound') {
        audio.currentTime = 0;
        audio.play();
    }
});

function updateCheckboxDisplay(item) {
    let checkImage = document.querySelector(".item-" + item.id + " .checkbox-container img");
    checkImage.style.display = item.checked ? 'block' : 'none';
}

function setCurrentSelected(id, direction = "none") {
    $(".ui-info").css("display", "none");

    const totalItems = Object.keys(ITEMS).length;

    if (id < startIndex) {
        startIndex = Math.max(1, id);
    } else if (id > startIndex + VISIBLE_ITEMS - 1) {
        startIndex = Math.min(totalItems - VISIBLE_ITEMS + 1, id - VISIBLE_ITEMS + 1);
    }

    renderItems();

    $(".item-" + CURRENT_SELECTED).removeClass("item-selected");
    $(".item-" + id).addClass("item-selected");

    CURRENT_SELECTED = id;

    let description = ITEMS[id].description;
    if (description) {
        $("#footer").show();
        $("#footer h1").text(description);
    } else {
        $("#footer").hide();
        $("#footer h1").text("");
    }

    if (ITEMS[id].type === "button" || ITEMS[id].type === "list") {
        let info = ITEMS[id].info;
        if (info) {
            displayInfo(info);
        }
    }

    $(".currentSelected").text(CURRENT_SELECTED);
    $.post(`https://${getResourceName()}/setHoveredItem`, JSON.stringify({
        id: CURRENT_SELECTED,
        menuId: MenuId
    }));

    $.post(`https://${getResourceName()}/updateButtonDisplay`, JSON.stringify({
        id: CURRENT_SELECTED,
        menuId: MenuId
    }));

    let item = ITEMS[CURRENT_SELECTED];
    if (item.type === "list") {
        updateListDisplay(item);
    }
}

registerEvent("change_ui", function (data) {
    $("#menu").hide();
    const links = document.querySelectorAll('link[rel="stylesheet"]');
    links.forEach(link => {
        link.href = link.href.replace(/style\/\w+\/(.*)/, `style/${data.ui}/$1`);
    });
    setTimeout(() => $("#menu").show(), 5);
});

registerEvent("close_menu", function(metadata) {
    toggleVisibility(false);
});

registerEvent("open_menu", function(metadata) {
    MenuId = metadata.id;
    setTitle(metadata.title);
    setSubtitle(metadata.subtitle);
    setItems(metadata.items);
    startIndex = 1;
    renderItems();

    let selected = 1;
    while (ITEMS[selected].type === "separator" || ITEMS[selected].type === "line") {
        selected++;
    }

    setCurrentSelected(selected);

    for (let item of Object.values(ITEMS)) {
        if (item.type === "checkbox") {
            updateCheckboxDisplay(item);
        }
    }

    toggleVisibility(true);
});

registerEvent("up_selection", function() {
    let newSelected = CURRENT_SELECTED - 1;
    const totalItems = Object.keys(ITEMS).length;

    if (newSelected < 1) {
        newSelected = totalItems;
    }

    while (ITEMS[newSelected].type === "separator" || ITEMS[newSelected].type === "line") {
        newSelected--;
        if (newSelected < 1) {
            newSelected = totalItems;
        }
    }

    setCurrentSelected(newSelected, 'up');
});

registerEvent("down_selection", function() {
    let newSelected = CURRENT_SELECTED + 1;
    const totalItems = Object.keys(ITEMS).length;

    if (newSelected > totalItems) {
        newSelected = 1;
    }

    while (ITEMS[newSelected].type === "separator" || ITEMS[newSelected].type === "line") {
        newSelected++;
        if (newSelected > totalItems) {
            newSelected = 1;
        }
    }

    setCurrentSelected(newSelected, 'down');
});

registerEvent("left_selection", function() {
    let item = ITEMS[CURRENT_SELECTED];
    if (item.type === "list") {
        item.currentSelect--;
        if (item.currentSelect < 1) {
            item.currentSelect = item.list.length;
        }
        updateListDisplay(item);
    }
});

registerEvent("right_selection", function() {
    let item = ITEMS[CURRENT_SELECTED];
    if (item.type === "list") {
        item.currentSelect++;
        if (item.currentSelect > item.list.length) {
            item.currentSelect = 1;
        }
        updateListDisplay(item);
    }
});

registerEvent("select_item", function() {
    let item = ITEMS[CURRENT_SELECTED];
    if (item.type === "button") {
        $.post(`https://${getResourceName()}/onSelected`, JSON.stringify({
            id: item.id,
            menuId: MenuId
        }));
    }
    if (item.type === "list") {
        $.post(`https://${getResourceName()}/onListSelected`, JSON.stringify({
            id: item.id,
            itemId: item.list[item.currentSelect - 1].id,
            menuId: MenuId
        }));
    }
    if (item.type === "checkbox") {
        item.checked = !item.checked;
        updateCheckboxDisplay(item);
        $.post(`https://${getResourceName()}/onCheckboxSelected`, JSON.stringify({
            id: item.id,
            checked: item.checked,
            menuId: MenuId
        }));
    }
});