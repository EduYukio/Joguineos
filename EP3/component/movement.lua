--luacheck: globals love class


class = require "class"
class.Movement()

local Vec = require 'common/vec'

function Movement:_init(motion) -- luacheck: ignore
  self.motion = Vec(0, 0)
end

function Movement:update(dt, v, x0) -- luacheck: ignore
	if v then
		self.motion = v
	end

	local x = x0 + self.motion*dt

	return x
end
