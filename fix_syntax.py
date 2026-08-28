import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# I will replace the newlines inside the quotes with \n.
# We can match `rules_text = "..."` where `...` spans multiple lines.
def fix_lua_string(m):
    # m.group(1) is everything inside the quotes
    s = m.group(1)
    s = s.replace('\n', '\\n')
    return f'rules_text = "{s}"'

content = re.sub(r'rules_text\s*=\s*"([^"]+)"', fix_lua_string, content)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
