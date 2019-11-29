
local State = require 'common.class' ()

local RULE_MODULES = { 'rules' }
local RULESETS = {
  'character',
  'ui_related',
  'existence',
}
local RuleEngine = require 'ur-proto' (RULE_MODULES, RULESETS)

function State:_init(stack)
  self.stack = stack
  self.rules = RuleEngine
end

function State:view()
  return self.stack.game.view
end

function State:fg_view()
  return self.stack.game.fg_view
end

function State:push(statename, info)
  return self.stack:push(statename, info)
end

function State:pop(info)
  return self.stack:pop(info)
end

function State:call_handler(eventname, ...)
  local handler = self['on_' .. eventname]
  if handler then
    return handler(self, ...)
  end
end

return State

