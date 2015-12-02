local config
local configLocation = 'config.json'
local keybindsLocation = 'keybinds.json'
local mainTick = require('lib.tickman')()
local drawTick = require('lib.tickman')()
local onLoad = require('lib.tickman')()
local eventer = require('lib.events')
local controlParser = require('lib.controls')
local ecs = require('lib.vendor.tiny') -- http://bakpakin.github.io/tiny-ecs/doc/
local viewports = require('lib.vendor.hump.camera') -- http://hump.readthedocs.org/en/latest/camera.html

onLoad:addCallback(function()
  config = require('lib.vendor.dkjson').decode((love.filesystem.read(configLocation)))
  controlParser.parse(require('lib.vendor.dkjson').decode((love.filesystem.read(keybindsLocation))))
end, math.huge)

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
  eventer = eventer,
  controls = controlParser,
  config = config,
  fileLocations = {
    config = configLocation,
    keybinds = keybindsLocation
  }
}
