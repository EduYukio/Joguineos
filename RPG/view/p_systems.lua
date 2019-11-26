
local g = love.graphics
local PSystems = require 'common.class' ()
local Vec = require 'common.vec'
local PALETTE_DB = require 'database.palette'

function PSystems:_init()
  self.list = {}
end

function PSystems:add_all(unit, position)
  local p_systems = {
    green = self:add(unit, position, "green"),
    pure_black = self:add(unit, position, "pure_black"),
    light_blue = self:add(unit, position, "light_blue"),
    dark_blue = self:add(unit, position, "dark_blue"),
    dark_red = self:add(unit, position, "dark_red"),
    pink = self:add(unit, position, "pink"),
    orange = self:add(unit, position, "orange"),
  }

  return p_systems
end

function PSystems:add(unit, position, color)
  local img = g.newImage("assets/textures/white_particle.png")

  local p_system = {
    sys = g.newParticleSystem(img, 30),
    position = position + Vec(0, 17),
    color = color,
  }

  p_system.sys:setParticleLifetime(0.5, 1.3)
  p_system.sys:setLinearAcceleration(-4, -19, 4, -30)
  p_system.sys:setSpeed(30)
  p_system.sys:setEmissionArea("normal", 3, 6, 3*math.pi/2, true)

  if not self.list[unit] then
    self.list[unit] = {}
  end

  self.list[unit][color] = p_system

  return p_system.sys
end

function PSystems:remove_all(unit)
  self:remove(unit, "green")
  self:remove(unit, "dark_green")
  self:remove(unit, "blue")
  self:remove(unit, "dark_blue")
  self:remove(unit, "red")
  self:remove(unit, "pink")
  self:remove(unit, "orange")
end

function PSystems:remove(unit, color)
  if self.list[unit] and self.list[unit][color] then
    self.list[unit][color] = nil
  end
end

function PSystems:update(dt)
  for _, unit in pairs(self.list) do
    for _, p_system in pairs(unit) do
      p_system.sys:update(dt)
    end
  end
end

function PSystems:draw()
  g.push()

  for _, unit in pairs(self.list) do
    for _, p_system in pairs(unit) do
      local color = p_system.color
      g.setColor(PALETTE_DB[color])
      g.draw(p_system.sys, p_system.position:get())
    end
  end

  g.pop()
end

return PSystems

