--luacheck: globals love

local Control = require "class"()

function Control:_init(acceleration, max_speed)
  if not acceleration then
    self.acceleration = 0.0
  else
    self.acceleration = acceleration
  end

  if not max_speed then
    self.max_speed = 50.0
  else
    self.max_speed = max_speed
  end
end

function Control:update(dt, currentMotion, direction)
  local v = direction*(self.acceleration*dt) + currentMotion

  v:clamp(self.max_speed)

  return v
end

return Control