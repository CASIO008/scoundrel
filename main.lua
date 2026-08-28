screenWidth = love.graphics.getWidth()
screenHeight = love.graphics.getHeight()
startTime = love.timer.getTime()

cardScale = 0.75
cardWidth = 126 * cardScale
cardHeight = 176 * cardScale
cardSpriteW, cardSpriteH = 126, 176

cardSprite = nil
cardSpritesheet = nil
cardQuads = {}
cardBackQuad = nil
usingSpritesheet = false
heartSprite = nil
cardSound = nil
crtShader = nil
sfxVolume = 1.0
musicVolume = 1.0
gameOver = false
gameWon = false
youWinSprite = nil
gameOverSprite = nil
oldLondonFont = nil
oldLondonMedFont = nil
gothikSteelFont = nil
FiftiesMoviesFont = nil
largeRadialTitleFont = nil
largeRadialSubFont = nil
xSprite = nil
plusSprite = nil
fistSprite = nil
knifeSprite = nil
spriteVisibleBounds = {}
startVideo = nil
videoPlaying = false
videoFailed = false
canUseFish = true
wallpapers = {}
currentWallpaperIndex = 1

gameState = "menu"
rulesScrollY = 0
rulesReturnTo = "menu"

currentLang = "pt"
langs = {"en", "pt", "zh"}
i18n = {
    en = {
        menu_opt_how = "HOW TO PLAY",
        rules_title = "-- SYSTEM MANUAL --",
        rule_enemy = "BLACK CARDS: Enemies. Click to attack with FISTS. Take dmg if unshielded.",
        rule_potion = "RED CARDS: Potions. Heal HP.",
        rule_weapon = "YELLOW CARDS: Weapons. Deal damage.",
        rule_special = "SPECIALS (J, Q, K, A): Shield, Add Power, Double Power, Special.",
        rules_exit = "PRESS ESC TO RETURN",
        rules_subtitle = "KNOW THE CARDS. CONTROL THE DECK.",
        rules_scroll = "SCROLL : MOUSE WHEEL / UP DOWN KEYS",
        rules_sections = {
            {
                title = "DIAMONDS - WEAPONS",
                items = {
                    { label = "2-10", desc = "Weapons deal damage equal to the card number." },
                    { label = "JACK (J)", desc = "Creates a 10-point shield on the equipped weapon." },
                    { label = "QUEEN (Q)", desc = "Adds +2 points to a weapon." },
                    { label = "KING (K)", desc = "Multiplies a weapon's points by x2." },
                    { label = "ACE (A)", desc = "Eliminates an enemy card of any value." },
                },
            },
            {
                title = "HEARTS - POTIONS",
                items = {
                    { label = "2-10", desc = "Potions heal HP equal to the card number." },
                    { label = "JACK (J)", desc = "Creates a 10-point shield over your HP." },
                    { label = "QUEEN (Q)", desc = "Adds +2 points to a potion." },
                    { label = "KING (K)", desc = "Multiplies a potion's points by x2." },
                    { label = "ACE (A)", desc = "Halves an enemy card's value." },
                },
            },
            {
                title = "SPADES & CLUBS - ENEMIES",
                items = {
                    { label = "2-10", desc = "Enemies attack equal to the card number." },
                    { label = "JACK (J)", desc = "Worth 11 attack." },
                    { label = "QUEEN (Q)", desc = "Worth 12 attack." },
                    { label = "KING (K)", desc = "Worth 13 attack." },
                    { label = "ACE (A)", desc = "Worth 14 attack." },
                },
            },
            {
                title = "GOAL & TURNS",
                items = {
                    { label = "WIN", desc = "Start with 20 HP and survive until the last turn." },
                    { label = "TURNS", desc = "Each turn has 4 cards. Advance by leaving only 1 card in hand." },
                    { label = "FISH", desc = "Skips the current turn. Acquiring or eliminating a card accepts the turn (fish blocked)." },
                    { label = "FISH LIMIT", desc = "The fish can only be used once every two turns." },
                },
            },
            {
                title = "COMBAT",
                items = {
                    { label = "FISTS", desc = "Without an equipped weapon you fight with fists: no option appears, only damage." },
                    { label = "RED LIMIT", desc = "The red number on a weapon is its limit: if weapon 10 kills a 12 unshielded, you take 2 damage and the limit becomes 12. The weapon only accepts enemies 12 and below." },
                },
            },
            {
                title = "INTERFACE",
                items = {
                    { label = "DECK", desc = "Top right corner. Click a deck card to discard it." },
                    { label = "SLOTS", desc = "Click a dealt card to equip it automatically (3 slots + power + weapon)." },
                    { label = "TRASH (X)", desc = "Discard with the right button or by selecting a card and clicking the trash." },
                    { label = "SETTINGS", desc = "Adjust difficulty, volumes, language and wallpaper." },
                },
            },
            {
                title = "DIFFICULTY",
                items = {
                    { label = "EASY", desc = "At most 2 enemies per hand." },
                    { label = "MEDIUM", desc = "At most 3 enemies per hand." },
                    { label = "HARD", desc = "At most 4 enemies per hand." },
                },
            },
        },
        menu_opt1 = "SET UP VISION",
        menu_opt2 = "CREATE LEGACY: ",
        menu_opt3 = "SOUND: ",
        menu_opt4 = "MUSIC: ",
        menu_opt5 = "WALLPAPER: ",
        menu_opt6 = "LANGUAGE: EN",
        menu_opt7_menu = "LEAVE A LEGACY",
        menu_opt7_game = "BACK TO MENU",
        menu_opt1_game = "RESUME",
        controls = "SELECT : UP DOWN KEY\nSET    : RIGHT LEFT KEY\nEND    : ACTION KEY",
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
        menu_opt_how = "COMO JOGAR",
        rules_title = "-- MANUAL DO SISTEMA --",
        rule_enemy = "CARTAS PRETAS: Inimigos. Clique p/ PUNHOS. Dano se sem escudo.",
        rule_potion = "CARTAS VERMELHAS: Pocoes. Curam PV.",
        rule_weapon = "CARTAS AMARELAS: Armas. Causam dano.",
        rule_special = "ESPECIAIS (J, Q, K, A): Escudo, +Poder, x2 Poder, Veneno/Morte.",
        rules_exit = "PRESSIONE ESC PARA VOLTAR",
        rules_subtitle = "CONHEÇA AS CARTAS. CONTROLE O BARALHO.",
        rules_scroll = "ROLAR : RODA DO MOUSE / SETAS CIMA BAIXO",
        rules_sections = {
            {
                title = "OUROS - ARMAS",
                items = {
                    { label = "2-10", desc = "Armas com dano igual ao número da carta." },
                    { label = "VALETE (J)", desc = "Cria um escudo de 10 pontos na arma equipada." },
                    { label = "DAMA (Q)", desc = "Adiciona +2 pontos a uma arma." },
                    { label = "REI (K)", desc = "Multiplica x2 os pontos de uma arma." },
                    { label = "ÁS (A)", desc = "Elimina uma carta inimiga de qualquer valor." },
                },
            },
            {
                title = "COPAS - POÇÕES",
                items = {
                    { label = "2-10", desc = "Poções que curam vida igual ao número da carta." },
                    { label = "VALETE (J)", desc = "Cria um escudo de 10 pontos sobre os pontos de vida." },
                    { label = "DAMA (Q)", desc = "Adiciona +2 pontos a uma poção." },
                    { label = "REI (K)", desc = "Multiplica x2 os pontos de uma poção." },
                    { label = "ÁS (A)", desc = "Reduz o valor de uma carta inimiga pela metade." },
                },
            },
            {
                title = "ESPADAS E PAUS - INIMIGOS",
                items = {
                    { label = "2-10", desc = "Inimigos com ataque igual ao número da carta." },
                    { label = "VALETE (J)", desc = "Vale 11 de ataque." },
                    { label = "DAMA (Q)", desc = "Vale 12 de ataque." },
                    { label = "REI (K)", desc = "Vale 13 de ataque." },
                    { label = "ÁS (A)", desc = "Vale 14 de ataque." },
                },
            },
            {
                title = "OBJETIVO E TURNOS",
                items = {
                    { label = "VITÓRIA", desc = "Comece com 20 PV e sobreviva até o último turno." },
                    { label = "TURNOS", desc = "Cada turno tem 4 cartas. Passe de turno deixando apenas 1 carta na mão." },
                    { label = "PEIXE", desc = "Pula o turno atual. Se adquiriu ou eliminou carta no turno, o turno foi aceito (peixe bloqueado)." },
                    { label = "LIMITE DO PEIXE", desc = "O peixe só pode ser usado uma vez a cada dois turnos." },
                },
            },
            {
                title = "COMBATE",
                items = {
                    { label = "PUNHOS", desc = "Sem arma equipada, você usa os punhos: nenhuma opção aparece, apenas o dano." },
                    { label = "LIMITE VERMELHO", desc = "O número vermelho na arma é seu limite: se a arma 10 matar um 12 sem escudo, você recebe 2 de dano e o limite vira 12. A arma só aceita inimigos de 12 para baixo." },
                },
            },
            {
                title = "INTERFACE",
                items = {
                    { label = "BARALHO", desc = "Canto superior direito. Clique numa carta do baralho para descartá-la." },
                    { label = "SLOTS", desc = "Clique numa carta distribuída para equipá-la automaticamente (3 slots + poder + arma)." },
                    { label = "LIXO (X)", desc = "Descarte com o botão direito ou selecione a carta e clique no lixo." },
                    { label = "CONFIGURAÇÕES", desc = "Ajuste dificuldade, volumes, idioma e papel de parede." },
                },
            },
            {
                title = "DIFICULDADE",
                items = {
                    { label = "FÁCIL", desc = "No máximo 2 inimigos por mão." },
                    { label = "MÉDIO", desc = "No máximo 3 inimigos por mão." },
                    { label = "DIFÍCIL", desc = "No máximo 4 inimigos por mão." },
                },
            },
        },
        menu_opt1 = "DEFINIR VISÃO",
        menu_opt2 = "CRIAR LEGADO: ",
        menu_opt3 = "EFEITOS: ",
        menu_opt4 = "MÚSICA: ",
        menu_opt5 = "PAPEL DE PAREDE: ",
        menu_opt6 = "IDIOMA: PT",
        menu_opt7_menu = "DEIXAR UM LEGADO",
        menu_opt7_game = "VOLTAR AO MENU",
        menu_opt1_game = "CONTINUAR",
        controls = "SELECIONAR : SETAS CIMA BAIXO\nAJUSTAR    : SETAS ESQUERDA DIREITA\nCONFIRMAR  : TECLA DE AÇÃO",
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
        menu_opt_how = "如何游玩",
        rules_title = "-- 系统手册 --",
        rule_enemy = "黑卡：敌人。点击以拳头攻击。无护盾时受到伤害。",
        rule_potion = "红卡：药水。恢复生命值。",
        rule_weapon = "黄卡：武器。造成伤害。",
        rule_special = "特殊卡 (J, Q, K, A)：护盾, +能力, x2能力, 毒药/秒杀。",
        rules_exit = "按 ESC 返回",
        rules_subtitle = "了解卡牌。控制牌组。",
        rules_scroll = "滚动 : 鼠标滚轮 / 上下方向键",
        rules_sections = {
            {
                title = "方块 - 武器",
                items = {
                    { label = "2-10", desc = "武器伤害等于卡面数字。" },
                    { label = "J (杰克)", desc = "为装备的武器创造 10 点护盾。" },
                    { label = "Q (王后)", desc = "为武器增加 +2 点。" },
                    { label = "K (国王)", desc = "将武器点数 x2。" },
                    { label = "A (王牌)", desc = "消灭任意数值的敌人卡牌。" },
                },
            },
            {
                title = "红心 - 药水",
                items = {
                    { label = "2-10", desc = "药水恢复生命值，等于卡面数字。" },
                    { label = "J (杰克)", desc = "为生命值创造 10 点护盾。" },
                    { label = "Q (王后)", desc = "为药水增加 +2 点。" },
                    { label = "K (国王)", desc = "将药水点数 x2。" },
                    { label = "A (王牌)", desc = "将敌人卡牌数值减半。" },
                },
            },
            {
                title = "黑桃与梅花 - 敌人",
                items = {
                    { label = "2-10", desc = "敌人攻击力等于卡面数字。" },
                    { label = "J (杰克)", desc = "攻击力 11。" },
                    { label = "Q (王后)", desc = "攻击力 12。" },
                    { label = "K (国王)", desc = "攻击力 13。" },
                    { label = "A (王牌)", desc = "攻击力 14。" },
                },
            },
            {
                title = "目标与回合",
                items = {
                    { label = "胜利", desc = "以 20 点生命值开局，存活到最后一回合。" },
                    { label = "回合", desc = "每回合 4 张牌。手牌只剩 1 张时进入下一回合。" },
                    { label = "鱼", desc = "跳过当前回合。若本回合已获得或消灭卡牌，则视为接受回合（鱼被锁定）。" },
                    { label = "鱼的限制", desc = "鱼每两个回合只能使用一次。" },
                },
            },
            {
                title = "战斗",
                items = {
                    { label = "拳头", desc = "没有装备武器时使用拳头：不会出现选项，只会受到伤害。" },
                    { label = "红色极限", desc = "武器下方的红色数字是它的极限：武器 10 无盾击杀 12 会受 2 点伤害，极限变为 12。武器只接受 12 及以下的敌人。" },
                },
            },
            {
                title = "界面",
                items = {
                    { label = "牌堆", desc = "右上角。点击牌堆中的卡牌可将其丢弃。" },
                    { label = "卡槽", desc = "点击已发出的牌自动装备（3 个物品槽 + 能量槽 + 武器槽）。" },
                    { label = "垃圾桶 (X)", desc = "右键，或选中卡牌后点击垃圾桶即可丢弃。" },
                    { label = "设置", desc = "调整难度、音量、语言和壁纸。" },
                },
            },
            {
                title = "难度",
                items = {
                    { label = "简单", desc = "每手最多 2 个敌人。" },
                    { label = "中等", desc = "每手最多 3 个敌人。" },
                    { label = "困难", desc = "每手最多 4 个敌人。" },
                },
            },
        },
        menu_opt1 = "设定视界",
        menu_opt2 = "创造遗产: ",
        menu_opt3 = "音效: ",
        menu_opt4 = "音乐: ",
        menu_opt5 = "壁纸: ",
        menu_opt6 = "语言: 中文",
        menu_opt7_menu = "留下遗产",
        menu_opt7_game = "返回菜单",
        menu_opt1_game = "继续",
        controls = "选择 : 上下方向键\n调整 : 左右方向键\n确认 : 行动键",
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
        term_4 = "ROOT.访问",
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

function t(key)
    return i18n[currentLang][key] or key
end

hasPlayed = false
savePath = "privy_save.lua"
menuOptions = {
    "SET UP VISION",
    "BUILD THE BRAND",
    "CREATE THE LIFE",
    "INVEST IN YOURSELF",
    "STAY CONSISTENT",
    "LEAVE A LEGACY"
}
menuSelection = 1
bootProgress = 0
bootTimer = 0
terminalFont = nil
terminalSmallFont = nil
terminalLargeFont = nil

canvas = nil
largeFont = nil
defaultFont = nil
mediumFont = nil
hpFont = nil

cardValues = {
    weapon = 5,
    power = 0,
    potion = 3,
    enemy = 7
}

cardScale = 0.75
cardWidth = 126 * cardScale
cardHeight = 176 * cardScale

deck = {
    cards = {},
    transform = {
        x = screenWidth - cardWidth - 20,
        y = 20,
        width = cardWidth,
        height = cardHeight,
    },
}



trashSprite = nil
runSprite = nil
bgSprite = nil

btnTrash = {
    x = 20,
    y = 40,
    width = 80,
    height = 80,
    text = "X"
}

btnRun = {
    x = 20,
    y = screenHeight / 2 - 140,
    width = 80,
    height = 80,
    text = "RUN"
}

currentDifficulty = "Medium"
showSettings = false
settingsSprite = nil

btnSettings = {
    x = 20,
    y = screenHeight / 2 - 40,
    width = 80,
    height = 80
}

cards = {}
sounds = {}

cardColors = {
    { 0.2,  0.5,  1,    1 }, -- Blue
    { 1,    0.9,  0.2,  1 }, -- Yellow
    { 1,    0.3,  0.3,  1 }, -- Red
    { 0.15, 0.15, 0.15, 1 }  -- Black
}

cardTypes = {
    "weapon",
    "power",
    "potion",
    "enemy"
}

playerHP = 20
maxHP = 20
playerShield = 0
healedThisTurn = false

slots = {}
powerSlot = {}
weaponSlot = {}
weaponKills = {}
maxSlots = 3
enemyPopup = nil

function align(deck)
    local deck_height = 10 / #deck.cards
    for position, card in ipairs(deck.cards) do
        card.target_transform.x = deck.transform.x - deck_height * (position - 1)
        card.target_transform.y = deck.transform.y + deck_height * (position - 1)
    end
end


function move(card, dt)
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

function new_card(color, cardType, suit_idx, rank)
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

function card_face_index(rank)
    if rank == 1 then return 13 end
    return rank - 1
end

function queue_sound(soundSrc, delay, pitch)
    local snd = soundSrc
    if type(soundSrc) == "table" then
        snd = soundSrc[math.random(#soundSrc)]
    end
    table.insert(sounds, { sound = snd, delay = delay, pitch = pitch })
end

function refresh_audio_volumes()
    for _, snd in ipairs({ sndFish, sndGameOver, sndHealing, sndKillCard, sndMoreEffect, sndShield, sndYouWin, sndOptions, sndVolume }) do
        if snd then snd:setVolume(sfxVolume) end
    end
    if sndMenu then sndMenu:setVolume(musicVolume) end
    if sndSecondScreen then sndSecondScreen:setVolume(musicVolume) end
    if musicCurrent then musicCurrent:setVolume(musicVolume) end
end

function get_dealt_cards()
    local dealt = {}
    for _, card in ipairs(cards) do
        if card.is_dealt then
            table.insert(dealt, card)
        end
    end
    return dealt
end

function max_enemies_per_turn()
    if currentDifficulty == "Easy" then
        return 2
    elseif currentDifficulty == "Hard" then
        return 4
    end
    return 3
end

function deal_new_cards(count)
    local currentDealt = get_dealt_cards()

    local spacing = 20
    local totalWidth = (4 * cardWidth) + (3 * spacing)
    local startX = (screenWidth - totalWidth) / 2
    local dealY = screenHeight / 2 - cardHeight / 2

    for i, card in ipairs(currentDealt) do
        card.target_transform.x = startX + (i - 1) * (cardWidth + spacing)
        card.target_transform.y = dealY
    end

    local maxEnemies = max_enemies_per_turn()
    local dealtCount = 0
    local enemiesDealt = 0
    local position = #deck.cards
    while dealtCount < count and position > 0 do
        local card = deck.cards[position]
        local canDeal = true

        if card.type == "enemy" and enemiesDealt >= maxEnemies then
            local nonEnemiesLeft = 0
            for i = 1, position - 1 do
                if deck.cards[i].type ~= "enemy" then
                    nonEnemiesLeft = nonEnemiesLeft + 1
                end
            end
            -- Exception: if the rest of the deck is all enemies, stop filling
            -- the hand so the cap is never exceeded (hand is dealt smaller).
            if nonEnemiesLeft == 0 then break end
            canDeal = false
        end

        if canDeal then
            card.is_on_deck = false
            card.is_dealt = true
            card.anim.punch = 0.2
            card.target_transform.x = startX + (#currentDealt + dealtCount) * (cardWidth + spacing)
            card.target_transform.y = dealY
            table.remove(deck.cards, position)
            dealtCount = dealtCount + 1
            if card.type == "enemy" then enemiesDealt = enemiesDealt + 1 end
            position = #deck.cards
        else
            position = position - 1
        end
    end

    if dealtCount > 0 then
        queue_sound(dealSounds, 0, 1)
    end
end

function refill_session_if_needed()
    local dealtCount = #get_dealt_cards()

    if dealtCount == 0 and #deck.cards == 0 then
        gameWon = true
                if sndYouWin then sndYouWin:clone():play() end
        return
    end

    if dealtCount <= 1 then
        deal_new_cards(math.min(4 - dealtCount, #deck.cards))
        healedThisTurn = false
        canUseFish = true
    end
end

function reset_match()
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

                if rank == 1 then
                    cardType = "item"
                    itemType = suit == "Diamonds" and "kill" or "poison"
                elseif rank == 11 then
                    cardType = "shield"
                    shieldTarget = suit == "Diamonds" and "weapon" or "health"
                elseif rank == 12 then
                    cardType = "power"
                    powerType = "add"
                    powerAmount = 2
                    powerTarget = suit == "Diamonds" and "weapon" or "potion"
                elseif rank == 13 then
                    cardType = "power"
                    powerType = "double"
                    powerAmount = 1
                    powerTarget = suit == "Diamonds" and "weapon" or "potion"
                else
                    -- Ranks 2 to 10
                    cardType = suit == "Diamonds" and "weapon" or "potion"
                end
            end

            local card = new_card(color, cardType, suitToRow[suit], rank)
            if cardType == "enemy" and rank == 1 then
                card.value = 14
            else
                card.value = rank
            end
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

function effective_value(card)
    return card.value
end

function take_damage(amount)
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
        if sndGameOver then sndGameOver:clone():play() end
        end
    end
end

function kill_enemy_with_fists(enemy)
    take_damage(enemy.value)
    if enemy.value >= 10 and sndKillCard then sndKillCard:clone():play() end
    enemy.is_discarded = true
    enemy.is_dealt = false
    canUseFish = false
    enemy.anim.punch = -0.2
    queue_sound(impactSounds, 0, 0.8)
end

function kill_enemy_with_weapon(weapon, enemy)
    local check_val = enemy.value
    if weapon.last_killed_value and check_val > weapon.last_killed_value then
        queue_sound(dealSounds, 0, 0.5)
        return false
    end

    if enemy.value >= 10 and sndKillCard then sndKillCard:clone():play() end

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

function sprite_visible_bounds(sprite, path, threshold)
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

function open_enemy_popup(enemy)
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

function load_settings()
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

function save_settings()
    local lines = {
        "sfxVolume = " .. string.format("%.1f", sfxVolume),
        "musicVolume = " .. string.format("%.1f", musicVolume),
        "currentDifficulty = " .. string.format("%q", currentDifficulty),
        "currentWallpaperIndex = " .. tostring(currentWallpaperIndex),
        "hasPlayed = " .. tostring(hasPlayed),
    }
    love.filesystem.write(savePath, table.concat(lines, "\n"))
end

function start_match()
    reset_match()
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


function load_fonts()
    local isZH = currentLang == "zh"
    local font_path = "fonts/Fifties Movies.ttf"
    local msyh_path = "fonts/msyh.ttc"
    
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

    local successKnife, kImg = pcall(love.graphics.newImage, "assets/sword.png")
    if successKnife then
        knifeSprite = kImg
        knifeSprite:setFilter("nearest", "nearest")
        spriteVisibleBounds[knifeSprite] = sprite_visible_bounds(knifeSprite, "assets/sword.png", 0.04)
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

    local function load_sound(path, mode)
        local ok, src = pcall(love.audio.newSource, path, mode)
        if ok then return src end
        return nil
    end

    sndFish = load_sound("fish.ogg", "static")
    sndGameOver = load_sound("game_over.ogg", "static")
    sndHealing = load_sound("healing_potion.ogg", "static")
    sndKillCard = load_sound("kill_card.ogg", "static")
    sndMenu = load_sound("menu_sound.ogg", "stream")
    if sndMenu then sndMenu:setLooping(true) end
    sndMoreEffect = load_sound("more_effect.ogg", "static")
    sndSecondScreen = load_sound("second_screen.ogg", "stream")
    if sndSecondScreen then sndSecondScreen:setLooping(true) end
    sndShield = load_sound("shield.ogg", "static")
    sndYouWin = load_sound("you_win.ogg", "static")
    sndOptions = load_sound("options.ogg", "static")
    sndVolume = load_sound("volume.ogg", "static")

    local musicFilenames = {
        "An Unbroken Thread of Awareness",
        "Ascent",
        "Everything Is Going to Be OK",
        "Friday Film Special",
        "Parasite",
        "Wave Decay",
        "You're Stronger Than You Think",
    }
    musicTracks = {}
    for _, name in ipairs(musicFilenames) do
        local trk = load_sound("soundtrack/" .. name .. ".ogg", "stream")
        if trk then
            trk:setLooping(false)
            table.insert(musicTracks, trk)
        end
    end
    musicCurrent = nil
    musicLastIndex = nil

    refresh_audio_volumes()

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
    load_fonts()

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

function handleMenuConfirm()
    if gameState == "play" and showSettings then
        if menuSelection == 1 then
            showSettings = false
        elseif menuSelection == 2 then
            gameState = "rules"
            showSettings = false
            rulesReturnTo = "play"
            rulesScrollY = 0
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
        rulesReturnTo = "menu"
        rulesScrollY = 0
    elseif menuSelection == 8 then
        if gameState == "menu" then
            love.event.quit()
        elseif gameState == "settings" then
            reset_match()
            gameState = "menu"
            menuSelection = 1
        end
    end
end

function volume_bar(vol, width)
    local filled = math.floor(vol * width + 0.5)
    return "[" .. string.rep("|", filled) .. string.rep(" ", math.max(0, width - filled)) .. "]"
end

function draw_menu_list()
    local marginX = screenWidth * 0.125

    
    local options = {}
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
    for i = 1, 8 do
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
    love.graphics.printf(t("controls"), marginX,
        screenHeight - 150, screenWidth, "left")
end

function draw_menu()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    local marginX = screenWidth * 0.125

    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.setColor(0.2, 0.9, 0.2, 1) -- Terminal green
    love.graphics.printf("NUE 2046", marginX, 30, 200, "left")
    love.graphics.printf(gameState == "menu" and t("play") or t("settings"), screenWidth - marginX - 200, 30, 200,
        "right")

    love.graphics.setFont(terminalLargeFont or largeFont)
    love.graphics.printf(gameState == "menu" and t("menu_header") or t("settings_header"), 0, 110,
        screenWidth, "center")

    draw_menu_list()

    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.setColor(0.2, 0.9, 0.2, 0.8)
    love.graphics.printf(t("term_1"), marginX, screenHeight - 45, screenWidth / 2,
        "left")
    love.graphics.printf(t("term_2"), screenWidth / 2, screenHeight - 45, screenWidth / 2 - marginX,
        "right")
end

function draw_boot()
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    local g = { 0.2, 0.9, 0.2, 1 }
    local r = { 0.9, 0.2, 0.2, 1 }
    local w = { 1, 1, 1, 1 }

    local content = {}
    local function line(...) table.insert(content, { ... }) end

    line({ text = t("term_3"), color = g }, { text = t("term_4"), color = r }, { text = t("term_5"), color = w })
    line({ text = t("term_iam"), color = w }, { text = t("term_not"), color = r })
    line({ text = t("term_a"), color = w }, { text = t("term_user"), color = r })
    line({ text = t("term_iam2"), color = w }, { text = t("term_admin"), color = r })

    if bootProgress > 10 then
        line({ text = t("term_priv"), color = g }, { text = t("term_succ"), color = w })
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
        line({ text = t("term_unlocked"), color = r })
    else
        line()
    end
    if bootProgress > 95 then
        line({ text = t("term_unsafe"), color = r })
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


rulesHeaderH = 96
rulesFooterH = 40

function exit_rules()
    rulesScrollY = 0
    if rulesReturnTo == "play" then
        showSettings = true
        menuSelection = 1
        gameState = "play"
    else
        gameState = "menu"
    end
end

function draw_rules()
    love.graphics.clear(0.05, 0.05, 0.05)

    local marginX = screenWidth * 0.08
    local contentW = screenWidth - marginX * 2
    local cScale = cardScale * 0.7
    local drawW = cardWidth * cScale
    local drawH = cardHeight * cScale
    local titleRowH = 40
    local panelPad = 12
    local itemGap = 10
    local textX = marginX + drawW + 16
    local textW = contentW - drawW - 16
    local labelFont = FiftiesMoviesFont or mediumFont
    local descFont = terminalFont or mediumFont
    local labelH = labelFont:getHeight() or 26
    local lineH = descFont:getHeight() or 28

    local sections = (i18n[currentLang] and i18n[currentLang].rules_sections) or {}

    local secItemSprites = {
        { cardQuads[3][1], cardQuads[3][10], cardQuads[3][11], cardQuads[3][12], cardQuads[3][13] },
        { cardQuads[1][1], cardQuads[1][10], cardQuads[1][11], cardQuads[1][12], cardQuads[1][13] },
        { cardQuads[2][1], cardQuads[2][10], cardQuads[2][11], cardQuads[2][12], cardQuads[2][13] },
        { cardBackQuad, cardBackQuad, "fish", cardBackQuad },
        { "fist", "12" },
        { cardBackQuad, cardBackQuad, "trash", cardBackQuad },
        { cardQuads[2][1], cardQuads[2][6], cardQuads[2][9] },
    }

    local function item_height(item)
        local a, b = descFont:getWrap(item.desc or "", textW)
        local lines = type(a) == "table" and a or b
        local descH = math.max(1, #lines) * lineH
        return math.max(drawH, labelH + 6 + descH + 10)
    end

    local function section_panel_h(sec)
        local h = panelPad + titleRowH
        for _, item in ipairs(sec.items) do
            h = h + item_height(item) + itemGap
        end
        return h + panelPad
    end

    local contentH = rulesHeaderH + 20
    for _, sec in ipairs(sections) do
        contentH = contentH + 10 + section_panel_h(sec)
    end

    local scrollAreaH = screenHeight - rulesHeaderH - rulesFooterH
    local maxScroll = math.max(0, contentH - scrollAreaH)
    rulesScrollY = math.max(0, math.min(rulesScrollY, maxScroll))

    -- Title (fixed)
    local title = t("rules_title")
    love.graphics.setFont(gothikSteelFont or largeFont)
    if love.graphics.getFont():getWidth(title) > screenWidth - 60 then
        love.graphics.setFont(largeRadialTitleFont or largeFont)
    end
    love.graphics.setColor(0.9, 0.2, 0.2, 1)
    love.graphics.printf(title, 0, 14, screenWidth, "center")

    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.setColor(0.2, 0.9, 0.2, 0.85)
    love.graphics.printf(t("rules_subtitle") or "", 0, 62, screenWidth, "center")

    -- Scrollbar
    if maxScroll > 0 then
        local barX = screenWidth - 8
        local barH = math.max(40, scrollAreaH * (scrollAreaH / contentH))
        local barY = rulesHeaderH + (scrollAreaH - barH) * (rulesScrollY / maxScroll)
        love.graphics.setColor(0.2, 0.9, 0.2, 0.9)
        love.graphics.rectangle("fill", barX, barY, 4, barH)
    end

    -- Scrollable content
    love.graphics.setScissor(0, rulesHeaderH, screenWidth, scrollAreaH)
    love.graphics.push()
    love.graphics.translate(0, -rulesScrollY)

    local y = rulesHeaderH + 20
    for idx, sec in ipairs(sections) do
        y = y + 10
        local panelH = section_panel_h(sec)

        love.graphics.setColor(0.08, 0.08, 0.08, 0.9)
        love.graphics.rectangle("fill", marginX - 12, y, contentW + 24, panelH, 8, 8)
        love.graphics.setColor(0.2, 0.9, 0.2, 0.4)
        love.graphics.setLineWidth(1)
        love.graphics.rectangle("line", marginX - 12, y, contentW + 24, panelH, 8, 8)

        love.graphics.setFont(largeRadialTitleFont or FiftiesMoviesFont or mediumFont)
        love.graphics.setColor(0.2, 0.9, 0.2, 1)
        love.graphics.printf(sec.title, marginX, y + 6, contentW, "left")

        local itemY = y + panelPad + titleRowH
        local sprites = secItemSprites[idx] or {}
        for i, item in ipairs(sec.items) do
            local ih = item_height(item)
            local iconH = math.min(drawH, 72)

            local function draw_icon_sprite(sprite)
                if not sprite then return end
                local sw, sh = sprite:getDimensions()
                local sc = iconH / sh
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(sprite, marginX + drawW / 2, itemY + ih / 2, 0, sc, sc, sw / 2, sh / 2)
            end

            local spec = sprites[i] or sprites[#sprites]
            if spec then
                if spec == "fist" then
                    draw_icon_sprite(fistSprite)
                elseif spec == "fish" then
                    draw_icon_sprite(runSprite)
                elseif spec == "trash" then
                    draw_icon_sprite(trashSprite)
                elseif spec == "12" then
                    if usingSpritesheet then
                        love.graphics.setColor(1, 1, 1, 1)
                        love.graphics.draw(cardSpritesheet, cardQuads[3][9], marginX, itemY + (ih - drawH) / 2, 0, cScale, cScale, 0, 0)
                    end
                    love.graphics.setFont(oldLondonMedFont or mediumFont)
                    love.graphics.setColor(1, 0.2, 0.2, 1)
                    love.graphics.printf("12", marginX, itemY + (ih - drawH) / 2 + drawH * 0.58, drawW, "center")
                    love.graphics.setFont(descFont)
                elseif usingSpritesheet then
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.draw(cardSpritesheet, spec, marginX, itemY + (ih - drawH) / 2, 0, cScale, cScale, 0, 0)
                end
            end

            love.graphics.setFont(labelFont)
            love.graphics.setColor(0.95, 0.95, 0.95, 1)
            love.graphics.printf(item.label, textX, itemY + 4, textW, "left")

            love.graphics.setFont(descFont)
            love.graphics.setColor(0.45, 0.9, 0.45, 1)
            love.graphics.printf(item.desc or "", textX, itemY + 4 + labelH + 6, textW, "left")

            itemY = itemY + ih + itemGap
        end

        y = y + panelH
    end

    love.graphics.pop()
    love.graphics.setScissor()

    -- Footer (fixed)
    love.graphics.setFont(terminalSmallFont or mediumFont)
    love.graphics.setColor(0.2, 0.9, 0.2, 1)
    local footer = t("rules_exit")
    if maxScroll > 0 then
        footer = footer .. "    |    " .. t("rules_scroll")
    end
    love.graphics.printf(footer, 0, screenHeight - rulesFooterH + 8, screenWidth, "center")
end

function love.draw()
    love.graphics.setCanvas(canvas)

    if gameState == "menu" then
        draw_menu()
    elseif gameState == "rules" then
        draw_rules()
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
                rot = math.sin(love.timer.getTime() * 6) * 0.15 -- balanÃƒÂ§ar levemente
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
                if card.anim.scale > cardScale + 0.02 then
                    shadow_dist = 10
                end
                love.graphics.setColor(0, 0, 0, 0.4 * card.anim.opacity)
                if usingSpritesheet then
                    love.graphics.draw(cardSpritesheet, cardQuads[card.suit_idx][card_face_index(card.rank)], 0, shadow_dist, 0, 1, 1,
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
                    love.graphics.draw(cardSpritesheet, cardQuads[card.suit_idx][card_face_index(card.rank)], 0, 0, 0, 1, 1,
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
            love.graphics.setFont(largeRadialTitleFont)
            textShadowed(t("fists"), p.cx - p.radius, p.cy + 35, p.radius, "center", 1, 1, 1, 1)
            love.graphics.setFont(largeRadialSubFont)
            local fist_dmg = p.enemy.value
            if playerShield > 0 then
                fist_dmg = math.max(0, fist_dmg - playerShield)
            end
            if fist_dmg > 0 then
                textShadowed(string.format(t("hp_dmg"), fist_dmg), p.cx - p.radius, p.cy + 72, p.radius, "center", 1, 1,
                    1, 1)
            else
                textShadowed(t("shielded"), p.cx - p.radius, p.cy + 72, p.radius, "center", 0.6, 1, 0.6, 1)
            end

            -- Weapon side (right)
            if knifeSprite then
                local kw, kh = knifeSprite:getDimensions()
                local base = 160 / kh
                local scale = hoverRight and (base * 1.3) or base
                local rot = hoverRight and (math.sin(time * 6) * 0.15) or 0
                love.graphics.setColor(1, 1, 1, p.canWeapon and 1 or 0.35)
                love.graphics.draw(knifeSprite, p.cx + p.radius / 2, p.cy - 60, rot, scale, scale, kw / 2, kh / 2)
            end
            love.graphics.setFont(largeRadialTitleFont)
            if p.canWeapon then
                textShadowed(t("weapon"), p.cx, p.cy + 35, p.radius, "center", 0.5, 1, 0.6, 1)
            else
                textShadowed(t("weapon"), p.cx, p.cy + 35, p.radius, "center", 1, 0.5, 0.5, 1)
            end
            love.graphics.setFont(largeRadialSubFont)
            if p.weapon then
                local effective = effective_value(p.weapon)
                local info = tostring(effective)
                if p.weapon.power_mult and p.weapon.power_mult > 0 then
                    info = info .. " (x" .. tostring(p.weapon.power_mult) .. ")"
                end
                if not p.canWeapon then
                    info = info .. t("chain")
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
                        info = info .. string.format(t("dmg_suffix"), final_dmg)
                    else
                        info = info .. t("shield_suffix")
                    end
                else
                    info = info .. t("kill_suffix")
                end
                textShadowed(info, p.cx, p.cy + 72, p.radius, "center", 1, 1, 1, 1)
            end

            love.graphics.setFont(terminalSmallFont or mediumFont)
            textShadowed(t("cancel"), 0, p.cy + p.radius + 25, screenWidth, "center", 1, 1, 1, 0.6)
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
                drawBulgingText(gameWon and t("you_win") or t("game_over"), gothikSteelFont or largeFont, screenHeight / 2 - 80,
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
                love.graphics.printf(t("restart"), 0, screenHeight / 2 + yOffset, screenWidth, "center")
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

function free_card_slot(card_to_free)
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

function handle_card_click(clicked_card)
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
            if sndMoreEffect then sndMoreEffect:play() end
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
            if sndMoreEffect then sndMoreEffect:play() end
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
            if sndShield then sndShield:play() end
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
                        if sndShield then sndShield:play() end
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
                            queue_sound(impactSounds, 0, 0.5)
                        else
                            playerHP = math.min(maxHP, playerHP + effective_value(clicked_card))
                            if sndHealing then sndHealing:clone():play() end
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
                queue_sound(impactSounds, 0, 0.5)
            else
                playerHP = math.min(maxHP, playerHP + effective_value(clicked_card))
                if sndHealing then sndHealing:clone():play() end
                clicked_card.is_slotted = false
                clicked_card.is_discarded = true
                free_slot(clicked_card)
                queue_sound(dealSounds, 0, 1.5)
                healedThisTurn = true
            end
        elseif clicked_card.type == "shield" and clicked_card.shield_target == "health" then
            playerShield = playerShield + 10
            if sndShield then sndShield:play() end
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
end

function love.mousepressed(x, y, button, istouch, presses)
    if gameState == "rules" then
        if button == 1 then
            exit_rules()
        end
        return
    end
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
        if sndFish then sndFish:play() end
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
        -- NOVA ADIÇÃO: Move a carta clicada para o final da tabela (topo da renderização)
        for i, c in ipairs(cards) do
            if c == clicked_card then
                table.remove(cards, i)
                table.insert(cards, clicked_card)
                break
            end
        end

        handle_card_click(clicked_card)
        return
    end

    for position = #deck.cards, 1, -1 do
        local card = deck.cards[position]
        if x > card.transform.x
            and x < card.transform.x + card.transform.width
            and y > card.transform.y
            and y < card.transform.y + card.transform.height
        then
            card.is_on_deck = false
            card.is_discarded = true
            card.anim.punch = -0.2
            card.target_transform.x = btnTrash.x + btnTrash.width / 2 - card.transform.width / 2
            card.target_transform.y = btnTrash.y + btnTrash.height / 2 - card.transform.height / 2
            queue_sound(dealSounds, 0, 0.8)
            table.remove(deck.cards, position)
            break
        end
    end
end

function love.keypressed(key)
    if gameState == "rules" then
        if key == "escape" or key == "return" or key == "space" then
            exit_rules()
        elseif key == "up" or key == "w" then
            rulesScrollY = rulesScrollY - 48
        elseif key == "down" or key == "s" then
            rulesScrollY = rulesScrollY + 48
        elseif key == "pageup" then
            rulesScrollY = rulesScrollY - screenHeight
        elseif key == "pagedown" then
            rulesScrollY = rulesScrollY + screenHeight
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
                refresh_audio_volumes()
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 5 then
                musicVolume = math.min(1.0, musicVolume + 0.1)
                refresh_audio_volumes()
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
                refresh_audio_volumes()
                if sndVolume then sndVolume:clone():play() end
            elseif menuSelection == 5 then
                musicVolume = math.max(0.0, musicVolume - 0.1)
                refresh_audio_volumes()
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
    end
end

function love.wheelmoved(x, y)
    if gameState == "rules" then
        rulesScrollY = rulesScrollY - y * 48
    end
end

function love.update(delta_time)
    if gameState == "menu" then
        if musicCurrent and musicCurrent:isPlaying() then musicCurrent:pause() end
        if sndSecondScreen and sndSecondScreen:isPlaying() then sndSecondScreen:pause() end
        if sndMenu and not sndMenu:isPlaying() then
            sndMenu:setVolume(musicVolume)
            sndMenu:play()
        end
        return
    elseif gameState == "boot" then
        if musicCurrent and musicCurrent:isPlaying() then musicCurrent:pause() end
        if sndMenu and sndMenu:isPlaying() then sndMenu:pause() end
        if sndSecondScreen and not sndSecondScreen:isPlaying() then
            sndSecondScreen:setVolume(musicVolume)
            sndSecondScreen:play()
        end
        bootTimer = bootTimer + delta_time
        bootProgress = math.min(100, bootProgress + (delta_time * 25))
        if bootTimer > 5 then
            start_match()
        end
        return
    elseif gameState == "rules" then
        return
    end
    if sndMenu and sndMenu:isPlaying() then sndMenu:pause() end
    if sndSecondScreen and sndSecondScreen:isPlaying() then sndSecondScreen:pause() end

    if (videoPlaying and startVideo) or gameOver or gameWon then
        if musicCurrent and musicCurrent:isPlaying() then musicCurrent:pause() end
    elseif #musicTracks > 0 and (not musicCurrent or not musicCurrent:isPlaying()) then
        local idx = math.random(#musicTracks)
        if #musicTracks > 1 then
            local guard = 0
            while idx == musicLastIndex and guard < 8 do
                idx = math.random(#musicTracks)
                guard = guard + 1
            end
        end
        musicLastIndex = idx
        musicCurrent = musicTracks[idx]
        musicCurrent:setVolume(musicVolume)
        musicCurrent:seek(0)
        musicCurrent:play()
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
            if is_hover then
                target_scale = cardScale * 1.1
            end
            target_rotation = wobble
        elseif card.is_on_deck then
            target_rotation = card.base_rotation + wobble
        end

        if is_hover then
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

        move(card, delta_time)
        align(deck)
    end

    for position, sound in ipairs(sounds) do
        if sound.delay <= 0 then
            sound.sound:setVolume(sfxVolume)
            sound.sound:setPitch(sound.pitch)
            love.audio.play(sound.sound)
            table.remove(sounds, position)
            sound.sound:setPitch(sound.pitch)
        else
            sound.delay = sound.delay - delta_time
        end
    end
end

function love.quit()
    save_settings()
end
