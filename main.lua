io.stdout:setvbuf('no')
print('\n')

_G.class = require('lib.vendor.30logclean')
_G.tiny = require('lib.vendor.tiny')
_G.gamestate = require('lib.vendor.hump.gamestate')

local Game = require('src.states.Game')

function love.load()
  love.mouse.setVisible(false)
  gamestate.registerEvents()
	gamestate.switch(Game())
  love.resize(love.graphics.getWidth(), love.graphics.getHeight())
end

function love.resize(w, h)
	pauseCanvas = love.graphics.newCanvas(w, h)
	if camera then
		camera:setWindow(0, 0, w, h)
	end
	if paused then
		love.graphics.setCanvas(pauseCanvas)
		world:update(0)
		love.graphics.setCanvas()
	end
end

function love.draw()
	if paused then
		love.graphics.setColor(90, 90, 90, 255)
		love.graphics.draw(pauseCanvas, 0, 0)
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.setFont(assets.fnt_hud)
		love.graphics.printf('Paused - P to Resume', love.graphics.getWidth() * 0.5 - 125, love.graphics.getHeight() * 0.4, 250, "center")
	else
		local dt = love.timer.getDelta()
		if world then
			world:update(dt)
		end
	end
end
