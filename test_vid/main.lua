function love.load() local success, err = pcall(love.graphics.newVideo, '../start.ogv'); print('Err: ', err); love.event.quit() end
