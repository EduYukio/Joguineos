--luacheck: globals love class


class = require "class"
class.Body()

function Body:_init() -- luacheck: ignore
  self.size = 8
end

function Body:update() -- luacheck: ignore
end
