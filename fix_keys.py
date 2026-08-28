import re

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update right key logic
right_old = """              elseif menuSelection == 5 then
                  currentWallpaperIndex = currentWallpaperIndex + 1
                  if currentWallpaperIndex > #wallpapers then currentWallpaperIndex = 1 end
                  if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
              elseif menuSelection == 1 or menuSelection == 6 then
                  handleMenuConfirm()
              end"""

right_new = """              elseif menuSelection == 5 then
                  currentWallpaperIndex = currentWallpaperIndex + 1
                  if currentWallpaperIndex > #wallpapers then currentWallpaperIndex = 1 end
                  if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
              elseif menuSelection == 6 then
                  local idx = 1
                  for i, l in ipairs(langs) do if l == currentLang then idx = i break end end
                  idx = idx % #langs + 1
                  currentLang = langs[idx]
                  load_fonts()
                  if sndVolume then sndVolume:clone():play() end
              elseif menuSelection == 1 or menuSelection == 7 then
                  handleMenuConfirm()
              end"""

content = content.replace(right_old, right_new)

# 2. Update left key logic
left_old = """              elseif menuSelection == 5 then
                  currentWallpaperIndex = currentWallpaperIndex - 1
                  if currentWallpaperIndex < 1 then currentWallpaperIndex = #wallpapers end
                  if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
              end"""

left_new = """              elseif menuSelection == 5 then
                  currentWallpaperIndex = currentWallpaperIndex - 1
                  if currentWallpaperIndex < 1 then currentWallpaperIndex = #wallpapers end
                  if #wallpapers > 0 then bgSprite = wallpapers[currentWallpaperIndex] end
              elseif menuSelection == 6 then
                  local idx = 1
                  for i, l in ipairs(langs) do if l == currentLang then idx = i break end end
                  idx = (idx - 2) % #langs + 1
                  currentLang = langs[idx]
                  load_fonts()
                  if sndVolume then sndVolume:clone():play() end
              end"""

content = content.replace(left_old, left_new)

with open('c:/Users/casio/Desktop/project/privy/main.lua', 'w', encoding='utf-8') as f:
    f.write(content)
