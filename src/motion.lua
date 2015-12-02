local newFFIVector = require('ffi.vector')

local MotionEngine
do MotionEngine = setmetatable({}, {
    __call = function(class)
      return setmetatable({
        motioners = {}
      }, class)
    end
  })
  MotionEngine.__index = MotionEngine

  function MotionEngine:new(initial, shouldTrack)
    if shouldTrack == nil then
      shouldTrack = true
    end

    if not (type(initial) == 'table') then
      initial = {}
    else
      if not (type(initial.acceleration) == 'table') then
        initial.acceleration = {
          x = 0,
          y = 0,
          z = 0
        }
      else
        if not (type(initial.acceleration.x) == 'number') then
          initial.acceleration.x = 0
        end
        if not (type(initial.acceleration.y) == 'number') then
          initial.acceleration.y = 0
        end
        if not (type(initial.acceleration.z) == 'number') then
          initial.acceleration.z = 0
        end
      end
      if not (type(initial.velocity) == 'table') then
        initial.velocity = {
          x = 0,
          y = 0,
          z = 0
        }
      else
        if not (type(initial.velocity.x) == 'number') then
          initial.velocity.x = 0
        end
        if not (type(initial.velocity.y) == 'number') then
          initial.velocity.y = 0
        end
        if not (type(initial.velocity.z) == 'number') then
          initial.velocity.z = 0
        end
      end
      if not (type(initial.position) == 'table') then
        initial.position = {
          x = 0,
          y = 0,
          z = 0
        }
      else
        if not (type(initial.position.x) == 'number') then
          initial.position.x = 0
        end
        if not (type(initial.position.y) == 'number') then
          initial.position.y = 0
        end
        if not (type(initial.position.z) == 'number') then
          initial.position.z = 0
        end
      end
    end

    local motionerObj = {
      acceleration = newFFIVector(initial.acceleration.x, initial.acceleration.y, initial.acceleration.z),
      velocity = newFFIVector(initial.velocity.x, initial.velocity.y, initial.velocity.z),
      position = newFFIVector(initial.position.x, initial.position.y, initial.position.z),
      jerk = newFFIVector(0, 0, 0),
      dilation = newFFIVector(1, 1, 1)
    }

    if shouldTrack then
      table.insert(self.motioners, motionerObj)
    end

    return motionerObj
  end

  function MotionEngine:decommission(motioner)
    for k, v in pairs(self.motioners) do
      if (v == motioner) then
        table.remove(self.motioners, k)
      end
    end
  end

  function MotionEngine:step(deltaTime)
    for _, motioner in pairs(self.motioners) do
      MotionEngine.processLocomotion(motioner, deltaTime)
    end
  end

  function MotionEngine.processLocomotion(motioner, deltaTime)
    local initial = {
      acceleration = newFFIVector(motioner.acceleration.x, motioner.acceleration.y, motioner.acceleration.z),
      velocity = newFFIVector(motioner.velocity.x, motioner.velocity.y, motioner.velocity.z)
    }
    motioner.acceleration.x = MotionEngine.calculateAcceleration(initial.acceleration.x, motioner.jerk.x, deltaTime, motioner.dilation.x)
    motioner.acceleration.y = MotionEngine.calculateAcceleration(initial.acceleration.y, motioner.jerk.y, deltaTime, motioner.dilation.y)
    motioner.acceleration.z = MotionEngine.calculateAcceleration(initial.acceleration.z, motioner.jerk.z, deltaTime, motioner.dilation.z)

    motioner.velocity.x = MotionEngine.calculateVelocity(initial.velocity.x, initial.acceleration.x, motioner.jerk.x, deltaTime, motioner.dilation.x)
    motioner.velocity.y = MotionEngine.calculateVelocity(initial.velocity.y, initial.acceleration.y, motioner.jerk.y, deltaTime, motioner.dilation.y)
    motioner.velocity.z = MotionEngine.calculateVelocity(initial.velocity.z, initial.acceleration.z, motioner.jerk.z, deltaTime, motioner.dilation.z)

    motioner.position.x = MotionEngine.calculatePosition(motioner.position.x, initial.velocity.x, initial.acceleration.x, motioner.jerk.x, deltaTime, motioner.dilation.x)
    motioner.position.y = MotionEngine.calculatePosition(motioner.position.y, initial.velocity.y, initial.acceleration.y, motioner.jerk.y, deltaTime, motioner.dilation.y)
    motioner.position.z = MotionEngine.calculatePosition(motioner.position.z, initial.velocity.z, initial.acceleration.z, motioner.jerk.z, deltaTime, motioner.dilation.z)
  end

  function MotionEngine.calculateAcceleration(initialAcceleration, jerk, time, dilation)
    time = time * dilation
    return initialAcceleration + (jerk * time)
  end

  function MotionEngine.calculateVelocity(initialVelocity, initialAcceleration, jerk, time, dilation)
    time = time * dilation
    return initialVelocity + (initialAcceleration * time) + (0.5 * jerk * (time * time))
  end

  function MotionEngine.calculatePosition(initialPosition, initialVelocity, initialAcceleration, jerk, time, dilation)
    time = time * dilation
    return initialPosition + (initialVelocity * time) + (0.5 * initialAcceleration * (time * time)) + ((1/6) * jerk * (time * time * time))
  end
end

return MotionEngine
