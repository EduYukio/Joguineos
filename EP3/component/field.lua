--luacheck: globals love

local Field = require "class"()

function Field:_init()
  self.strength = 1
end

function Field:update()
end

return Field