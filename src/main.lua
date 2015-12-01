--[[
Code based on:
http://nova-fusion.com/2011/04/19/cameras-in-love2d-part-1-the-basics/
]]


local camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0
camera.translateX = 0
camera.translateY = 0

function love.update()
  if love.keyboard.isDown('w') then
    camera.translateY = camera.translateY - 1
  end
  if love.keyboard.isDown('s') then
    camera.translateY = camera.translateY + 1
  end
  if love.keyboard.isDown('a') then
    camera.translateX = camera.translateX - 1
  end
  if love.keyboard.isDown('d') then
    camera.translateX = camera.translateX + 1
  end
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end
end

function camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 * camera.scaleX , 1 * camera.scaleY)
  love.graphics.translate(camera.translateX, camera.translateY)
end

function camera:unset()
  love.graphics.pop()
end

function love.draw()
  camera:set()
  love.graphics.setColor( 50, 255, 60, 255)
  love.graphics.rectangle("fill", (love.graphics.getHeight()/2) + camera.translateX ,(love.graphics.getWidth()/2 )+ camera.translateY , 50, 50)
  love.graphics.setColor( 255, 255, 255, 255)
  love.graphics.rectangle("fill", 150, 150, 50, 50)
  camera:unset()
end
