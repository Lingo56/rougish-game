require "camera"

local player = {}
player.sizeX = 50
player.sizeY = 50
player.posX = 0
player.posY = 0

function love.update()
  if love.keyboard.isDown('w') then
    player.posY = player.posY - 10
  end
  if love.keyboard.isDown('s') then
      player.posY = player.posY + 10
  end
  if love.keyboard.isDown('a') then
      player.posX = player.posX - 10
  end
  if love.keyboard.isDown('d') then
    player.posX = player.posX + 10
  end
  if love.keyboard.isDown('e') then
    _G.camera.scaleX = _G.camera.scaleX + 0.0075
    _G.camera.scaleY = _G.camera.scaleY + 0.0075
  end
  if love.keyboard.isDown('q') then
    _G.camera.scaleX = _G.camera.scaleX - 0.0075
    _G.camera.scaleY = _G.camera.scaleY - 0.0075
  end
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  _G.camera.x = player.posX - love.graphics.getWidth()/2

  _G.camera.y = player.posY - love.graphics.getHeight()/2
end

function love.draw()
  _G.camera:set()
  love.graphics.setColor( 50, 255, 60, 255)
  love.graphics.rectangle("fill", player.posX, player.posY, player.sizeX, player.sizeY)
  love.graphics.setColor( 255, 255, 255, 255)
  love.graphics.rectangle("fill", 150, 150, 50, 50)
  _G.camera:unset()
end
