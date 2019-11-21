
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
  self.ongoing_state = nil
  self.cursor = nil
  self.atlas = self:view():get('atlas')
  self.monster_index = 0
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

function PlayerTurnState:on_keypressed(key)
  if self.ongoing_state == "fighting" then
    if key == 'down' then
      self:next_monster()
    elseif key == 'up' then
      self:prev_monster()
    elseif key == 'return' or key == 'kpenter' then
      local monster = self.monsters[self.monster_index]
      self.rules:take_damage(monster, self.character.damage)
      self.rules:enrage_if_dying(monster, self.atlas)
      self.rules:remove_if_dead(monster, self.atlas, self.monsters, self.monster_index)

      self.ongoing_state = "choosing_option"
      self.monster_index = 0

      if #self.monsters == 0 then
        return self:pop({ action = "Victory" })
      end

      return self:pop({ action = "Fight", character = self.character, monster = monster })
    end
  else
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

return PlayerTurnState

