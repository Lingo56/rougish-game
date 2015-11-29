local createShim

local function newShim(t, k, options)
  local newShim = createShim(options)
  t[k] = newShim
  return newShim
end

createShim = function(options)
  options = options or {}
  local shim = {}
  local shimMetaTable = {
    __call = options.callFunc or function(t, k)
      return newShim(t, k, options)
    end,
    __index = function(t, k)
      return newShim(t, k, options)
    end
  }
  if options.isWeak then shimMetaTable.__mode = 'kv' end
  setmetatable(shim, shimMetaTable)
  return shim
end

return createShim
