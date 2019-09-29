--luacheck: globals love

local Charge = require "class"()

function Charge:_init()
  self.strength = 1
end

function Charge:update()
end

return Charge