io.stdout:setvbuf('no')
print('\n')

require('lib.vendor.lovetoys.lovetoys')
_G.lovetoyDebug = true

local class = _G.class
local engine, events
_G.engine = engine
_G.events = events

function love.load()
  love.mouse.setVisible(false)
  engine = Engine()
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, endContact)
  events = EventManager()
  love.mouse.setVisible(true)
end

function love.update(deltaTime)
  engine:update(deltaTime)
  world:update(deltaTime)
end

function love.draw()
  engine:draw()
end
