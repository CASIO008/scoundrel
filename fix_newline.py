import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace actual newlines within the "SELECT : UP DOWN KEY" string with \\n
content = re.sub(
    r'("SELECT : UP DOWN KEY)\n(SET    : RIGHT LEFT KEY)\n(END    : ACTION KEY")',
    r'\1\\n\2\\n\3',
    content
)

content = re.sub(
    r'("SELECIONAR : SETAS CIMA BAIXO)\n(AJUSTAR    : SETAS ESQUERDA DIREITA)\n(CONFIRMAR  : TECLA DE AÇÃO")',
    r'\1\\n\2\\n\3',
    content
)

content = re.sub(
    r'("选择 : 上下方向键)\n(设置 : 左右方向键)\n(确认 : 行动键")',
    r'\1\\n\2\\n\3',
    content
)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
