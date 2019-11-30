
local Vec = require 'common.vec'
local CharacterStats = require 'view.character_stats'
local TurnCursor = require 'view.turn_cursor'
local ListMenu = require 'view.list_menu'
local UI_Info = require 'view.ui_info'
local Lives = require 'view.lives'
local State = require 'state'
local p = require 'database.properties'
local SOUNDS_DB = require 'database.sounds'
local Animation = require 'handlers.animation'

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
  ["Charm"] = "reducing its\nresistance to 0.",
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


end

function PlayerTurnState:enter(params)
  self.character = params.current_character
  self.attacker = params.attacker
  self.items = params.items
  self.p_systems = params.p_systems
  self.turn = params.turn

  self.battlefield = self:view():get('battlefield')
  self.atlas = self:view():get('atlas')

  self.menu = ListMenu(TURN_OPTIONS)

  self.character_sprite = self.atlas:get(self.character)
  self.monsters = params.monsters
  self.players = params.players
  self.dmg_dealt = 0

  local _, right, top, _ = self.battlefield.bounds:get()
  self.ui_info = UI_Info(Vec(right + 250, top + 10))
  self:view():add('ui_info', self.ui_info)
  self.rules:add_ui_sprites(self.atlas, self.ui_info.monsters_info)

  self.lives = Lives()
  self:view():add('lives', self.lives)
  self.rules:add_ui_lives(self.lives, self.atlas, self.players)
  self.rules:add_ui_lives(self.lives, self.atlas, self.monsters)

  self.animation = Animation(self)
  if self.attacker == "Player" then
    if self.character == self.players[1] then
      self:check_condition_turns()
    end
    self.ongoing_state = "choosing_option"
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

function PlayerTurnState:check_condition_turns()
  for _, player in pairs(self.players) do
    if player.empowered then
      if self.turn - player.empowered.turn == self.p_systems:get_lifetime(player, "orange") then
        player.empowered = false
      end
    end
    if player.energized then
      if self.turn - player.energized.turn == self.p_systems:get_lifetime(player, "light_blue") then
        player.energized = false
      end
    end
  end

  for i, monster in pairs(self.monsters) do
    if monster.sticky then
      if self.turn - monster.sticky.turn == self.p_systems:get_lifetime(monster, "dark_blue") then
        monster.sticky = false
      end
    end
    if monster.poisoned then
      if self.turn - monster.poisoned.turn == self.p_systems:get_lifetime(monster, "pure_black") then
        monster.poisoned = false
      end
      SOUNDS_DB.unit_take_hit:play()
      monster.hp = monster.hp - p.poison_dmg
      local spr = self.atlas:get(monster)
      self.lives:upgrade_life(spr, monster.hp)

      local died = self.rules:remove_if_dead(monster, self.atlas, self.monsters, i, self.lives)
      local msg = monster.name .. " took " .. tostring(p.poison_dmg) .. " damage from poison."

      if died then
        msg = msg .. "\nIt died from bandejao's mighty fish..."
      end

      self:view():get('message'):set(msg)
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
  self:view():remove('lives')
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




--Animations
--



function PlayerTurnState:on_keypressed(key)
  if self.ongoing_state == "fighting" then
    if key == 'down' then
      self:next_unit("monster")
    elseif key == 'up' then
      self:prev_unit("monster")
    elseif key == 'return' or key == 'kpenter' then
      SOUNDS_DB.select_menu:play()
      self.animation:setup_attack_animation(55, self.monster_index)
    end
  elseif self.ongoing_state == "choosing_skill" then
    if key == 'down' then
      self.menu:next()
    elseif key == 'up' then
      self.menu:previous()
    elseif key == 'escape' then
      self.ongoing_state = "choosing_option"
      self.menu = ListMenu(TURN_OPTIONS)
      self:_show_menu()
    elseif key == 'return' or key == 'kpenter' then
      SOUNDS_DB.select_menu:play()
      self.selected_skill = self.character.skill_set[self.menu:current_option()]
      if self.character.mana > 0 then
        if self.selected_skill == "Charm" then
          self:next_unit("monster")
          self.ongoing_state = "using_skill_on_monster"
          self:view():remove('turn_menu', self.menu)
          self:view():get('message'):set(MESSAGES.ChooseTarget)
        else
          self:next_unit("player")
          self.ongoing_state = "using_skill_on_player"
          self:view():remove('turn_menu', self.menu)
          self:view():get('message'):set(MESSAGES.ChooseTarget)
        end
        self.character.mana = self.character.mana - 1
      else
        SOUNDS_DB.fail:play()
        self:view():get('message'):set(MESSAGES.NoMana)
        self.ongoing_state = "choosing_option"
        self.menu = ListMenu(TURN_OPTIONS)
        self:_show_menu()
      end
    end
  elseif self.ongoing_state == "using_skill_on_player" then
    if key == 'down' then
      self:next_unit("player")
    elseif key == 'up' then
      self:prev_unit("player")
    elseif key == 'return' or key == 'kpenter' then
      SOUNDS_DB.select_menu:play()
      local target = self.players[self.player_index]
      self.rules:cast_skill(target, self.selected_skill, self.turn)

      return self:pop({
        action = "Skill",
        character = self.character,
        skill_or_item = self.selected_skill,
        selected = target,
        msg_complement = MSG_COMPLEMENTS[self.selected_skill],
      })
    end
  elseif self.ongoing_state == "using_skill_on_monster" then
    if key == 'down' then
      self:next_unit("monster")
    elseif key == 'up' then
      self:prev_unit("monster")
    elseif key == 'return' or key == 'kpenter' then
      SOUNDS_DB.select_menu:play()
      local target = self.monsters[self.monster_index]
      self.rules:cast_skill(target, self.selected_skill, self.turn)

      return self:pop({
        action = "Skill",
        character = self.character,
        skill_or_item = self.selected_skill,
        selected = target,
        msg_complement = MSG_COMPLEMENTS[self.selected_skill],
      })
    end
  elseif self.ongoing_state == "choosing_item" then
    if key == 'down' then
      self.menu:next()
    elseif key == 'up' then
      self.menu:previous()
    elseif key == 'escape' then
      self.ongoing_state = "choosing_option"
      self.menu = ListMenu(TURN_OPTIONS)
      self:_show_menu()
    elseif key == 'return' or key == 'kpenter' then
      SOUNDS_DB.select_menu:play()
      self.item_index = self.menu:current_option()
      self.selected_item = self.items[self.item_index]
      if self.selected_item == "Mud Slap" or self.selected_item == "Bandejao's Fish" then
        self:next_unit("monster")
        self.ongoing_state = "using_item_on_monster"
        self:view():remove('turn_menu', self.menu)
        self:view():get('message'):set(MESSAGES.ChooseItemTarget)
      else
        self:next_unit("player")
        self.ongoing_state = "using_item_on_player"
        self:view():remove('turn_menu', self.menu)
        self:view():get('message'):set(MESSAGES.ChooseItemTarget)
      end
    end
  elseif self.ongoing_state == "using_item_on_player" then
    if key == 'down' then
      self:next_unit("player")
    elseif key == 'up' then
      self:prev_unit("player")
    elseif key == 'return' or key == 'kpenter' then
      SOUNDS_DB.select_menu:play()
      local target = self.players[self.player_index]
      self.rules:use_item(target, self.selected_item, self.items, self.item_index, self.turn)

      return self:pop({
        action = "Item",
        character = self.character,
        skill_or_item = self.selected_item,
        selected = target,
        msg_complement = MSG_COMPLEMENTS[self.selected_item],
      })
    end
  elseif self.ongoing_state == "using_item_on_monster" then
    if key == 'down' then
      self:next_unit("monster")
    elseif key == 'up' then
      self:prev_unit("monster")
    elseif key == 'return' or key == 'kpenter' then
      SOUNDS_DB.select_menu:play()
      local target = self.monsters[self.monster_index]
      self.rules:use_item(target, self.selected_item, self.items, self.item_index, self.turn)

      return self:pop({
        action = "Item",
        character = self.character,
        skill_or_item = self.selected_item,
        selected = target,
        msg_complement = MSG_COMPLEMENTS[self.selected_item],
      })
    end
  elseif self.ongoing_state == "choosing_option" then
    if key == 'down' then
      self.menu:next()
    elseif key == 'up' then
      self.menu:previous()
    elseif key == 'return' or key == 'kpenter' then
      SOUNDS_DB.select_menu:play()
      local option = TURN_OPTIONS[self.menu:current_option()]
      if option == "Fight" then
        self.ongoing_state = "fighting"
        self:next_unit("monster")
      elseif option == "Run" then
        self.ongoing_state = "running_away"
        self.animation:setup_run_away_animation()
      elseif option == "Skill" then
        self.ongoing_state = "choosing_skill"
        self:view():remove('turn_menu', self.menu)
        self.menu = ListMenu(self.character.skill_set)
        self:_show_menu()
      elseif option == "Item" then
        if #self.items == 0 then
          SOUNDS_DB.fail:play()
          self:view():get('message'):set(MESSAGES.NoItems)
          self.ongoing_state = "choosing_option"
        else
          self.ongoing_state = "choosing_item"
          self:view():remove('turn_menu', self.menu)
          self.menu = ListMenu(self.items, "items")
          self:_show_menu()
        end
      end
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

