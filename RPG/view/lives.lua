
local PALETTE_DB = require 'database.palette'
local Vec = require 'common.vec'

local Lives = require 'common.class' ()

function Lives:_init()
  self.list = {}
end

function Lives:add(unit, hp, max_hp)
  local life_pos = unit.position:clone()
  life_pos:add(Vec(-25, 28))
  self.list[unit] = {
    position = life_pos,
    hp = hp,
    max_hp = max_hp,
  }
end

function Lives:remove(unit)
  if self.list[unit] then
    self.list[unit] = nil
  end
end

function Lives:add_position(unit, value)
  self.list[unit].position = self.list[unit].position + value
end

function Lives:draw()
  local g = love.graphics
  g.push()

  g.setColor(PALETTE_DB.dark_green)

  for _, life in pairs(self.list) do
    local x1, y1 = life.position:get()

    g.print(("%d/%d"):format(life.hp, life.max_hp), x1, y1)
  end

  g.pop()
end

return Lives

