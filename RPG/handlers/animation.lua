
local Vec = require 'common.vec'
local Attack = require 'handlers.attack'

local MESSAGES = {
  Victory = "You won the encounter!",
  Run = "You ran away safely.",
  Defeat = "You lost the adventure...",
  Missed = "The attack missed...",
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
  self.character_sprite = self.stage.character_sprite

  self.rules = self.stage.rules
  self.selected_monster = nil
  self.running_animation = false

  self.attack = Attack(stage)
  self.waiting_time = 0
  self.left_dir = Vec(-1, 0)
  self.right_dir = Vec(1, 0)
end

function Animation:setup_delay_animation(delay_duration, return_action)
  self.running_animation = true
  self.delay_animation = true
  self.delay_duration = delay_duration
  self.return_action = return_action
  self.stage:view():remove('turn_cursor')

  if MESSAGES[return_action] then
    self.stage:view():get('message'):set(MESSAGES[return_action])
  end
end

function Animation:manage_delay_animation(dt)
  self.waiting_time = self.waiting_time + dt
  local act = self.return_action
  if self.waiting_time < self.delay_duration then
    return
  else
    self.waiting_time = 0
    self.delay_animation = false
    if act == "Missed" then
      self.retreat_animation = true
    elseif act == "MonsterTurn" then
      self:setup_attack_animation(55, self.monster_index)
    elseif act == "Victory" or act == "Defeat" then
      return self.stage:pop({ action = self.return_action })
    end
  end
end

function Animation:setup_attack_animation(walking_length, monster_index)
  self.running_animation = true
  self.attack_animation = true
  self.walked_length = 0
  self.walking_length = walking_length
  self.monster_index = monster_index

  if self.attacker == "Player" then
    self.selected_monster = self.monsters[monster_index]
    self.selected_monster_sprite = self.atlas:get(self.selected_monster)
  elseif self.attacker == "Monster" then
    self.stage.player_index = math.random(#self.players)
    self.selected_player = self.players[self.stage.player_index]
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
  elseif self.waiting_time < 0.3 then
    self.waiting_time = self.waiting_time + dt
  else
    self.walked_length = 0
    self.waiting_time = 0
    self.attack_animation = false
    self.attack:setup_targets(self.selected_monster, self.selected_player)
    self.missed_attack = self.attack:check_miss(self.attacker)
    if self.missed_attack then
      self:setup_delay_animation(1.5, "Missed")
    else
      self.attack:enemy(self.attacker)
      self.getting_hit_animation = true
    end
  end
end

function Animation:play_walking_animation(dt, unit_sprite, direction, speed)
  local delta_s = direction * speed * dt

  self.walked_length = self.walked_length + speed * dt
  self.lives:add_position(unit_sprite, delta_s)
  self.p_systems:add_position(self.character, delta_s)
  unit_sprite.position:add(delta_s)
end

function Animation:setup_getting_hit_animation(shaking_length)
  self.running_animation = true
  self.shaking_length = shaking_length
end

function Animation:manage_getting_hit_animations(dt)
  if self.walked_length < self.shaking_length then
    if self.attacker == "Player" then
      self:play_shaking_animation(dt, self.selected_monster,
           self.selected_monster_sprite, self.left_dir)
    elseif self.attacker == "Monster" then
      self:play_shaking_animation(dt, self.selected_player,
           self.selected_player_sprite, self.right_dir)
    end
  elseif self.waiting_time < 0.3 then
    self.waiting_time = self.waiting_time + dt
  else
    self.walked_length = 0
    self.waiting_time = 0
    self.getting_hit_animation = false
    self.retreat_animation = true
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
  else
    self.walked_length = 0
    self.waiting_time = 0
    self.retreat_animation = false
    if self.missed_attack then
      return self.stage:pop({})
    end
    self.aftermath = self.attack:aftermath(self.attacker)
    if self.aftermath == "Victory" or self.aftermath == "Defeat" then
      self:setup_delay_animation(2.5, self.aftermath)
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
  self.running_animation = true
  self.stage:view():remove('turn_cursor')
  self.run_away_animation = true
  self.run_away_duration = 0.4
  self.walked_length = 0
end

function Animation:manage_run_away_animations(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < self.run_away_duration then
    for _, player in pairs(self.players) do
      self.p_systems:reset_all(player)
      self.rules:reset_conditions(player)
      self:play_walking_animation(dt, self.atlas:get(player), self.right_dir, 100)
    end
  elseif self.waiting_time < self.run_away_duration + 0.1 then
    for _, player in pairs(self.players) do
      self.lives:remove(self.atlas:get(player))
      self.atlas:remove(player)
    end
    self.stage:view():get('message'):set(MESSAGES["Run"])
  elseif self.waiting_time < self.run_away_duration + 2 then
    return
  else
    self.waiting_time = 0
    self.run_away_animation = false
    return self.stage:pop({ action = "Run" })
  end
end

function Animation:update_animations(dt)
  if self.running_animation then
    if self.attack_animation then
      self:manage_attack_animations(dt)
    elseif self.getting_hit_animation then
      self:manage_getting_hit_animations(dt)
    elseif self.run_away_animation then
      self:manage_run_away_animations(dt)
    elseif self.delay_animation then
      self:manage_delay_animation(dt)
    elseif self.retreat_animation then
      self:manage_retreat_animations(dt)
    end
  end
end

return Animation
