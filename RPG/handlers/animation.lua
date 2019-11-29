
local SOUNDS_DB = require 'database.sounds'
local Vec = require 'common.vec'

local MESSAGES = {
  Victory = "You won the encounter!",
  Run = "You ran away safely.",
  Defeat = "You lost the adventure...",
  Missed = "The attack missed...",
  NoMana = "Not enough mana.",
  NoItems = "You don\'t have items.",
  ChooseSkillTarget = "Select the target of the skill.",
  ChooseItemTarget = "Select the target of the item.",
}

local Animation = require 'common.class' ()

function Animation:_init(stage)
  self.stage = stage
  self.attacker = self.stage.attacker
  self.character = self.stage.character
  self.atlas = self.stage.atlas
  self.lives = self.stage.lives
  self.p_systems = self.stage.p_systems
  self.monsters = self.stage.monsters
  self.players = self.stage.players

  self.selected_monster = self.stage.selected_monster
  self.character_sprite = self.stage.character_sprite

  self.monster_index = self.stage.monster_index
  self.player_index = self.stage.player_index

  self.waiting_time = 0
  self.left_dir = Vec(-1, 0)
  self.right_dir = Vec(1, 0)
end

function Animation:setup_delay_animation(delay_duration, return_action)
  self.stage.ongoing_state = "animation"
  self.stage.delay_animation = true
  self.delay_duration = delay_duration
  self.return_action = return_action
  self:view():remove('turn_cursor')
  if MESSAGES[return_action] then
    self:view():get('message'):set(MESSAGES[return_action])
  end
end

function Animation:manage_delay_animation(dt)
  self.waiting_time = self.waiting_time + dt
  local act = self.return_action
  if self.waiting_time < self.delay_duration then
    return
  else
    self.waiting_time = 0
    self.stage.delay_animation = false
    if act == "Missed" then
      self.stage.retreat_animation = true
    elseif act == "MonsterTurn" then
      self:setup_attack_animation(55)
    elseif act == "Victory" or act == "Defeat" then
      return self:pop({ action = self.return_action })
    end
  end
end

function Animation:setup_attack_animation(walking_length)
  self.stage.ongoing_state = "animation"
  self.stage.attack_animation = true

  self.walked_length = 0
  self.walking_length = walking_length

  if self.attacker == "Player" then
    self.selected_monster = self.monsters[self.monster_index]
    self.selected_monster_sprite = self.atlas:get(self.selected_monster)
  elseif self.attacker == "Monster" then
    self.player_index = math.random(#self.players)
    self.selected_player = self.players[self.player_index]
    self.selected_player_sprite = self.atlas:get(self.selected_player)
  end

  self:setup_getting_hit_animation(40)
end

function Animation:manage_attack_animations(dt)
  if self.walked_length < self.walking_length then
    if self.attacker == "Player" then
      self:play_walking_animation(dt, self.character_sprite, self.left_dir, 400)
    elseif self.attacker == "Monster" then
      self:play_walking_animation(dt, self.character_sprite, self.right_dir, 400)
    end
  elseif self.waiting_time < 0.4 then
    self.waiting_time = self.waiting_time + dt
    return
  else
    self.walked_length = 0
    self.waiting_time = 0
    self.stage.attack_animation = false
    self.missed_attack = true

    local accuracy = math.random()
    if self.attacker == "Player" then
      if self.character.crit_ensured or accuracy > self.selected_monster.evasion then
        self.stage:attack_monster()
        self.stage.getting_hit_animation = true
        self.missed_attack = false
      end
    elseif self.attacker == "Monster" then
      if accuracy > self.selected_player.evasion then
        self.stage:attack_player()
        self.stage.getting_hit_animation = true
        self.missed_attack = false
      end
    end

    if self.missed_attack then
      self:setup_delay_animation(1.5, "Missed")
    end
  end
end

function Animation:play_walking_animation(dt, unit_sprite, direction, speed) --luacheck: no self
  local delta_s = direction * speed * dt

  self.walked_length = self.walked_length + speed * dt
  self.lives:add_position(unit_sprite, delta_s)
  self.p_systems:add_position(self.character, delta_s)
  unit_sprite.position:add(delta_s)
end

function Animation:setup_getting_hit_animation(shaking_length)
  self.stage.ongoing_state = "animation"
  self.shaking_length = shaking_length
end

function Animation:manage_getting_hit_animations(dt)
  if self.walked_length < self.shaking_length then
    if self.attacker == "Player" then
      self:play_shaking_animation(dt, self.selected_monster, self.selected_monster_sprite, self.left_dir)
    elseif self.attacker == "Monster" then
      self:play_shaking_animation(dt, self.selected_player, self.selected_player_sprite, self.right_dir)
    end
  elseif self.waiting_time < 0.4 then
    self.waiting_time = self.waiting_time + dt
    return
  else
    self.walked_length = 0
    self.waiting_time = 0
    self.stage.getting_hit_animation = false
    self.stage.retreat_animation = true
  end
end

function Animation:manage_retreat_animations(dt)
  if self.walked_length < self.walking_length then
    if self.attacker == "Player" then
      self:play_walking_animation(dt, self.character_sprite, self.right_dir, 400)
    elseif self.attacker == "Monster" then
      self:play_walking_animation(dt, self.character_sprite, self.left_dir, 400)
    end
  elseif self.waiting_time < 0.5 then
    self.waiting_time = self.waiting_time + dt
    return
  else
    self.walked_length = 0
    self.waiting_time = 0
    self.stage.retreat_animation = false

    if self.missed_attack then
      return self:pop({})
    end

    if self.attacker == "Player" then
      self.stage.ongoing_state = "choosing_option"
      self.rules:remove_if_dead(self.selected_monster, self.atlas, self.monsters, self.monster_index, self.lives)
      self.monster_index = 0

      if #self.monsters == 0 then
        SOUNDS_DB.fanfare:play()
        self:setup_delay_animation(2.5, "Victory")
        return
      end

      return self:pop({
        action = "Fight",
        character = self.character,
        selected = self.selected_monster,
        dmg_dealt = self.dmg_dealt,
        became_enraged = self.became_enraged,
        crit_attack = self.crit_attack,
      })
    elseif self.attacker == "Monster" then
      self.stage.ongoing_state = "monster_turn"
      self.rules:remove_if_dead(self.selected_player, self.atlas, self.players, self.player_index, self.lives)
      self.player_index = 0

      if #self.players == 0 then
        SOUNDS_DB.game_over:play()
        self:setup_delay_animation(2.5, "Defeat")
        return
      end

      return self:pop({
        action = "Fight",
        character = self.character,
        selected = self.selected_player,
        dmg_dealt = self.dmg_dealt,
      })
    end
  end
end

function Animation:play_shaking_animation(dt, unit, unit_sprite, back_direction)
  local speed = 250 * dt
  local delta_s

  if self.walked_length < self.shaking_length/2 then
    delta_s = back_direction * speed
  else
    delta_s = back_direction*-1 * speed
  end

  self.walked_length = self.walked_length + speed
  self.lives:add_position(unit_sprite, delta_s)
  self.p_systems:add_position(unit, delta_s)
  unit_sprite.position:add(delta_s)
end

function Animation:setup_run_away_animation()
  self.stage.ongoing_state = "animation"
  self:view():remove('turn_cursor')
  self.stage.run_away_animation = true
  self.run_away_duration = 0.4
  self.walked_length = 0
end

function Animation:manage_run_away_animations(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < self.run_away_duration then
    for _, player in pairs(self.players) do
      self.p_systems:reset_all(player)
      self.rules:reset_conditions(player)

      local player_sprite = self.atlas:get(player)
      self:play_walking_animation(dt, player_sprite, self.right_dir, 100)
    end
  elseif self.waiting_time < self.run_away_duration + 0.1 then
    for _, player in pairs(self.players) do
      local player_sprite = self.atlas:get(player)
      self.atlas:remove(player)
      self.lives:remove(player_sprite)
    end
    self:view():get('message'):set(MESSAGES["Run"])
  elseif self.waiting_time < self.run_away_duration + 2 then
    return
  else
    self.waiting_time = 0
    self.stage.run_away_animation = false
    return self:pop({ action = "Run" })
  end
end

return Animation
