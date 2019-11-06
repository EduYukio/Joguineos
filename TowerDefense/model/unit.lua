
local Unit = require 'common.class' ()

function Unit:_init(specname)
  local spec = require('database.units.' .. specname)
  self.spec = spec
  self.name = spec.name
  self.max_hp = spec.max_hp
  self.hp = spec.max_hp
  self.category = spec.category
  self.cost = spec.cost
  self.range = spec.range
  self.damage = spec.damage
  self.damage_buffs = 0
  self.base_speed = spec.speed
  self.speed = spec.speed
  self.special = spec.special
  self.target_policy = spec.target_policy
  self.reward = spec.reward
end

function Unit:get_name()
  return self.spec.name
end

function Unit:get_appearance()
  return self.spec.appearance
end

function Unit:get_hp()
  return self.hp, self.spec.max_hp
end

function Unit:get_category()
  return self.category
end

return Unit

