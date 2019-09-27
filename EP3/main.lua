--luacheck: globals love class

local scene
local entities = {}

class = require "class"

require "component/position"
require "component/movement"
require "component/body"
require "component/control"
require "component/field"
require "component/charge"

class.Entity()

function Entity:_init(name, initialState) -- luacheck: ignore
  self.name = name
  self.initialState = initialState

  local position = initialState.position
  if not position then
    self.position = nil
  else
    self.position = Position(position.point) -- luacheck: ignore
  end

  self.movement = nil
  self.body = nil

  local control = initialState.control
  if not control then
    self.control = nil
  else
    self.control = Control(control.acceleration, control.max_speed) -- luacheck: ignore
  end


  self.field = nil
  self.charge = nil
end

function love.load(args)
  math.randomseed(os.time())

  scene = love.filesystem.load("scene/" .. args[1] .. ".lua")()

  for i = 1, #scene do
    for _ = 1, scene[i].n do
      local name = scene[i].entity
      local initialState = require("entity/" .. name)
      local entity = Entity(name, initialState) -- luacheck: ignore
      table.insert(entities, entity)
    end
  end
end

function love.update(_)
  for _, entity in ipairs(entities) do
    if entity.position then entity.position:update() end
    if entity.movement then entity.movement:update() end
    if entity.body     then entity.body:update()     end
    if entity.control  then entity.control:update()  end
    if entity.field    then entity.field:update()    end
    if entity.charge   then entity.charge:update()   end
  end
end

function love.draw()
  love.graphics.translate(1280/2, 600/2)

  -- love.graphics.scale(0.3,0.3)

  love.graphics.setColor(1, 1, 1)
  love.graphics.circle("line", 0, 0, 1000)

  for _, entity in ipairs(entities) do
    if(entity.name == "player") then
      love.graphics.setColor(1, 1, 1)
      love.graphics.polygon('fill', -3, -4, 3, -4, 0, 6)

      -- love.graphics.setColor(0, 1, 0)
      -- love.graphics.circle("line", 0, 0, 8)
    else
      love.graphics.setColor(0, 1, 0)
      local xPos, yPos = entity.position.point:get()
      love.graphics.circle("line", xPos, yPos, 8)
    end
  end
end