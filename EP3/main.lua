--luacheck: globals love class

class = require "class"

class.Entity()

function Entity:_init(name, properties)
  self.name = name
  self.properties = properties
end

local scene
local entities = {}

function love.load(args)
  scene = love.filesystem.load("scene/".. args[1] ..".lua")()

  for i = 1, #scene do
    for _ = 1, scene[i].n do
      local objName = scene[i].entity
      local object = Entity(objName, require("entity/" .. objName))
      table.insert(entities, object)
    end
  end
end

-- function love.update(dt)
--   print(entities[1].name)
--   print(entities[1].properties.control.acceleration)
-- end

function love.draw()
  love.graphics.translate(1280/2, 600/2)
  love.graphics.circle("line", 0, 0, 1000)
end