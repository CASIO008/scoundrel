import sys

file_path = 'c:\\Users\\casio\\Desktop\\project\\privy\\main.lua'

new_content = """    pt = {
        menu_opt_how = "COMO JOGAR",
        rules_title = "-- MANUAL DO SISTEMA --",
        rule_enemy = "CARTAS PRETAS: Inimigos. Arraste p/ PUNHOS. Dano se sem escudo.",
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
                    { label = "BARALHO", desc = "Canto superior direito. Arraste cartas para a mão." },
                    { label = "SLOTS", desc = "Clique numa carta distribuída para equipá-la automaticamente (3 slots + poder + arma)." },
                    { label = "LIXO (X)", desc = "Descarte com o botão direito ou arrastando as cartas dos slots/mão até o lixo." },
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
        menu_opt_how = "如何游玩",
        rules_title = "-- 系统手册 --",
        rule_enemy = "黑卡：敌人。拖动到拳头。无护盾时受到伤害。",
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
                    { label = "牌堆", desc = "右上角。拖牌到手牌。" },
                    { label = "卡槽", desc = "点击已发出的牌自动装备（3 个物品槽 + 能量槽 + 武器槽）。" },
                    { label = "垃圾桶 (X)", desc = "右键或把卡牌拖到垃圾桶即可丢弃。" },
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
        controls = "选择 : 上下方向键\\n调整 : 左右方向键\\n确认 : 行动键",
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
"""

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Replace from line 169 to 408 (indices 168 to 407)
# But wait, let's make sure the lines match exactly what we want to replace
start_idx = 168
end_idx = 407

print("Replacing lines from index", start_idx, "to", end_idx)
print("Start line is:", lines[start_idx].strip())
print("End line is:", lines[end_idx].strip())

if lines[start_idx].strip() == "pt = {" and lines[end_idx].strip() == "}":
    new_lines = lines[:start_idx] + [new_content] + lines[end_idx+1:]
    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    print("Success")
else:
    print("Lines did not match perfectly!")
    
