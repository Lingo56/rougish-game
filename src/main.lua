io.stdout:setvbuf('no')
print('\n')

local engine = require('engine')
require('lib.vendor.light')
require('lib.vendor.postshader')

local lightWorld, lightMouse
local lightDirection, colorAberration = 0, 0

--[[
LOAD FUNCTION
]]--
engine.when.load(function()
  engine.controls.state = 'game'
  lightWorld = love.light.newWorld()
  lightWorld.setAmbientColor(50, 50, 80)
  lightWorld.setRefractionStrength(64)
  lightMouse = lightWorld.newLight(0, 0, 255, 128, 80, 100)
	lightMouse.setGlowStrength(2)
  lightMouse.setGlowSize(1)
  lightMouse.setSmooth(5)
end)

--PLAYER OBJECT
local player = {
  sprite = { -- Sets player's looks
    color = {
      r = 50, -- Red
      g = 200, -- Green
      b = 75, -- Blue
      a = 255 -- Alpha
    }
  },
  stats = {
    movementSpeed = 1100, -- In pixels per second
    hitMultiplier = 0,
    hitMultiplierTimeToDecrease = 0.5,
    hitMultiplierDecreaseTimer = 0
  },
  physics = engine.physics:new({ -- Gives player physics properties
    position = {
      x = 0,
      y = 0
    },
    velocity = {
      x = 0,
      y = 0
    },
    size = {
      x = 100,
      y = 100
    }
  }),
  items = {
    gun = {
      projectiles = {},
      tick = nil,
      fireRate = 0.2,
      timeToFireRate = 0.2,
      projectileSpeed = 0000,
      projectileAcceleration = 20000,
      projectileSize = {
        x = 4,
        y = 64
      },
      shootMagnitude = 2,
      hitMagnitudeMin = 4,
      hitMagnitudeMax = 6
    }
  }
}

--Set Spawn Location for player
player.physics.position.x = (love.graphics.getWidth() / 2) - (player.physics.size.x / 2) -- Center player x relative to window
player.physics.position.y = (-love.graphics.getHeight() + player.physics.size.y) + 25 -- Center player y relative to window

engine.when.load(function()
  player.light = lightWorld.newLight(player.physics.position.x + (player.physics.size.x / 2), -player.physics.position.y + (player.physics.size.y / 2), 200, 150, 90, 300)

  player.light.setGlowStrength(1)
  player.light.setSmooth(3)

  player.physics.collisionFilter = function(item, other)
    if other then
      for i = 1, #player.items.gun.projectiles do
        if player.items.gun.projectiles[i].physics == other then
          return nil
        end
      end
    end
    return 'touch'
  end

  player.physics.tick = function(deltaTime)
    player.light.setPosition(player.physics.position.x + (player.physics.size.x / 2), -player.physics.position.y + (player.physics.size.y / 2))
  end

  player.physics.onDie = function()
    for k, light in pairs(lightWorld.lights) do
      if player.light == light then
        table.remove(lightWorld.lights, k)
      end
    end
  end
end)

-- Projectile Object
local playerProjectile = {
  sprite = {
    color = {
      r = 255,
      g = 0,
      b = 50,
      a = 255
    }
  }
}
playerProjectile.__index = playerProjectile

--Enemy Object
local normalEnemy = {
  sprite = {
    color = {
      r = 255,
      g = 0,
      b = 120,
      a = 255
    }
  },
   -- Gives player physics properties
  velocity = 100,
  size = 100,
  acceleration = 800,
  invincibilityTime = 0.75
}
normalEnemy.__index = normalEnemy

--Spawner Object
local genericSpawner = {--[[
  rate = 0.25,
  _timeToSpawn = 0.25,
  defaultX = 0,
  defaultY = 0,
  entity = {},
  spawnedEntities = {}
]]}
genericSpawner.__index = genericSpawner

local spawnerFactory = {
  spawners = {}
}

-- Uses objects created above to draw and update position
local function draw(obj, offset, debugPrint)
  love.graphics.setColor(obj.sprite.color.r, obj.sprite.color.g, obj.sprite.color.b, obj.sprite.color.a)
  love.graphics.rectangle('fill', obj.physics.position.x, -obj.physics.position.y, obj.physics.size.x, obj.physics.size.y)
  love.graphics.setColor(255, 255, 255, 255)
  if debugPrint then
    -- love.graphics.rectangle('line', obj.physics.position.x - 3, -obj.physics.position.y - 3, obj.physics.size.x + 6, obj.physics.size.y + 6)
    love.graphics.print('jerk x: ' .. obj.physics.jerk.x, offset, 400)
    love.graphics.print('jerk y: ' .. obj.physics.jerk.y, offset, 410)
    love.graphics.print('accel x: ' .. obj.physics.acceleration.x, offset, 420)
    love.graphics.print('accel y: ' .. obj.physics.acceleration.y, offset, 430)
    love.graphics.print('veloc x: ' .. obj.physics.velocity.x, offset, 440)
    love.graphics.print('veloc y: ' .. obj.physics.velocity.y, offset, 450)
    love.graphics.print('pos x: ' .. obj.physics.position.x, offset, 460)
    love.graphics.print('pos y: ' .. obj.physics.position.y, offset, 470)
    love.graphics.print('CCD x: ' .. tostring(obj.physics.continuousPrediction.x), offset, 480)
    love.graphics.print('CCD y: ' .. tostring(obj.physics.continuousPrediction.y), offset, 490)
  end
end

engine.when.draw(function()
  lightWorld.update()
  love.postshader.setBuffer('render')
  love.graphics.setColor(60, 60, 90)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

  lightWorld.drawShadow()
end, 10)

engine.when.draw(function()
  lightWorld.drawShine()
  lightWorld.drawPixelShadow()
  lightWorld.drawGlow()
  lightWorld.drawRefraction()
  lightWorld.drawReflection()

  if colorAberration > 0.0 then
    love.postshader.addEffect('blur', 1, 1)
    love.postshader.addEffect('chromatic', math.sin(lightDirection * 10.0) * colorAberration, math.cos(lightDirection * 10.0) * colorAberration, math.cos(lightDirection * 10.0) * colorAberration, math.sin(lightDirection * 10.0) * -colorAberration, math.sin(lightDirection * 10.0) * colorAberration, math.cos(lightDirection * 10.0) * -colorAberration)
  end
end, -10)

engine.when.draw(function()
  love.postshader.draw()
end, -21)

--[[
UPDATE FUNCTION
]]--
engine.when.tick(function(deltaTime)
  player.stats.hitMultiplierDecreaseTimer = player.stats.hitMultiplierDecreaseTimer + deltaTime
  if player.stats.hitMultiplierDecreaseTimer >= player.stats.hitMultiplierTimeToDecrease then
    player.stats.hitMultiplierDecreaseTimer = 0
    player.stats.hitMultiplier = player.stats.hitMultiplier - math.ceil(player.stats.hitMultiplier * 0.05)
  end

  lightMouse.setPosition(love.mouse.getX(), love.mouse.getY())
  lightDirection = lightDirection + deltaTime
  if lightDirection > 3 then
    lightDirection = 0
  end
  -- Loop for shooting
  for k, projectile in pairs(player.items.gun.projectiles) do -- Remove offscreen projectiles.
    if (projectile.physics.position.y - player.items.gun.projectileSize.y > 0) then
      projectile.physics:die() -- Remove it from the physics engine.
      table.remove(player.items.gun.projectiles, k) -- Remove it from the projectiles table.
    end
  end

  -- Forces player to not leave the screen sides
  if (player.physics.position.y >= 0) then
    player.physics.position.y = 0
  end

  if (player.physics.position.y - player.physics.size.y <= -love.graphics.getHeight()) then
    player.physics.position.y = -love.graphics.getHeight() + player.physics.size.y
  end

  if (player.physics.position.x <= 0) then
    player.physics.position.x = 0
  end

  if (player.physics.position.x + player.physics.size.x >= love.graphics.getWidth()) then
    player.physics.position.x = love.graphics.getWidth() - player.physics.size.x
  end

  if player.items.gun.timeToFireRate < player.items.gun.fireRate then
    player.items.gun.timeToFireRate = player.items.gun.timeToFireRate + deltaTime -- Increases the shoot timer
  end
end)

-- Enemy Spawning

-- Tells the spawner object to spawn an enemy. Accepts 2 optional arguments; x and y which is the coordinates at where to spawn to.
function genericSpawner:spawn(x, y)
  local newEntity = setmetatable({
    physics = engine.physics:new({
      position = {
        x = x or self.defaultX,
        y = y or self.defaultY
      },
      velocity = {
        y = -self.entity.velocity
      },
      size = {
        x = self.entity.size,
        y = self.entity.size
      },
      acceleration = {
        y = -self.entity.acceleration
      }
    }),
    _age = 0
  }, self.entity)

  newEntity.lightingBody = love.light.newRectangle(lightWorld, newEntity.physics.position.x + (self.entity.size / 2), newEntity.physics.position.y + (self.entity.size / 2), self.entity.size, self.entity.size)

  newEntity.physics.tick = function(deltaTime)
    newEntity.lightingBody.setPosition(newEntity.physics.position.x + (self.entity.size / 2), -newEntity.physics.position.y  + (self.entity.size / 2))
  end

  newEntity.physics.onDie = function()
    for k, body in pairs(lightWorld.body) do
      if body == newEntity.lightingBody then
        table.remove(lightWorld.body, k)
      end
    end
  end

  newEntity.physics.collisionFilter = function(item, other)
    if newEntity._age > newEntity.invincibilityTime then
      for _, spawner in pairs(spawnerFactory.spawners) do
        for _, entity in pairs(spawner.spawnedEntities) do
          if entity.physics == other then
            return 'touch'
          end
        end
      end
      return 'touch'
    end
  end

  table.insert(self.spawnedEntities, newEntity)

  self._timeToSpawn = 0
end

-- Creates and returns a new spawner object. Accepts a required @entity object for the spawner to spawn and an optional @initOptions object containing setup parameters.
function spawnerFactory.new(entity, initOptions)
  if not (type(initOptions) == 'table') then initOptions = {} end
  local spawner = setmetatable({
    rate = initOptions.rate or 0.25,
    _timeToSpawn = initOptions.timeToFirstSpawn or 9e999,
    defaultX = initOptions.spawnX or 0,
    defaultY = initOptions.spawnY or 0,
    entity = entity,
    spawnedEntities = {},
    enabled = initOptions.enabled or true
  }, genericSpawner)

  table.insert(spawnerFactory.spawners, spawner)

  return spawner
end

-- Enables or disables all of the spawners depending on boolean passed. Defaults to true.
function spawnerFactory.setAllEnabled(bool)
  for _, v in pairs(spawnerFactory.spawners) do
    v.enabled = (function() if type(bool) == 'boolean' then return bool else return true end end)()
  end
end

local enabled = true

engine.controls.binding('toggle_spawns'):onPress(function()
  if enabled then
    spawnerFactory.setAllEnabled(false)
    enabled = false
  else
    spawnerFactory.setAllEnabled(true)
    enabled = true
  end
end)

spawnerFactory.new(normalEnemy, {
  spawnY = normalEnemy.size,
  rate = 0.25
})

engine.when.tick(function(deltaTime)
  for _, spawner in pairs(spawnerFactory.spawners) do
    if spawner.enabled then
      spawner._timeToSpawn = spawner._timeToSpawn + deltaTime
      if spawner._timeToSpawn >= spawner.rate then
        spawner:spawn(math.random(0, love.graphics.getWidth() - spawner.entity.size))
      end
    end

    for k, entity in pairs(spawner.spawnedEntities) do
      entity._age = entity._age + deltaTime
      if (entity.physics.position.y < -love.graphics.getHeight()) then
        entity.physics:die()
        table.remove(spawner.spawnedEntities, k)
      end
    end
  end
end)

engine.when.draw(function()
  for i  = 1, #spawnerFactory.spawners do
    for _, entity in pairs(spawnerFactory.spawners[i].spawnedEntities) do
      draw(entity)
    end
  end
end)

local function createProjectile(offset)
  local newProjectile = setmetatable({ -- clone the genericProjectile object and add a physics property to it.
  physics = engine.physics:new({ -- Gives player physics properties
    position = {
      x = ((player.physics.position.x + (player.physics.size.x / 2)) - (player.items.gun.projectileSize.x / 2)) + offset,
      y = (player.physics.position.y) + (player.items.gun.projectileSize.y)
    },
    velocity = {
      x = 0,
      y = player.items.gun.projectileSpeed
    },
    size = {
      x = player.items.gun.projectileSize.x,
      y = player.items.gun.projectileSize.y
    },
    acceleration = {
      x = 0,
      y = player.items.gun.projectileAcceleration,
    },
    collisionFilter = function(item, other) -- Optional function passed to the physics.
      return 'cross'
    end
  })
  }, playerProjectile)

  newProjectile.physics.onCollide = function(collisions)
    for _, collision in pairs(collisions) do
      for _, spawner in pairs(spawnerFactory.spawners) do
        for id, entity in pairs(spawner.spawnedEntities) do
          if entity.physics == collision.other then --means bullet hits enemy
            player.stats.hitMultiplier = player.stats.hitMultiplier + 1
            for k, v in pairs(player.items.gun.projectiles) do
              if v.physics == collision.item then
                table.remove(player.items.gun.projectiles, k)
                v.physics:die()
              end
            end
            entity.physics:die()
            table.remove(spawner.spawnedEntities, id)

            -- Screenshake
            engine.camera.shake.magnitude = (math.random(player.items.gun.hitMagnitudeMin, player.items.gun.hitMagnitudeMax)) * (1 + (player.stats.hitMultiplier * 0.025))
            engine.tickers.main:addCallback(function()
              engine.camera.shake.magnitude = 0
            end, -9e99, 15, true)

            colorAberration = 3
            engine.tickers.draw:addCallback(function()
              colorAberration = 0
            end, -11, 15, true)

            -- newProjectile.light.setGlowStrength(0)

            local flash = lightWorld.newLight(newProjectile.physics.position.x + (newProjectile.physics.size.x / 2), -newProjectile.physics.position.y + (newProjectile.physics.size.y / 2), 0, 255, 255, 200)
            local flashBrightness = 0.5
            flash.setGlowStrength(1)
            flash.setSmooth(flashBrightness)
            local brightnessTicker
            brightnessTicker = engine.tickers.main:addCallback(function(deltaTime)
              flashBrightness = flashBrightness + (deltaTime * 10)
              flash.setSmooth(flashBrightness)
              if flashBrightness >= 1 then
                engine.tickers.main:removeCallback(brightnessTicker)
                for k, light in pairs(lightWorld.lights) do
                  if flash == light then
                    table.remove(lightWorld.lights, k)
                  end
                end
              end
            end)

            engine.tickers.main:addCallback(function(deltaTime)
              engine.tickers.main:setSkipTicks(math.ceil((deltaTime^-1) / 40))
            end, nil, nil, true)
          end
        end
      end
    end
  end

  newProjectile.light = lightWorld.newLight(newProjectile.physics.position.x + (newProjectile.physics.size.x / 2), -newProjectile.physics.position.y + (newProjectile.physics.size.y / 4), 510, 150, 90, 150)

  newProjectile.light.setGlowStrength(1)
  newProjectile.light.setSmooth(1)

  newProjectile.physics.tick = function(deltaTime)
    newProjectile.light.setPosition(newProjectile.physics.position.x + (newProjectile.physics.size.x / 2), -newProjectile.physics.position.y + (newProjectile.physics.size.y / 4))
  end

  newProjectile.physics.onDie = function()
    for k, light in pairs(lightWorld.lights) do
      if newProjectile.light == light then
        table.remove(lightWorld.lights, k)
      end
    end
  end

  return newProjectile
end

--[[

CONTROLS

]]
engine.controls.binding('player_shoot'):onPress(function()
  player.items.gun.tick = engine.tickers.main:addCallback(function(deltaTime) -- Make an ontick callback and assign the returned callback object.
    if player.items.gun.timeToFireRate >= player.items.gun.fireRate then -- Checks if timer is more than fire rate. If true, then shoot.
      player.items.gun.timeToFireRate = 0 -- Reset the timer.
      table.insert(player.items.gun.projectiles, createProjectile(32))
      table.insert(player.items.gun.projectiles, createProjectile(-32))

      engine.camera.shake.magnitude = player.items.gun.shootMagnitude * (1 + (player.stats.hitMultiplier * 0.025))
      engine.tickers.main:addCallback(function()
        engine.camera.shake.magnitude = 0
      end, -9e99, 5, true)
    end
  end)
end)

engine.controls.binding('player_shoot'):onRelease(function()
  engine.tickers.main:removeCallback(player.items.gun.tick)
end)

engine.controls.binding('player_up'):onPress(function()
  player.physics.velocity.y = player.physics.velocity.y + player.stats.movementSpeed
end)

engine.controls.binding('player_up'):onRelease(function()
  player.physics.velocity.y = player.physics.velocity.y - player.stats.movementSpeed
end)

engine.controls.binding('player_down'):onPress(function()
  player.physics.velocity.y = player.physics.velocity.y - player.stats.movementSpeed
end)

engine.controls.binding('player_down'):onRelease(function()
  player.physics.velocity.y = player.physics.velocity.y + player.stats.movementSpeed
end)

engine.controls.binding('player_left'):onPress(function()
  player.physics.velocity.x = player.physics.velocity.x - player.stats.movementSpeed
end)

engine.controls.binding('player_left'):onRelease(function()
  player.physics.velocity.x = player.physics.velocity.x + player.stats.movementSpeed
end)

engine.controls.binding('player_right'):onPress(function()
  player.physics.velocity.x = player.physics.velocity.x + player.stats.movementSpeed
end)

engine.controls.binding('player_right'):onRelease(function()
  player.physics.velocity.x = player.physics.velocity.x - player.stats.movementSpeed
end)

engine.controls.binding('close'):onPress(function()
  love.event.push('quit')
end)


--[[

DRAW FUNCTIONS

]]
engine.when.draw(function()
  love.graphics.print('Avg delta time: ' .. love.timer.getAverageDelta(), 8, 8)
  love.graphics.print('Current FPS: ' .. tostring(love.timer.getFPS( )), 8, 28)
  love.graphics.print('physics objects: ' .. #engine.physics.physicsObjects, 8, 48)
  love.graphics.print('Lights: ' .. #lightWorld.lights, 8, 68)
  love.graphics.print('Lighting Bodies: ' .. #lightWorld.body, 8, 88)
  love.graphics.print('Hit Multiplier: ' .. player.stats.hitMultiplier, 8, 108)
end, -9e999)

engine.when.draw(function()
  draw(player, 24, true)
  for i = 1, #player.items.gun.projectiles do -- Loop through the projectile list and draw each one
    draw(player.items.gun.projectiles[i])
  end
end)
