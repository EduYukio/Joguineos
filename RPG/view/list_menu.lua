
local Vec = require 'common.vec'
local SOUNDS_DB = require 'database.sounds'
local g = love.graphics

local ListMenu = require 'common.class' ()

ListMenu.GAP = 4
ListMenu.PADDING = Vec(24, 8)

function ListMenu:_init(options, category)
  self.category = category
  if category == "items" then
    self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 22)
  else
    self.font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  end
  self.font:setFilter('nearest', 'nearest')
  self.options = {}
  self.position = Vec()
  self.vert_offset = 0
  self.max_width = 0
  self:build_options_array(options)
  self.size = Vec(self.max_width, self.vert_offset)
  self.current = 1
end

function ListMenu:build_options_array(options)
  for i, option in ipairs(options) do
    self.options[i] = love.graphics.newText(self.font, option)
    local width, height = self.options[i]:getDimensions()
    if width > self.max_width then
      self.max_width = width
    end
    if self.category == "items" then
      self.vert_offset = self.vert_offset + height + ListMenu.GAP
    else
      self.vert_offset = self.vert_offset + 36 + ListMenu.GAP
    end
  end
end

function ListMenu:reset_cursor()
  self.current = 1
end

function ListMenu:next()
  self.current = math.min(#self.options, self.current + 1)
  SOUNDS_DB.cursor_menu:play()
end

function ListMenu:previous()
  self.current = math.max(1, self.current - 1)
  SOUNDS_DB.cursor_menu:play()
end

function ListMenu:current_option()
  return self.current
end

function ListMenu:get_dimensions()
  return (self.size + ListMenu.PADDING * 2):get()
end

function ListMenu:draw_options(voffset)
  for i, option in ipairs(self.options) do
    local height = option:getHeight()
    if i == self.current then
      local left = - ListMenu.PADDING.x * 0.5
      local right = - ListMenu.PADDING.x * 0.25
      local top, bottom = voffset + height * .25, voffset + height * .75
      g.polygon('fill', left, top, right, (top + bottom) / 2, left, bottom)
    end
    g.setColor(1, 1, 1)
    g.draw(option, 0, voffset)
    voffset = voffset + height + ListMenu.GAP
  end
end

function ListMenu:draw()
  local size = self.size + ListMenu.PADDING * 2
  local voffset = 0
  g.push()

  g.translate(self.position:get())
  if self.category == "items" then
    g.translate(Vec(0, 55):get())
  end
  g.setColor(1, 1, 1)
  g.setLineWidth(4)
  g.translate(Vec(-5,40):get())
  g.rectangle('line', 0, 0, size:get())
  g.translate(ListMenu.PADDING:get())
  self:draw_options(voffset)

  g.pop()
end

return ListMenu
