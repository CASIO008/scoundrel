import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the en dictionary replacements
content = content.replace('term_1 = t("term_1"),', 'term_1 = "FOR THOSE BECOMING. || ||||| ||| |||| ||",')
content = content.replace('term_2 = t("term_2"),', 'term_2 = "35.0456 N, 85.3097 W",')
content = content.replace('term_unlocked = t("term_unlocked"),', 'term_unlocked = "NOTHING IS LOCKED",')
content = content.replace('term_unsafe = t("term_unsafe"),', 'term_unsafe = "NOTHING IS SAFE",')

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
