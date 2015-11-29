local bump = require('lib.vendor.bump')

local setmetatable = setmetatable
local pairs = pairs
local print = print
local error = error
local table = {
  insert = table.insert,
  remove = table.remove
}
local math = {
  abs = math.abs
}

local PhysicsWrapper
do PhysicsWrapper = setmetatable({}, {
    __call = function(class)
      return setmetatable({
        MotionEngine = require('lib.motion')(),
        physicsObjects = {},
        world = bump.newWorld(32)
      }, class)
    end
  })
  PhysicsWrapper.__index = PhysicsWrapper

  local physicsObj = {}
  physicsObj.__index = physicsObj

  function physicsObj:die(...)
    if type(self.onDie) == 'function' then self.onDie(...) end
    self.handler:decommission(self)
  end

  function physicsObj:revive()
    self.handler:commission(self)
  end

  function PhysicsWrapper:new(arg, super)
    if not (type(arg) == 'table') then
      arg = {}
    else
      if not (type(arg.size) == 'table') then
        arg.size = {}
      end
    end

    if not (type(arg.continuousPrediction) == 'table') then
      arg.continuousPrediction = {}
    end

    local newPhysicsObj = setmetatable({
      mass = arg.mass or 0,
      size = {
        x = arg.size.x or 0,
        y = arg.size.y or 0
      },
      -- mu = arg.mu and ((math.abs(arg.mu) >= 0 and math.abs(arg.mu) <= 1) and math.abs(arg.mu)) or 0,
      -- restitution = arg.restitution and math.abs(arg.restitution) or 0, -- Bounciness
      continuousPrediction = {
        auto = (function() if type(arg.continuousPrediction.auto) == 'boolean' then return arg.continuousPrediction.auto else return true end end)(),
        x = arg.continuousPrediction.x or false,
        y = arg.continuousPrediction.y or false
      },
      handler = self,
      onCollide = arg.onCollide or function() end,
      collisionFilter = arg.collisionFilter or function() return 'cross' end,
      super = super
    }, physicsObj)

    for k, v in pairs(self.MotionEngine:new(arg, false)) do
      newPhysicsObj[k] = v
    end

    self:commission(newPhysicsObj)

    return newPhysicsObj
  end

  function PhysicsWrapper:commission(physicsObj)
    self.world:add(physicsObj, physicsObj.position.x, physicsObj.position.y, physicsObj.size.y, physicsObj.size.x, physicsObj.size.y)
    table.insert(self.physicsObjects, physicsObj)
  end

  function PhysicsWrapper:decommission(physicsObj)
    if self.world:hasItem(physicsObj) then
      self.world:remove(physicsObj)
    else
      print('[WARN] PhysicsWrapper: Decommissioning table ' .. tostring(physicsObj) .. ' but it doesn\'t exist in bump world. Possible memory leak.')
    end

    local didRemove = false

    for k, v in pairs(self.physicsObjects) do
      if (v == physicsObj) then
        table.remove(self.physicsObjects, k)
        didRemove = true
      end
    end

    if not didRemove then
      print('[WARN] PhysicsWrapper: Attempted to remove table ' .. tostring(physicsObj) .. ' but not found in tracking table. Possible memory leak.')
    end
  end

  function PhysicsWrapper:step(deltaTime)
    if not (self.world:countItems() == #self.physicsObjects) then
      print('[WARN] PhysicsWrapper: Bump library item count not in sync with own item count. Bump: ' .. self.world:countItems() .. ' Self: ' .. #self.physicsObjects)
    end

    for _, physicsObj in pairs(self.physicsObjects) do
      self.world:update(physicsObj, physicsObj.position.x, physicsObj.position.y, physicsObj.size.x, physicsObj.size.y)
      self.MotionEngine.processLocomotion(physicsObj, deltaTime)
      if (physicsObj.continuousPrediction.auto) then
        physicsObj.continuousPrediction.x, physicsObj.continuousPrediction.y = self:checkCCDRequired(physicsObj)
      end

      local actualX, actualY, collisions, collisionAmount
      actualX, actualY, collisions, collisionAmount = self.world:move(physicsObj, physicsObj.position.x, physicsObj.position.y, physicsObj.collisionFilter)
      if collisionAmount > 0 then
        physicsObj.onCollide(collisions)
      end

      if not (physicsObj.collisionFilter() == 'cross' or physicsObj.collisionFilter() == nil) then
        physicsObj.position.x, physicsObj.position.y = actualX, actualY
      end

      if type(physicsObj.tick) == 'function' then physicsObj.tick(deltaTime) end
    end
  end

  function PhysicsWrapper:checkCCDRequired(physicsObj)
    local doesXRequire, doesYRequire

    if (math.abs(self.MotionEngine.calculateVelocity(physicsObj.velocity.x, physicsObj.acceleration.x, physicsObj.jerk.x, love.timer.getAverageDelta(), physicsObj.dilation.x)) * love.timer.getAverageDelta() >= physicsObj.size.x) then
      doesXRequire = true
      -- error('CCD REQUIRED BUT NOT IMPLEMENTED')
    else
      doesXRequire = false
    end

    if (math.abs(self.MotionEngine.calculateVelocity(physicsObj.velocity.y, physicsObj.acceleration.y, physicsObj.jerk.y, love.timer.getAverageDelta(), physicsObj.dilation.y)) * love.timer.getAverageDelta() >= physicsObj.size.y) then
      doesYRequire = true
      -- error('CCD REQUIRED BUT NOT IMPLEMENTED')
    else
      doesYRequire = false
    end

    return doesXRequire, doesYRequire
  end
end

return PhysicsWrapper
