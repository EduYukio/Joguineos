
local Attack = require 'common.class' ()

function Attack:_init(stage)
  self.stage = stage
  self.character = self.stage.character
  self.atlas = self.stage.atlas
  self.rules = self.stage.rules
end

function Attack:player(selected_player)
  local dmg_dealt = self.rules:take_damage(selected_player, self.character.damage)

  return dmg_dealt, false
end

function Attack:monster(selected_monster)
  local crit_attack = false
  local crit_attempt = math.random()
  if self.character.crit_ensured or crit_attempt < self.character.crit_chance then
    crit_attack = true
    self.atlas:flash_crit()
    self.character.crit_ensured = false
  end

  local dmg_dealt = self.rules:take_damage(selected_monster, self.character.damage, crit_attack)
  self.became_enraged = self.rules:enrage_if_dying(selected_monster, self.atlas)

  return dmg_dealt, crit_attack
end

return Attack