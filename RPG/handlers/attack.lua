
local Attack = require 'common.class' ()

function Attack:_init(stage)
  self.stage = stage
  self.character = self.stage.character
  self.atlas = self.stage.atlas
  self.rules = self.stage.rules

  self.dmg_dealt = 0
  self.crit_attack = false

  self.selected_monster = nil
  self.selected_player = nil
  self.became_enraged = nil
end

function Attack:player(selected_player)
  self.dmg_dealt = self.rules:take_damage(selected_player, self.character.damage)
end

function Attack:monster(selected_monster)
  self.crit_attack = false
  local crit_attempt = math.random()
  if self.character.crit_ensured or crit_attempt < self.character.crit_chance then
    self.crit_attack = true
    self.atlas:flash_crit()
    self.character.crit_ensured = false
  end

  self.dmg_dealt =  self.rules:take_damage(selected_monster, self.character.damage, self.crit_attack)
  self.became_enraged = self.rules:enrage_if_dying(selected_monster, self.atlas)
end

function Attack:enemy(attacker)
  if attacker == "Player" then
    self:monster(self.selected_monster)
  elseif attacker == "Monster" then
    self:player(self.selected_player)
  end
end

function Attack:check_miss(attacker)
  local accuracy = math.random()
  if attacker == "Player" then
    if self.character.crit_ensured then
      return false
    end

    if accuracy > self.selected_monster.evasion then
      return false
    end
  elseif attacker == "Monster" then
    if accuracy > self.selected_player.evasion then
      return false
    end
  end

  return true
end

function Attack:setup_targets(selected_monster, selected_player)
  self.selected_monster = selected_monster
  self.selected_player = selected_player
end

return Attack