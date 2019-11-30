
local Vec = require 'common.vec'
local CharacterStats = require 'view.character_stats'
local TurnCursor = require 'view.turn_cursor'
local ListMenu = require 'view.list_menu'
local UI_Info = require 'view.ui_info'
local Lives = require 'view.lives'
local State = require 'state'
local SOUNDS_DB = require 'database.sounds'
local Animation = require 'handlers.animation'
local Condition = require 'handlers.condition'

local PlayerTurnState = require 'common.class' (State)

local TURN_OPTIONS = { 'Fight', 'Skill', 'Item', 'Run' }

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

local MSG_COMPLEMENTS = {
  ["Heal"] = "healing 10 points.",
  ["War Cry"] = "ensuring the next\nattack is critical.",
  ["Charm"] = "reducing its\nresistance to 0 for 1 attack.",
  ["Energy Drink"] = "increasing the\nevasion for 2 turns!",
  ["Mud Slap"] = "decreasing the\nevasion for 2 turns!",
  ["Spinach"] = "raising the strength\nfor 2 turns!",
  ["Bandejao's Fish"] = "poisoning him\nfor 2 turns!",
}

function PlayerTurnState:_init(stack)
  self:super(stack)
  self.character = nil
  self.cursor = nil
  self.message = self:view():get('message')

  self.function_array = {
    fighting = self.fighting,
    choosing_skill = self.choosing_skill,
    using_skill = self.using_skill,
    choosing_item = self.choosing_item,
    using_item = self.using_item,
    choosing_option = self.choosing_option,
  }
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
    self.ongoing_state = "choosing_option"
    self.choosing_list = "menu"
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





function PlayerTurnState:cancel_action()
  self.ongoing_state = "choosing_option"
  self.choosing_list = "menu"
  self.menu = ListMenu(TURN_OPTIONS)
  self:_show_menu()
  self.monster_index = 0
  for i, player in ipairs(self.players) do
    if player == self.character then
      self.player_index = i
    end
  end
  self:switch_cursor("player")
end

function PlayerTurnState:fighting()
  SOUNDS_DB.select_menu:play()
  self.animation:setup_attack_animation(55, self.monster_index)
end

function PlayerTurnState:choosing_skill()
  SOUNDS_DB.select_menu:play()
  self.selected_skill = self.character.skill_set[self.menu:current_option()]
  if self.character.mana > 0 then
    if self.selected_skill == "Charm" then
      self:select_target("monster", "skill")
    else
      self.player_index = 0
      self:select_target("player", "skill")
    end
  else
    SOUNDS_DB.fail:play()
    self:view():get('message'):set(MESSAGES.NoMana)
    self.ongoing_state = "choosing_option"
    self.choosing_list = "menu"
    self.menu = ListMenu(TURN_OPTIONS)
    self:_show_menu()
  end
end

function PlayerTurnState:select_target(unit_category, usable_category)
  local message
  local state
  if usable_category == "item" then
    message = MESSAGES.ChooseItemTarget
    state = "using_item"
  elseif usable_category == "skill" then
    message = MESSAGES.ChooseSkillTarget
    state = "using_skill"
  end
  self:next_unit(unit_category)
  self.ongoing_state = state
  self.choosing_list = unit_category
  self:view():remove('turn_menu', self.menu)
  self:view():get('message'):set(message)
end

function PlayerTurnState:using_skill()
  SOUNDS_DB.select_menu:play()
  if self.choosing_list == "monster" then
    self.target = self.monsters[self.monster_index]
  elseif self.choosing_list == "player" then
    self.target = self.players[self.player_index]
  end
  self.rules:cast_skill(self.target, self.selected_skill, self.turn)
  self.character.mana = self.character.mana - 1

  return self:pop({
    action = "Skill",
    character = self.character,
    skill_or_item = self.selected_skill,
    selected = self.target,
    msg_complement = MSG_COMPLEMENTS[self.selected_skill],
  })
end

function PlayerTurnState:choosing_item()
  SOUNDS_DB.select_menu:play()
  self.item_index = self.menu:current_option()
  self.selected_item = self.items[self.item_index]
  if self.selected_item == "Mud Slap" or self.selected_item == "Bandejao's Fish" then
    self.monster_index = 0
    self:select_target("monster", "item")
  else
    self.player_index = 0
    self:select_target("player", "item")
  end
end

function PlayerTurnState:using_item()
  SOUNDS_DB.select_menu:play()
  if self.choosing_list == "monster" then
    self.target = self.monsters[self.monster_index]
  elseif self.choosing_list == "player" then
    self.target = self.players[self.player_index]
  end
  self.rules:use_item(self.target, self.selected_item, self.items, self.item_index, self.turn)

  return self:pop({
    action = "Item",
    character = self.character,
    skill_or_item = self.selected_item,
    selected = self.target,
    msg_complement = MSG_COMPLEMENTS[self.selected_item],
  })
end

function PlayerTurnState:setup_fight_option()
  self.ongoing_state = "fighting"
  self.choosing_list = "monster"
  self:next_unit("monster")
end

function PlayerTurnState:setup_run_option()
  self.ongoing_state = "running_away"
  self.animation:setup_run_away_animation()
end

function PlayerTurnState:setup_skill_option()
  self.ongoing_state = "choosing_skill"
  self.choosing_list = "menu"
  self:view():remove('turn_menu', self.menu)
  self.menu = ListMenu(self.character.skill_set)
  self:_show_menu()
end

function PlayerTurnState:setup_item_option()
  if #self.items == 0 then
    SOUNDS_DB.fail:play()
    self:view():get('message'):set(MESSAGES.NoItems)
    self.ongoing_state = "choosing_option"
  else
    self:view():remove('turn_menu', self.menu)
    self.menu = ListMenu(self.items, "items")
    self:_show_menu()
    self.ongoing_state = "choosing_item"
  end
  self.choosing_list = "menu"
end

function PlayerTurnState:choosing_option()
  SOUNDS_DB.select_menu:play()
  local option = TURN_OPTIONS[self.menu:current_option()]
  if option == "Fight" then
    self:setup_fight_option()
  elseif option == "Run" then
    self:setup_run_option()
  elseif option == "Skill" then
    self:setup_skill_option()
  elseif option == "Item" then
    self:setup_item_option()
  end
end

function PlayerTurnState:on_keypressed(key)
  if key == 'down' then
    if self.choosing_list == "menu" then
      self.menu:next()
    else
      self:next_unit(self.choosing_list)
    end
  elseif key == 'up' then
    if self.choosing_list == "menu" then
      self.menu:previous()
    else
      self:prev_unit(self.choosing_list)
    end
  elseif key == 'escape' then
    self:cancel_action()
  elseif key == 'return' or key == 'kpenter' then
    local action = self.function_array[self.ongoing_state]
    if action then
      action(self)
    end
  end
end

function PlayerTurnState:emit_players_particles(dt)
  for _, player in pairs(self.players) do
    if player.crit_ensured then
      player.p_systems.dark_red:emit(1)
    end

    if player.energized then
      player.p_systems.light_blue:emit(1)
    end

    if player.empowered then
      player.p_systems.orange:emit(1)
    end

    for _, p_system in pairs(player.p_systems) do
      p_system:update(dt)
    end
  end
end

function PlayerTurnState:emit_monsters_particles(dt)
  for _, monster in pairs(self.monsters) do
    if monster.charmed then
      monster.p_systems.pink:emit(1)
    end

    if monster.poisoned then
      monster.p_systems.pure_black:emit(1)
    end

    if monster.sticky then
      monster.p_systems.dark_blue:emit(1)
    end

    for _, p_system in pairs(monster.p_systems) do
      p_system:update(dt)
    end
  end
end

function PlayerTurnState:update(dt)
  self:emit_players_particles(dt)
  self:emit_monsters_particles(dt)

  if self.ongoing_state == "animation" then
    self.animation:update_animations(dt)
  end
end

return PlayerTurnState

