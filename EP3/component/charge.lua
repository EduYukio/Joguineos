--luacheck: globals love class


class = require "class"
class.Charge()

function Charge:_init() -- luacheck: ignore
  self.strength = 1
end

function Charge:update() -- luacheck: ignore
end
