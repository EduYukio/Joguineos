
local Stats = require 'common.class' ()
local PALETTE_DB = require 'database.palette'

function Stats:_init(position)
  self.position = position
  self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.font:setFilter('nearest', 'nearest')
  self.gold = 0
end

function Stats:draw()
  local g = love.graphics
  g.push()
  g.setFont(self.font)
  g.setColor(PALETTE_DB.white)
  g.translate(self.position:get())
  g.print(("Gold: %d"):format(self.gold))
  g.translate(0, self.font:getHeight())
  g.pop()
end

return Stats

