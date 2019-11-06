
local Wave = require 'common.class' ()

function Wave:_init(wave_info)
  self.order = wave_info.order
  self.quantity = {}
  for i, v in ipairs(wave_info.quantity) do
    self.quantity[i] = v
  end
  self.cooldown = wave_info.cooldown
  self.default_delay = 2
  self.delay = self.default_delay
  self.left = nil
  self.pending = 0
end

function Wave:start()
  self.left = self.delay
end

function Wave:update(dt)
  self.left = self.left - dt
  if self.left <= 0 then
    self.left = self.left + self.delay
    self.pending = self.pending + 1
  end
end

function Wave:poll()
  local pending = self.pending
  self.pending = 0
  return pending
end

return Wave

