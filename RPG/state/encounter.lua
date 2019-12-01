
local Vec = require 'common.vec'
local MessageBox = require 'view.message_box'
local SpriteAtlas = require 'view.sprite_atlas'
local BattleField = require 'view.battlefield'
local State = require 'state'
local P_Systems = require 'view.p_systems'

local EncounterState = require 'common.class' (State)

local CHARACTER_GAP = 96 + 8

local MESSAGES = {
  Fight = "%s attacked %s dealing %d damage",
  Skill = "%s cast %s on %s, %s",
  Item = "%s used %s on %s, %s",
}

function EncounterState:_init(stack)
  self:super(stack)
  self.players = nil
  self.monsters = nil
  self.chosen_player = nil
  self.player_index = nil
  self.next_player = nil
  self.p_systems = P_Systems()
end

function EncounterState:build_players_array(params)
  local party_origin = self.battlefield:east_team_origin()
  self.players = {}
  self.next_player = 1
  local n = 1
  for i, character in ipairs(params.party) do
    if character.hp > 0 then
      local pos = party_origin + Vec(0, 1) * CHARACTER_GAP * (i - 1)
      character.p_systems = self.p_systems:add_all(character, pos)
      self.players[n] = character
      n = n + 1
      self.atlas:add(character, pos, character.appearance)
    end
  end
end

function EncounterState:build_monsters_array(params)
  local encounter_origin = self.battlefield:west_team_origin()
  self.monsters = {}
  self.next_monster = 1
  for i, character in ipairs(params.encounter) do
    local pos = encounter_origin + Vec(0, 1) * CHARACTER_GAP * (i - 1)
    character.p_systems = self.p_systems:add_all(character, pos)
    self.monsters[i] = character
    self.atlas:add(character, pos, character.appearance)
  end
end

function EncounterState:enter(params)
  self.turn = 0
  self.atlas = SpriteAtlas()
  self.items = params.items
  self.battlefield = BattleField()
  local bfbox = self.battlefield.bounds
  local message = MessageBox(Vec(bfbox.left, bfbox.bottom + 16))

  self:build_players_array(params)
  self:build_monsters_array(params)

  self:view():add('atlas', self.atlas)
  self:view():add('battlefield', self.battlefield)
  self:view():add('message', message)
  self:fg_view():add('p_systems', self.p_systems)
  message:set("You stumble upon an encounter")
end

function EncounterState:leave()
  self:view():get('atlas'):clear()
  self:view():remove('atlas')
  self:view():remove('battlefield')
  self:view():remove('message')
  self:fg_view():remove('p_systems')
end

function EncounterState:set_monster_turn()
  self.attacker = "Monster"
  self.current_character = self.monsters[self.next_monster]
  self.next_monster = self.next_monster + 1
end

function EncounterState:set_player_turn()
  if self.next_player == 1 then
    self.turn = self.turn + 1
  end
  self.attacker = "Player"
  self.current_character = self.players[self.next_player]
  self.next_player = self.next_player + 1
end

function EncounterState:set_battle_params()
  return {
    current_character = self.current_character,
    attacker = self.attacker,
    monsters = self.monsters,
    players = self.players,
    items = self.items,
    p_systems = self.p_systems,
    turn = self.turn,
  }
end

function EncounterState:update(_)
  if self.next_monster > #self.monsters then
    self.next_player = 1
    self.next_monster = 1
  end

  if self.next_player > #self.players then
    self:set_monster_turn()
  else
    self:set_player_turn()
  end
  local params = self:set_battle_params()
  return self:push('battle_turn', params)
end

function EncounterState:handle_fight_action(params)
  if params.crit_attack then
    self.message = "Critical attack!\n"
  end

  self.message = self.message .. MESSAGES[params.action]:format(
    params.character.name,
    self.selected.name,
    params.dmg_dealt
  )

  if self.selected.hp <= 0 then
    self.message = self.message .. "\n" .. self.selected.name .. " died."
  elseif params.became_enraged then
    self.message = self.message .. "\n" .. self.selected.name ..
         " became enraged, increasing its damage!"
  end
end

function EncounterState:handle_skills_or_item_action(params)
  self.message = self.message .. MESSAGES[params.action]:format(
      params.character.name,
      params.skill_or_item,
      self.selected.name,
      params.msg_complement
    )
end

function EncounterState:handle_defeat_action()
  for _, monster in pairs(self.monsters) do
    for _, p_system in pairs(monster.p_systems) do
      p_system:reset()
    end
  end

  return self:pop({ action = "Defeat" })
end

function EncounterState:handle_run_or_victory_action()
  for _, player in pairs(self.players) do
    self.rules:reset_conditions(player)
  end

  return self:pop()
end

function EncounterState:resume(params)
  self.message = ""
  self.selected = params.selected

  if params.action == 'Fight' then
    self:handle_fight_action(params)
  elseif params.action == "Skill" or params.action == "Item" then
    self:handle_skills_or_item_action(params)
  elseif params.action == "Defeat" then
    return self:handle_defeat_action()
  elseif params.action == "Run" or params.action == "Victory" then
    return self:handle_run_or_victory_action()
  end
  self:view():get('message'):set(self.message)
end

return EncounterState


