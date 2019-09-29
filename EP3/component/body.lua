--luacheck: globals love

local Body = require "class"()

function Body:_init()
  self.size = 8
end

function Body:update()
end

return Body