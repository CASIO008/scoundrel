function love.load() print('Loading video...') local success, vid = pcall(love.graphics.newVideo, 'start.ogv') print('Success: ', success) love.event.quit() end
