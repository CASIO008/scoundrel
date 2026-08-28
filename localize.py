import re
import sys

def apply_translations():
    with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
        content = f.read()

    i18n_code = """
local currentLang = "pt"
local langs = {"en", "pt", "zh"}
local i18n = {
    en = {
        menu_opt1 = "SET UP VISION",
        menu_opt2 = "CREATE LEGACY: ",
        menu_opt3 = "CONSISTENCY: ",
        menu_opt4 = "INVESTMENT: ",
        menu_opt5 = "WALLPAPER: ",
        menu_opt6 = "LANGUAGE: EN",
        menu_opt7_menu = "LEAVE A LEGACY",
        menu_opt7_game = "BACK TO MENU",
        menu_opt1_game = "RESUME",
        controls = "SELECT : UP DOWN KEY\\nSET    : RIGHT LEFT KEY\\nEND    : ACTION KEY",
        diff_easy = "Easy",
        diff_medium = "Medium",
        diff_hard = "Hard",
        play = "PLAY >",
        settings = "SETTINGS >",
        menu_header = "-------- MENU --------",
        settings_header = "------ SETTINGS ------",
        fists = "FISTS",
        weapon = "WEAPON",
        shielded = "(Shielded)",
        hp_dmg = "(-%d HP)",
        chain = " - chain",
        dmg_suffix = " - %d HP dmg",
        shield_suffix = " - shielded",
        kill_suffix = " - kill",
        cancel = "click outside to cancel",
        you_win = "YOU WIN",
        game_over = "GAME OVER",
        restart = "click anywhere to restart",
        term_1 = "FOR THOSE BECOMING. || ||||| ||| |||| ||",
        term_2 = "35.0456 N, 85.3097 W",
        term_3 = ">> ",
        term_4 = "ROOT.ACCESS",
        term_5 = " v1.0",
        term_iam = "I AM ",
        term_not = "NOT",
        term_a = "A ",
        term_user = "USER",
        term_iam2 = "I AM ",
        term_admin = "ADMIN",
        term_priv = "> PRIVILEGE ESCALATION: ",
        term_succ = "SUCCESS",
        term_unlocked = "NOTHING IS LOCKED",
        term_unsafe = "NOTHING IS SAFE",
    },
    pt = {
        menu_opt1 = "DEFINIR VISÃO",
        menu_opt2 = "CRIAR LEGADO: ",
        menu_opt3 = "CONSISTÊNCIA: ",
        menu_opt4 = "INVESTIMENTO: ",
        menu_opt5 = "PAPEL DE PAREDE: ",
        menu_opt6 = "IDIOMA: PT",
        menu_opt7_menu = "DEIXAR UM LEGADO",
        menu_opt7_game = "VOLTAR AO MENU",
        menu_opt1_game = "CONTINUAR",
        controls = "SELECIONAR : SETAS CIMA BAIXO\\nAJUSTAR    : SETAS ESQUERDA DIREITA\\nCONFIRMAR  : TECLA DE AÇÃO",
        diff_easy = "Fácil",
        diff_medium = "Médio",
        diff_hard = "Difícil",
        play = "JOGAR >",
        settings = "CONFIGURAÇÕES >",
        menu_header = "-------- MENU --------",
        settings_header = "--- CONFIGURAÇÕES ---",
        fists = "PUNHOS",
        weapon = "ARMA",
        shielded = "(Protegido)",
        hp_dmg = "(-%d PV)",
        chain = " - combo",
        dmg_suffix = " - %d PV dano",
        shield_suffix = " - defendido",
        kill_suffix = " - abater",
        cancel = "clique fora para cancelar",
        you_win = "VITÓRIA",
        game_over = "FIM DE JOGO",
        restart = "clique novamente para uma nova partida",
        term_1 = "PARA AQUELES QUE SE TORNAM. || ||||| ||| |||| ||",
        term_2 = "35.0456 N, 85.3097 W",
        term_3 = ">> ",
        term_4 = "ACESSO.ROOT",
        term_5 = " v1.0",
        term_iam = "EU SOU ",
        term_not = "NÃO",
        term_a = "UM ",
        term_user = "USUÁRIO",
        term_iam2 = "EU SOU ",
        term_admin = "ADMIN",
        term_priv = "> ESCALAÇÃO DE PRIVILÉGIOS: ",
        term_succ = "SUCESSO",
        term_unlocked = "NADA ESTÁ TRANCADO",
        term_unsafe = "NADA ESTÁ SEGURO",
    },
    zh = {
        menu_opt1 = "设定愿景",
        menu_opt2 = "创造遗产: ",
        menu_opt3 = "一致性: ",
        menu_opt4 = "投资: ",
        menu_opt5 = "壁纸: ",
        menu_opt6 = "语言: 中文",
        menu_opt7_menu = "留下遗产",
        menu_opt7_game = "返回菜单",
        menu_opt1_game = "继续",
        controls = "选择 : 上下方向键\\n设置 : 左右方向键\\n确认 : 行动键",
        diff_easy = "简单",
        diff_medium = "中等",
        diff_hard = "困难",
        play = "开始游戏 >",
        settings = "设置 >",
        menu_header = "-------- 菜单 --------",
        settings_header = "-------- 设置 --------",
        fists = "拳头",
        weapon = "武器",
        shielded = "(已护盾)",
        hp_dmg = "(-%d 血量)",
        chain = " - 连击",
        dmg_suffix = " - %d 伤害",
        shield_suffix = " - 已护盾",
        kill_suffix = " - 击杀",
        cancel = "点击外部取消",
        you_win = "你赢了",
        game_over = "游戏结束",
        restart = "点击任意处重新开始",
        term_1 = "致那些正在蜕变的人。 || ||||| ||| |||| ||",
        term_2 = "北纬 35.0456, 西经 85.3097",
        term_3 = ">> ",
        term_4 = "根.权限",
        term_5 = " v1.0",
        term_iam = "我",
        term_not = "不是",
        term_a = "一个",
        term_user = "用户",
        term_iam2 = "我是",
        term_admin = "管理员",
        term_priv = "> 提权: ",
        term_succ = "成功",
        term_unlocked = "没有什么被锁住",
        term_unsafe = "没有什么安全",
    }
}

local function t(key)
    return i18n[currentLang][key] or key
end
"""
    # 1. Inject i18n variables after gameState
    content = re.sub(r'(local gameState = "menu")', r'\1\n' + i18n_code, content)

    # 2. Modify save/load system
    content = content.replace('save_data = {', 'save_data = {\n        lang = currentLang,')
    content = content.replace('sfxVolume = loaded.sfx or 1.0', 'sfxVolume = loaded.sfx or 1.0\n        currentLang = loaded.lang or "pt"')

    # 3. Create a function to load fonts dynamically based on currentLang
    font_injection = """
local function load_fonts()
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
"""
    # Replace the manual font loading in love.load
    content = re.sub(r'largeFont = love\.graphics\.newFont\(48\).*?local successGothik, gFont = pcall\(love\.graphics\.newFont, "fonts/Gothik Steel\.ttf", 60\)\n\s*if successGothik then gothikSteelFont = gFont else gothikSteelFont = largeFont end', font_injection + '\n    load_fonts()', content, flags=re.DOTALL)

    # 4. Modify draw_menu_list options
    menu_list_replacement = """
    local options = {}
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
"""
    content = re.sub(r'local options = \{\}.*?options\[5\] = "WALLPAPER: " \.\. tostring\(currentWallpaperIndex\)', menu_list_replacement, content, flags=re.DOTALL)

    # Change 6 to 7 in draw_menu_list loop
    content = re.sub(r'for i = 1, 6 do\n\s*local option = options\[i\]', r'for i = 1, 7 do\n        local option = options[i]', content)
    
    # Keypressed for 6 and 7
    content = re.sub(r'if menuSelection < 1 then menuSelection = 6 end', r'if menuSelection < 1 then menuSelection = 7 end', content)
    content = re.sub(r'if menuSelection > 6 then menuSelection = 1 end', r'if menuSelection > 7 then menuSelection = 1 end', content)
    
    # Keypressed interactions
    lang_cycle_logic = """
            elseif menuSelection == 6 then
                local idx = 1
                for i, l in ipairs(langs) do if l == currentLang then idx = i break end end
                if key == "right" or key == "d" then
                    idx = idx % #langs + 1
                else
                    idx = (idx - 2) % #langs + 1
                end
                currentLang = langs[idx]
                load_fonts()
                if sndVolume then sndVolume:clone():play() end
"""
    content = re.sub(r'elseif menuSelection == 5 then\n\s*if key == "right" or key == "d" then.*?currentWallpaperIndex = 1 end\n\s*end\n\s*if sndVolume then sndVolume:clone\(\):play\(\) end\n\s*end\n', 
                     r'elseif menuSelection == 5 then\n                if key == "right" or key == "d" then\n                    currentWallpaperIndex = currentWallpaperIndex + 1\n                    if currentWallpaperIndex > #wallpapers then currentWallpaperIndex = 1 end\n                else\n                    currentWallpaperIndex = currentWallpaperIndex - 1\n                    if currentWallpaperIndex < 1 then currentWallpaperIndex = #wallpapers end\n                end\n                if sndVolume then sndVolume:clone():play() end' + lang_cycle_logic, content, flags=re.DOTALL)

    # Keypressed return logic
    content = content.replace('elseif menuSelection == 6 then', 'elseif menuSelection == 7 then')
    
    # 5. Translate hardcoded strings
    content = content.replace('"SELECT : UP DOWN KEY\\nSET    : RIGHT LEFT KEY\\nEND    : ACTION KEY"', 't("controls")')
    content = content.replace('love.graphics.printf(gameState == "menu" and "PLAY >" or "SETTINGS >",', 'love.graphics.printf(gameState == "menu" and t("play") or t("settings"),')
    content = content.replace('love.graphics.printf(gameState == "menu" and "-------- MENU --------" or "------ SETTINGS ------",', 'love.graphics.printf(gameState == "menu" and t("menu_header") or t("settings_header"),')
    content = content.replace('"FOR THOSE BECOMING. || ||||| ||| |||| ||"', 't("term_1")')
    content = content.replace('"35.0456 N, 85.3097 W"', 't("term_2")')
    
    content = content.replace('{ text = ">> ", color = g }', '{ text = t("term_3"), color = g }')
    content = content.replace('{ text = "ROOT.ACCESS", color = r }', '{ text = t("term_4"), color = r }')
    content = content.replace('{ text = " v1.0", color = w }', '{ text = t("term_5"), color = w }')
    
    content = content.replace('line({ text = "I AM ", color = w }, { text = "NOT", color = r })', 'line({ text = t("term_iam"), color = w }, { text = t("term_not"), color = r })')
    content = content.replace('line({ text = "A ", color = w }, { text = "USER", color = r })', 'line({ text = t("term_a"), color = w }, { text = t("term_user"), color = r })')
    content = content.replace('line({ text = "I AM ", color = w }, { text = "ADMIN", color = r })', 'line({ text = t("term_iam2"), color = w }, { text = t("term_admin"), color = r })')
    
    content = content.replace('{ text = "> PRIVILEGE ESCALATION: ", color = g }', '{ text = t("term_priv"), color = g }')
    content = content.replace('{ text = "SUCCESS", color = w }', '{ text = t("term_succ"), color = w }')
    content = content.replace('"NOTHING IS LOCKED"', 't("term_unlocked")')
    content = content.replace('"NOTHING IS SAFE"', 't("term_unsafe")')

    content = content.replace('textShadowed("FISTS"', 'textShadowed(t("fists")')
    content = content.replace('textShadowed("(-" .. tostring(fist_dmg) .. " HP)"', 'textShadowed(string.format(t("hp_dmg"), fist_dmg)')
    content = content.replace('textShadowed("(Shielded)"', 'textShadowed(t("shielded")')
    
    content = content.replace('textShadowed("WEAPON"', 'textShadowed(t("weapon")')
    content = content.replace('info = info .. " - chain"', 'info = info .. t("chain")')
    content = content.replace('info = info .. " - " .. tostring(final_dmg) .. " HP dmg"', 'info = info .. string.format(t("dmg_suffix"), final_dmg)')
    content = content.replace('info = info .. " - shielded"', 'info = info .. t("shield_suffix")')
    content = content.replace('info = info .. " - kill"', 'info = info .. t("kill_suffix")')
    content = content.replace('textShadowed("click outside to cancel"', 'textShadowed(t("cancel")')
    
    content = content.replace('drawBulgingText(gameWon and "YOU WIN" or "GAME OVER",', 'drawBulgingText(gameWon and t("you_win") or t("game_over"),')
    content = content.replace('love.graphics.printf("clique novamente para uma nova partida"', 'love.graphics.printf(t("restart")')

    with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
        f.write(content)

if __name__ == "__main__":
    apply_translations()
