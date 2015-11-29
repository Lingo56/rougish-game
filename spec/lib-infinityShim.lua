local createShim
createShim = function(options)
  options = options or {}
  local shim = {}
  local shimMetaTable = {
    __call = options.callFunc or function(t)
      return t
    end,
    __index = function(t, k)
      local newShim = createShim(options)
      t[k] = newShim
      return newShim
    end,
    __unm = function()
      return 1
    end,
    __add = function()
      return 1
    end,
    __sub = function()
      return 1
    end,
    __mul = function()
      return 1
    end,
    __div = function()
      return 1
    end,
    __mod = function()
      return 1
    end,
    __pow = function()
      return 1
    end,
    __concat = function()
      return 1
    end
  }
  if options.isWeak then shimMetaTable.__mode = 'kv' end
  setmetatable(shim, shimMetaTable)
  return shim
end

return createShim
