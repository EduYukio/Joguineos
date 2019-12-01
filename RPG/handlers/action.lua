
local SOUNDS_DB = require 'database.sounds'
local ListMenu = require 'view.list_menu'
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
  ["Heal"] = "healing 15 points.",
  ["War Cry"] = "ensuring the next\nattack is critical.",
  ["Charm"] = "reducing its\nresistance to 0 for 2 turns!.",
  ["Energy Drink"] = "increasing the\nevasion for 2 turns!",
  ["Mud Slap"] = "decreasing the\nevasion for 2 turns!",
  ["Spinach"] = "raising the strength\nfor 2 turns!",
  ["Bandejao's Fish"] = "poisoning him\nfor 2 turns!",
}
local TURN_OPTIONS = { 'Fight', 'Skill', 'Item', 'Run' }

local Action = require 'common.class' ()

function Action:_init(stage)
  self.stage = stage
  self.character = self.stage.character
  self.monsters = self.stage.monsters
  self.players = self.stage.players
  self.animation = self.stage.animation
  self.rules = self.stage.rules
  self.turn = self.stage.turn
  self.items = self.stage.items
  self.ongoing_state = "choosing_option"
  self.choosing_list = "menu"
  self.function_array = {
    fighting = self.fighting,
    choosing_skill = self.choosing_skill,
    using_skill = self.using_skill,
    choosing_item = self.choosing_item,
    using_item = self.using_item,
    choosing_option = self.choosing_option,
  }
end

function Action:cancel_action()
  self.ongoing_state = "choosing_option"
  self.choosing_list = "menu"
  self.stage.menu = ListMenu(TURN_OPTIONS)
  self.stage:_show_menu()
  self.stage.monster_index = 0
  for i, player in ipairs(self.players) do
    if player == self.character then
      self.stage.player_index = i
    end
  end
  self.stage:switch_cursor("player")
end

function Action:fighting()
  SOUNDS_DB.select_menu:play()
  self.animation:setup_attack_animation(55, self.stage.monster_index)
end

function Action:choosing_skill()
  SOUNDS_DB.select_menu:play()
  self.selected_skill = self.character.skill_set[self.stage.menu:current_option()]
  if self.character.mana > 0 then
    if self.selected_skill == "Charm" then
      self:select_target("monster", "skill")
    else
      self.stage.player_index = 0
      self:select_target("player", "skill")
    end
  else
    SOUNDS_DB.fail:play()
    self.stage:view():get('message'):set(MESSAGES.NoMana)
    self.ongoing_state = "choosing_option"
    self.choosing_list = "menu"
    self.stage.menu = ListMenu(TURN_OPTIONS)
    self.stage:_show_menu()
  end
end

function Action:select_target(unit_category, usable_category)
  local message
  local state
  if usable_category == "item" then
    message = MESSAGES.ChooseItemTarget
    state = "using_item"
  elseif usable_category == "skill" then
    message = MESSAGES.ChooseSkillTarget
    state = "using_skill"
  end
  self.stage:next_unit(unit_category)
  self.ongoing_state = state
  self.choosing_list = unit_category
  self.stage:view():remove('turn_menu', self.stage.menu)
  self.stage:view():get('message'):set(message)
end

function Action:using_skill()
  SOUNDS_DB.select_menu:play()
  if self.choosing_list == "monster" then
    self.target = self.monsters[self.stage.monster_index]
  elseif self.choosing_list == "player" then
    self.target = self.players[self.stage.player_index]
  end
  self.rules:cast_skill(self.target, self.selected_skill, self.turn)
  self.character.mana = self.character.mana - 1
  return self.stage:pop({
    action = "Skill",
    character = self.character,
    skill_or_item = self.selected_skill,
    selected = self.target,
    msg_complement = MSG_COMPLEMENTS[self.selected_skill],
  })
end

function Action:choosing_item()
  SOUNDS_DB.select_menu:play()
  self.item_index = self.stage.menu:current_option()
  self.selected_item = self.items[self.item_index]
  if self.selected_item == "Mud Slap" or self.selected_item == "Bandejao's Fish" then
    self.stage.monster_index = 0
    self:select_target("monster", "item")
  else
    self.stage.player_index = 0
    self:select_target("player", "item")
  end
end

function Action:using_item()
  SOUNDS_DB.select_menu:play()
  if self.choosing_list == "monster" then
    self.target = self.monsters[self.stage.monster_index]
  elseif self.choosing_list == "player" then
    self.target = self.players[self.stage.player_index]
  end
  self.rules:use_item(self.target, self.selected_item,
       self.items, self.item_index, self.turn)
  return self.stage:pop({
    action = "Item",
    character = self.character,
    skill_or_item = self.selected_item,
    selected = self.target,
    msg_complement = MSG_COMPLEMENTS[self.selected_item],
  })
end

function Action:setup_fight_option()
  self.ongoing_state = "fighting"
  self.choosing_list = "monster"
  self.stage:next_unit("monster")
end

function Action:setup_run_option()
  self.ongoing_state = "running_away"
  self.animation:setup_run_away_animation()
end

function Action:setup_skill_option()
  self.ongoing_state = "choosing_skill"
  self.choosing_list = "menu"
  self.stage:view():remove('turn_menu', self.stage.menu)
  self.stage.menu = ListMenu(self.character.skill_set)
  self.stage:_show_menu()
end

function Action:setup_item_option()
  if #self.items == 0 then
    SOUNDS_DB.fail:play()
    self.stage:view():get('message'):set(MESSAGES.NoItems)
    self.ongoing_state = "choosing_option"
  else
    self.stage:view():remove('turn_menu', self.stage.menu)
    self.stage.menu = ListMenu(self.items, "items")
    self.stage:_show_menu()
    self.ongoing_state = "choosing_item"
  end
  self.choosing_list = "menu"
end

function Action:choosing_option()
  SOUNDS_DB.select_menu:play()
  local option = TURN_OPTIONS[self.stage.menu:current_option()]
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

return Action