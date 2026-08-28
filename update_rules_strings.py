import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the big rules_text with granular ones for EN, PT, ZH

old_en = r'rules_text = "BLACK CARDS.*?(?=\n\s*rules_exit)'
new_en = r'''rule_enemy = "BLACK CARDS: Enemies. Drag to FISTS. Take dmg if unshielded.",
        rule_potion = "RED CARDS: Potions. Heal HP.",
        rule_weapon = "YELLOW CARDS: Weapons. Deal damage.",
        rule_special = "SPECIALS (J, Q, K, A): Shield, Add Power, Double Power, Special.",'''

content = re.sub(old_en, new_en, content, flags=re.DOTALL)


old_pt = r'rules_text = "CARTAS PRETAS.*?(?=\n\s*rules_exit)'
new_pt = r'''rule_enemy = "CARTAS PRETAS: Inimigos. Arraste p/ PUNHOS. Dano se sem escudo.",
        rule_potion = "CARTAS VERMELHAS: Pocoes. Curam PV.",
        rule_weapon = "CARTAS AMARELAS: Armas. Causam dano.",
        rule_special = "ESPECIAIS (J, Q, K, A): Escudo, +Poder, x2 Poder, Veneno/Morte.",'''

content = re.sub(old_pt, new_pt, content, flags=re.DOTALL)


old_zh = r'rules_text = "黑卡.*?(?=\n\s*rules_exit)'
new_zh = r'''rule_enemy = "黑卡: 敌人。拖到拳头。无护盾时受伤害。",
        rule_potion = "红卡: 药水。恢复生命值。",
        rule_weapon = "黄卡: 武器。造成伤害。",
        rule_special = "特殊卡 (J, Q, K, A): 护盾, +力量, x2力量, 毒药/击杀。",'''

content = re.sub(old_zh, new_zh, content, flags=re.DOTALL)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
