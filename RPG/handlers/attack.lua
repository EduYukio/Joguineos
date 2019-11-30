
local SOUNDS_DB = require 'database.sounds'

local Attack = require 'common.class' ()

function Attack:_init(stage)
  self.stage = stage
  self.character = self.stage.character
  self.atlas = self.stage.atlas
  self.rules = self.stage.rules
  self.players = self.stage.players
  self.monsters = self.stage.monsters
  self.lives = self.stage.lives

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

function Attack:player_aftermath()
  self.stage.ongoing_state = "choosing_option"
  self.rules:remove_if_dead(self.selected_monster, self.atlas, self.monsters, self.stage.monster_index, self.lives)
  self.stage.monster_index = 0

  if #self.monsters == 0 then
    SOUNDS_DB.fanfare:play()
    return "Victory"
  end

  return self.stage:pop({
    action = "Fight",
    character = self.character,
    selected = self.selected_monster,
    became_enraged = self.became_enraged,
    dmg_dealt = self.dmg_dealt,
    crit_attack = self.crit_attack,
  })
end

function Attack:monster_aftermath()
  self.stage.ongoing_state = "monster_turn"
  self.rules:remove_if_dead(self.selected_player, self.atlas, self.players, self.stage.player_index, self.lives)
  self.stage.player_index = 0

  if #self.players == 0 then
    SOUNDS_DB.game_over:play()
    return "Defeat"
  end

  return self.stage:pop({
    action = "Fight",
    character = self.character,
    selected = self.selected_player,
    dmg_dealt = self.dmg_dealt,
  })
end

function Attack:aftermath(attacker)
  if attacker == "Player" then
    return self:player_aftermath()
  elseif attacker == "Monster" then
    return self:monster_aftermath()
  end
end

return Attack