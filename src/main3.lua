function love.load()
	love.graphics.setBackgroundColor(54, 172, 248)

	bulletSpeed = 250

	bullets = {}
	player = {x=250, y=250, width=15, height=15}
end

function love.mousepressed(x, y, button)
	if button == "l" then
		local startX = player.x + player.width / 2
		local startY = player.y + player.height / 2
		local mouseX = x
		local mouseY = y

		local angle = math.atan2((mouseY - startY), (mouseX - startX))

		local bulletDx = bulletSpeed * math.cos(angle)
		local bulletDy = bulletSpeed * math.sin(angle)

		table.insert(bullets, {x = startX, y = startY, dx = bulletDx, dy = bulletDy})
	end
end

function love.update(dt)
	for i,v in ipairs(bullets) do
		v.x = v.x + (v.dx * dt)
		v.y = v.y + (v.dy * dt)
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill",  player.x, player.y, player.width, player.height)

	love.graphics.setColor(128, 128, 128)
	for i,v in ipairs(bullets) do
		love.graphics.circle("fill", v.x, v.y, 3)
	end
end
