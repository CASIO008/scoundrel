import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add global declarations for largeRadialTitleFont and largeRadialSubFont at the top
if 'local largeRadialTitleFont' not in content:
    content = content.replace('local FiftiesMoviesFont', 'local FiftiesMoviesFont\nlocal largeRadialTitleFont\nlocal largeRadialSubFont')

# 2. Replace the English text with Portuguese text
content = content.replace('"Click anywhere to restart"', '"clique novamente para uma nova partida"')

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
