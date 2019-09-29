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

function Movement:update(dt, updatedMotion, currentPosition)
	if updatedMotion then
		self.motion = updatedMotion
	end

	local x = currentPosition + self.motion*dt

	return x
end

return Movement