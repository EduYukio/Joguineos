--luacheck: globals love class


class = require "class"
class.Field()

function Field:_init() -- luacheck: ignore
  self.strength = 1
end

function Field:update() -- luacheck: ignore
end
