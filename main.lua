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
local fistSprite
local knifeSprite
local spriteVisibleBounds = {}
local startVideo
local videoPlaying = false
local videoFailed = false
local canUseFish = true
local wallpapers = {}
local currentWallpaperIndex = 1

local gameState = "menu"
local hasPlayed = false
local savePath = "privy_save.lua"
local menuOptions = {
    "SET UP VISION",
    "BUILD THE BRAND",
    "CREATE THE LIFE",
    "INVEST IN YOURSELF",
    "STAY CONSISTENT",
    "LEAVE A LEGACY"
}
local menuSelection = 1
local bootProgress = 0
local bootTimer = 0
local terminalFont
local terminalSmallFont
local terminalLargeFont

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

    local dealtCount = 0
    local position = #deck.cards
    while dealtCount < count and position > 0 do
        local card = deck.cards[position]
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

local function refill_session_if_needed()
    local dealtCount = #get_dealt_cards()

    if dealtCount == 0 and #deck.cards == 0 then
        gameWon = true
        return
    end

    if dealtCount <= 1 then
        deal_new_cards(math.min(4 - dealtCount, #deck.cards))
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
    canUseFish = false
    enemy.anim.punch = -0.2
    queue_sound(impactSounds, 0, 0.8)
end

local function kill_enemy_with_weapon(weapon, enemy)
    local check_val = enemy.value
    if weapon.last_killed_value and check_val > weapon.last_killed_value then
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

    weapon.last_killed_value = check_val

    enemy.is_dealt = false
    canUseFish = false
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

local function sprite_visible_bounds(sprite, path, threshold)
    local data = love.image.newImageData(path)
    local w, h = data:getDimensions()
    local minX, minY, maxX, maxY = w, h, -1, -1
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r, g, b, a = data:getPixel(x, y)
            if a > threshold then
                if x < minX then minX = x end
                if x > maxX then maxX = x end
                if y < minY then minY = y end
                if y > maxY then maxY = y end
            end
        end
    end
    if maxX < 0 then return nil end
    return { x = minX, y = minY, w = maxX - minX + 1, h = maxY - minY + 1 }
end

local function open_enemy_popup(enemy)
    local weapon = weaponSlot.card
    local check_val = enemy.value
    local canWeapon = weapon ~= nil and
        (weapon.last_killed_value == nil or check_val <= weapon.last_killed_value)

    local radius = 200
    local cx = enemy.transform.x + enemy.transform.width / 2
    local cy = enemy.transform.y - radius + 60
    if cy < radius + 10 then
        cy = enemy.transform.y + enemy.transform.height + radius - 40
    end
    cx = math.max(radius + 10, math.min(cx, screenWidth - radius - 10))
    cy = math.max(radius + 10, math.min(cy, screenHeight - radius - 30))

    local function sprite_box(sprite, bx, by, targetSize)
        if not sprite then return nil end
        local sw, sh = sprite:getDimensions()
        local scale = targetSize / sh
        local vis = spriteVisibleBounds[sprite]
        local ox = (vis and vis.x or 0) * scale
        local oy = (vis and vis.y or 0) * scale
        local vw = (vis and vis.w or sw) * scale
        local vh = (vis and vis.h or sh) * scale
        return {
            x = bx - (sw * scale) / 2 + ox,
            y = by - (sh * scale) / 2 + oy,
            w = vw,
            h = vh,
        }
    end

    enemyPopup = {
        enemy = enemy,
        weapon = weapon,
        canWeapon = canWeapon,
        cx = cx,
        cy = cy,
        radius = radius,
        fistBox = sprite_box(fistSprite, cx - radius / 2, cy - 40, 80),
        weaponBox = sprite_box(knifeSprite, cx + radius / 2, cy - 60, 160),
    }
end

local function load_settings()
    if not love.filesystem.getInfo(savePath) then return end
    local data = love.filesystem.read(savePath)
    if not data then return end
    local chunk, err = loadstring(data)
    if not chunk then return end
    local env = {}
    setfenv(chunk, env)
    local ok = pcall(chunk)
    if not ok then return end
    if env.sfxVolume ~= nil then sfxVolume = env.sfxVolume end
    if env.musicVolume ~= nil then musicVolume = env.musicVolume end
    if env.currentDifficulty ~= nil then currentDifficulty = env.currentDifficulty end
    if env.currentWallpaperIndex ~= nil then currentWallpaperIndex = env.currentWallpaperIndex end
    if env.hasPlayed ~= nil then hasPlayed = env.hasPlayed end
end

local function save_settings()
    local lines = {
        "sfxVolume = " .. string.format("%.1f", sfxVolume),
        "musicVolume = " .. string.format("%.1f", musicVolume),
        "currentDifficulty = " .. string.format("%q", currentDifficulty),
        "currentWallpaperIndex = " .. tostring(currentWallpaperIndex),
        "hasPlayed = " .. tostring(hasPlayed),
    }
    love.filesystem.write(savePath, table.concat(lines, "\n"))
end

local function start_match()
    hasPlayed = true
    save_settings()
    gameState = "play"
    if startVideo then
        startVideo:play()
        videoPlaying = true
    else
        videoFailed = false
        deal_new_cards(4)
    end
end

function love.load()
    load_settings()
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

    local successFist, fImg = pcall(love.graphics.newImage, "assets/fist.png")
    if successFist then
        fistSprite = fImg
        fistSprite:setFilter("nearest", "nearest")
        spriteVisibleBounds[fistSprite] = sprite_visible_bounds(fistSprite, "assets/fist.png", 0.04)
    end

    local successKnife, kImg = pcall(love.graphics.newImage, "assets/knife.png")
    if successKnife then
        knifeSprite = kImg
        knifeSprite:setFilter("nearest", "nearest")
        spriteVisibleBounds[knifeSprite] = sprite_visible_bounds(knifeSprite, "assets/knife.png", 0.04)
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
        currentWallpaperIndex = math.max(1, math.min(#wallpapers, currentWallpaperIndex))
        bgSprite = wallpapers[currentWallpaperIndex]
    end


    dealSounds = {
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Deck Deal - 1.ogg", "static"),
        love.audio.newSource("Stereo/ogg/JDSherbert - Tabletop Games SFX Pack - Deck Deal - 2.ogg", "static")
    }

    local successVid, vid = pcall(love.graphics.newVideo, "start.ogv")
    if successVid then
        startVideo = vid
        videoPlaying = false
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
    terminalSmallFont = love.graphics.newFont(16)
    terminalFont = love.graphics.newFont(24)
    terminalLargeFont = love.graphics.newFont(32)

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

    if hasPlayed then
        start_match()
    end
end

local function handleMenuConfirm()
    if gameState == "play" and showSettings then
        if menuSelection == 1 then
            showSettings = false
        elseif menuSelection == 6 then
            showSettings = false
            reset_match()
            gameState = "menu"
            menuSelection = 1
        end
        return
    end
    if menuSelection == 1 then
        if gameState == "menu" then
            if hasPlayed then
                start_match()
            else
                gameState = "boot"
                bootProgress = 0
                bootTimer = 0
            end
        elseif gameState == "settings" then
            gameState = "play"
        end
    elseif menuSelection == 6 then
        if gameState == "menu" then
            love.event.quit()
        elseif gameState == "settings" then
            reset_match()
            gameState = "menu"
            menuSelection = 1
        end
    end
end

local function volume_bar(vol, width)
    local filled = math.floor(vol * width + 0.5)
    return "[" .. string.rep("|", filled) .. string.rep(" ", math.max(0, width - filled)) .. "]"
end

local function draw_menu_list()
    local marginX = screenWidth * 0.125

    local options = {}
    if gameState == "menu" then
        options[1] = "SET UP VISION"
        options[6] = "LEAVE A LEGACY"
    else
        options[1] = "RESUME"
        options[6] = "BACK TO MENU"
    end
    options[2] = "CREATE LEGACY: " .. currentDifficulty
    options[3] = "CONSISTENCY: " .. volume_bar(sfxVolume, 14) .. " " .. math.floor(sfxVolume * 100) .. "%"
    options[4] = "INVESTIMENT: " .. volume_bar(musicVolume, 14) .. " " .. math.floor(musicVolume * 100) .. "%"
    options[5] = "WALLPAPER: " .. tostring(currentWallpaperIndex)

    love.graphics.setFont(terminalFont or mediumFont)
    local startY = screenHeight * 0.3
    for i = 1, 6 do
        local option = options[i]
        local optionY = startY + (i - 1) * 35
        if i == menuSelection then
            local textW = terminalFont:getWidth(option)
            love.graphics.setColor(0.2, 0.9, 0.2, 1)
            love.graphics.rectangle("fill", marginX - 20, optionY - 5, textW + 40, 35)
            love.graphics.setColor(0, 0, 0, 1)
        else
            love.graphics.setColor(0.2, 0.9, 0.2, 1)
        end
        love.graphics.printf(option, marginX, optionY, screenWidth, "left")
    end

    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.setFont(terminalFont or mediumFont)
    love.graphics.printf("SELECT : UP DOWN KEY\nSET    : RIGHT LEFT KEY\nEND    : ACTION KEY", marginX,
        screenHeight - 150, screenWidth, "left")
end

local function draw_menu()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    local marginX = screenWidth * 0.125

    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.setColor(0.2, 0.9, 0.2, 1) -- Terminal green
    love.graphics.printf("NUE 2046", marginX, 30, 200, "left")
    love.graphics.printf(gameState == "menu" and "PLAY >" or "SETTINGS >", screenWidth - marginX - 200, 30, 200,
        "right")

    love.graphics.setFont(terminalLargeFont or largeFont)
    love.graphics.printf(gameState == "menu" and "-------- MENU --------" or "------ SETTINGS ------", 0, 110,
        screenWidth, "center")

    draw_menu_list()

    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.setColor(0.2, 0.9, 0.2, 0.8)
    love.graphics.printf("FOR THOSE BECOMING. || ||||| ||| |||| ||", marginX, screenHeight - 45, screenWidth / 2,
        "left")
    love.graphics.printf("35.0456 N, 85.3097 W", screenWidth / 2, screenHeight - 45, screenWidth / 2 - marginX,
        "right")
end

local function draw_boot()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    local g = { 0.2, 0.9, 0.2, 1 }
    local r = { 0.9, 0.2, 0.2, 1 }
    local w = { 1, 1, 1, 1 }

    local content = {}
    local function line(...) table.insert(content, { ... }) end

    line({ text = ">> ", color = g }, { text = "ROOT.ACCESS", color = r }, { text = " v1.0", color = w })
    line({ text = "I AM ", color = w }, { text = "NOT", color = r })
    line({ text = "A ", color = w }, { text = "USER", color = r })
    line({ text = "I AM ", color = w }, { text = "ADMIN", color = r })

    if bootProgress > 10 then
        line({ text = "> PRIVILEGE ESCALATION: ", color = g }, { text = "SUCCESS", color = w })
    else
        line()
    end

    local function barLine(label, maxProg, currentProg)
        local pct = math.min(maxProg, currentProg)
        local fillCount = math.floor((pct / 100) * 14)
        return {
            { text = label,                           color = w },
            { text = "[",                             color = w },
            { text = string.rep("|", fillCount),      color = g },
            { text = string.rep(" ", 14 - fillCount), color = w },
            { text = "]",                             color = w },
            { text = " " .. math.floor(pct) .. "%",   color = g },
        }
    end

    if bootProgress > 20 then
        table.insert(content, barLine("KERNEL CONTROL   ", 100, (bootProgress - 20) * 1.25))
    else
        line()
    end
    if bootProgress > 40 then
        table.insert(content, barLine("FIREWALL BYPASSED", 100, (bootProgress - 40) * 1.667))
    else
        line()
    end
    if bootProgress > 60 then
        table.insert(content, barLine("LOGS ERASED      ", 100, (bootProgress - 60) * 2.5))
    else
        line()
    end

    if bootProgress > 80 then
        line({ text = "NOTHING IS LOCKED", color = r })
    else
        line()
    end
    if bootProgress > 95 then
        line({ text = "NOTHING IS SAFE", color = r })
    else
        line()
    end

    love.graphics.setFont(terminalFont or mediumFont)
    local lineHeight = 35
    local marginX = screenWidth * 0.125
    local startY = math.max(40, (screenHeight - (#content * lineHeight)) / 2)
    for idx, segs in ipairs(content) do
        if #segs > 0 then
            local x = marginX
            for _, seg in ipairs(segs) do
                love.graphics.setColor(seg.color[1], seg.color[2], seg.color[3], 1)
                love.graphics.print(seg.text, x, startY + (idx - 1) * lineHeight)
                x = x + terminalFont:getWidth(seg.text)
            end
        end
    end
end

function love.draw()
    love.graphics.setCanvas(canvas)

    if gameState == "menu" then
        draw_menu()
    elseif gameState == "boot" then
        draw_boot()
    else
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
            love.graphics.printf(playerHP, -90, 50, screenWidth, "center")

            love.graphics.setFont(hpFont)
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
            love.graphics.printf(playerShield, 90, 50, screenWidth, "center")
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
            love.graphics.draw(runSprite, btnRun.x + btnRun.width / 2, btnRun.y + btnRun.height / 2, rot, scale, scale,
                tw /
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
            love.graphics.draw(settingsSprite, btnSettings.x + btnSettings.width / 2,
                btnSettings.y + btnSettings.height / 2,
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
                    love.graphics.draw(cardSpritesheet, cardQuads[card.suit_idx][card.rank], 0, 0, 0, 1, 1,
                        cardSpriteW / 2,
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
                    love.graphics.setFont(oldLondonMedFont or mediumFont)
                    love.graphics.setColor(1, 0.2, 0.2, card.anim.opacity)
                    local offset = usingSpritesheet and (cardSpriteH / 2 - 20) or 20
                    local x_offset = usingSpritesheet and -cardSpriteW / 2 or -63
                    local text_w = usingSpritesheet and cardSpriteW or 126
                    love.graphics.printf(tostring(card.last_killed_value), x_offset, offset - 5, text_w, "center")
                    love.graphics.setFont(defaultFont)
                end

                if card.weapon_shield and card.weapon_shield > 0 then
                    love.graphics.setFont(oldLondonMedFont or mediumFont)
                    love.graphics.setColor(0.5, 0.6, 0.9, card.anim.opacity)
                    local top_offset = usingSpritesheet and (-cardSpriteH / 2 + 5) or -82
                    local x_offset = usingSpritesheet and -cardSpriteW / 2 or -63
                    local text_w = usingSpritesheet and cardSpriteW or 126
                    love.graphics.printf(tostring(card.weapon_shield), x_offset, top_offset, text_w, "center")
                    love.graphics.setFont(defaultFont)
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

                if #badges > 0 then
                    love.graphics.setFont(mediumFont)
                    local start_y = -110
                    for i, badge in ipairs(badges) do
                        local base_y = usingSpritesheet and (-cardSpriteH / 2 - 32) or start_y

                        local x_shift = (i - 1) * -45
                        local y_shift = 0

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
                                love.graphics.printf(badge.value, 15 + x_shift, final_y - 10, 100, "left")
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
                        love.graphics.rectangle("line", -cardSpriteW / 2, -cardSpriteH / 2, cardSpriteW, cardSpriteH, 8,
                            8)
                    else
                        love.graphics.rectangle("line", -63, -88, 126, 176, 8, 8)
                    end
                    love.graphics.setLineWidth(1)
                end
                love.graphics.pop()
            end
        end

        -- Draw enemy kill popup (fists left / weapon right)
        if enemyPopup then
            local p = enemyPopup
            local mx, my = love.mouse.getPosition()
            local hoverLeft = p.fistBox ~= nil and
                mx > p.fistBox.x and mx < p.fistBox.x + p.fistBox.w and
                my > p.fistBox.y and my < p.fistBox.y + p.fistBox.h
            local hoverRight = p.weaponBox ~= nil and
                mx > p.weaponBox.x and mx < p.weaponBox.x + p.weaponBox.w and
                my > p.weaponBox.y and my < p.weaponBox.y + p.weaponBox.h
            local time = love.timer.getTime()

            local function textShadowed(text, x, y, w, align, cr, cg, cb, ca)
                love.graphics.setColor(0, 0, 0, 0.85 * (ca or 1))
                love.graphics.printf(text, x + 1, y + 1, w, align)
                love.graphics.setColor(cr, cg, cb, ca or 1)
                love.graphics.printf(text, x, y, w, align)
            end

            -- Fists side (left)
            if fistSprite then
                local fw, fh = fistSprite:getDimensions()
                local base = 80 / fh
                local scale = hoverLeft and (base * 1.3) or base
                local rot = hoverLeft and (math.sin(time * 6) * 0.15) or 0
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(fistSprite, p.cx - p.radius / 2, p.cy - 40, rot, scale, scale, fw / 2, fh / 2)
            end
            love.graphics.push()
            love.graphics.translate(p.cx - p.radius / 2, p.cy + 55)
            love.graphics.scale(1.15, 1.15)
            love.graphics.translate(-(p.cx - p.radius / 2), -(p.cy + 55))

            love.graphics.setFont(FiftiesMoviesFont)
            textShadowed("FISTS", p.cx - p.radius, p.cy + 35, p.radius, "center", 1, 1, 1, 1)
            love.graphics.setFont(defaultFont)
            local fist_dmg = p.enemy.value
            if playerShield > 0 then
                fist_dmg = math.max(0, fist_dmg - playerShield)
            end
            if fist_dmg > 0 then
                textShadowed("(-" .. tostring(fist_dmg) .. " HP)", p.cx - p.radius, p.cy + 72, p.radius, "center", 1, 1,
                    1, 1)
            else
                textShadowed("(Shielded)", p.cx - p.radius, p.cy + 72, p.radius, "center", 0.6, 1, 0.6, 1)
            end

            love.graphics.pop()

            -- Weapon side (right)
            if knifeSprite then
                local kw, kh = knifeSprite:getDimensions()
                local base = 160 / kh
                local scale = hoverRight and (base * 1.3) or base
                local rot = hoverRight and (math.sin(time * 6) * 0.15) or 0
                love.graphics.setColor(1, 1, 1, p.canWeapon and 1 or 0.35)
                love.graphics.draw(knifeSprite, p.cx + p.radius / 2, p.cy - 60, rot, scale, scale, kw / 2, kh / 2)
            end
            love.graphics.push()
            love.graphics.translate(p.cx + p.radius / 2, p.cy + 55)
            love.graphics.scale(1.15, 1.15)
            love.graphics.translate(-(p.cx + p.radius / 2), -(p.cy + 55))

            love.graphics.setFont(FiftiesMoviesFont)
            if p.canWeapon then
                textShadowed("WEAPON", p.cx, p.cy + 35, p.radius, "center", 0.5, 1, 0.6, 1)
            else
                textShadowed("WEAPON", p.cx, p.cy + 35, p.radius, "center", 1, 0.5, 0.5, 1)
            end
            love.graphics.setFont(defaultFont)
            if p.weapon then
                local effective = effective_value(p.weapon)
                local info = tostring(effective)
                if p.weapon.power_mult and p.weapon.power_mult > 0 then
                    info = info .. " (x" .. tostring(p.weapon.power_mult) .. ")"
                end
                if not p.canWeapon then
                    info = info .. " - chain"
                elseif effective < p.enemy.value then
                    local leftover = p.enemy.value - effective
                    if p.weapon.weapon_shield and p.weapon.weapon_shield > 0 then
                        leftover = math.max(0, leftover - p.weapon.weapon_shield)
                    end
                    local final_dmg = leftover
                    if playerShield > 0 then
                        final_dmg = math.max(0, final_dmg - playerShield)
                    end
                    if final_dmg > 0 then
                        info = info .. " - " .. tostring(final_dmg) .. " HP dmg"
                    else
                        info = info .. " - shielded"
                    end
                else
                    info = info .. " - kill"
                end
                textShadowed(info, p.cx, p.cy + 72, p.radius, "center", 1, 1, 1, 1)
            end

            love.graphics.pop()

            love.graphics.setFont(terminalSmallFont or mediumFont)
            textShadowed("click outside to cancel", 0, p.cy + p.radius + 25, screenWidth, "center", 1, 1, 1, 0.6)
            love.graphics.setFont(defaultFont)
        end

        -- Draw Settings popup
        if showSettings then
            love.graphics.setColor(0, 0, 0, 0.85)
            love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

            love.graphics.setFont(terminalLargeFont or largeFont)
            love.graphics.setColor(0.2, 0.9, 0.2, 1)
            love.graphics.printf("------ SETTINGS ------", 0, 110, screenWidth, "center")

            draw_menu_list()
        end

        if gameOver or gameWon then
            love.graphics.setColor(0, 0, 0, 0.85)
            love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

            if gameWon and youWinSprite then
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.setBlendMode("add", "premultiplied")
                local iw, ih = youWinSprite:getDimensions()
                love.graphics.draw(youWinSprite, screenWidth / 2 - iw / 2, screenHeight / 2 - ih / 2 - 50)
                love.graphics.setBlendMode("alpha")
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
    end -- end of play state branch

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
    if gameState ~= "play" then return end
    if gameOver or gameWon then
        if button == 1 then
            reset_match()
            deal_new_cards(4)
        end
        return
    end

    if showSettings then
        if button == 1 then
            if x > btnSettings.x and x < btnSettings.x + btnSettings.width and
                y > btnSettings.y and y < btnSettings.y + btnSettings.height then
                showSettings = false
            end
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





    -- Enemy kill popup logic
    if enemyPopup then
        local p = enemyPopup
        local hitFist = p.fistBox ~= nil and
            x > p.fistBox.x and x < p.fistBox.x + p.fistBox.w and
            y > p.fistBox.y and y < p.fistBox.y + p.fistBox.h
        local hitWeapon = p.weaponBox ~= nil and
            x > p.weaponBox.x and x < p.weaponBox.x + p.weaponBox.w and
            y > p.weaponBox.y and y < p.weaponBox.y + p.weaponBox.h
        if hitFist then
            kill_enemy_with_fists(p.enemy)
            enemyPopup = nil
            refill_session_if_needed()
            return
        elseif hitWeapon then
            if p.canWeapon then
                kill_enemy_with_weapon(p.weapon, p.enemy)
                enemyPopup = nil
                refill_session_if_needed()
            else
                queue_sound(dealSounds, 0, 0.5)
            end
            return
        else
            enemyPopup = nil
        end
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
                if clicked_card.is_dealt then canUseFish = false end
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
                if clicked_card.is_dealt then canUseFish = false end
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
                canUseFish = false
                if clicked_card.is_dealt then canUseFish = false end
                clicked_card.original_value = clicked_card.original_value or clicked_card.value
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
                    canUseFish = false
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
                            canUseFish = false
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
                    canUseFish = false
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
                            canUseFish = false
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
                                canUseFish = false
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

function love.keypressed(key)
    if gameState == "menu" or gameState == "settings" or (gameState == "play" and showSettings) then
        if key == "up" or key == "w" then
            menuSelection = menuSelection - 1
            if menuSelection < 1 then menuSelection = 6 end
        elseif key == "down" or key == "s" then
            menuSelection = menuSelection + 1
            if menuSelection > 6 then menuSelection = 1 end
        elseif key == "right" or key == "d" then
            if menuSelection == 2 then
                if currentDifficulty == "Easy" then
                    currentDifficulty = "Medium"
                elseif currentDifficulty == "Medium" then
                    currentDifficulty = "Hard"
                else
                    currentDifficulty = "Easy"
                end
            elseif menuSelection == 3 then
                sfxVolume = math.min(1.0, sfxVolume + 0.1)
            elseif menuSelection == 4 then
                musicVolume = math.min(1.0, musicVolume + 0.1)
            elseif menuSelection == 5 then
                currentWallpaperIndex = currentWallpaperIndex + 1
                if currentWallpaperIndex > #wallpapers then currentWallpaperIndex = 1 end
                if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
            elseif menuSelection == 1 or menuSelection == 6 then
                handleMenuConfirm()
            end
            save_settings()
        elseif key == "left" or key == "a" then
            if menuSelection == 2 then
                if currentDifficulty == "Easy" then
                    currentDifficulty = "Hard"
                elseif currentDifficulty == "Medium" then
                    currentDifficulty = "Easy"
                else
                    currentDifficulty = "Medium"
                end
            elseif menuSelection == 3 then
                sfxVolume = math.max(0.0, sfxVolume - 0.1)
            elseif menuSelection == 4 then
                musicVolume = math.max(0.0, musicVolume - 0.1)
            elseif menuSelection == 5 then
                currentWallpaperIndex = currentWallpaperIndex - 1
                if currentWallpaperIndex < 1 then currentWallpaperIndex = #wallpapers end
                if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
            end
            save_settings()
        elseif key == "return" or key == "space" then
            handleMenuConfirm()
        elseif key == "escape" then
            if gameState == "play" and showSettings then
                showSettings = false
            end
        end
    end
end

function love.update(delta_time)
    if gameState == "boot" then
        bootTimer = bootTimer + delta_time
        bootProgress = math.min(100, bootProgress + (delta_time * 25))
        if bootTimer > 5 then
            start_match()
        end
        return
    elseif gameState == "menu" then
        return
    end
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
    if gameState ~= "play" then return end
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

function love.quit()
    save_settings()
end
