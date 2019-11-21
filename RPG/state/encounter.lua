
local Vec = require 'common.vec'
local MessageBox = require 'view.message_box'
local SpriteAtlas = require 'view.sprite_atlas'
local BattleField = require 'view.battlefield'
local State = require 'state'

local EncounterState = require 'common.class' (State)

local CHARACTER_GAP = 96

local MESSAGES = {
  Fight = "%s attacked %s",
  Skill = "%s unleashed a skill",
  Item = "%s used an item",
}

function EncounterState:_init(stack)
  self:super(stack)
  self.turns = nil
  self.monsters = nil
  self.next_turn = nil
end

function EncounterState:enter(params)
  local atlas = SpriteAtlas()
  local battlefield = BattleField()
  local bfbox = battlefield.bounds
  local message = MessageBox(Vec(bfbox.left, bfbox.bottom + 16))
  local n = 0
  local party_origin = battlefield:east_team_origin()
  self.turns = {}
  self.next_turn = 1
  for i, character in ipairs(params.party) do
    local pos = party_origin + Vec(0, 1) * CHARACTER_GAP * (i - 1)
    self.turns[i] = character
    atlas:add(character, pos, character.appearance)
    n = n + 1
  end


  local encounter_origin = battlefield:west_team_origin()
  self.monsters = {}
  for i, character in ipairs(params.encounter) do
    local pos = encounter_origin + Vec(0, 1) * CHARACTER_GAP * (i - 1)
    self.monsters[i] = character
    atlas:add(character, pos, character.appearance)
  end
  self:view():add('atlas', atlas)
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
  local current_character = self.turns[self.next_turn]
  self.next_turn = self.next_turn % #self.turns + 1
  local params = { current_character = current_character, monsters = self.monsters }
  return self:push('player_turn', params)
end

function EncounterState:resume(params)
  local message
  if params.action == 'Fight' then
    message = MESSAGES[params.action]:format(params.character.name, params.monster.name)
  elseif params.action == "Run" or params.action == "Victory" then
    return self:pop()
  else
    message = MESSAGES[params.action]:format(params.character.name)
  end
  self:view():get('message'):set(message)
end

return EncounterState


