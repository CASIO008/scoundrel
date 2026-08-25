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
local sfxVolume = 1.0
local musicVolume = 1.0
local gameOver = false
local gameWon = false
local youWinSprite
local gameOverSprite
local oldLondonFont
local oldLondonMedFont
local gothikSteelFont
local FiftiesMoviesFont
local xSprite
local plusSprite
local startVideo
local videoPlaying = false
local videoFailed = false
local canUseFish = true
local wallpapers = {}
local currentWallpaperIndex = 1

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



local trashSprite
local runSprite
local bgSprite

local btnTrash = {
    x = 20,
    y = 40,
    width = 80,
    height = 80,
    text = "X"
}

local btnRun = {
    x = 20,
    y = screenHeight / 2 - 140,
    width = 80,
    height = 80,
    text = "RUN"
}

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
local playerShield = 0
local healedThisTurn = false

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
        power_target = nil,
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

local function queue_sound(soundSrc, delay, pitch)
    local snd = soundSrc
    if type(soundSrc) == "table" then
        snd = soundSrc[math.random(#soundSrc)]
    end
    snd:setVolume(sfxVolume)
    table.insert(sounds, { sound = snd, delay = delay, pitch = pitch })
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

    if dealtCount == 0 and #deck.cards == 0 then
        gameWon = true
        return
    end

    if dealtCount == 1 then
        deal_new_cards(3)
        healedThisTurn = false
        canUseFish = true
    elseif dealtCount == 0 then
        deal_new_cards(4)
        healedThisTurn = false
        canUseFish = true
    end
end

local function reset_match()
    playerHP = 20
    playerShield = 0
    gameOver = false
    gameWon = false
    canUseFish = true
    healedThisTurn = false
    weaponKills = {}

    for _, slot in ipairs(slots) do slot.card = nil end
    if powerSlot then powerSlot.card = nil end
    if weaponSlot then weaponSlot.card = nil end

    cards = {}
    deck.cards = {}

    local deckBuilder = {}
    local suits = { "Spades", "Clubs", "Hearts", "Diamonds" }
    local suitToRow = { Hearts = 1, Spades = 2, Diamonds = 3, Clubs = 4 }

    for _, suit in ipairs(suits) do
        for rank = 1, 13 do
            local cardType
            local color
            local powerType = nil
            local powerTarget = nil
            local powerAmount = nil
            local itemType = nil
            local shieldTarget = nil

            if suit == "Spades" or suit == "Clubs" then
                cardType = "enemy"
                color = cardColors[4] -- Black
            else
                -- Hearts (Red) or Diamonds (Yellow)
                color = suit == "Diamonds" and cardColors[2] or cardColors[3]

                if rank == 13 then
                    cardType = "item"
                    itemType = suit == "Diamonds" and "kill" or "poison"
                elseif rank == 10 then
                    cardType = "shield"
                    shieldTarget = suit == "Diamonds" and "weapon" or "health"
                elseif rank == 11 then
                    cardType = "power"
                    powerType = "add"
                    powerAmount = 2
                    powerTarget = suit == "Diamonds" and "weapon" or "potion"
                elseif rank == 12 then
                    cardType = "power"
                    powerType = "double"
                    powerAmount = 1
                    powerTarget = suit == "Diamonds" and "weapon" or "potion"
                else
                    -- Ranks 1 to 9 (Cards 2 to 10)
                    cardType = suit == "Diamonds" and "weapon" or "potion"
                end
            end

            local card = new_card(color, cardType, suitToRow[suit], rank)
            card.value = rank + 1
            card.power_type = powerType
            card.power_target = powerTarget
            card.item_type = itemType
            card.shield_target = shieldTarget
            if powerAmount then card.power_amount = powerAmount end
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

    deal_new_cards(4)
end

local function effective_value(card)
    return card.value
end

local function take_damage(amount)
    if playerShield > 0 then
        if playerShield >= amount then
            playerShield = playerShield - amount
            amount = 0
        else
            amount = amount - playerShield
            playerShield = 0
        end
    end
    if amount > 0 then
        playerHP = math.max(0, playerHP - amount)
        if playerHP <= 0 then
            gameOver = true
        end
    end
end

local function kill_enemy_with_fists(enemy)
    take_damage(enemy.value)
    enemy.is_discarded = true
    enemy.is_dealt = false
    enemy.anim.punch = -0.2
    queue_sound(impactSounds, 0, 0.8)
end

local function kill_enemy_with_weapon(weapon, enemy)
    if weapon.last_killed_value and enemy.value > weapon.last_killed_value then
        queue_sound(dealSounds, 0, 0.5)
        return false
    end

    local effective = effective_value(weapon)
    if effective < enemy.value then
        local leftover = enemy.value - effective
        if weapon.weapon_shield and weapon.weapon_shield > 0 then
            if weapon.weapon_shield >= leftover then
                weapon.weapon_shield = weapon.weapon_shield - leftover
                leftover = 0
            else
                leftover = leftover - weapon.weapon_shield
                weapon.weapon_shield = 0
            end
        end
        if leftover > 0 then
            take_damage(leftover)
        end
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
    queue_sound(impactSounds, 0, 0.8)
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
    youWinSprite = love.graphics.newImage("assets/youwin.jpg")
    gameOverSprite = love.graphics.newImage("assets/gameover.jpg")
    local success, img = pcall(love.graphics.newImage, "assets/spritesheet.png")
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
        cardSprite = love.graphics.newImage("assets/card.png")
    end

    local successSettings, sImg = pcall(love.graphics.newImage, "assets/settings.png")
    if successSettings then
        settingsSprite = sImg
        settingsSprite:setFilter("nearest", "nearest")
    end

    local successTrash, tImg = pcall(love.graphics.newImage, "assets/trash.png")
    if successTrash then
        trashSprite = tImg
        trashSprite:setFilter("nearest", "nearest")
    end

    local successX, xImg = pcall(love.graphics.newImage, "assets/x.png")
    if successX then
        xSprite = xImg
        xSprite:setFilter("nearest", "nearest")
    end

    local successPlus, pImg = pcall(love.graphics.newImage, "assets/+.png")
    if successPlus then
        plusSprite = pImg
        plusSprite:setFilter("nearest", "nearest")
    end

    local successRun, rImg = pcall(love.graphics.newImage, "assets/fish.png")
    if successRun then
        runSprite = rImg
        runSprite:setFilter("nearest", "nearest")
    end

    local possible_bgs = {
        "assets/wallpaper.jpg",
        "assets/wallpaper1.jpg",
        "assets/wallpaper2.png",
        "assets/wallpaper3.jpg",
        "assets/wallpaper4.jpg",
        "assets/wallpaper5.jpg",
        "assets/wallpaper6.jpg",
        "assets/wallpaper7.jpg",
        "assets/wallpaper8.jpg"
    }
    for _, fname in ipairs(possible_bgs) do
        local successBg, bImg = pcall(love.graphics.newImage, fname)
        if successBg then
            bImg:setFilter("nearest", "nearest")
            table.insert(wallpapers, bImg)
        end
    end
    if #wallpapers > 0 then
        bgSprite = wallpapers[1]
        currentWallpaperIndex = 1
    end


    dealSounds = {
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Deck Deal - 1.ogg", "static"),
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Deck Deal - 2.ogg", "static")
    }

    local successVid, vid = pcall(love.graphics.newVideo, "start.ogv")
    if successVid then
        startVideo = vid
        startVideo:play()
        videoPlaying = true
    else
        videoPlaying = false
        videoFailed = true
    end
    shuffleSounds = {
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Deck Shuffle - 1.ogg", "static"),
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Deck Shuffle - 2.ogg", "static")
    }
    moveSounds = {
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Piece Move - 1.ogg", "static"),
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Piece Move - 2.ogg", "static")
    }
    impactSounds = {
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Piece Impact - 1.ogg", "static"),
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Piece Impact - 2.ogg", "static")
    }
    cardSound = dealSounds[1]
    crtShader = love.graphics.newShader("crt.glsl")
    canvas = love.graphics.newCanvas(screenWidth, screenHeight, { type = '2d', readable = true })
    defaultFont = love.graphics.getFont()
    largeFont = love.graphics.newFont(48)
    mediumFont = love.graphics.newFont(24)

    local successFifties, fFont = pcall(love.graphics.newFont, "fonts/Fifties Movies.ttf", 26)
    if successFifties then FiftiesMoviesFont = fFont else FiftiesMoviesFont = mediumFont end

    local successOld, oldFont = pcall(love.graphics.newFont, "fonts/OldLondon.ttf", 52)
    if successOld then oldLondonFont = oldFont else oldLondonFont = largeFont end

    local successOldMed, oldFontMed = pcall(love.graphics.newFont, "fonts/OldLondon.ttf", 32)
    if successOldMed then oldLondonMedFont = oldFontMed else oldLondonMedFont = mediumFont end

    local successGoth, gothFont = pcall(love.graphics.newFont, "fonts/Gothik Steel.ttf", 100)
    if successGoth then gothikSteelFont = gothFont else gothikSteelFont = largeFont end

    local successFont, fontData = pcall(love.graphics.newFont, "fonts/blackflag.ttf", 50)
    if not successFont then
        successFont, fontData = pcall(love.graphics.newFont, "fonts/BlackFlag.ttf", 50)
    end
    if not successFont then
        successFont, fontData = pcall(love.graphics.newFont, "fonts/blackflag.otf", 50)
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
            local powerTarget = nil
            local powerAmount = nil
            local itemType = nil
            local shieldTarget = nil

            if suit == "Spades" or suit == "Clubs" then
                cardType = "enemy"
                color = cardColors[4] -- Black
            else
                -- Hearts (Red) or Diamonds (Yellow)
                color = suit == "Diamonds" and cardColors[2] or cardColors[3]

                if rank == 13 then
                    cardType = "item"
                    itemType = suit == "Diamonds" and "kill" or "poison"
                elseif rank == 10 then
                    cardType = "shield"
                    shieldTarget = suit == "Diamonds" and "weapon" or "health"
                elseif rank == 11 then
                    cardType = "power"
                    powerType = "add"
                    powerAmount = 2
                    powerTarget = suit == "Diamonds" and "weapon" or "potion"
                elseif rank == 12 then
                    cardType = "power"
                    powerType = "double"
                    powerAmount = 1
                    powerTarget = suit == "Diamonds" and "weapon" or "potion"
                else
                    -- Ranks 1 to 9 (Cards 2 to 10)
                    cardType = suit == "Diamonds" and "weapon" or "potion"
                end
            end

            local card = new_card(color, cardType, suitToRow[suit], rank)
            card.value = rank + 1
            card.power_type = powerType
            card.power_target = powerTarget
            card.item_type = itemType
            card.shield_target = shieldTarget
            if powerAmount then card.power_amount = powerAmount end
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

    if videoPlaying and startVideo then
        local vw, vh = startVideo:getDimensions()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(startVideo, 0, 0, 0, screenWidth / vw, screenHeight / vh)
        love.graphics.setCanvas()

        love.graphics.setColor({ 1, 1, 1, 1 })
        crtShader:send('millis', love.timer.getTime() - startTime)
        love.graphics.setShader(crtShader)
        love.graphics.draw(canvas, globalOffsetX, globalOffsetY, 0, globalScaleX, globalScaleY)
        love.graphics.setShader()

        if tvFrameSprite then
            love.graphics.setColor(1, 1, 1, 1)
            local fw, fh = tvFrameSprite:getDimensions()
            love.graphics.draw(tvFrameSprite, 0, 0, 0, screenWidth / fw, screenHeight / fh)
        end
        return
    end

    love.graphics.clear(0.937, 0.945, 0.96, 1)

    if bgSprite then
        love.graphics.setColor(1, 1, 1, 1)
        local bw, bh = bgSprite:getDimensions()
        love.graphics.draw(bgSprite, 0, 0, 0, screenWidth / bw, screenHeight / bh)
    end

    -- Draw HP
    love.graphics.setFont(hpFont)
    love.graphics.setColor(1, 0.3, 0.3, 1)

    if playerShield > 0 then
        love.graphics.printf(playerHP, -80, 50, screenWidth, "center")
        love.graphics.setColor(0.5, 0.5, 0.5, 1)
        love.graphics.printf("S: " .. playerShield, 80, 50, screenWidth, "center")
    else
        love.graphics.printf(playerHP, 0, 50, screenWidth, "center")
    end

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
    local mx, my = love.mouse.getPosition()
    local isRunHover = canUseFish and not showSettings and mx > btnRun.x and mx < btnRun.x + btnRun.width and
        my > btnRun.y and my < btnRun.y + btnRun.height

    love.graphics.setColor(1, 1, 1, canUseFish and 1 or 0.3)
    if runSprite then
        local tw, th = runSprite:getDimensions()
        local baseScale = 80 / th
        local scale = isRunHover and (baseScale * 1.15) or baseScale
        local rot = 0
        if isRunHover then
            rot = math.sin(love.timer.getTime() * 6) * 0.15
        end
        love.graphics.draw(runSprite, btnRun.x + btnRun.width / 2, btnRun.y + btnRun.height / 2, rot, scale, scale, tw /
            2, th / 2)
    else
        love.graphics.setColor(0.8, 0.2, 0.2, 1)
        love.graphics.rectangle("fill", btnRun.x, btnRun.y, btnRun.width, btnRun.height, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(btnRun.text, btnRun.x, btnRun.y + 24, btnRun.width, "center")
    end

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
            if card.dragging then
                shadow_dist = 16
            elseif card.anim.scale > cardScale + 0.02 then
                shadow_dist = 10
            end
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
                if card.type == "item" then
                    local label = card.item_type == "kill" and "KILL" or "POISON"
                    love.graphics.setColor(0.1, 0.1, 0.1, card.anim.opacity)
                    love.graphics.printf(label, -63, -16, 126, "center")
                    love.graphics.setFont(defaultFont)
                    love.graphics.printf(label, -55, -82, 126, "left")
                elseif card.type == "shield" then
                    local label = "SHIELD 10"
                    love.graphics.setColor(0.1, 0.1, 0.1, card.anim.opacity)
                    love.graphics.printf(label, -63, -16, 126, "center")
                    love.graphics.setFont(defaultFont)
                    love.graphics.printf(label, -55, -82, 126, "left")
                elseif card.type == "power" then
                    if card.power_type == "add" then
                        local label = tostring(card.power_amount)
                        if plusSprite then
                            love.graphics.setColor(1, 1, 1, card.anim.opacity)
                            local sw, sh = plusSprite:getDimensions()
                            local scale = 140 / sh
                            love.graphics.draw(plusSprite, -45, -45, 0, scale, scale)
                            love.graphics.setColor(0.1, 0.1, 0.1, card.anim.opacity)
                            love.graphics.setFont(FiftiesMoviesFont)
                            love.graphics.printf(label, 20, -32, 100, "left")
                        else
                            love.graphics.setColor(0.1, 0.1, 0.1, card.anim.opacity)
                            love.graphics.printf("+" .. label, -63, -16, 126, "center")
                        end
                    elseif card.power_type == "double" then
                        local label = "2"
                        if xSprite then
                            love.graphics.setColor(1, 1, 1, card.anim.opacity)
                            local sw, sh = xSprite:getDimensions()
                            local scale = 140 / sh
                            love.graphics.draw(xSprite, -45, -45, 0, scale, scale)
                            love.graphics.setColor(0.1, 0.1, 0.1, card.anim.opacity)
                            love.graphics.setFont(FiftiesMoviesFont)
                            love.graphics.printf(label, 20, -32, 100, "left")
                        else
                            love.graphics.setColor(0.1, 0.1, 0.1, card.anim.opacity)
                            love.graphics.printf("x" .. label, -63, -16, 126, "center")
                        end
                    end
                    love.graphics.setFont(defaultFont)
                else
                    love.graphics.setColor(0.1, 0.1, 0.1, card.anim.opacity)
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

            local badges = {}
            if card.power_mult and card.power_mult > 0 then
                local pAmt = card.power_mult
                local c
                if pAmt == 1 then
                    c = { 0.1, 0.1, 0.1 }
                elseif pAmt == 2 then
                    c = { 1, 0.85, 0.2 }
                elseif pAmt == 3 then
                    c = { 1, 0.2, 0.2 }
                else
                    c = { 0.2, 0.5, 1 }
                end
                table.insert(badges, { type = "x", value = tostring(pAmt * 2), color = c })
            end
            if card.added_value and card.added_value > 0 then
                table.insert(badges, { type = "+", value = tostring(card.added_value), color = { 0.1, 0.1, 0.1 } })
            end
            if card.weapon_shield and card.weapon_shield > 0 then
                table.insert(badges,
                    { type = "text", text = "S:" .. tostring(card.weapon_shield), color = { 0.5, 0.5, 0.5 } })
            end

            if #badges > 0 then
                love.graphics.setFont(mediumFont)
                local start_y = -110
                for i, badge in ipairs(badges) do
                    local base_y = usingSpritesheet and (-cardSpriteH / 2 - 32) or start_y

                    local x_shift = 0
                    local y_shift = 0
                    if i == 2 then
                        x_shift = -40
                        y_shift = 45
                    elseif i == 3 then
                        x_shift = 40
                        y_shift = 45
                    end

                    local final_y = base_y + y_shift

                    if badge.type == "x" or badge.type == "+" then
                        local sprite = badge.type == "x" and xSprite or plusSprite
                        if sprite then
                            love.graphics.setColor(1, 1, 1, card.anim.opacity)
                            local sw, sh = sprite:getDimensions()
                            local scale = 60 / sh
                            love.graphics.draw(sprite, -38 + x_shift, final_y - 15, 0, scale, scale)
                            love.graphics.setColor(badge.color[1], badge.color[2], badge.color[3], card.anim.opacity)
                            love.graphics.setFont(FiftiesMoviesFont)
                            if i == 2 then
                                love.graphics.printf(badge.value, -125 + x_shift, final_y - 10, 100, "right")
                            else
                                love.graphics.printf(badge.value, 15 + x_shift, final_y - 10, 100, "left")
                            end
                            love.graphics.setFont(mediumFont)
                        else
                            love.graphics.setColor(badge.color[1], badge.color[2], badge.color[3], card.anim.opacity)
                            love.graphics.printf(badge.type .. badge.value, -63 + x_shift, final_y, 126, "center")
                        end
                    else
                        love.graphics.setColor(badge.color[1], badge.color[2], badge.color[3], card.anim.opacity)
                        love.graphics.printf(badge.text, -63 + x_shift, final_y, 126, "center")
                    end
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

        local pw, ph = 400, 460
        local px, py = screenWidth / 2 - pw / 2, screenHeight / 2 - ph / 2
        love.graphics.setColor(0.15, 0.15, 0.18, 1)
        love.graphics.rectangle("fill", px, py, pw, ph, 12, 12)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(oldLondonFont)
        love.graphics.printf("Settings", px, py + 15, pw, "center")

        love.graphics.setFont(oldLondonMedFont)
        love.graphics.printf("Select Difficulty:", px, py + 95, pw, "center")

        local difficulties = { "Easy", "Medium", "Hard" }
        for i, diff in ipairs(difficulties) do
            local bx = px + 40 + (i - 1) * 110
            local by = py + 140
            if currentDifficulty == diff then
                love.graphics.setColor(0.2, 0.8, 0.3, 1)
            else
                love.graphics.setColor(0.3, 0.3, 0.35, 1)
            end
            love.graphics.rectangle("fill", bx, by, 100, 50, 8, 8)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.printf(diff, bx, by + 12, 100, "center")
        end

        -- Draw volume controls
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(oldLondonMedFont)
        love.graphics.printf("SFX: " .. math.floor(sfxVolume * 100) .. "%", px + 90, py + 215, pw - 180, "center")
        love.graphics.setColor(0.3, 0.3, 0.35, 1)
        love.graphics.rectangle("fill", px + 40, py + 210, 40, 40, 5, 5)      -- SFX minus
        love.graphics.rectangle("fill", px + pw - 80, py + 210, 40, 40, 5, 5) -- SFX plus
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("-", px + 40, py + 215, 40, "center")
        love.graphics.printf("+", px + pw - 80, py + 215, 40, "center")

        love.graphics.printf("Music: " .. math.floor(musicVolume * 100) .. "%", px + 90, py + 275, pw - 180, "center")
        love.graphics.setColor(0.3, 0.3, 0.35, 1)
        love.graphics.rectangle("fill", px + 40, py + 270, 40, 40, 5, 5)      -- Music minus
        love.graphics.rectangle("fill", px + pw - 80, py + 270, 40, 40, 5, 5) -- Music plus
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("-", px + 40, py + 275, 40, "center")
        love.graphics.printf("+", px + pw - 80, py + 275, 40, "center")

        -- Draw wallpaper controls
        love.graphics.printf("Wallpaper: " .. currentWallpaperIndex, px + 90, py + 335, pw - 180, "center")
        love.graphics.setColor(0.3, 0.3, 0.35, 1)
        love.graphics.rectangle("fill", px + 40, py + 330, 40, 40, 5, 5)      -- WP prev
        love.graphics.rectangle("fill", px + pw - 80, py + 330, 40, 40, 5, 5) -- WP next
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("<", px + 40, py + 335, 40, "center")
        love.graphics.printf(">", px + pw - 80, py + 335, 40, "center")

        love.graphics.setColor(0.8, 0.3, 0.3, 1)
        love.graphics.rectangle("fill", px + pw / 2 - 75, py + 395, 150, 45, 8, 8)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Close", px + pw / 2 - 75, py + 395 + 10, 150, "center")
    end

    if gameOver or gameWon then
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

        if gameWon and youWinSprite then
            love.graphics.setColor(1, 1, 1, 1)
            local iw, ih = youWinSprite:getDimensions()
            love.graphics.draw(youWinSprite, screenWidth / 2 - iw / 2, screenHeight / 2 - ih / 2 - 50)
        elseif gameOver and gameOverSprite then
            love.graphics.setColor(1, 1, 1, 1)
            local iw, ih = gameOverSprite:getDimensions()
            love.graphics.draw(gameOverSprite, screenWidth / 2 - iw / 2, screenHeight / 2 - ih / 2 - 50)
        else
            local function drawBulgingText(text, font, yCenter, minScale, maxScale)
                love.graphics.setFont(font)
                local totalW = 0
                local chars = {}
                local unscaledW = font:getWidth(text)
                local currUnscaledX = -unscaledW / 2

                for i = 1, #text do
                    local char = text:sub(i, i)
                    local charW = font:getWidth(char)
                    local cx = currUnscaledX + charW / 2
                    local normalized = cx / (unscaledW / 2)

                    local bulge = 1 - (normalized * normalized)
                    local charScale = minScale + (maxScale - minScale) * bulge

                    table.insert(chars, {
                        char = char,
                        w = charW,
                        scale = charScale
                    })
                    totalW = totalW + charW * charScale
                    currUnscaledX = currUnscaledX + charW
                end

                local globalScale = 1.0
                local maxAllowedW = screenWidth - 100
                if totalW > maxAllowedW then
                    globalScale = maxAllowedW / totalW
                    totalW = totalW * globalScale
                end

                local currX = screenWidth / 2 - totalW / 2
                local baseline = font:getBaseline()
                local ascent = font:getAscent()
                local visualCenterY = baseline - (ascent / 2)

                for _, c in ipairs(chars) do
                    local finalScale = c.scale * globalScale
                    local scaledW = c.w * finalScale
                    love.graphics.print(c.char, currX + scaledW / 2, yCenter, 0, finalScale, finalScale, c.w / 2,
                        visualCenterY)
                    currX = currX + scaledW
                end
            end

            love.graphics.setColor(0.8, 0.1, 0.1, 1)
            drawBulgingText(gameWon and "YOU WIN" or "GAME OVER", gothikSteelFont or largeFont, screenHeight / 2 - 80,
                0.8, 1.3)
        end

        if not (gameWon and youWinSprite) then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.setFont(oldLondonMedFont or mediumFont)
            local yOffset = 80
            if gameWon and youWinSprite then
                yOffset = youWinSprite:getHeight() / 2 + 20
            elseif gameOver and gameOverSprite then
                yOffset = gameOverSprite:getHeight() / 2 + 20
            end
            love.graphics.printf("Click anywhere to restart", 0, screenHeight / 2 + yOffset, screenWidth, "center")
        end
    end

    love.graphics.setCanvas()
    love.graphics.setColor({ 1, 1, 1 })
    crtShader:send('millis', love.timer.getTime() - startTime)
    love.graphics.setShader(crtShader)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setShader()

    if tvFrameSprite then
        love.graphics.setColor(1, 1, 1, 1)
        local fw, fh = tvFrameSprite:getDimensions()
        love.graphics.draw(tvFrameSprite, 0, 0, 0, screenWidth / fw, screenHeight / fh)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if gameOver or gameWon then
        if button == 1 then
            reset_match()
        end
        return
    end

    local function free_slot(card_to_free)
        for _, slot in ipairs(slots) do
            if slot.card == card_to_free then
                slot.card = nil
                break
            end
        end
        if powerSlot.card == card_to_free then powerSlot.card = nil end
        if weaponSlot.card == card_to_free then
            weaponSlot.card = nil
            for _, stacked_enemy in ipairs(weaponKills) do
                stacked_enemy.is_stacked = false
                stacked_enemy.is_discarded = true
            end
            weaponKills = {}
        end
    end

    if button == 2 then
        for i = #cards, 1, -1 do
            local card = cards[i]
            if not card.is_discarded and not card.is_on_deck and card.type ~= "enemy" then
                if x > card.transform.x and x < card.transform.x + card.transform.width and
                    y > card.transform.y and y < card.transform.y + card.transform.height then
                    if card.is_dealt or card.is_slotted then
                        local was_dealt = card.is_dealt
                        card.is_slotted = false
                        card.is_dealt = false
                        card.is_selected = false
                        card.is_discarded = true
                        card.anim.punch = -0.3
                        card.target_transform.x = btnTrash.x + btnTrash.width / 2 - card.transform.width / 2
                        card.target_transform.y = btnTrash.y + btnTrash.height / 2 - card.transform.height / 2
                        queue_sound(dealSounds, 0, 0.8)
                        free_slot(card)
                        if was_dealt then
                            refill_session_if_needed()
                        end
                        return
                    end
                end
            end
        end
        return
    end

    if button ~= 1 then return end

    if showSettings then
        local pw, ph = 400, 460
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

        -- SFX Volume
        if x > px + 40 and x < px + 80 and y > py + 210 and y < py + 250 then
            sfxVolume = math.max(0, sfxVolume - 0.1)
            return
        end
        if x > px + pw - 80 and x < px + pw - 40 and y > py + 210 and y < py + 250 then
            sfxVolume = math.min(1, sfxVolume + 0.1)
            return
        end

        -- Music Volume
        if x > px + 40 and x < px + 80 and y > py + 270 and y < py + 310 then
            musicVolume = math.max(0, musicVolume - 0.1)
            return
        end
        if x > px + pw - 80 and x < px + pw - 40 and y > py + 270 and y < py + 310 then
            musicVolume = math.min(1, musicVolume + 0.1)
            return
        end

        -- Wallpaper
        if x > px + 40 and x < px + 80 and y > py + 330 and y < py + 370 then
            currentWallpaperIndex = currentWallpaperIndex - 1
            if currentWallpaperIndex < 1 then currentWallpaperIndex = #wallpapers end
            if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
            return
        end
        if x > px + pw - 80 and x < px + pw - 40 and y > py + 330 and y < py + 370 then
            currentWallpaperIndex = currentWallpaperIndex + 1
            if currentWallpaperIndex > #wallpapers then currentWallpaperIndex = 1 end
            if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
            return
        end

        -- Close button or outside click
        local cx, cy, cw, ch = px + pw / 2 - 75, py + 395, 150, 45
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
                queue_sound(dealSounds, 0, 0.5)
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
                queue_sound(dealSounds, 0, 0.8)

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

    -- Skip video on click
    if videoPlaying then
        if startVideo then startVideo:pause() end
        videoPlaying = false
        deal_new_cards(4)
        return
    end

    -- Settings button logic
    if x > btnSettings.x and x < btnSettings.x + btnSettings.width and
        y > btnSettings.y and y < btnSettings.y + btnSettings.height then
        showSettings = true
        return
    end

    -- Run button logic
    if canUseFish and x > btnRun.x and x < btnRun.x + btnRun.width and
        y > btnRun.y and y < btnRun.y + btnRun.height then
        local count = 1
        for _, card in ipairs(cards) do
            if card.is_dealt then
                queue_sound(dealSounds, count * 0.05, 1 + count * 0.2)
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

        healedThisTurn = false
        canUseFish = false
        deal_new_cards(4)
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
                queue_sound(dealSounds, 0, 1)
            else
                if #weaponKills > 0 then
                    queue_sound(dealSounds, 0, 0.5)
                    return
                end

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
                        queue_sound(dealSounds, 0, 1)
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
                    queue_sound(dealSounds, 0, 1)
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
            if weaponSlot.card == card_to_free then
                weaponSlot.card = nil
                for _, stacked_enemy in ipairs(weaponKills) do
                    stacked_enemy.is_stacked = false
                    stacked_enemy.is_discarded = true
                end
                weaponKills = {}
            end
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
                        if #weaponKills > 0 then
                            queue_sound(dealSounds, 0, 0.5)
                            return
                        end

                        generic_slot.card = moving_out
                        moving_out.target_transform.x = generic_slot.x
                        moving_out.target_transform.y = generic_slot.y

                        weaponSlot.card = moving_in
                        moving_in.target_transform.x = weaponSlot.x
                        moving_in.target_transform.y = weaponSlot.y

                        moving_in.is_selected = false
                        moving_out.is_selected = false
                        queue_sound(dealSounds, 0, 1)

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
            elseif selected_card.type == "power" and selected_card.power_type == "double" and (clicked_card.is_slotted or clicked_card.is_dealt) and clicked_card.type == selected_card.power_target then
                local pAmt = selected_card.power_amount or 1
                clicked_card.power_mult = (clicked_card.power_mult or 0) + pAmt
                clicked_card.value = clicked_card.value * (2 ^ pAmt)
                clicked_card.anim.punch = 0.4
                selected_card.is_discarded = true
                selected_card.is_slotted = false
                selected_card.is_selected = false
                free_slot(selected_card)
                queue_sound(dealSounds, 0, 1.5)
                return
            elseif selected_card.type == "power" and selected_card.power_type == "add" and (clicked_card.is_slotted or clicked_card.is_dealt) and clicked_card.type == selected_card.power_target then
                local pAmt = selected_card.power_amount or 2
                clicked_card.added_value = (clicked_card.added_value or 0) + pAmt
                clicked_card.value = clicked_card.value + pAmt
                clicked_card.anim.punch = 0.4
                selected_card.is_discarded = true
                selected_card.is_slotted = false
                selected_card.is_selected = false
                free_slot(selected_card)
                queue_sound(dealSounds, 0, 1.5)
                return
            elseif selected_card.type == "item" and selected_card.item_type == "kill" and (clicked_card.is_slotted or clicked_card.is_dealt) and clicked_card.type == "enemy" then
                clicked_card.is_discarded = true
                clicked_card.is_dealt = false
                clicked_card.anim.punch = -0.4
                selected_card.is_discarded = true
                selected_card.is_slotted = false
                selected_card.is_selected = false
                free_slot(selected_card)
                queue_sound(impactSounds, 0, 1.5)
                refill_session_if_needed()
                return
            elseif selected_card.type == "item" and selected_card.item_type == "poison" and (clicked_card.is_slotted or clicked_card.is_dealt) and clicked_card.type == "enemy" then
                clicked_card.value = math.ceil(clicked_card.value / 2)
                clicked_card.anim.punch = 0.4
                selected_card.is_discarded = true
                selected_card.is_slotted = false
                selected_card.is_selected = false
                free_slot(selected_card)
                queue_sound(dealSounds, 0, 1.5)
                return
            elseif selected_card.type == "shield" and selected_card.shield_target == "weapon" and clicked_card == weaponSlot.card then
                clicked_card.weapon_shield = (clicked_card.weapon_shield or 0) + 10
                clicked_card.anim.punch = 0.4
                selected_card.is_discarded = true
                selected_card.is_slotted = false
                selected_card.is_selected = false
                free_slot(selected_card)
                queue_sound(dealSounds, 0, 1.5)
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
            elseif clicked_card.type == "power" or clicked_card.type == "item" or clicked_card.type == "shield" then
                if not powerSlot.card then
                    powerSlot.card = clicked_card
                    clicked_card.is_dealt = false
                    clicked_card.is_slotted = true
                    clicked_card.anim.punch = 0.3
                    clicked_card.target_transform.x = powerSlot.x
                    clicked_card.target_transform.y = powerSlot.y
                    queue_sound(dealSounds, 0, 1)
                    refill_session_if_needed()
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
                            queue_sound(dealSounds, 0, 1)
                            refill_session_if_needed()
                            equipped = true
                            break
                        end
                    end
                    if not equipped then
                        if clicked_card.type == "shield" and clicked_card.shield_target == "health" then
                            playerShield = playerShield + 10
                            clicked_card.is_dealt = false
                            clicked_card.is_discarded = true
                            queue_sound(dealSounds, 0, 1.5)
                            refill_session_if_needed()
                        else
                            local was_selected = clicked_card.is_selected
                            for _, c in ipairs(cards) do c.is_selected = false end
                            clicked_card.is_selected = not was_selected
                            clicked_card.anim.punch = 0.15
                            queue_sound(dealSounds, 0, 1.2)
                        end
                    end
                end
            elseif clicked_card.type == "weapon" or clicked_card.type == "potion" then
                if clicked_card.type == "weapon" and not weaponSlot.card then
                    weaponSlot.card = clicked_card
                    clicked_card.is_dealt = false
                    clicked_card.is_slotted = true
                    clicked_card.anim.punch = 0.3
                    clicked_card.target_transform.x = weaponSlot.x
                    clicked_card.target_transform.y = weaponSlot.y
                    queue_sound(dealSounds, 0, 1)
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
                            queue_sound(dealSounds, 0, 1)
                            refill_session_if_needed()
                            equipped = true
                            break
                        end
                    end
                    if not equipped then
                        if clicked_card.type == "potion" then
                            if healedThisTurn then
                                queue_sound(dealSounds, 0, 0.5)
                            else
                                playerHP = math.min(maxHP, playerHP + effective_value(clicked_card))
                                clicked_card.is_dealt = false
                                clicked_card.is_discarded = true
                                queue_sound(dealSounds, 0, 1.5)
                                healedThisTurn = true
                                refill_session_if_needed()
                            end
                        else
                            local was_selected = clicked_card.is_selected
                            for _, c in ipairs(cards) do c.is_selected = false end
                            clicked_card.is_selected = not was_selected
                            clicked_card.anim.punch = 0.15
                            queue_sound(dealSounds, 0, 1.2)
                        end
                    end
                end
            end
        elseif clicked_card.is_slotted then
            if clicked_card.type == "potion" then
                if healedThisTurn then
                    queue_sound(dealSounds, 0, 0.5)
                else
                    playerHP = math.min(maxHP, playerHP + effective_value(clicked_card))
                    clicked_card.is_slotted = false
                    clicked_card.is_discarded = true
                    free_slot(clicked_card)
                    queue_sound(dealSounds, 0, 1.5)
                    healedThisTurn = true
                end
            elseif clicked_card.type == "shield" and clicked_card.shield_target == "health" then
                playerShield = playerShield + 10
                clicked_card.is_slotted = false
                clicked_card.is_discarded = true
                free_slot(clicked_card)
                queue_sound(dealSounds, 0, 1.5)
            else
                local was_selected = clicked_card.is_selected
                for _, c in ipairs(cards) do c.is_selected = false end
                clicked_card.is_selected = not was_selected
                clicked_card.anim.punch = 0.15
                queue_sound(dealSounds, 0, 1.2)
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
    if videoFailed then
        videoFailed = false
        deal_new_cards(4)
    end

    if videoPlaying and startVideo then
        if not startVideo:isPlaying() then
            videoPlaying = false
            deal_new_cards(4)
        end
        return
    end

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
            local dropSnd = dealSounds[math.random(#dealSounds)]
            dropSnd:setVolume(sfxVolume)
            love.audio.play(dropSnd)
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
