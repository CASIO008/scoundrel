import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

old_draw_rules = r'local function draw_rules\(\).*?end\n\nfunction love\.draw\(\)'

new_draw_rules = r'''local function draw_rules()
    love.graphics.clear(0.05, 0.05, 0.05)
    
    local marginX = screenWidth * 0.1
    
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.setFont(terminalLargeFont or largeFont)
    love.graphics.printf(t("rules_title"), 0, 40, screenWidth, "center")
    
    love.graphics.setFont(terminalFont or mediumFont)
    
    local cScale = cardScale * 0.6
    local drawW = cardWidth * cScale
    local drawH = cardHeight * cScale
    
    local startX = marginX
    local textX = startX + drawW + 20
    local textW = screenWidth - textX - marginX
    
    local y_gap = drawH + 20
    local currentY = 120
    
    if usingSpritesheet then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(cardSpritesheet, cardQuads[2][3], startX, currentY, 0, cScale, cScale, 0, 0)
    end
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.printf(t("rule_enemy") or "", textX, currentY + 10, textW, "left")
    currentY = currentY + y_gap
    
    if usingSpritesheet then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(cardSpritesheet, cardQuads[1][4], startX, currentY, 0, cScale, cScale, 0, 0)
    end
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.printf(t("rule_potion") or "", textX, currentY + 10, textW, "left")
    currentY = currentY + y_gap
    
    if usingSpritesheet then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(cardSpritesheet, cardQuads[3][7], startX, currentY, 0, cScale, cScale, 0, 0)
    end
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.printf(t("rule_weapon") or "", textX, currentY + 10, textW, "left")
    currentY = currentY + y_gap
    
    if usingSpritesheet then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(cardSpritesheet, cardQuads[1][11], startX, currentY, 0, cScale, cScale, 0, 0)
    end
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.printf(t("rule_special") or "", textX, currentY + 10, textW, "left")
    
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.printf(t("rules_exit"), 0, screenHeight - 40, screenWidth, "center")
end

function love.draw()'''

content = re.sub(old_draw_rules, new_draw_rules, content, flags=re.DOTALL)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
