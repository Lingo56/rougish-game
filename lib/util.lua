local util = {}

util.table = {}

util.table.merge = function(mergee, merger)
  for k, v in merger do
    mergee[k] = v
  end

  return mergee
end
