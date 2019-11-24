
local Vec = require 'common.vec'
local CharacterStats = require 'view.character_stats'
local TurnCursor = require 'view.turn_cursor'
local ListMenu = require 'view.list_menu'
local UI_Info = require 'view.ui_info'
local State = require 'state'

local PlayerTurnState = require 'common.class' (State)

local TURN_OPTIONS = { 'Fight', 'Skill', 'Item', 'Run' }

local MESSAGES = {
  Victory = "You won the encounter!",
  Run = "You ran away safely.",
  Defeat = "You lost the adventure...",
  Missed = "The attack missed...",
}

function PlayerTurnState:_init(stack)
  self:super(stack)
  self.character = nil
  self.menu = ListMenu(TURN_OPTIONS)

  self.cursor = nil
  self.message = self:view():get('message')

  self.left_dir = Vec(-1, 0)
  self.right_dir = Vec(1, 0)
end

function PlayerTurnState:enter(params)
  self.character = params.current_character
  self.attacker = params.attacker

  self.battlefield = self:view():get('battlefield')
  local _, right, top, _ = self.battlefield.bounds:get()
  self.ui_info = UI_Info(Vec(right + 250, top + 10))
  self:view():add('ui_info', self.ui_info)

  self.atlas = self:view():get('atlas')
  self:add_ui_info_sprites()

  self.character_sprite = self.atlas:get(self.character)
  self.monsters = params.monsters
  self.players = params.players
  self.waiting_time = 0
  self.dmg_dealt = 0

  if self.attacker == "Player" then
    self.ongoing_state = "choosing_option"
    self.selected_monster = nil
    self.monster_index = 0

    self:_show_menu()
    self:_show_cursor()
    self:_show_stats()
  elseif self.attacker == "Monster" then
    if self.character == self.monsters[1] then
      self:setup_delay_animation(1.3, "MonsterTurn")
    else
      self:setup_attack_animation(0.2)
    end
  end
end

function PlayerTurnState:_show_menu()
  local bfbox = self:view():get('battlefield').bounds
  self.menu:reset_cursor()
  self.menu.position:set(bfbox.right + 32, (bfbox.top + bfbox.bottom) / 2)
  self:view():add('turn_menu', self.menu)
end

function PlayerTurnState:_show_cursor()
  self.atlas = self:view():get('atlas')
  local sprite_instance = self.atlas:get(self.character)
  self.cursor = TurnCursor(sprite_instance)
  self:view():add('turn_cursor', self.cursor)
end

function PlayerTurnState:_show_stats()
  local bfbox = self:view():get('battlefield').bounds
  local position = Vec(bfbox.right + 16, bfbox.top)
  local char_stats = CharacterStats(position, self.character)
  self:view():add('char_stats', char_stats)
end

function PlayerTurnState:leave()
  self:view():remove('turn_menu')
  self:view():remove('turn_cursor')
  self:view():remove('char_stats')
  self:view():remove('ui_info')
end

function PlayerTurnState:add_ui_info_sprites()
  for _, v in pairs(self.ui_info.monsters_info) do
    self.atlas:add(v.name, v.pos, v.appearance)
  end
end




function PlayerTurnState:switch_cursor()
  local sprite_instance = self.atlas:get(self.monsters[self.monster_index])
  self.cursor.selected_drawable = sprite_instance
end

function PlayerTurnState:next_monster()
  self.monster_index = self.monster_index + 1
  if self.monster_index == #self.monsters + 1 then
    self.monster_index = 1
  end

  self:switch_cursor()
end

function PlayerTurnState:prev_monster()
  self.monster_index = self.monster_index - 1
  if self.monster_index == 0 then
    self.monster_index = #self.monsters
  end

  self:switch_cursor()
end




--Animations
function PlayerTurnState:setup_delay_animation(delay_duration, return_action)
  self.ongoing_state = "animation"
  self.delay_animation = true
  self.delay_duration = delay_duration
  self.return_action = return_action
  self:view():remove('turn_cursor')
  if MESSAGES[return_action] then
    self:view():get('message'):set(MESSAGES[return_action])
  end
end

function PlayerTurnState:manage_delay_animation(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < self.delay_duration then
    return
  else
    self.waiting_time = 0
    self.delay_animation = false
    if self.return_action == "Missed" then
      self.retreat_animation = true
    elseif self.return_action == "MonsterTurn" then
      self:setup_attack_animation(0.2)
    else
      return self:pop({ action = self.return_action })
    end
  end
end

function PlayerTurnState:setup_attack_animation(walking_duration)
  self.ongoing_state = "animation"
  self.attack_animation = true

  self.walking_duration = walking_duration

  if self.attacker == "Player" then
    self.selected_monster = self.monsters[self.monster_index]
    self.selected_monster_sprite = self.atlas:get(self.selected_monster)
  elseif self.attacker == "Monster" then
    self.player_index = math.random(#self.players)
    self.selected_player = self.players[self.player_index]
    self.selected_player_sprite = self.atlas:get(self.selected_player)
  end

  self:setup_getting_hit_animation(0.2)
end

function PlayerTurnState:manage_attack_animations(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < self.walking_duration then
    if self.attacker == "Player" then
      self:play_walking_animation(dt, self.character_sprite, self.left_dir, 400)
    elseif self.attacker == "Monster" then
      self:play_walking_animation(dt, self.character_sprite, self.right_dir, 400)
    end
  elseif self.waiting_time < self.walking_duration + 0.15 then
    return
  else
    self.waiting_time = 0
    self.attack_animation = false
    self.missed_attack = true

    local accuracy = math.random()
    if self.attacker == "Player" then
      if accuracy > self.selected_monster.evasion then
        self:attack_monster()
        self.getting_hit_animation = true
        self.missed_attack = false
      end
    elseif self.attacker == "Monster" then
      if accuracy > self.selected_player.evasion then
        self:attack_player()
        self.getting_hit_animation = true
        self.missed_attack = false
      end
    end

    if self.missed_attack then
      self:setup_delay_animation(1.5, "Missed")
    end
  end
end

function PlayerTurnState:play_walking_animation(dt, unit_sprite, direction, speed) --luacheck: no self
  local delta_s = direction * speed * dt

  unit_sprite.position:add(delta_s)
end

function PlayerTurnState:setup_getting_hit_animation(shaking_duration)
  self.ongoing_state = "animation"
  self.shaking_duration = shaking_duration
end

function PlayerTurnState:manage_getting_hit_animations(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < self.shaking_duration then
    if self.attacker == "Player" then
      self:play_shaking_animation(dt, self.selected_monster_sprite, self.left_dir)
    elseif self.attacker == "Monster" then
      self:play_shaking_animation(dt, self.selected_player_sprite, self.right_dir)
    end
  elseif self.waiting_time < self.shaking_duration + 0.15 then
    return
  else
    self.waiting_time = 0
    self.getting_hit_animation = false
    self.retreat_animation = true
  end
end

function PlayerTurnState:manage_retreat_animations(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < self.walking_duration then
    if self.attacker == "Player" then
      self:play_walking_animation(dt, self.character_sprite, self.right_dir, 400)
    elseif self.attacker == "Monster" then
      self:play_walking_animation(dt, self.character_sprite, self.left_dir, 400)
    end
  elseif self.waiting_time < self.walking_duration + 0.5 then
    return
  else
    self.waiting_time = 0
    self.retreat_animation = false

    if self.missed_attack then
      return self:pop({})
    end

    if self.attacker == "Player" then
      self.ongoing_state = "choosing_option"
      self.rules:remove_if_dead(self.selected_monster, self.atlas, self.monsters, self.monster_index)
      self.monster_index = 0

      if #self.monsters == 0 then
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
      self.ongoing_state = "monster_turn"
      self.rules:remove_if_dead(self.selected_player, self.atlas, self.players, self.player_index)

      if #self.players == 0 then
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

function PlayerTurnState:play_shaking_animation(dt, unit_sprite, back_direction)
  local speed = 250 * dt
  local delta_s

  if self.waiting_time < self.shaking_duration/2 then
    delta_s = back_direction * speed
  else
    delta_s = back_direction*-1 * speed
  end

  unit_sprite.position:add(delta_s)
end

function PlayerTurnState:setup_run_away_animation()
  self.ongoing_state = "animation"
  self:view():remove('turn_cursor')
  self.run_away_animation = true
  self.run_away_duration = 0.4
end

function PlayerTurnState:manage_run_away_animations(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < self.run_away_duration then
    for i = 1, #self.players do
      local player_sprite = self.atlas:get(self.players[i])
      self:play_walking_animation(dt, player_sprite, self.right_dir, 100)
    end
  elseif self.waiting_time < self.run_away_duration + 0.1 then
    for i = 1, #self.players do
      self.atlas:remove(self.players[i])
    end
    self:view():get('message'):set(MESSAGES["Run"])
  elseif self.waiting_time < self.run_away_duration + 2 then
    return
  else
    self.waiting_time = 0
    self.run_away_animation = false
    return self:pop({ action = "Run" })
  end
end






function PlayerTurnState:attack_player()
  --SOUND: play attack sound
  self.dmg_dealt = self.rules:take_damage(self.selected_player, self.character.damage)
end

function PlayerTurnState:attack_monster()
  self.crit_attack = false
  local crit_attempt = math.random()
  if crit_attempt < self.character.crit_chance then
   --SOUND: play crit attack sound
    self.crit_attack = true
    self.atlas:flash_crit()

  -- else
    --SOUND: play normal attack sound
  end

  self.dmg_dealt = self.rules:take_damage(self.selected_monster, self.character.damage, self.crit_attack)
  self.became_enraged = self.rules:enrage_if_dying(self.selected_monster, self.atlas)
end

function PlayerTurnState:on_keypressed(key)
  if self.ongoing_state == "fighting" then
    if key == 'down' then
      self:next_monster()
    elseif key == 'up' then
      self:prev_monster()
    elseif key == 'return' or key == 'kpenter' then
      self:setup_attack_animation(0.2)
    end
  elseif self.ongoing_state == "choosing_option" then
    if key == 'down' then
      self.menu:next()
    elseif key == 'up' then
      self.menu:previous()
    elseif key == 'return' or key == 'kpenter' then
      local option = TURN_OPTIONS[self.menu:current_option()]
      if option == "Fight" then
        self.ongoing_state = "fighting"
        self:next_monster()
      elseif option == "Run" then
        self.ongoing_state = "running"
        self:setup_run_away_animation()
      else
        -- go to the next character action
        return self:pop({ action = option, character = self.character })
      end
    end
  end
end

function PlayerTurnState:update(dt)
  if self.ongoing_state == "animation" then
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

return PlayerTurnState

