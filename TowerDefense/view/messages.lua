
local Messages = require 'common.class' ()
local PALETTE_DB = require 'database.palette'

function Messages:_init()
  self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.font:setFilter('nearest', 'nearest')
end

function Messages:write(message, position)
  self.message = message
  self.position = position
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
    g.translate(self.position:get())
    g.print(self.message)
    g.translate(0, self.font:getHeight())

    g.pop()
  end
end

return Messages

