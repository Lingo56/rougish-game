local config
local configLocation = 'config.json'
local keybindsLocation = 'keybinds.json'
local mainTick = require('lib.tickman')()
local drawTick = require('lib.tickman')()
local onLoad = require('lib.tickman')()
local eventer = require('lib.events')
local controlParser = require('lib.controls')
local physicsControl = require('lib.physics')()
local util = require('lib.util')

onLoad:addCallback(function()
  config = require('lib.dkjson').decode((love.filesystem.read(configLocation)))
  controlParser.parse(require('lib.dkjson').decode((love.filesystem.read(keybindsLocation))))
end, 100)

local camera = {
  shake = {
    magnitude = 0,
    signX = math.random(0,50),
    signY = math.random(0,50)
  }
}

drawTick:addCallback(function()
  if (camera.shake.magnitude ~= 0) then love.graphics.translate((function()
    if camera.shake.signX > 25 then
      camera.shake.signX = math.random(0,50)
    else
      camera.shake.signX = math.random(0,50)
    end

    if camera.shake.signX > 25 then
      return -camera.shake.magnitude
    else
      return camera.shake.magnitude
    end
  end)(), (function()
    if camera.shake.signY > 25 then
      camera.shake.signY = math.random(0,50)
    else
      camera.shake.signY = math.random(0,50)
    end

    if camera.shake.signY > 25 then
      return -camera.shake.magnitude
    else
      return camera.shake.magnitude
    end
  end)()) end
end, -20)

mainTick:addCallback(function(deltaTime)
  physicsControl:step(deltaTime)
end, 9e999)

function love.load(args)
  onLoad:step(args)
  onLoad = nil
end

function love.draw()
  drawTick:step()
end

function love.update(dt)
  mainTick:step(dt)
end

-- Function shorthands

local function addTickCallback(...)
  mainTick:addCallback(...)
end

local function addDrawCallback(...)
  drawTick:addCallback(...)
end

local function addLoadCallback(...)
  onLoad:addCallback(...)
end

local function subscribe(event_names, callback_function)
  if (type(event_names) == 'table') then
    for i = 1, #event_names do
      eventer:createSubscription(event_names[i], callback_function)
    end
  else
    eventer:createSubscription(event_names, callback_function)
  end
end

return {
  when = {
    tick = addTickCallback,
    draw = addDrawCallback,
    load = addLoadCallback
  },
  on = subscribe,
  tickers = {
    draw = drawTick,
    main = mainTick
  },
  physics = physicsControl,
  eventer = eventer,
  controls = controlParser,
  config = config,
  fileLocations = {
    config = configLocation,
    keybinds = keybindsLocation
  },
  util = util,
  camera = camera
}
