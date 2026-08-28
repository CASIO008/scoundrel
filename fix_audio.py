import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

static_sounds = [
    'sndFish',
    'sndGameOver',
    'sndHealing',
    'sndKillCard',
    'sndMoreEffect',
    'sndShield',
    'sndYouWin',
    'sndOptions',
    'sndVolume'
]

for snd in static_sounds:
    # Replace `if sndX then sndX:play() end` with `if sndX then sndX:clone():play() end`
    content = re.sub(
        rf'(if {snd} then {snd}):play\(\) end',
        r'\1:clone():play() end',
        content
    )

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
