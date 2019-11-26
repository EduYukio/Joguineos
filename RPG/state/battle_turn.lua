
local Vec = require 'common.vec'
local CharacterStats = require 'view.character_stats'
local TurnCursor = require 'view.turn_cursor'
local ListMenu = require 'view.list_menu'
local UI_Info = require 'view.ui_info'
local Lives = require 'view.lives'
local State = require 'state'
local p = require 'database.properties'

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

  self.left_dir = Vec(-1, 0)
  self.right_dir = Vec(1, 0)
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
  self.waiting_time = 0
  self.dmg_dealt = 0

  local _, right, top, _ = self.battlefield.bounds:get()
  self.ui_info = UI_Info(Vec(right + 250, top + 10))
  self:view():add('ui_info', self.ui_info)
  self:add_ui_info_sprites()

  self.lives = Lives()
  self:view():add('lives', self.lives)
  self:add_ui_lives()

  if self.attacker == "Player" then
    if self.character == self.players[1] then
      self:check_condition_turns()
    end
    self.ongoing_state = "choosing_option"
    self.selected_monster = nil
    self.monster_index = 0
    self.player_index = 0

    self:_show_menu()
    self:_show_cursor()
    self:_show_stats()
  elseif self.attacker == "Monster" then
    if self.character == self.monsters[1] then
      self.turn = 0
      self:setup_delay_animation(2, "MonsterTurn")
    else
      self:setup_attack_animation(55)
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

function PlayerTurnState:add_ui_info_sprites()
  for _, v in pairs(self.ui_info.monsters_info) do
    self.atlas:add(v.name, v.pos, v.appearance)
  end
end

function PlayerTurnState:add_ui_lives()
  for _, player in pairs(self.players) do
    local spr = self.atlas:get(player)
    self.lives:add(spr, player.hp, player.max_hp)
  end

  for _, monster in pairs(self.monsters) do
    local spr = self.atlas:get(monster)
    self.lives:add(spr, monster.hp, monster.max_hp)
  end
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
  local act = self.return_action
  if self.waiting_time < self.delay_duration then
    return
  else
    self.waiting_time = 0
    self.delay_animation = false
    if act == "Missed" then
      self.retreat_animation = true
    elseif act == "MonsterTurn" then
      self:setup_attack_animation(55)
    elseif act == "Victory" or act == "Defeat" then
      return self:pop({ action = self.return_action })
    end
  end
end

function PlayerTurnState:setup_attack_animation(walking_length)
  self.ongoing_state = "animation"
  self.attack_animation = true

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

function PlayerTurnState:manage_attack_animations(dt)
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
    self.attack_animation = false
    self.missed_attack = true

    local accuracy = math.random()
    if self.attacker == "Player" then
      if self.character.crit_ensured or accuracy > self.selected_monster.evasion then
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

  self.walked_length = self.walked_length + speed * dt
  self.lives:add_position(unit_sprite, delta_s)
  self.p_systems:add_position(self.character, delta_s)
  unit_sprite.position:add(delta_s)
end

function PlayerTurnState:setup_getting_hit_animation(shaking_length)
  self.ongoing_state = "animation"
  self.shaking_length = shaking_length
end

function PlayerTurnState:manage_getting_hit_animations(dt)
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
    self.getting_hit_animation = false
    self.retreat_animation = true
  end
end

function PlayerTurnState:manage_retreat_animations(dt)
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
    self.retreat_animation = false

    if self.missed_attack then
      return self:pop({})
    end

    if self.attacker == "Player" then
      self.ongoing_state = "choosing_option"
      self.rules:remove_if_dead(self.selected_monster, self.atlas, self.monsters, self.monster_index, self.lives)
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
      self.rules:remove_if_dead(self.selected_player, self.atlas, self.players, self.player_index, self.lives)
      self.player_index = 0

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

function PlayerTurnState:play_shaking_animation(dt, unit, unit_sprite, back_direction)
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

function PlayerTurnState:setup_run_away_animation()
  self.ongoing_state = "animation"
  self:view():remove('turn_cursor')
  self.run_away_animation = true
  self.run_away_duration = 0.4
  self.walked_length = 0
end

function PlayerTurnState:manage_run_away_animations(dt)
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
  if self.character.crit_ensured or crit_attempt < self.character.crit_chance then
   --SOUND: play crit attack sound
    self.crit_attack = true
    self.atlas:flash_crit()
    self.character.crit_ensured = false

    -- else
      --SOUND: play normal attack sound
  end
  self.dmg_dealt = self.rules:take_damage(self.selected_monster, self.character.damage, self.crit_attack)
  self.became_enraged = self.rules:enrage_if_dying(self.selected_monster, self.atlas)
end

function PlayerTurnState:on_keypressed(key)
  if self.ongoing_state == "fighting" then
    if key == 'down' then
      self:next_unit("monster")
    elseif key == 'up' then
      self:prev_unit("monster")
    elseif key == 'return' or key == 'kpenter' then
      self:setup_attack_animation(55)
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
        --SOUND: fail
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
      local target = self.players[self.player_index]
      self.rules:use_item(target, self.selected_item, self.items, self.item_index)
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
      local target = self.monsters[self.monster_index]
      self.rules:use_item(target, self.selected_item, self.items, self.item_index)
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
      local option = TURN_OPTIONS[self.menu:current_option()]
      if option == "Fight" then
        self.ongoing_state = "fighting"
        self:next_unit("monster")
      elseif option == "Run" then
        self.ongoing_state = "running_away"
        self:setup_run_away_animation()
      elseif option == "Skill" then
        self.ongoing_state = "choosing_skill"
        self:view():remove('turn_menu', self.menu)
        self.menu = ListMenu(self.character.skill_set)
        self:_show_menu()
      elseif option == "Item" then
        if #self.items == 0 then
          --SOUND: fail
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

function PlayerTurnState:update(dt)
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

