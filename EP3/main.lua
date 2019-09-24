--luacheck: globals love

local scene


function love.load(args)
  scene = love.filesystem.load("scene/".. args[1] ..".lua")()
end