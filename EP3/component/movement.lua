--luacheck: globals love

local Movement = require "class"()
local Vec = require 'common/vec'

function Movement:_init(motion)
	if not motion then
	  self.motion = Vec(0, 0)
	else
	  self.motion = motion
	end
end

function Movement:update(dt, newMotion, currentPosition)
	self.motion = newMotion

	return currentPosition + self.motion*dt
end

return Movement