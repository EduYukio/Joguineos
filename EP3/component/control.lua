--luacheck: globals love class

class = require "class"
class.Control()

function Control:_init(acceleration, max_speed) -- luacheck: ignore
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

function Control:update(dt, v0, direction) -- luacheck: ignore
  local v = direction*(self.acceleration*dt) + v0

  v:clamp(self.max_speed)

  return v
end
