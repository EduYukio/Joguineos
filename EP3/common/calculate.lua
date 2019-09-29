local Calculate = {}

function Calculate.pointingAngle(direction, previousAngle)
  local x, y = direction:get()
  local angle = 0
  local step = math.pi/4

  if x == -1 then
    if y == 1 then
      angle = step
    elseif y == 0 then
      angle = 2*step
    elseif y == -1 then
      angle = 3*step
    end
  elseif x == 0 then
    if y == 1 then
      angle = 0
    elseif y == 0 then
      angle = previousAngle
    elseif y == -1 then
      angle = 4*step
    end
  elseif x == 1 then
    if y == 1 then
      angle = -1*step
    elseif y == 0 then
      angle = -2*step
    elseif y == -1 then
      angle = -3*step
    end
  end

  return angle
end

return Calculate