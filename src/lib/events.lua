local Events = {}
Events.__index = Events

local subscription = {}
subscription.__index = subscription

function subscription:subscribe()
  if (self.isSingleton == false) or (self.isSingleton == true and self.isSubscribed == false) then
    self.super:createSubscription(self.event_name, self.callback)
  end
end

function subscription:unsubscribe()
  self.isSubscribed = false
  self.super:removeSubscription(self)
end

function Events:createSubscription(event_name, func, isSingleton)
  if not (type(event_name) == 'string') then
    error('Event name must be a string')
  end

  local newSubscription = setmetatable({
    isSingleton = isSingleton or false,
    isSubscribed = true,
    event_name = event_name,
    callback = func,
    super = self
  }, subscription)

  table.insert(self.subscriptions, newSubscription)

  return newSubscription
end

function Events:removeSubscription(subscription)
  for k, v in pairs(self.subscriptions) do
    if (v == subscription) then
      table.remove(self.subscriptions, k)
    end
  end
end

function Events:publishEvent(event_name, args)
  for _, subscription in pairs(self.subscriptions) do
    if (subscription.event_name == event_name) then
      subscription.callback((type(args) == 'table' and unpack(args) or args))
    end
  end
end

return setmetatable({
  _lowest_unused_id = 0,
  subscriptions = {},
}, Events)
