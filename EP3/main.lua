--luacheck: globals love class

local scene
local entities = {}

class = require "class"

class.Entity()

function Entity:_init(name, initialState) -- luacheck: ignore
  self.name = name
  self.initialState = initialState

  self.position = nil
  self.movement = nil
  self.body = nil
  self.field = nil
  self.charge = nil
  self.control = nil
end

function love.load(args)
  scene = love.filesystem.load("scene/".. args[1] ..".lua")()

  for i = 1, #scene do
    for _ = 1, scene[i].n do
      local name = scene[i].entity
      local initialState = require("entity/" .. name)
      local entity = Entity(name, initialState) -- luacheck: ignore
      table.insert(entities, entity)
    end
  end
end

function love.update(dt)
  for _, entity in ipairs(entities) do
    if entity.position then entity.position:update() end
    if entity.movement then entity.movement:update() end
    if entity.body     then entity.body:update() end
    if entity.field    then entity.field:update() end
    if entity.charge   then entity.charge:update() end
    if entity.control  then entity.control:update() end
  end
end

function love.draw()
  love.graphics.translate(1280/2, 600/2)
  love.graphics.circle("line", 0, 0, 1000)
end