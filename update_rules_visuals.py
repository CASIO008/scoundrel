import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

old_func = '''local function draw_rules()
    love.graphics.clear(0.05, 0.05, 0.05)
    
    local marginX = screenWidth * 0.1
    
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.setFont(terminalLargeFont or largeFont)
    love.graphics.printf(t("rules_title"), 0, 50, screenWidth, "center")
    
    love.graphics.setFont(terminalFont or mediumFont)
    love.graphics.printf(t("rules_text"), marginX, 150, screenWidth - marginX * 2, "left")
    
    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.printf(t("rules_exit"), 0, screenHeight - 60, screenWidth, "center")
end'''

new_func = '''local function draw_rules()
    love.graphics.clear(0.05, 0.05, 0.05)
    
    local marginX = screenWidth * 0.1
    
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.setFont(terminalLargeFont or largeFont)
    love.graphics.printf(t("rules_title"), 0, 40, screenWidth, "center")
    
    love.graphics.setFont(terminalFont or mediumFont)
    
    -- We can extract the rule text directly, or rely on the localized string.
    local rules_text = t("rules_text")
    love.graphics.printf(rules_text, marginX, 120, screenWidth - marginX * 2, "left")
    
    -- Draw example cards on the right side if usingSpritesheet is true
    if usingSpritesheet then
        love.graphics.setColor(1, 1, 1, 1)
        local rightX = screenWidth - marginX - cardWidth
        local startY = 150
        
        -- Enemy (Spades 4)
        love.graphics.draw(cardSpritesheet, cardQuads[2][3], rightX, startY, 0, cardScale, cardScale, 0, 0)
        
        -- Potion (Hearts 5)
        love.graphics.draw(cardSpritesheet, cardQuads[1][4], rightX - 60, startY + 120, 0, cardScale, cardScale, 0, 0)
        
        -- Weapon (Diamonds 8)
        love.graphics.draw(cardSpritesheet, cardQuads[3][7], rightX + 20, startY + 120, 0, cardScale, cardScale, 0, 0)
        
        -- Special (Queen of Hearts)
        love.graphics.draw(cardSpritesheet, cardQuads[1][11], rightX - 40, startY + 280, 0, cardScale, cardScale, 0, 0)
    end
    
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.printf(t("rules_exit"), 0, screenHeight - 40, screenWidth, "center")
end'''

content = content.replace(old_func, new_func)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
