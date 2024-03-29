
local Stack = require 'stack'
local View  = require 'view'

local _game
local _stack

function love.load()
  local path = love.filesystem.getRequirePath()
  love.filesystem.setRequirePath("lib/?.lua;lib/?/init.lua;" .. path)

  math.randomseed(os.time())

  _game = {
    view = View(),
    fg_view = View()
  }
  _stack = Stack(_game)
  _stack:push('choose_quest')
end

function love.update(dt)
  _stack:update(dt)
  _game.view:update(dt)
end

function love.draw()
  _game.view:draw()
  _game.fg_view:draw()
end

for eventname, _ in pairs(love.handlers) do
  love[eventname] = function (...)
    _stack:forward(eventname, ...)
  end
end

