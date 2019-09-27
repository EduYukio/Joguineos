--luacheck: globals love class


class = require "class"
class.Movement()

local Vec = require 'common/vec'

function Movement:_init() -- luacheck: ignore
  self.motion = Vec(0, 0)
end

function Movement:update() -- luacheck: ignore
end
