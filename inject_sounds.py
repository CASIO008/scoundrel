import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Globals
globals_str = """
local sndFish
local sndGameOver
local sndHealing
local sndKillCard
local sndMenu
local sndMoreEffect
local sndSecondScreen
local sndShield
local sndYouWin
local sndOptions
local sndVolume
"""
content = re.sub(r'(local dealSounds = {.*?})', globals_str + r'\1', content, flags=re.DOTALL|re.MULTILINE)

# 2. Loading
load_str = """
    sndFish = pcall(love.audio.newSource, "fish.ogg", "static") and love.audio.newSource("fish.ogg", "static") or nil
    sndGameOver = pcall(love.audio.newSource, "game_over.ogg", "static") and love.audio.newSource("game_over.ogg", "static") or nil
    sndHealing = pcall(love.audio.newSource, "healing_potion.ogg", "static") and love.audio.newSource("healing_potion.ogg", "static") or nil
    sndKillCard = pcall(love.audio.newSource, "kill_card.ogg", "static") and love.audio.newSource("kill_card.ogg", "static") or nil
    sndMenu = pcall(love.audio.newSource, "menu_sound.ogg", "stream") and love.audio.newSource("menu_sound.ogg", "stream") or nil
    if sndMenu then sndMenu:setLooping(true) end
    sndMoreEffect = pcall(love.audio.newSource, "more_effect.ogg", "static") and love.audio.newSource("more_effect.ogg", "static") or nil
    sndSecondScreen = pcall(love.audio.newSource, "second_screen.ogg", "stream") and love.audio.newSource("second_screen.ogg", "stream") or nil
    if sndSecondScreen then sndSecondScreen:setLooping(true) end
    sndShield = pcall(love.audio.newSource, "shield.ogg", "static") and love.audio.newSource("shield.ogg", "static") or nil
    sndYouWin = pcall(love.audio.newSource, "you_win.ogg", "static") and love.audio.newSource("you_win.ogg", "static") or nil
    sndOptions = pcall(love.audio.newSource, "options.ogg", "static") and love.audio.newSource("options.ogg", "static") or nil
    sndVolume = pcall(love.audio.newSource, "volume.ogg", "static") and love.audio.newSource("volume.ogg", "static") or nil
"""
content = re.sub(r'(function love\.load\(\).*?)(local defaultFont)', r'\1' + load_str + r'\n    \2', content, flags=re.DOTALL)

# 3. Fish
content = re.sub(
    r'(if canUseFish and x > btnRun\.x and x < btnRun\.x \+ btnRun\.width and\n.*?y > btnRun\.y and y < btnRun\.y \+ btnRun\.height then\n)(\s*)(canUseFish = false)',
    r'\1\2if sndFish then sndFish:play() end\n\2\3',
    content, flags=re.DOTALL
)

# 4. GameOver
content = re.sub(
    r'(gameOver = true)',
    r'\1\n        if sndGameOver then sndGameOver:play() end',
    content
)

# 5. Healing
content = re.sub(
    r'(playerHP = math\.min\(maxHP, playerHP \+.*?\))',
    r'\1\n                if sndHealing then sndHealing:play() end',
    content
)

# 6. Kill Card
content = re.sub(
    r'(local final_dmg = leftover\n\s*if playerShield > 0 then\n\s*final_dmg = math\.max\(0, final_dmg - playerShield\)\n\s*end\n\s*if final_dmg > 0 then\n.*?\n\s*else\n\s*info = info \.\. " - shielded"\n\s*end\n\s*else\n\s*info = info \.\. " - kill"\n\s*end)',
    r'\1',
    content, flags=re.DOTALL
) # Just matching, but wait. We can just add the sound when enemy is actually removed.
content = re.sub(
    r'(table\.remove\(deck\.cards, position\))',
    r'if card.type == "enemy" and card.value >= 10 and sndKillCard then sndKillCard:play() end\n                        \1',
    content
)
content = re.sub(
    r'(p\.enemy\.is_dead = true)',
    r'\1\n                    if p.enemy.value >= 10 and sndKillCard then sndKillCard:play() end',
    content
)

# 7. Menu & Boot Sounds
update_sounds = """
    if gameState == "menu" then
        if sndMenu and not sndMenu:isPlaying() then sndMenu:play() end
    else
        if sndMenu and sndMenu:isPlaying() then sndMenu:pause() end
    end

    if gameState == "boot" then
        if sndSecondScreen and not sndSecondScreen:isPlaying() then sndSecondScreen:play() end
    else
        if sndSecondScreen and sndSecondScreen:isPlaying() then sndSecondScreen:pause() end
    end
"""
content = re.sub(
    r'(function love\.update\(dt\))',
    r'\1\n' + update_sounds,
    content
)

# 8. More Effect
content = re.sub(
    r'(target\.power_mult = \(target\.power_mult or 1\) \* card\.value)',
    r'\1\n            if sndMoreEffect then sndMoreEffect:play() end',
    content
)
content = re.sub(
    r'(target\.added_value = \(target\.added_value or 0\) \+ card\.value)',
    r'\1\n            if sndMoreEffect then sndMoreEffect:play() end',
    content
)

# 9. Shield
content = re.sub(
    r'(playerShield = playerShield \+ card\.value)',
    r'\1\n                    if sndShield then sndShield:play() end',
    content
)
content = re.sub(
    r'(target\.weapon_shield = \(target\.weapon_shield or 0\) \+ card\.value)',
    r'\1\n            if sndShield then sndShield:play() end',
    content
)

# 10. You Win
content = re.sub(
    r'(gameWon = true)',
    r'\1\n                if sndYouWin then sndYouWin:play() end',
    content
)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
