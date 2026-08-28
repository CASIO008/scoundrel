import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# 11. Options & Volume
content = re.sub(
    r'(if menuSelection < 1 then menuSelection = 6 end)',
    r'\1\n            if sndOptions then sndOptions:play() end',
    content
)
content = re.sub(
    r'(if menuSelection > 6 then menuSelection = 1 end)',
    r'\1\n            if sndOptions then sndOptions:play() end',
    content
)

content = re.sub(
    r'(sfxVolume = math\.min\(1\.0, sfxVolume \+ 0\.1\))',
    r'\1\n                if sndVolume then sndVolume:play() end',
    content
)
content = re.sub(
    r'(musicVolume = math\.min\(1\.0, musicVolume \+ 0\.1\))',
    r'\1\n                if sndVolume then sndVolume:play() end',
    content
)
content = re.sub(
    r'(sfxVolume = math\.max\(0\.0, sfxVolume - 0\.1\))',
    r'\1\n                if sndVolume then sndVolume:play() end',
    content
)
content = re.sub(
    r'(musicVolume = math\.max\(0\.0, musicVolume - 0\.1\))',
    r'\1\n                if sndVolume then sndVolume:play() end',
    content
)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
