import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace EN
content = re.sub(r'(en\s*=\s*\{.*?menu_opt3\s*=\s*)"[^"]+"', r'\1"SOUND: "', content, flags=re.DOTALL)
content = re.sub(r'(en\s*=\s*\{.*?menu_opt4\s*=\s*)"[^"]+"', r'\1"MUSIC: "', content, flags=re.DOTALL)

# Replace PT
content = re.sub(r'(pt\s*=\s*\{.*?menu_opt3\s*=\s*)"[^"]+"', r'\1"EFEITOS: "', content, flags=re.DOTALL)
content = re.sub(r'(pt\s*=\s*\{.*?menu_opt4\s*=\s*)"[^"]+"', r'\1"MÚSICA: "', content, flags=re.DOTALL)

# Replace ZH
content = re.sub(r'(zh\s*=\s*\{.*?menu_opt3\s*=\s*)"[^"]+"', r'\1"音效: "', content, flags=re.DOTALL)
content = re.sub(r'(zh\s*=\s*\{.*?menu_opt4\s*=\s*)"[^"]+"', r'\1"音乐: "', content, flags=re.DOTALL)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
