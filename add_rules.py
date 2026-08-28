import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update i18n
en_rules = r'''
        menu_opt_how = "HOW TO PLAY",
        rules_title = "-- SYSTEM MANUAL --",
        rules_text = "BLACK CARDS (Spades/Clubs): Enemies.\nDrag to FISTS to attack. You take damage if not shielded.\n\nRED CARDS (Hearts): Potions. Heal HP.\nYELLOW CARDS (Diamonds): Weapons. Deal damage.\n\nSPECIAL CARDS:\nJ: Shield (Hearts = HP, Diamonds = Weapon)\nQ: +2 Power (Hearts = Potion, Diamonds = Weapon)\nK: x2 Power (Hearts = Potion, Diamonds = Weapon)\nA: Special (Hearts = Poison, Diamonds = Kill)",
        rules_exit = "PRESS ESC TO RETURN",'''

pt_rules = r'''
        menu_opt_how = "COMO JOGAR",
        rules_title = "-- MANUAL DO SISTEMA --",
        rules_text = "CARTAS PRETAS (Espadas/Paus): Inimigos.\nArraste para PUNHOS para atacar. Voce sofre dano se nao tiver escudo.\n\nCARTAS VERMELHAS (Copas): Pocoes. Curam Vida.\nCARTAS AMARELAS (Ouros): Armas. Causam dano.\n\nCARTAS ESPECIAIS:\nJ: Escudo (Copas = Vida, Ouros = Arma)\nQ: +2 Poder (Copas = Pocao, Ouros = Arma)\nK: x2 Poder (Copas = Pocao, Ouros = Arma)\nA: Especial (Copas = Veneno, Ouros = Morte)",
        rules_exit = "PRESSIONE ESC PARA VOLTAR",'''

zh_rules = r'''
        menu_opt_how = "如何游玩",
        rules_title = "-- 系统手册 --",
        rules_text = "黑卡 (黑桃/梅花): 敌人。\n拖动至“拳头”攻击。未受护盾保护将受伤害。\n\n红卡 (红桃): 药水。恢复生命值。\n黄卡 (方块): 武器。造成伤害。\n\n特殊卡牌:\nJ: 护盾 (红桃 = 生命, 方块 = 武器)\nQ: +2 力量 (红桃 = 药水, 方块 = 武器)\nK: x2 力量 (红桃 = 药水, 方块 = 武器)\nA: 专属 (红桃 = 毒药, 方块 = 击杀)",
        rules_exit = "按 ESC 返回",'''

content = re.sub(r'(en\s*=\s*\{)', r'\1' + en_rules, content)
content = re.sub(r'(pt\s*=\s*\{)', r'\1' + pt_rules, content)
content = re.sub(r'(zh\s*=\s*\{)', r'\1' + zh_rules, content)


# 2. Update draw_menu_list
old_menu_list = '''    local options = {}
    if gameState == "menu" then
        options[1] = t("menu_opt1")
        options[7] = t("menu_opt7_menu")
    else
        options[1] = t("menu_opt1_game")
        options[7] = t("menu_opt7_game")
    end
    
    local diffText = currentDifficulty
    if currentDifficulty == "Easy" then diffText = t("diff_easy")
    elseif currentDifficulty == "Medium" then diffText = t("diff_medium")
    elseif currentDifficulty == "Hard" then diffText = t("diff_hard") end

    options[2] = t("menu_opt2") .. diffText
    options[3] = t("menu_opt3") .. volume_bar(sfxVolume, 14) .. " " .. math.floor(sfxVolume * 100) .. "%"
    options[4] = t("menu_opt4") .. volume_bar(musicVolume, 14) .. " " .. math.floor(musicVolume * 100) .. "%"
    options[5] = t("menu_opt5") .. tostring(currentWallpaperIndex)
    options[6] = t("menu_opt6")


    love.graphics.setFont(terminalFont or mediumFont)
    local startY = screenHeight * 0.3
    for i = 1, 7 do'''

new_menu_list = '''    local options = {}
    if gameState == "menu" then
        options[1] = t("menu_opt1")
        options[8] = t("menu_opt7_menu")
    else
        options[1] = t("menu_opt1_game")
        options[8] = t("menu_opt7_game")
    end
    
    local diffText = currentDifficulty
    if currentDifficulty == "Easy" then diffText = t("diff_easy")
    elseif currentDifficulty == "Medium" then diffText = t("diff_medium")
    elseif currentDifficulty == "Hard" then diffText = t("diff_hard") end

    options[2] = t("menu_opt_how")
    options[3] = t("menu_opt2") .. diffText
    options[4] = t("menu_opt3") .. volume_bar(sfxVolume, 14) .. " " .. math.floor(sfxVolume * 100) .. "%"
    options[5] = t("menu_opt4") .. volume_bar(musicVolume, 14) .. " " .. math.floor(musicVolume * 100) .. "%"
    options[6] = t("menu_opt5") .. tostring(currentWallpaperIndex)
    options[7] = t("menu_opt6")


    love.graphics.setFont(terminalFont or mediumFont)
    local startY = screenHeight * 0.25
    for i = 1, 8 do'''
content = content.replace(old_menu_list, new_menu_list)

# 3. Handle Menu Confirm (options shift)
old_handle_confirm = '''local function handleMenuConfirm()
    if gameState == "play" and showSettings then
        if menuSelection == 1 then
            showSettings = false
        elseif menuSelection == 7 then
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
    elseif menuSelection == 7 then'''

new_handle_confirm = '''local function handleMenuConfirm()
    if gameState == "play" and showSettings then
        if menuSelection == 1 then
            showSettings = false
        elseif menuSelection == 2 then
            gameState = "rules"
            showSettings = false
        elseif menuSelection == 8 then
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
    elseif menuSelection == 2 then
        gameState = "rules"
    elseif menuSelection == 8 then'''
content = content.replace(old_handle_confirm, new_handle_confirm)

# 4. Draw Rules Function & inject love.draw
draw_rules_func = '''
local function draw_rules()
    love.graphics.clear(0.05, 0.05, 0.05)
    
    local marginX = screenWidth * 0.1
    
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.setFont(terminalLargeFont or largeFont)
    love.graphics.printf(t("rules_title"), 0, 50, screenWidth, "center")
    
    love.graphics.setFont(terminalFont or mediumFont)
    love.graphics.printf(t("rules_text"), marginX, 150, screenWidth - marginX * 2, "left")
    
    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.printf(t("rules_exit"), 0, screenHeight - 60, screenWidth, "center")
end

function love.draw()'''
content = content.replace("function love.draw()", draw_rules_func)

old_love_draw_state = '''    if gameState == "menu" then
        draw_menu()
    elseif gameState == "boot" then
        draw_boot()
    else'''

new_love_draw_state = '''    if gameState == "menu" then
        draw_menu()
    elseif gameState == "rules" then
        draw_rules()
    elseif gameState == "boot" then
        draw_boot()
    else'''
content = content.replace(old_love_draw_state, new_love_draw_state)

# 5. Keypressed options shift
old_keypressed = '''function love.keypressed(key)
    if gameState == "menu" or gameState == "settings" or (gameState == "play" and showSettings) then
        if key == "up" or key == "w" then
            menuSelection = menuSelection - 1
            if menuSelection < 1 then menuSelection = 7 end
            if sndOptions then sndOptions:clone():play() end
        elseif key == "down" or key == "s" then
            menuSelection = menuSelection + 1
            if menuSelection > 7 then menuSelection = 1 end
            if sndOptions then sndOptions:clone():play() end
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
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 4 then
                musicVolume = math.min(1.0, musicVolume + 0.1)
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 5 then
                currentWallpaperIndex = currentWallpaperIndex + 1
                if currentWallpaperIndex > #wallpapers then currentWallpaperIndex = 1 end
                if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
            elseif menuSelection == 6 then
                local idx = 1
                for i, l in ipairs(langs) do if l == currentLang then idx = i break end end
                idx = idx % #langs + 1
                currentLang = langs[idx]
                load_fonts()
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 1 or menuSelection == 7 then
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
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 4 then
                musicVolume = math.max(0.0, musicVolume - 0.1)
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 5 then
                currentWallpaperIndex = currentWallpaperIndex - 1
                if currentWallpaperIndex < 1 then currentWallpaperIndex = #wallpapers end
                if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
            elseif menuSelection == 6 then
                local idx = 1
                for i, l in ipairs(langs) do if l == currentLang then idx = i break end end
                idx = (idx - 2) % #langs + 1
                currentLang = langs[idx]
                load_fonts()
                if sndVolume then sndVolume:clone():play() end
            end
            save_settings()
        elseif key == "return" or key == "space" then
            handleMenuConfirm()
        elseif key == "escape" then
            if gameState == "play" and showSettings then
                showSettings = false
            end
        end
    end'''

new_keypressed = '''function love.keypressed(key)
    if gameState == "rules" then
        if key == "escape" or key == "return" or key == "space" then
            gameState = "menu"
            if hasPlayed then showSettings = true gameState = "play" end
        end
        return
    end

    if gameState == "menu" or gameState == "settings" or (gameState == "play" and showSettings) then
        if key == "up" or key == "w" then
            menuSelection = menuSelection - 1
            if menuSelection < 1 then menuSelection = 8 end
            if sndOptions then sndOptions:clone():play() end
        elseif key == "down" or key == "s" then
            menuSelection = menuSelection + 1
            if menuSelection > 8 then menuSelection = 1 end
            if sndOptions then sndOptions:clone():play() end
        elseif key == "right" or key == "d" then
            if menuSelection == 3 then
                if currentDifficulty == "Easy" then
                    currentDifficulty = "Medium"
                elseif currentDifficulty == "Medium" then
                    currentDifficulty = "Hard"
                else
                    currentDifficulty = "Easy"
                end
            elseif menuSelection == 4 then
                sfxVolume = math.min(1.0, sfxVolume + 0.1)
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 5 then
                musicVolume = math.min(1.0, musicVolume + 0.1)
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 6 then
                currentWallpaperIndex = currentWallpaperIndex + 1
                if currentWallpaperIndex > #wallpapers then currentWallpaperIndex = 1 end
                if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
            elseif menuSelection == 7 then
                local idx = 1
                for i, l in ipairs(langs) do if l == currentLang then idx = i break end end
                idx = idx % #langs + 1
                currentLang = langs[idx]
                load_fonts()
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 1 or menuSelection == 2 or menuSelection == 8 then
                handleMenuConfirm()
            end
            save_settings()
        elseif key == "left" or key == "a" then
            if menuSelection == 3 then
                if currentDifficulty == "Easy" then
                    currentDifficulty = "Hard"
                elseif currentDifficulty == "Medium" then
                    currentDifficulty = "Easy"
                else
                    currentDifficulty = "Medium"
                end
            elseif menuSelection == 4 then
                sfxVolume = math.max(0.0, sfxVolume - 0.1)
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 5 then
                musicVolume = math.max(0.0, musicVolume - 0.1)
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 6 then
                currentWallpaperIndex = currentWallpaperIndex - 1
                if currentWallpaperIndex < 1 then currentWallpaperIndex = #wallpapers end
                if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
            elseif menuSelection == 7 then
                local idx = 1
                for i, l in ipairs(langs) do if l == currentLang then idx = i break end end
                idx = (idx - 2) % #langs + 1
                currentLang = langs[idx]
                load_fonts()
                if sndVolume then sndVolume:clone():play() end
            end
            save_settings()
        elseif key == "return" or key == "space" then
            handleMenuConfirm()
        elseif key == "escape" then
            if gameState == "play" and showSettings then
                showSettings = false
            end
        end
    end'''
content = content.replace(old_keypressed, new_keypressed)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
