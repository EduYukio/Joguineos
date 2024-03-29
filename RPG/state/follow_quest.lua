
local State = require 'state'

local FollowQuestState = require 'common.class' (State)

function FollowQuestState:_init(stack)
  self:super(stack)
  self.party = nil
  self.encounters = nil
  self.next_encounter = nil
end

function FollowQuestState:enter(params)
  local quest = params.quest
  self.items = params.items
  self.encounters = quest.encounters
  self.next_encounter = 1
  self.party = {}
  for i, character_name in ipairs(quest.party) do
    local character_spec = require('database.characters.' .. character_name)
    self.party[i] = self.rules:new_character(character_spec)
  end
end

function FollowQuestState:update(_)
  if self.next_encounter <= #self.encounters then
    local encounter = {}
    local encounter_specnames = self.encounters[self.next_encounter]
    self.next_encounter = self.next_encounter + 1
    for i, character_name in ipairs(encounter_specnames) do
      local character_spec = require('database.characters.' .. character_name)
      encounter[i] = self.rules:new_character(character_spec)
    end
    local params = { party = self.party, encounter = encounter, items = self.items }
    return self:push('encounter', params)
  else
    return self:pop()
  end
end

function FollowQuestState:resume(params)
  if params and params.action == "Defeat" then
    return self:pop()
  end
end

return FollowQuestState


