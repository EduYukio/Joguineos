--luacheck: globals love class


class = require "class"
class.Body()

function Body:_init() -- luacheck: ignore
  -- self.name = name
end

function Body:update() -- luacheck: ignore
end
