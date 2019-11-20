
local Character = require 'common.class' ()

function Character:_init(spec)
  self.spec = spec
  self.name = spec.name
  self.hp = spec.max_hp
  self.damage = spec.damage
end

function Character:get_name()
  return self.spec.name
end

function Character:get_appearance()
  return self.spec.appearance
end

function Character:get_hp()
  return self.hp, self.spec.max_hp
end

return Character

