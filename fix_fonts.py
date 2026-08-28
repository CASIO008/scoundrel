import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# Define the load_fonts function to be placed before love.load
load_fonts_func = """
function load_fonts()
    local isZH = currentLang == "zh"
    local font_path = "fonts/Fifties Movies.ttf"
    local msyh_path = "c:/windows/fonts/msyh.ttc"
    
    local function load_or_fallback(path, fallback_path, size)
        local ok, font = pcall(love.graphics.newFont, path, size)
        if ok then return font end
        ok, font = pcall(love.graphics.newFont, fallback_path, size)
        if ok then return font end
        return love.graphics.newFont(size)
    end
    
    local f_path = isZH and msyh_path or font_path
    FiftiesMoviesFont = load_or_fallback(f_path, msyh_path, 26)
    largeRadialTitleFont = load_or_fallback(f_path, msyh_path, 30)
    largeRadialSubFont = load_or_fallback(f_path, msyh_path, 20)
    
    local old_path = isZH and msyh_path or "fonts/OldLondon.ttf"
    oldLondonFont = load_or_fallback(old_path, msyh_path, 52)
    oldLondonMedFont = load_or_fallback(old_path, msyh_path, 32)
    
    local goth_path = isZH and msyh_path or "fonts/Gothik Steel.ttf"
    gothikSteelFont = load_or_fallback(goth_path, msyh_path, 60)
    
    local term_path = isZH and msyh_path or ""
    terminalFont = load_or_fallback(term_path, msyh_path, 24)
    terminalSmallFont = load_or_fallback(term_path, msyh_path, 16)
    terminalLargeFont = load_or_fallback(term_path, msyh_path, 32)
    
    largeFont = load_or_fallback(msyh_path, msyh_path, 48)
    mediumFont = load_or_fallback(msyh_path, msyh_path, 24)
end

function love.load()"""

content = content.replace('function love.load()', load_fonts_func)

# Remove the old font loading logic from love.load and insert load_fonts() instead.
pattern = r'(defaultFont = love\.graphics\.getFont\(\)).*?(if successGoth then gothikSteelFont = gothFont else gothikSteelFont = largeFont end)'

replacement = r'\1\n    load_fonts()'

content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
