local createShim
createShim = function(options)
  options = options or {}
  local shim = {}
  local shimMetaTable = {
    __call = options.callFunc or function() end,
    __index = function(t, k)
      local newShim = createShim(options)
      t[k] = newShim
      return newShim
    end
  }
  if options.isWeak then shimMetaTable.__mode = 'kv' end
  setmetatable(shim, shimMetaTable)
  return shim
end

return createShim
