local Utils = {}

function Utils._tickTopologicalSort(a, b)
  return a.priority > b.priority
end

local TickManager
do TickManager = setmetatable({}, {
    __call = function(class)
      return setmetatable({
        _callbacks = {},
        _isPaused = false
      }, class)
    end
  })
  TickManager.__index = TickManager

  function TickManager:setPaused(bool)
    self._isPaused = bool
  end

  function TickManager:isPaused()
    return self._isPaused
  end

  function TickManager:setSkipTicks(number)
    if (number >= 0) then
      for _, v in pairs(self._callbacks) do
        v.skipTicks = number
      end
    end
  end

  function TickManager:addCallback(func, call_order, initSkipTicks, isOneShot)
    local order = (call_order and call_order or 0)

    local callback = {
      priority = order,
      callback = func,
      skipTicks = initSkipTicks or 0,
      isOneShot = isOneShot or false
    }

    table.insert(self._callbacks, callback)
    table.sort(self._callbacks, Utils._tickTopologicalSort)

    return callback
  end

  function TickManager:removeCallback(callback)
    for k, v in pairs(self._callbacks) do
      if (v == callback) then
        table.remove(self._callbacks, k)
      end
    end
  end

  function TickManager:step(...)
    if not (self._isPaused) then
      for _, v in pairs(self._callbacks) do
        if (v.skipTicks <= 0) then
          v.callback(...)
          if v.isOneShot then
            self:removeCallback(v)
          end
        else
          v.skipTicks = v.skipTicks - 1
        end
      end
    end
  end
end

return TickManager
