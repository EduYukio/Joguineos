
local Stats = require 'common.class' ()
local PALETTE_DB = require 'database.palette'

function Stats:_init(position)
  self.position = position
  self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.font:setFilter('nearest', 'nearest')
  self.gold = 0
  self.current_wave = 0
  self.number_of_waves = 0
end

function Stats:draw()
  local g = love.graphics
  g.push()

  g.setFont(self.font)
  g.setColor(PALETTE_DB.white)
  g.translate(240, 4)
  g.print(("Wave: %d/%d"):format(self.current_wave, self.number_of_waves))
  g.origin()

  local x,y = self.position:get()
  x = x - 7
  g.translate(x,y)
  g.printf("Gold: " .. tostring(self.gold), -15, 0, 160, "center")
  g.translate(0, self.font:getHeight())

  g.pop()
end

return Stats

