
local Vec = require 'common.vec'
local CharacterStats = require 'view.character_stats'
local TurnCursor = require 'view.turn_cursor'
local ListMenu = require 'view.list_menu'
local UI_Info = require 'view.ui_info'
local Lives = require 'view.lives'
local State = require 'state'
local Animation = require 'handlers.animation'
local Condition = require 'handlers.condition'
local Action = require 'handlers.action'
local Particles = require 'handlers.particles'

local PlayerTurnState = require 'common.class' (State)

local TURN_OPTIONS = { 'Fight', 'Skill', 'Item', 'Run' }

function PlayerTurnState:_init(stack)
  self:super(stack)
  self.character = nil
  self.cursor = nil
  self.message = self:view():get('message')
end

function PlayerTurnState:enter(params)
  self.character = params.current_character
  self.attacker = params.attacker
  self.items = params.items
  self.p_systems = params.p_systems
  self.turn = params.turn
  self.monsters = params.monsters
  self.players = params.players

  self.battlefield = self:view():get('battlefield')
  self.atlas = self:view():get('atlas')
  self.character_sprite = self.atlas:get(self.character)
  self.menu = ListMenu(TURN_OPTIONS)
  self.dmg_dealt = 0

  self:load_ui_elements()
  self.animation = Animation(self)
  self.condition = Condition(self)
  self:load_units()
  self.action = Action(self)
  self.particles = Particles(self)
end

function PlayerTurnState:leave()
  self:view():remove('turn_menu')
  self:view():remove('turn_cursor')
  self:view():remove('char_stats')
  self:view():remove('ui_info')
  self:view():remove('lives')
end

function PlayerTurnState:load_ui_elements()
  local _, right, top, _ = self.battlefield.bounds:get()
  self.ui_info = UI_Info(Vec(right + 250, top + 10))
  self:view():add('ui_info', self.ui_info)
  self.rules:add_ui_sprites(self.atlas, self.ui_info.monsters_info)

  self.lives = Lives()
  self:view():add('lives', self.lives)
  self.rules:add_ui_lives(self.lives, self.atlas, self.players)
  self.rules:add_ui_lives(self.lives, self.atlas, self.monsters)
end

function PlayerTurnState:load_units()
  if self.attacker == "Player" then
    if self.character == self.players[1] then
      self.condition:check_player()
      if self.condition:check_monster() then
        return self:pop({ action = "Victory" })
      end
    end
    self.monster_index = 0
    self.player_index = 0
    self:_show_menu()
    self:_show_cursor()
    self:_show_stats()
  elseif self.attacker == "Monster" then
    if self.character == self.monsters[1] then
      self.turn = 0
      self.animation:setup_delay_animation(2, "MonsterTurn")
    else
      self.animation:setup_attack_animation(55, self.monster_index)
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

function PlayerTurnState:switch_cursor(category)
  local sprite_instance
  if category == "monster" then
    sprite_instance = self.atlas:get(self.monsters[self.monster_index])
  elseif category == "player" then
    sprite_instance = self.atlas:get(self.players[self.player_index])
  end
  self.cursor.selected_drawable = sprite_instance
end

function PlayerTurnState:next_unit(category)
  if category == "monster" then
    self.monster_index = self.monster_index + 1
    if self.monster_index == #self.monsters + 1 then
      self.monster_index = 1
    end
  elseif category == "player" then
    self.player_index = self.player_index + 1
    if self.player_index == #self.players + 1 then
      self.player_index = 1
    end
  end

  self:switch_cursor(category)
end

function PlayerTurnState:prev_unit(category)
  if category == "monster" then
    self.monster_index = self.monster_index - 1
    if self.monster_index == 0 then
      self.monster_index = #self.monsters
    end
  elseif category == "player" then
    self.player_index = self.player_index - 1
    if self.player_index == 0 then
      self.player_index = #self.players
    end
  end

  self:switch_cursor(category)
end

function PlayerTurnState:on_keypressed(key)
  if key == 'down' then
    if self.action.choosing_list == "menu" then
      self.menu:next()
    else
      self:next_unit(self.action.choosing_list)
    end
  elseif key == 'up' then
    if self.action.choosing_list == "menu" then
      self.menu:previous()
    else
      self:prev_unit(self.action.choosing_list)
    end
  elseif key == 'escape' then
    self:cancel_action()
  elseif key == 'return' or key == 'kpenter' then
    if not self.animation.running_animation then
      local action = self.action.function_array[self.action.ongoing_state]
      if action then
        action(self.action)
      end
    end
  end
end

function PlayerTurnState:update(dt)
  self.particles:emit_players_particles(dt)
  self.particles:emit_monsters_particles(dt)
  self.animation:update_animations(dt)
end

return PlayerTurnState

