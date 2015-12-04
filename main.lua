io.stdout:setvbuf('no')
print('\n')

_G.tiny = require('lib.vendor.tiny')
_G.gamestate = require('lib.vendor.hump.gamestate')

local Game = require('src.states.Game')

function love.load()
  love.mouse.setVisible(false)
  gamestate.registerEvents()
	gamestate.switch(Game())
  love.resize(love.graphics.getWidth(), love.graphics.getHeight())
end
