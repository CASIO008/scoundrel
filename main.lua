local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local startTime = love.timer.getTime()

local cardScale = 0.75
local cardWidth = 126 * cardScale
local cardHeight = 176 * cardScale
local cardSpriteW, cardSpriteH = 126, 176

local cardSprite
local cardSpritesheet
local cardQuads = {}
local cardBackQuad
local usingSpritesheet = false
local heartSprite
local cardSound
local crtShader

local canvas
local largeFont
local defaultFont
local mediumFont
local hpFont

local cardValues = {
    weapon = 5,
    power = 0,
    potion = 3,
    enemy = 7
}

local cardScale = 0.75
local cardWidth = 126 * cardScale
local cardHeight = 176 * cardScale

local deck = {
    cards = {},
    transform = {
        x = screenWidth - cardWidth - 20,
        y = 20,
        width = cardWidth,
        height = cardHeight,
    },
}

local btnStart = {
    x = screenWidth / 2 - 60,
    y = screenHeight / 2 - 25,
    width = 120,
    height = 50,
    text = "START"
}

local trashSprite

local btnTrash = {
    x = screenWidth / 2 + 250,
    y = screenHeight / 2 - 40,
    width = 80,
    height = 80,
    text = "X"
}

local btnRun = {
    x = 20,
    y = 20,
    width = 100,
    height = 40,
    text = "RUN"
}

local runCooldown = 0
local currentDifficulty = "Medium"
local showSettings = false
local settingsSprite

local btnSettings = {
    x = 20,
    y = screenHeight / 2 - 40,
    width = 80,
    height = 80
}

local cards = {}
local sounds = {}

local cardColors = {
    { 0.2,  0.5,  1,    1 }, -- Blue
    { 1,    0.9,  0.2,  1 }, -- Yellow
    { 1,    0.3,  0.3,  1 }, -- Red
    { 0.15, 0.15, 0.15, 1 }  -- Black
}

local cardTypes = {
    "weapon",
    "power",
    "potion",
    "enemy"
}

local playerHP = 20
local maxHP = 20

local slots = {}
local powerSlot = {}
local weaponSlot = {}
local weaponKills = {}
local maxSlots = 3
local enemyPopup = nil

local function align(deck)
    local deck_height = 10 / #deck.cards
    for position, card in ipairs(deck.cards) do
        if not card.dragging then
            card.target_transform.x = deck.transform.x - deck_height * (position - 1)
            card.target_transform.y = deck.transform.y + deck_height * (position - 1)
        end
    end
end


local function move(card, dt)
    local momentum = 0.75
    local max_velocity = 10
    if (card.target_transform.x ~= card.transform.x or card.velocity.x ~= 0) or
        (card.target_transform.y ~= card.transform.y or card.velocity.y ~= 0) then
        card.velocity.x = momentum * card.velocity.x +
            (1 - momentum) * (card.target_transform.x - card.transform.x) * 30 * dt
        card.velocity.y = momentum * card.velocity.y +
            (1 - momentum) * (card.target_transform.y - card.transform.y) * 30 * dt
        card.transform.x = card.transform.x + card.velocity.x
        card.transform.y = card.transform.y + card.velocity.y

        local velocity = math.sqrt(card.velocity.x ^ 2 + card.velocity.y ^ 2)
        if velocity > max_velocity then
            card.velocity.x = max_velocity * card.velocity.x / velocity
            card.velocity.y = max_velocity * card.velocity.y / velocity
        end
    end
end

local function new_card(color, cardType, suit_idx, rank)
    return {
        color = color,
        type = cardType,
        value = cardValues[cardType],
        power_type = nil,
        power_mult = nil,
        suit_idx = suit_idx,
        rank = rank,
        last_killed_value = nil,
        base_rotation = (math.random() - 0.5) * 0.4,
        dragging = false,
        is_on_deck = true,
        is_dealt = false,
        is_slotted = false,
        is_discarded = false,
        is_selected = false,
        is_stacked = false,
        transform = {
            x = deck.transform.x,
            y = deck.transform.y,
            width = cardWidth,
            height = cardHeight
        },
        target_transform = {
            x = deck.transform.x,
            y = deck.transform.y,
            width = cardWidth,
            height = cardHeight
        },
        velocity = {
            x = 0,
            y = 0,
        },
        anim = {
            scale = cardScale,
            opacity = 1,
            rotation = 0,
            punch = 0
        }
    }
end

local function queue_sound(sound, delay, pitch)
    table.insert(sounds, { sound = sound, delay = delay, pitch = pitch })
end

local function get_dealt_cards()
    local dealt = {}
    for _, card in ipairs(cards) do
        if card.is_dealt then
            table.insert(dealt, card)
        end
    end
    return dealt
end

local function deal_new_cards(count)
    local currentDealt = get_dealt_cards()

    local spacing = 20
    local totalWidth = (4 * cardWidth) + (3 * spacing)
    local startX = (screenWidth - totalWidth) / 2
    local dealY = screenHeight / 2 - cardHeight / 2

    for i, card in ipairs(currentDealt) do
        card.target_transform.x = startX + (i - 1) * (cardWidth + spacing)
        card.target_transform.y = dealY
    end

    local maxEnemies = 4
    if currentDifficulty == "Easy" then
        maxEnemies = 2
    elseif currentDifficulty == "Medium" then
        maxEnemies = 3
    end

    local dealtEnemies = 0
    for _, card in ipairs(currentDealt) do
        if card.type == "enemy" then
            dealtEnemies = dealtEnemies + 1
        end
    end

    local dealtCount = 0
    local position = #deck.cards
    while dealtCount < count and position > 0 do
        local card = deck.cards[position]
        if card.type == "enemy" and dealtEnemies >= maxEnemies then
            position = position - 1
        else
            if card.type == "enemy" then
                dealtEnemies = dealtEnemies + 1
            end
            card.is_on_deck = false
            card.is_dealt = true
            card.anim.punch = 0.2
            card.target_transform.x = startX + (#currentDealt + dealtCount) * (cardWidth + spacing)
            card.target_transform.y = dealY
            table.remove(deck.cards, position)
            dealtCount = dealtCount + 1
            position = #deck.cards
        end
    end
end

local function refill_session_if_needed()
    local dealtCount = #get_dealt_cards()
    if dealtCount == 1 then
        deal_new_cards(3)
    elseif dealtCount == 0 then
        deal_new_cards(4)
    end
end

local function effective_value(card)
    return card.value * (card.power_mult or 1)
end

local function kill_enemy_with_fists(enemy)
    playerHP = math.max(0, playerHP - enemy.value)
    enemy.is_discarded = true
    enemy.is_dealt = false
    enemy.anim.punch = -0.2
    queue_sound(cardSound, 0, 0.8)
end

local function kill_enemy_with_weapon(weapon, enemy)
    if weapon.last_killed_value and enemy.value > weapon.last_killed_value then
        queue_sound(cardSound, 0, 0.5)
        return false
    end

    local effective = effective_value(weapon)
    if effective < enemy.value then
        playerHP = math.max(0, playerHP - (enemy.value - effective))
    end

    weapon.last_killed_value = enemy.value

    enemy.is_dealt = false
    enemy.is_stacked = true
    enemy.anim.punch = 0.3
    weapon.anim.punch = 0.3
    table.insert(weaponKills, enemy)
    enemy.target_transform.x = weaponSlot.x
    enemy.target_transform.y = weaponSlot.y - (#weaponKills * 35)

    -- Insert at beginning so it renders BEHIND previous enemies
    for i, c in ipairs(cards) do
        if c == enemy then
            table.remove(cards, i)
            break
        end
    end
    table.insert(cards, 1, enemy)

    -- Bring weapon to very top for rendering
    for i, c in ipairs(cards) do
        if c == weapon then
            table.remove(cards, i)
            break
        end
    end
    table.insert(cards, weapon)

    weapon.is_selected = false
    queue_sound(cardSound, 0, 0.8)
    return true
end

local function open_enemy_popup(enemy)
    local weapon = weaponSlot.card
    local w = 460
    local h = 190
    local x = enemy.transform.x + enemy.transform.width / 2 - w / 2
    local y = enemy.transform.y - h - 40
    if y < 15 then
        y = enemy.transform.y + enemy.transform.height + 40
    end
    x = math.max(15, math.min(x, screenWidth - w - 15))
    y = math.max(15, math.min(y, screenHeight - h - 15))

    local btnY = y + h - 75
    local btnW = (w - 60) / 2

    local canWeapon = weapon ~= nil and
        (weapon.last_killed_value == nil or enemy.value <= weapon.last_killed_value)

    enemyPopup = {
        enemy = enemy,
        weapon = weapon,
        canWeapon = canWeapon,
        x = x,
        y = y,
        w = w,
        h = h,
        fistsBtn = { x = x + 20, y = btnY, w = btnW, h = 55 },
        weaponBtn = { x = x + w - 20 - btnW, y = btnY, w = btnW, h = 55 },
    }
end

function love.load()
    local success, img = pcall(love.graphics.newImage, "spritesheet.png")
    if success then
        usingSpritesheet = true
        cardSpritesheet = img
        cardSpritesheet:setFilter("nearest", "nearest")
        local imgW, imgH = img:getDimensions()
        cardSpriteW, cardSpriteH = imgW / 14, imgH / 4

        local targetWidth = 126 * 0.75
        cardScale = targetWidth / cardSpriteW
        cardWidth = cardSpriteW * cardScale
        cardHeight = cardSpriteH * cardScale

        deck.transform.x = screenWidth - cardWidth - 20
        deck.transform.width = cardWidth
        deck.transform.height = cardHeight

        for row = 0, 3 do
            cardQuads[row + 1] = {}
            for col = 0, 13 do
                cardQuads[row + 1][col + 1] = love.graphics.newQuad(col * cardSpriteW, row * cardSpriteH, cardSpriteW,
                    cardSpriteH, imgW, imgH)
            end
        end
        cardBackQuad = cardQuads[1][14]
    else
        cardSprite = love.graphics.newImage("card.png")
    end

    local successSettings, sImg = pcall(love.graphics.newImage, "settings.jpg")
    if successSettings then
        settingsSprite = sImg
        settingsSprite:setFilter("nearest", "nearest")
    end

    local successTrash, tImg = pcall(love.graphics.newImage, "trash.jpg")
    if successTrash then
        trashSprite = tImg
        trashSprite:setFilter("nearest", "nearest")
    end

    cardSound = love.audio.newSource("card.ogg", "static")
    crtShader = love.graphics.newShader("crt.glsl")
    canvas = love.graphics.newCanvas(screenWidth, screenHeight, { type = '2d', readable = true })
    defaultFont = love.graphics.getFont()
    largeFont = love.graphics.newFont(48)
    mediumFont = love.graphics.newFont(24)

    local successFont, fontData = pcall(love.graphics.newFont, "blackflag.ttf", 50)
    if not successFont then
        successFont, fontData = pcall(love.graphics.newFont, "BlackFlag.ttf", 50)
    end
    if not successFont then
        successFont, fontData = pcall(love.graphics.newFont, "blackflag.otf", 50)
    end
    if successFont then
        hpFont = fontData
    else
        hpFont = largeFont
    end

    local slotSpacing = 20
    local totalSlotWidth = (maxSlots * cardWidth) + ((maxSlots - 1) * slotSpacing)
    local startSlotX = (screenWidth - totalSlotWidth) / 2
    local slotY = screenHeight - cardHeight - 20

    for i = 1, maxSlots do
        table.insert(slots, {
            x = startSlotX + (i - 1) * (cardWidth + slotSpacing),
            y = slotY,
            width = cardWidth,
            height = cardHeight,
            card = nil
        })
    end

    powerSlot = {
        x = 20,
        y = slotY,
        width = cardWidth,
        height = cardHeight,
        card = nil
    }

    weaponSlot = {
        x = screenWidth - cardWidth - 20,
        y = slotY,
        width = cardWidth,
        height = cardHeight,
        card = nil
    }

    local deckBuilder = {}
    local suits = { "Spades", "Clubs", "Hearts", "Diamonds" }
    local suitToRow = { Hearts = 1, Spades = 2, Diamonds = 3, Clubs = 4 }

    for _, suit in ipairs(suits) do
        for rank = 1, 13 do
            local cardType
            local color
            local powerType = nil
            if suit == "Spades" or suit == "Clubs" then
                cardType = "enemy"
                color = cardColors[4] -- Black
            elseif rank >= 11 and rank <= 13 then
                cardType = "power"
                if suit == "Diamonds" then
                    color = cardColors[2] -- Yellow (2x power)
                    powerType = "double"
                else
                    color = cardColors[3] -- Red (heal power)
                    powerType = "heal"
                end
            elseif suit == "Hearts" then
                cardType = "potion"
                color = cardColors[3] -- Red
            else
                cardType = "weapon"
                color = cardColors[1] -- Blue
            end

            local card = new_card(color, cardType, suitToRow[suit], rank)
            card.value = rank
            card.power_type = powerType
            table.insert(deckBuilder, card)
        end
    end

    math.randomseed(os.time())
    for i = #deckBuilder, 2, -1 do
        local j = math.random(i)
        deckBuilder[i], deckBuilder[j] = deckBuilder[j], deckBuilder[i]
    end

    for _, card in ipairs(deckBuilder) do
        table.insert(cards, card)
        table.insert(deck.cards, card)
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.937, 0.945, 0.96, 1)

    -- Draw HP
    love.graphics.setFont(hpFont)
    love.graphics.setColor(1, 0.3, 0.3, 1)
    love.graphics.printf(playerHP, 0, 50, screenWidth, "center")
    love.graphics.setFont(defaultFont)

    -- Draw Inventory Slots
    love.graphics.setColor(0.8, 0.8, 0.8, 0.5)
    for _, slot in ipairs(slots) do
        love.graphics.rectangle("fill", slot.x, slot.y, slot.width, slot.height, 5, 5)
        love.graphics.rectangle("line", slot.x, slot.y, slot.width, slot.height, 5, 5)
    end

    -- Draw Power Slot
    love.graphics.setColor(1, 0.9, 0.2, 0.3)
    love.graphics.rectangle("fill", powerSlot.x, powerSlot.y, powerSlot.width, powerSlot.height, 5, 5)
    love.graphics.setColor(0.8, 0.8, 0.8, 0.5)
    love.graphics.rectangle("line", powerSlot.x, powerSlot.y, powerSlot.width, powerSlot.height, 5, 5)

    -- Draw Weapon Slot
    love.graphics.setColor(0.2, 0.5, 1, 0.3)
    love.graphics.rectangle("fill", weaponSlot.x, weaponSlot.y, weaponSlot.width, weaponSlot.height, 5, 5)
    love.graphics.setColor(0.8, 0.8, 0.8, 0.5)
    love.graphics.rectangle("line", weaponSlot.x, weaponSlot.y, weaponSlot.width, weaponSlot.height, 5, 5)

    -- Draw START button
    if #get_dealt_cards() == 0 then
        love.graphics.setColor(0.1, 0.6, 0.3, 1)
        love.graphics.rectangle("fill", btnStart.x, btnStart.y, btnStart.width, btnStart.height, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(btnStart.text, btnStart.x, btnStart.y + 18, btnStart.width, "center")
    end

    -- Draw Trash button
    local mx, my = love.mouse.getPosition()
    local isTrashHover = not showSettings and mx > btnTrash.x and mx < btnTrash.x + btnTrash.width and
        my > btnTrash.y and my < btnTrash.y + btnTrash.height

    love.graphics.setColor(1, 1, 1, 1)
    if trashSprite then
        local tw, th = trashSprite:getDimensions()
        local baseScale = 80 / th
        local scale = isTrashHover and (baseScale * 1.15) or baseScale
        local rot = 0
        if isTrashHover then
            rot = math.sin(love.timer.getTime() * 6) * 0.15
        end
        love.graphics.draw(trashSprite, btnTrash.x + btnTrash.width / 2, btnTrash.y + btnTrash.height / 2, rot, scale,
            scale, tw / 2, th / 2)
    else
        love.graphics.setColor(0.8, 0.2, 0.2, 1)
        love.graphics.rectangle("fill", btnTrash.x, btnTrash.y, btnTrash.width, btnTrash.height, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(btnTrash.text, btnTrash.x, btnTrash.y + 24, btnTrash.width, "center")
    end

    -- Draw RUN button
    if runCooldown == 0 then
        love.graphics.setColor(0.8, 0.2, 0.2, 1)
    else
        love.graphics.setColor(0.4, 0.4, 0.4, 1)
    end
    love.graphics.rectangle("fill", btnRun.x, btnRun.y, btnRun.width, btnRun.height, 8, 8)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(btnRun.text, btnRun.x, btnRun.y + 14, btnRun.width, "center")

    -- Draw Settings button
    local mx, my = love.mouse.getPosition()
    local isSettingsHover = not showSettings and mx > btnSettings.x and mx < btnSettings.x + btnSettings.width and
        my > btnSettings.y and my < btnSettings.y + btnSettings.height

    love.graphics.setColor(1, 1, 1, 1)
    if settingsSprite then
        local sw, sh = settingsSprite:getDimensions()
        local baseScale = 80 / sh
        local scale = isSettingsHover and (baseScale * 1.15) or baseScale
        local rot = 0
        if isSettingsHover then
            rot = math.sin(love.timer.getTime() * 6) * 0.15 -- balançar levemente
        end
        love.graphics.draw(settingsSprite, btnSettings.x + btnSettings.width / 2, btnSettings.y + btnSettings.height / 2,
            rot, scale, scale, sw / 2, sh / 2)
    else
        love.graphics.printf("S", btnSettings.x, btnSettings.y + 24, btnSettings.width, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
    for _, card in ipairs(deck.cards) do
        if not usingSpritesheet then love.graphics.setColor(card.color) end
        local cx = card.transform.x + (cardWidth / 2)
        local cy = card.transform.y + (cardHeight / 2)
        if usingSpritesheet then
            love.graphics.draw(cardSpritesheet, cardBackQuad, cx, cy, 0, cardScale, cardScale, cardSpriteW / 2,
                cardSpriteH / 2)
        else
            love.graphics.draw(cardSprite, cx, cy, 0, cardScale, cardScale, 63, 88)
        end
    end
    for _, card in ipairs(cards) do
        if not card.is_on_deck and (not card.is_discarded or card.anim.opacity > 0.05) then
            love.graphics.push()
            local cx = card.transform.x + (cardWidth / 2)
            local cy = card.transform.y + (cardHeight / 2)
            love.graphics.translate(cx, cy)
            love.graphics.rotate(card.anim.rotation)
            local current_scale = card.anim.scale + card.anim.punch
            love.graphics.scale(current_scale, current_scale)

            local shadow_dist = 4
            if card.dragging then shadow_dist = 16 end
            if not card.dragging and card.anim.scale > cardScale then shadow_dist = 10 end
            love.graphics.setColor(0, 0, 0, 0.4 * card.anim.opacity)
            if usingSpritesheet then
                love.graphics.draw(cardSpritesheet, cardQuads[card.suit_idx][card.rank], 0, shadow_dist, 0, 1, 1,
                    cardSpriteW / 2, cardSpriteH / 2)
            else
                love.graphics.draw(cardSprite, 0, shadow_dist, 0, 1, 1, 63, 88)
            end

            if not usingSpritesheet then
                love.graphics.setColor(card.color[1], card.color[2], card.color[3],
                    card.anim.opacity)
            else
                love.graphics.setColor(1, 1, 1, card.anim.opacity)
            end
            if usingSpritesheet then
                love.graphics.draw(cardSpritesheet, cardQuads[card.suit_idx][card.rank], 0, 0, 0, 1, 1, cardSpriteW / 2,
                    cardSpriteH / 2)
            else
                love.graphics.draw(cardSprite, 0, 0, 0, 1, 1, 63, 88)
            end

            if not usingSpritesheet then
                love.graphics.setFont(mediumFont)
                if card.type == "power" then
                    local label = "x2"
                    if card.power_type == "heal" then
                        label = "+" .. tostring(card.value)
                    end
                    love.graphics.printf(label, -63, -16, 126, "center")
                    love.graphics.setFont(defaultFont)
                    love.graphics.printf(label, -55, -82, 126, "left")
                else
                    love.graphics.printf(tostring(effective_value(card)), -63, -16, 126, "center")
                    love.graphics.setFont(defaultFont)
                    love.graphics.printf(tostring(effective_value(card)), -55, -82, 126, "left")
                end
            end

            if card.last_killed_value then
                love.graphics.setFont(defaultFont)
                love.graphics.setColor(1, 0.3, 0.3, card.anim.opacity)
                local offset = usingSpritesheet and (cardSpriteH / 2 - 20) or 20
                local x_offset = usingSpritesheet and -cardSpriteW / 2 or -63
                local text_w = usingSpritesheet and cardSpriteW or 126
                love.graphics.printf("Max: " .. tostring(card.last_killed_value), x_offset, offset, text_w, "center")
            end

            if card.power_mult and card.power_mult > 0 then
                love.graphics.setFont(mediumFont)
                love.graphics.setColor(1, 0.85, 0.2, card.anim.opacity)
                local badge = "x" .. tostring(card.power_mult)
                if usingSpritesheet then
                    love.graphics.printf(badge, -cardSpriteW / 2, -cardSpriteH / 2 - 32, cardSpriteW, "center")
                else
                    love.graphics.printf(badge, -63, -110, 126, "center")
                end
                love.graphics.setFont(defaultFont)
            end

            love.graphics.setFont(defaultFont)

            if card.is_selected and (card.is_slotted or card.is_dealt) then
                love.graphics.setColor(1, 1, 1, card.anim.opacity)
                love.graphics.setLineWidth(4 / current_scale)
                if usingSpritesheet then
                    love.graphics.rectangle("line", -cardSpriteW / 2, -cardSpriteH / 2, cardSpriteW, cardSpriteH, 8, 8)
                else
                    love.graphics.rectangle("line", -63, -88, 126, 176, 8, 8)
                end
                love.graphics.setLineWidth(1)
            end
            love.graphics.pop()
        end
    end

    -- Draw enemy kill popup
    if enemyPopup then
        local p = enemyPopup
        love.graphics.setColor(0.08, 0.08, 0.1, 0.96)
        love.graphics.rectangle("fill", p.x, p.y, p.w, p.h, 12, 12)
        love.graphics.setColor(1, 1, 1, 0.25)
        love.graphics.rectangle("line", p.x, p.y, p.w, p.h, 12, 12)

        love.graphics.setFont(mediumFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Enemy " .. tostring(p.enemy.value), p.x, p.y + 12, p.w, "center")

        love.graphics.setFont(defaultFont)
        if p.weapon then
            local effective = effective_value(p.weapon)
            local info = "Weapon " .. tostring(effective)
            if p.weapon.power_mult and p.weapon.power_mult > 0 then
                info = info .. " (x" .. tostring(p.weapon.power_mult) .. ")"
            end
            if p.weapon.last_killed_value then
                info = info .. " - Max " .. tostring(p.weapon.last_killed_value)
            end
            if not p.canWeapon then
                info = info .. " - can't kill " .. tostring(p.enemy.value) .. " (chain)"
            elseif effective < p.enemy.value then
                info = info .. " - takes " .. tostring(p.enemy.value - effective) .. " dmg"
            end
            if p.canWeapon then
                love.graphics.setColor(0.5, 1, 0.6, 1)
            else
                love.graphics.setColor(1, 0.5, 0.5, 1)
            end
            love.graphics.printf(info, p.x + 20, p.y + 46, p.w - 40, "center")
        end

        -- Fists button
        love.graphics.setColor(0.9, 0.35, 0.3, 1)
        love.graphics.rectangle("fill", p.fistsBtn.x, p.fistsBtn.y, p.fistsBtn.w, p.fistsBtn.h, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(mediumFont)
        love.graphics.printf("Fists (-" .. tostring(p.enemy.value) .. " HP)", p.fistsBtn.x, p.fistsBtn.y + 16,
            p.fistsBtn.w, "center")

        -- Weapon button
        if p.canWeapon then
            love.graphics.setColor(0.2, 0.5, 1, 1)
        else
            love.graphics.setColor(0.35, 0.35, 0.4, 1)
        end
        love.graphics.rectangle("fill", p.weaponBtn.x, p.weaponBtn.y, p.weaponBtn.w, p.weaponBtn.h, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        local weaponLabel = "Weapon"
        if p.weapon then
            weaponLabel = "Weapon " .. tostring(effective_value(p.weapon))
        end
        love.graphics.printf(weaponLabel, p.weaponBtn.x, p.weaponBtn.y + 16, p.weaponBtn.w, "center")
        love.graphics.setFont(defaultFont)
    end

    -- Draw Settings popup
    if showSettings then
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

        local pw, ph = 400, 300
        local px, py = screenWidth / 2 - pw / 2, screenHeight / 2 - ph / 2
        love.graphics.setColor(0.15, 0.15, 0.18, 1)
        love.graphics.rectangle("fill", px, py, pw, ph, 12, 12)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(largeFont)
        love.graphics.printf("Settings", px, py + 20, pw, "center")

        love.graphics.setFont(mediumFont)
        love.graphics.printf("Select Difficulty:", px, py + 100, pw, "center")

        local difficulties = { "Easy", "Medium", "Hard" }
        for i, diff in ipairs(difficulties) do
            local bx = px + 40 + (i - 1) * 110
            local by = py + 150
            if currentDifficulty == diff then
                love.graphics.setColor(0.2, 0.8, 0.3, 1)
            else
                love.graphics.setColor(0.3, 0.3, 0.35, 1)
            end
            love.graphics.rectangle("fill", bx, by, 100, 50, 8, 8)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf(diff, bx, by + 14, 100, "center")
        end

        love.graphics.setColor(0.8, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", px + pw / 2 - 60, py + 230, 120, 40, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Close", px + pw / 2 - 60, py + 230 + 8, 120, "center")
    end

    love.graphics.setCanvas()
    love.graphics.setColor({ 1, 1, 1 })
    crtShader:send('millis', love.timer.getTime() - startTime)
    love.graphics.setShader(crtShader)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()
end

function love.mousepressed(x, y, button, istouch, presses)
    if button ~= 1 then return end

    if showSettings then
        local pw, ph = 400, 300
        local px, py = screenWidth / 2 - pw / 2, screenHeight / 2 - ph / 2

        -- Difficulty buttons
        local difficulties = { "Easy", "Medium", "Hard" }
        for i, diff in ipairs(difficulties) do
            local bx = px + 40 + (i - 1) * 110
            local by = py + 150
            if x > bx and x < bx + 100 and y > by and y < by + 50 then
                currentDifficulty = diff
                return
            end
        end

        -- Close button or outside click
        local cx, cy, cw, ch = px + pw / 2 - 60, py + 230, 120, 40
        if x > cx and x < cx + cw and y > cy and y < cy + ch then
            showSettings = false
            return
        end

        if x < px or x > px + pw or y < py or y > py + ph then
            showSettings = false
        end

        return -- Block interactions
    end

    -- Enemy kill popup logic
    if enemyPopup then
        local p = enemyPopup
        if x > p.fistsBtn.x and x < p.fistsBtn.x + p.fistsBtn.w and
            y > p.fistsBtn.y and y < p.fistsBtn.y + p.fistsBtn.h then
            kill_enemy_with_fists(p.enemy)
            enemyPopup = nil
            refill_session_if_needed()
        elseif x > p.weaponBtn.x and x < p.weaponBtn.x + p.weaponBtn.w and
            y > p.weaponBtn.y and y < p.weaponBtn.y + p.weaponBtn.h then
            if p.canWeapon then
                kill_enemy_with_weapon(p.weapon, p.enemy)
                enemyPopup = nil
                refill_session_if_needed()
            else
                queue_sound(cardSound, 0, 0.5)
            end
        elseif x > p.x and x < p.x + p.w and y > p.y and y < p.y + p.h then
            -- Click inside the popup but not on a button: ignore
        else
            enemyPopup = nil
        end
        return
    end

    -- Trash button logic
    if x > btnTrash.x and x < btnTrash.x + btnTrash.width and
        y > btnTrash.y and y < btnTrash.y + btnTrash.height then
        local discarded_something = false
        for _, card in ipairs(cards) do
            if card.is_slotted and card.is_selected then
                card.is_slotted = false
                card.is_selected = false
                card.is_discarded = true
                card.anim.punch = -0.3
                card.target_transform.x = btnTrash.x + btnTrash.width / 2 - card.transform.width / 2
                card.target_transform.y = btnTrash.y + btnTrash.height / 2 - card.transform.height / 2
                queue_sound(cardSound, 0, 0.8)

                -- Free slot
                for _, slot in ipairs(slots) do
                    if slot.card == card then
                        slot.card = nil
                        break
                    end
                end
                if powerSlot.card == card then powerSlot.card = nil end
                if weaponSlot.card == card then weaponSlot.card = nil end
                discarded_something = true
                break
            end
        end
        if discarded_something then return end
    end

    -- Start button logic
    if #get_dealt_cards() == 0 and x > btnStart.x and x < btnStart.x + btnStart.width and
        y > btnStart.y and y < btnStart.y + btnStart.height then
        local currentDealt = get_dealt_cards()

        local cardsToDeal = 4 - #currentDealt
        if cardsToDeal <= 0 then
            return
        end

        if runCooldown > 0 then
            runCooldown = runCooldown - 1
        end

        deal_new_cards(cardsToDeal)
        return
    end

    -- Settings button logic
    if x > btnSettings.x and x < btnSettings.x + btnSettings.width and
        y > btnSettings.y and y < btnSettings.y + btnSettings.height then
        showSettings = true
        return
    end

    -- Run button logic
    if x > btnRun.x and x < btnRun.x + btnRun.width and
        y > btnRun.y and y < btnRun.y + btnRun.height then
        if runCooldown > 0 then
            queue_sound(cardSound, 0, 0.5)
            return
        end

        local count = 1
        for _, card in ipairs(cards) do
            if card.is_dealt then
                queue_sound(cardSound, count * 0.05, 1 + count * 0.2)
                count = count + 1
                card.is_on_deck = true
                card.is_dealt = false
                table.insert(deck.cards, card)
            end
        end

        math.randomseed(os.time())
        for i = #deck.cards, 2, -1 do
            local j = math.random(i)
            deck.cards[i], deck.cards[j] = deck.cards[j], deck.cards[i]
        end

        runCooldown = 2
        return
    end

    -- Weapon base arming: click the weapon slot with a weapon selected
    if x > weaponSlot.x and x < weaponSlot.x + weaponSlot.width and
        y > weaponSlot.y and y < weaponSlot.y + weaponSlot.height then
        local selected_weapon = nil
        for _, c in ipairs(cards) do
            if c.type == "weapon" and c.is_selected and not c.is_discarded and (c.is_slotted or c.is_dealt) then
                selected_weapon = c
                break
            end
        end
        if selected_weapon then
            if selected_weapon == weaponSlot.card then
                selected_weapon.is_selected = false
                queue_sound(cardSound, 0, 1)
            else
                for _, stacked_enemy in ipairs(weaponKills) do
                    stacked_enemy.is_stacked = false
                    stacked_enemy.is_discarded = true
                end
                weaponKills = {}

                local old_weapon = weaponSlot.card
                if selected_weapon.is_slotted then
                    local from_slot = nil
                    for _, slot in ipairs(slots) do
                        if slot.card == selected_weapon then
                            from_slot = slot
                            break
                        end
                    end
                    if from_slot then
                        if old_weapon then
                            from_slot.card = old_weapon
                            old_weapon.target_transform.x = from_slot.x
                            old_weapon.target_transform.y = from_slot.y
                            old_weapon.is_selected = false
                        else
                            from_slot.card = nil
                        end
                        weaponSlot.card = selected_weapon
                        selected_weapon.target_transform.x = weaponSlot.x
                        selected_weapon.target_transform.y = weaponSlot.y
                        selected_weapon.is_selected = false
                        queue_sound(cardSound, 0, 1)
                        return
                    end
                elseif selected_weapon.is_dealt then
                    if old_weapon then
                        old_weapon.is_slotted = false
                        old_weapon.is_selected = false
                        old_weapon.is_on_deck = true
                        old_weapon.last_killed_value = nil
                        table.insert(deck.cards, old_weapon)
                    end
                    weaponSlot.card = selected_weapon
                    selected_weapon.is_dealt = false
                    selected_weapon.is_slotted = true
                    selected_weapon.target_transform.x = weaponSlot.x
                    selected_weapon.target_transform.y = weaponSlot.y
                    selected_weapon.is_selected = false
                    queue_sound(cardSound, 0, 1)
                    refill_session_if_needed()
                    return
                end
            end
        end
    end

    -- Find which card was clicked
    local clicked_card = nil
    for i = #cards, 1, -1 do
        local card = cards[i]
        if not card.is_discarded and not card.is_on_deck then
            if x > card.transform.x and x < card.transform.x + card.transform.width and
                y > card.transform.y and y < card.transform.y + card.transform.height then
                clicked_card = card
                break
            end
        end
    end

    if clicked_card then
        -- Check if we already have a selected slotted card
        local selected_card = nil
        for _, c in ipairs(cards) do
            if c.is_slotted and c.is_selected and c ~= clicked_card then
                selected_card = c
                break
            end
        end

        local function free_slot(card_to_free)
            for _, slot in ipairs(slots) do
                if slot.card == card_to_free then
                    slot.card = nil
                    break
                end
            end
            if powerSlot.card == card_to_free then powerSlot.card = nil end
            if weaponSlot.card == card_to_free then weaponSlot.card = nil end
        end

        -- Try interactions first
        if selected_card then
            if selected_card.type == "weapon" and clicked_card.type == "weapon" then
                local selected_in_weapon_slot = selected_card == weaponSlot.card
                local clicked_in_weapon_slot = clicked_card == weaponSlot.card
                local generic_slot = nil
                for _, slot in ipairs(slots) do
                    if slot.card == selected_card then generic_slot = slot end
                    if slot.card == clicked_card then generic_slot = slot end
                end
                if selected_in_weapon_slot ~= clicked_in_weapon_slot and generic_slot ~= nil then
                    local moving_in = selected_in_weapon_slot and clicked_card or selected_card
                    local moving_out = weaponSlot.card
                    if moving_out and moving_in ~= moving_out then
                        for _, stacked_enemy in ipairs(weaponKills) do
                            stacked_enemy.is_stacked = false
                            stacked_enemy.is_discarded = true
                        end
                        weaponKills = {}

                        generic_slot.card = moving_out
                        moving_out.target_transform.x = generic_slot.x
                        moving_out.target_transform.y = generic_slot.y

                        weaponSlot.card = moving_in
                        moving_in.target_transform.x = weaponSlot.x
                        moving_in.target_transform.y = weaponSlot.y

                        moving_in.is_selected = false
                        moving_out.is_selected = false
                        queue_sound(cardSound, 0, 1)

                        for i, c in ipairs(cards) do
                            if c == moving_in then
                                table.remove(cards, i)
                                break
                            end
                        end
                        table.insert(cards, moving_in)
                        return
                    end
                end
            elseif selected_card.type == "power" and selected_card.power_type == "double" and clicked_card.is_slotted and (clicked_card.type == "weapon" or clicked_card.type == "potion") then
                clicked_card.power_mult = (clicked_card.power_mult or 0) + 2
                clicked_card.anim.punch = 0.4
                selected_card.is_discarded = true
                selected_card.is_slotted = false
                selected_card.is_selected = false
                free_slot(selected_card)
                queue_sound(cardSound, 0, 1.5)
                return
            end
        end

        -- If no interaction, handle basic equip, usage, or selection
        if clicked_card.is_dealt then
            if clicked_card.type == "enemy" then
                if weaponSlot.card then
                    open_enemy_popup(clicked_card)
                else
                    kill_enemy_with_fists(clicked_card)
                    refill_session_if_needed()
                end
            elseif clicked_card.type == "power" then
                if not powerSlot.card then
                    powerSlot.card = clicked_card
                    clicked_card.is_dealt = false
                    clicked_card.is_slotted = true
                    clicked_card.anim.punch = 0.3
                    clicked_card.target_transform.x = powerSlot.x
                    clicked_card.target_transform.y = powerSlot.y
                    queue_sound(cardSound, 0, 1)
                    refill_session_if_needed()
                end
            elseif clicked_card.type == "weapon" or clicked_card.type == "potion" then
                if clicked_card.type == "weapon" and not weaponSlot.card then
                    weaponSlot.card = clicked_card
                    clicked_card.is_dealt = false
                    clicked_card.is_slotted = true
                    clicked_card.anim.punch = 0.3
                    clicked_card.target_transform.x = weaponSlot.x
                    clicked_card.target_transform.y = weaponSlot.y
                    queue_sound(cardSound, 0, 1)
                    refill_session_if_needed()

                    for i, c in ipairs(cards) do
                        if c == clicked_card then
                            table.remove(cards, i)
                            break
                        end
                    end
                    table.insert(cards, clicked_card)
                else
                    local equipped = false
                    for _, slot in ipairs(slots) do
                        if not slot.card then
                            slot.card = clicked_card
                            clicked_card.is_dealt = false
                            clicked_card.is_slotted = true
                            clicked_card.anim.punch = 0.3
                            clicked_card.target_transform.x = slot.x
                            clicked_card.target_transform.y = slot.y
                            queue_sound(cardSound, 0, 1)
                            refill_session_if_needed()
                            equipped = true
                            break
                        end
                    end
                    if not equipped and clicked_card.type == "weapon" and weaponSlot.card then
                        local was_selected = clicked_card.is_selected
                        for _, c in ipairs(cards) do c.is_selected = false end
                        clicked_card.is_selected = not was_selected
                        clicked_card.anim.punch = 0.15
                        queue_sound(cardSound, 0, 1.2)
                    end
                end
            end
        elseif clicked_card.is_slotted then
            if clicked_card.type == "potion" then
                playerHP = math.min(maxHP, playerHP + effective_value(clicked_card))
                clicked_card.is_slotted = false
                clicked_card.is_discarded = true
                free_slot(clicked_card)
                queue_sound(cardSound, 0, 1.5)
            elseif clicked_card.type == "power" and clicked_card.power_type == "heal" then
                playerHP = math.min(maxHP, playerHP + clicked_card.value)
                clicked_card.is_slotted = false
                clicked_card.is_discarded = true
                free_slot(clicked_card)
                queue_sound(cardSound, 0, 1.5)
            else
                local was_selected = clicked_card.is_selected
                for _, c in ipairs(cards) do c.is_selected = false end
                clicked_card.is_selected = not was_selected
                clicked_card.anim.punch = 0.15
                queue_sound(cardSound, 0, 1.2)
            end
        end
        return
    end

    for position = #deck.cards, 1, -1 do
        local card = deck.cards[position]
        if x > card.transform.x
            and x < card.transform.x + card.transform.width
            and y > card.transform.y
            and y < card.transform.y + card.transform.height
        then
            card.dragging = true
            break
        end
    end
end

function love.update(delta_time)
    local mx, my = love.mouse.getPosition()
    local time = love.timer.getTime()
    for _, card in ipairs(cards) do
        local is_hover = mx > card.transform.x and mx < card.transform.x + card.transform.width and
            my > card.transform.y and my < card.transform.y + card.transform.height

        local target_scale = cardScale
        local target_opacity = 1
        local target_rotation = 0
        local wobble = math.sin(time * 3 + card.base_rotation * 100) * 0.015
        local mouse_tilt = 0

        if card.is_slotted then
            if is_hover or card.is_selected then
                target_scale = cardScale * 1.1
                target_opacity = 1
                target_rotation = card.base_rotation
            else
                target_scale = cardScale * 0.8
                target_opacity = 0.6
                target_rotation = card.base_rotation + wobble
            end
        elseif card.is_discarded then
            target_scale = 0
            target_opacity = 0
            target_rotation = card.base_rotation + math.rad(90)
        elseif card.is_stacked then
            target_scale = cardScale * 1.0
            target_opacity = 1
            target_rotation = 0
        elseif card.is_dealt then
            target_scale = cardScale
            if is_hover and not card.dragging then
                target_scale = cardScale * 1.1
            end
            target_rotation = wobble
        elseif card.is_on_deck then
            target_rotation = card.base_rotation + wobble
        end

        if is_hover and not card.dragging then
            local cx = card.transform.x + (card.transform.width / 2)
            local dx = (mx - cx) / (card.transform.width / 2)
            mouse_tilt = dx * 0.05
        end

        local velocity_tilt = math.rad(card.velocity.x * 1.5)
        target_rotation = target_rotation + mouse_tilt + velocity_tilt

        local speed = 15 * delta_time
        card.anim.scale = card.anim.scale + (target_scale - card.anim.scale) * speed
        card.anim.opacity = card.anim.opacity + (target_opacity - card.anim.opacity) * speed
        card.anim.rotation = card.anim.rotation + (target_rotation - card.anim.rotation) * speed

        if card.anim.punch > 0.01 then
            card.anim.punch = card.anim.punch + (0 - card.anim.punch) * 15 * delta_time
        else
            card.anim.punch = 0
        end

        if card.dragging then
            card.target_transform.x = love.mouse.getX() - card.transform.width / 2
            card.target_transform.y = love.mouse.getY() - card.transform.height / 2
        end
        move(card, delta_time)
        align(deck)
    end

    for position, sound in ipairs(sounds) do
        if sound.delay <= 0 then
            sound.sound:setPitch(sound.pitch)
            love.audio.play(sound.sound)
            table.remove(sounds, position)
            sound.sound:setPitch(sound.pitch)
        else
            sound.delay = sound.delay - delta_time
        end
    end
end

function love.mousereleased()
    local mx, my = love.mouse.getPosition()
    for position, card in ipairs(deck.cards) do
        if card.dragging == true then
            love.audio.play(cardSound)
            card.dragging = false

            if mx > btnTrash.x and mx < btnTrash.x + btnTrash.width and
                my > btnTrash.y and my < btnTrash.y + btnTrash.height then
                card.is_on_deck = false
                card.is_discarded = true
                card.target_transform.x = btnTrash.x + btnTrash.width / 2 - card.transform.width / 2
                card.target_transform.y = btnTrash.y + btnTrash.height / 2 - card.transform.height / 2
                card.anim.punch = -0.2
                table.remove(deck.cards, position)
            end
            break
        end
    end
end
