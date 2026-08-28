import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Revert push/pop scaling in radial menu and use a larger font
# We will define `largeRadialTitleFont` and `largeRadialSubFont` in love.load
font_loading = """
    local successFifties, fFont = pcall(love.graphics.newFont, "fonts/Fifties Movies.ttf", 26)
    local successOld, oldFont = pcall(love.graphics.newFont, "fonts/OldLondon.ttf", 52)
"""
large_fonts = """
    largeRadialTitleFont = love.graphics.newFont("fonts/Fifties Movies.ttf", 30)
    largeRadialSubFont = love.graphics.newFont(18)
"""
content = content.replace(font_loading, font_loading + large_fonts)

# Replace the FISTS radial text rendering to remove push/pop and use new fonts
fists_regex = r'(\s*)love\.graphics\.push\(\)\s*love\.graphics\.translate[^\n]*\n\s*love\.graphics\.scale[^\n]*\n\s*love\.graphics\.translate[^\n]*\n\s*love\.graphics\.setFont\(FiftiesMoviesFont\)(.*?)\n\s*love\.graphics\.pop\(\)'
def fists_sub(m):
    return m.group(1) + 'love.graphics.setFont(largeRadialTitleFont)' + m.group(2).replace('love.graphics.setFont(defaultFont)', 'love.graphics.setFont(largeRadialSubFont)')
content = re.sub(fists_regex, fists_sub, content, flags=re.DOTALL)

# Replace the WEAPON radial text rendering
weapon_regex = r'(\s*)love\.graphics\.push\(\)\s*love\.graphics\.translate[^\n]*\n\s*love\.graphics\.scale[^\n]*\n\s*love\.graphics\.translate[^\n]*\n\s*love\.graphics\.setFont\(FiftiesMoviesFont\)(.*?)\n\s*love\.graphics\.pop\(\)'
content = re.sub(weapon_regex, fists_sub, content, flags=re.DOTALL)


# 2. Fix the sndKillCard logic
# Remove from table.remove
content = re.sub(r'\s*if card\.type == "enemy" and card\.value >= 10 and sndKillCard then sndKillCard:clone\(\):play\(\) end\n(\s*table\.remove\(deck\.cards, position\))', r'\n\1', content)

# Add to kill_enemy_with_fists
kill_fists = r'(local function kill_enemy_with_fists\(enemy\)\n\s*take_damage\(enemy\.value\))'
content = re.sub(kill_fists, r'\1\n    if enemy.value >= 10 and sndKillCard then sndKillCard:clone():play() end', content)

# Add to kill_enemy_with_weapon
kill_weapon = r'(local function kill_enemy_with_weapon\(weapon, enemy\)\n\s*local check_val = enemy\.value\n\s*if weapon\.last_killed_value and check_val > weapon\.last_killed_value then\n\s*queue_sound\(dealSounds, 0, 0\.5\)\n\s*return false\n\s*end)'
content = re.sub(kill_weapon, r'\1\n\n    if enemy.value >= 10 and sndKillCard then sndKillCard:clone():play() end', content)


with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
