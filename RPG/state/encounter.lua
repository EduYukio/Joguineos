
local Vec = require 'common.vec'
local MessageBox = require 'view.message_box'
local SpriteAtlas = require 'view.sprite_atlas'
local BattleField = require 'view.battlefield'
local State = require 'state'

local EncounterState = require 'common.class' (State)

local CHARACTER_GAP = 96

local MESSAGES = {
  Fight = "%s attacked %s dealing %d damage",
  Skill = "%s unleashed a skill",
  Item = "%s used an item",
}

function EncounterState:_init(stack)
  self:super(stack)
  self.players = nil
  self.monsters = nil
  self.chosen_player = nil
  self.player_index = nil
  self.next_player = nil
end

function EncounterState:enter(params)
  self.atlas = SpriteAtlas()
  local battlefield = BattleField()
  local bfbox = battlefield.bounds
  local message = MessageBox(Vec(bfbox.left, bfbox.bottom + 16))
  local party_origin = battlefield:east_team_origin()
  self.players = {}
  self.next_player = 1
  local n = 1
  for i, character in ipairs(params.party) do
    if character.hp > 0 then
      local pos = party_origin + Vec(0, 1) * CHARACTER_GAP * (i - 1)
      self.players[n] = character
      n = n + 1
      self.atlas:add(character, pos, character.appearance)
    end
  end


  local encounter_origin = battlefield:west_team_origin()
  self.monsters = {}
  self.next_monster = 1
  for i, character in ipairs(params.encounter) do
    local pos = encounter_origin + Vec(0, 1) * CHARACTER_GAP * (i - 1)
    self.monsters[i] = character
    self.atlas:add(character, pos, character.appearance)
  end
  self:view():add('atlas', self.atlas)
  self:view():add('battlefield', battlefield)
  self:view():add('message', message)
  message:set("You stumble upon an encounter")
end

function EncounterState:leave()
  self:view():get('atlas'):clear()
  self:view():remove('atlas')
  self:view():remove('battlefield')
  self:view():remove('message')
end



function EncounterState:update(_)
  --monsters turn
  local current_character
  local attacker
  if self.next_monster > #self.monsters then
    self.next_player = 1
    self.next_monster = 1
  end


  if self.next_player > #self.players then
    --turno dos monstros
    attacker = "Monster"
    current_character = self.monsters[self.next_monster]
    self.next_monster = self.next_monster + 1
  else
    --turno dos players
    attacker = "Player"
    current_character = self.players[self.next_player]
    self.next_player = self.next_player + 1
  end

  --setup battle turn
  local params = {
    current_character = current_character,
    attacker = attacker,
    monsters = self.monsters,
    players = self.players
  }
  return self:push('battle_turn', params)
end

function EncounterState:resume(params)
  local message
  local selected = params.selected

  if params.action == 'Fight' then
    message = MESSAGES[params.action]:format(params.character.name, selected.name, params.dmg_dealt)
    if selected.hp <= 0 then
      message = message .. "\n" .. selected.name .. " died."
    elseif params.became_enraged then
      message = message .. "\n" .. selected.name .. " became enraged, increasing its damage!"
    end
  elseif params.action == "Defeat" then
    return self:pop({ action = "Defeat" })
  elseif params.action == "Run" or params.action == "Victory" then
    return self:pop()
  end
  self:view():get('message'):set(message)
end

return EncounterState


