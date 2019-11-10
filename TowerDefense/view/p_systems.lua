
local g = love.graphics
local PSystems = require 'common.class' ()
local Vec = require 'common.vec'
local PALETTE_DB = require 'database.palette'

function PSystems:_init()
  self.list = {}
end

function PSystems:add(tower, position, color)
  local img = g.newImage("assets/textures/" .. color .. "_particle.png")

  local p_system = {
    sys = g.newParticleSystem(img, 32),
    position = position + Vec(0, 7),
  }

  p_system.sys:setParticleLifetime(0.5, 1.5)
  p_system.sys:setLinearAcceleration(-4, -12, 4, -20)
  p_system.sys:setSpeed(10)
  p_system.sys:setEmissionArea("normal", 3, 6, 3*math.pi/2, true)

  self.list[tower] = p_system

  return p_system.sys
end

function PSystems:remove(tower)
  if self.list[tower] then
    self.list[tower] = nil
  end
end

function PSystems:update(dt)
  for _, p_system in pairs(self.list) do
    p_system.sys:update(dt)
  end
end

function PSystems:draw()
  g.push()

  g.setColor(PALETTE_DB.pure_white)
  for _, p_system in pairs(self.list) do
    g.draw(p_system.sys, p_system.position:get())
  end

  g.pop()
end

return PSystems

