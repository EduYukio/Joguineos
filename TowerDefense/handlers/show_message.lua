
local ShowMessage = require 'common.class' ()

function ShowMessage:_init(stage)
  self.waiting_time = 0
  self.stage = stage
  self.messages = self.stage.messages
  if not self.stage.done_tutorial then
    self.time_to_wait = 30
    self.stage.done_tutorial = true
  else
    self.time_to_wait = 3
  end
end

function ShowMessage:next_wave(dt)
  self.waiting_time = self.waiting_time + dt

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