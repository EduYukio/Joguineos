
local ShowMessage = require 'common.class' ()

function ShowMessage:_init(stage)
  self.waiting_time = 0
  self.stage = stage
  self.messages = self.stage.messages
end

function ShowMessage:next_wave(dt)
  self.waiting_time = self.waiting_time + dt
  local time_to_wait = 5

  if self.waiting_time < self.time_to_wait then
    local seconds = tostring(self.time_to_wait - math.floor(self.waiting_time))
    self.messages:write("Next wave in " .. seconds .. "...")
  else
    self.waiting_time = 0
    self.stage.spawn:new_wave()
  end
end

function ShowMessage:you_win(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < 4 then
    self.messages:write("You Win!")
  else
    self.stage:pop()
  end
end

function ShowMessage:game_over(dt)
  self.waiting_time = self.waiting_time + dt
  if self.waiting_time < 3 then
    self.messages:write("Game Over :(")
  else
    self.stage:pop()
  end
end

return ShowMessage