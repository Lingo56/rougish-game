local Camera = require('hump.camera')

local scale = 1
local scaleSpeed = 0.1

local player = {}
player.sizeX = 50
player.sizeY = 50
player.x = 0
player.y = 0
player.angle = 0

local playerSquare = love.graphics.rectangle("fill", player.x, player.y, player.sizeX, player.sizeY)

local cam = Camera(player.x, player.y)

function love.update()
  if love.keyboard.isDown('w') then
    player.y = player.y - 10
  end
  if love.keyboard.isDown('s') then
    player.y = player.y + 10
  end
  if love.keyboard.isDown('a') then
    player.x = player.x - 10
  end
  if love.keyboard.isDown('d') then
    player.x = player.x + 10
  end
  if love.keyboard.isDown('q') then
    cam:zoom(scale + scaleSpeed)
  end
  if love.keyboard.isDown('e') then
    cam:zoom(scale - scaleSpeed)
  end
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end
  local dx,dy = player.x - cam.x + (player.sizeX / 2), player.y - cam.y + (player.sizeY / 2)
cam:move(dx/2, dy/2)

  player.midPosX = player.x - (player.sizeX / 2)
  player.midPosY = player.y - (player.sizeY / 2)

  local mouseX, mouseY = love.mouse.getPosition( )

  player.angle = math.atan2(mouseY - player.midPosY, mouseX - player.midPosX)
end

function love.draw()
  cam:attach()
  --player
  --love.graphics.rotate(1)
  love.graphics.rotate(player.angle)
  love.graphics.setColor( 50, 255, 60, 255)
  love.graphics.rectangle("fill", player.x, player.y, player.sizeX, player.sizeY)
  --aim dot on player
  love.graphics.setColor( 255, 0, 255, 255)
  love.graphics.rectangle("fill", player.x + (player.sizeX / 2.5), player.y, 10, 10)
  --extra square
--[[ love.graphics.setColor( 255, 255, 255, 255)
  love.graphics.rectangle("fill", 250, 300, 50, 50)]]
  cam:detach()
end
