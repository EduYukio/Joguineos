
local Messages = require 'common.class' ()
local PALETTE_DB = require 'database.palette'

function Messages:_init()
  self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.font:setFilter('nearest', 'nearest')
  self.x_pos = 50
  self.y_pos = 560
end

function Messages:write(message)
  self.message = message
end

function Messages:clear()
  self.message = nil
end

function Messages:draw()
  if self.message then
    local g = love.graphics
    g.push()

    g.setFont(self.font)
    g.setColor(PALETTE_DB.white)
    g.translate(self.x_pos, self.y_pos)
    g.printf(self.message, 0, 0, 500, "center")
    g.translate(0, self.font:getHeight())

    g.pop()
  end
end

return Messages

