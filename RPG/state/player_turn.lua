
local Vec = require 'common.vec'
local CharacterStats = require 'view.character_stats'
local TurnCursor = require 'view.turn_cursor'
local ListMenu = require 'view.list_menu'
local State = require 'state'

local PlayerTurnState = require 'common.class' (State)

local TURN_OPTIONS = { 'Fight', 'Skill', 'Item', 'Run' }

function PlayerTurnState:_init(stack)
  self:super(stack)
  self.character = nil
  self.menu = ListMenu(TURN_OPTIONS)
  self.cursor = nil
  self.atlas = self:view():get('atlas')
  self.message = self:view():get('message')

  self.monster = nil
  self.monster_index = 0

  self.ongoing_state = "choosing_option"
  self.walking_animation = false
  self.getting_hit_animation = false
  self.waiting_time = 0
end

function PlayerTurnState:enter(params)
  self.character = params.current_character
  self.monsters = params.monsters
  self:_show_menu()
  self:_show_cursor()
  self:_show_stats()
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

function PlayerTurnState:delay(dt, delay_duration)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time > delay_duration then
    self.delay_ended = true
  end
end

function PlayerTurnState:setup_attack_animation(unit, front_direction, walking_duration)
  self.ongoing_state = "animation"
  self.attack_animation = true
  self.attacking_unit_sprite = self.atlas:get(unit)

  self.front_direction = front_direction
  self.walking_duration = walking_duration

  self.monster = self.monsters[self.monster_index]
  self:setup_getting_hit_animation(self.monster, 0.2)
end

function PlayerTurnState:play_attack_animation(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < self.walking_duration then
    self:play_walking_animation(dt, self.front_direction)
  elseif self.waiting_time < self.walking_duration + 0.5 then
    return
  else
    self:attack_monster()
    self.waiting_time = 0
    self.attack_animation = false
    self.getting_hit_animation = true
    -- play attack sound
  end
end

function PlayerTurnState:play_walking_animation(dt, direction)
  local speed = 400 * dt
  local delta_s = direction * speed

  self.attacking_unit_sprite.position:add(delta_s)
end

function PlayerTurnState:setup_getting_hit_animation(unit, shaking_duration)
  self.hit_unit_sprite = self.atlas:get(unit)
  self.shaking_duration = shaking_duration
end

function PlayerTurnState:play_getting_hit_animation(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < self.shaking_duration then
    self:play_shaking_animation(dt)
  elseif self.waiting_time < self.shaking_duration + 0.5 then
    return
  elseif self.waiting_time < self.shaking_duration + 0.5 + self.walking_duration then
    self:play_walking_animation(dt, self.front_direction*-1)
  elseif self.waiting_time < self.shaking_duration + 1.5 + self.walking_duration then
    return
  else
    self.waiting_time = 0
    self.getting_hit_animation = false
    self.ongoing_state = "choosing_option"
    self.rules:remove_if_dead(self.monster, self.atlas, self.monsters, self.monster_index)
    if #self.monsters == 0 then
      return self:pop({ action = "Victory" })
    end

    return self:pop({ action = "Fight", character = self.character, monster = self.monster })
  end
end

function PlayerTurnState:play_shaking_animation(dt)
  local speed = 250 * dt
  local delta_s

  if self.waiting_time < self.shaking_duration/2 then
    delta_s = self.front_direction * speed
  else
    delta_s = self.front_direction*-1 * speed
  end

  self.hit_unit_sprite.position:add(delta_s)
end

function PlayerTurnState:attack_monster()
  self.monster = self.monsters[self.monster_index]
  self.rules:take_damage(self.monster, self.character.damage)
  self.rules:enrage_if_dying(self.monster, self.atlas)
  self.monster_index = 0
end

function PlayerTurnState:on_keypressed(key)
  if self.ongoing_state == "fighting" then
    if key == 'down' then
      self:next_monster()
    elseif key == 'up' then
      self:prev_monster()
    elseif key == 'return' or key == 'kpenter' then
      self:setup_attack_animation(self.character, Vec(-1, 0), 0.2)
      --
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
      else
        -- go to the next character action
        return self:pop({ action = option, character = self.character })
      end
    end
  end
end

function PlayerTurnState:update(dt)
  if self.attack_animation then
    self:play_attack_animation(dt)
  elseif self.getting_hit_animation then
    self:play_getting_hit_animation(dt)
  end
end

return PlayerTurnState

