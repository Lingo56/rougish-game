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
    __unm = function(t)
      return t
    end,
    __add = function(t)
      return t
    end,
    __sub = function(t)
      return t
    end,
    __mul = function(t)
      return t
    end,
    __div = function(t)
      return t
    end,
    __mod = function(t)
      return t
    end,
    __pow = function(t)
      return t
    end,
    __concat = function(t)
      return t
    end,
  }
  if options.isWeak then shimMetaTable.__mode = 'kv' end
  setmetatable(shim, shimMetaTable)
  return shim
end

return createShim
