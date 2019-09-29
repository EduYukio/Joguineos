local Calculate = {}

local function facingLeft(y, step)
  if y ==  1 then return step end
  if y ==  0 then return 2*step end
  if y == -1 then return 3*step end
end

local function facingCenter(y, step, previousAngle)
  if y ==  1 then return 0 end
  if y ==  0 then return previousAngle end
  if y == -1 then return 4*step end
end

local function facingRight(y, step)
  if y ==  1 then return -1*step end
  if y ==  0 then return -2*step end
  if y == -1 then return -3*step end
end

function Calculate.pointingAngle(direction, previousAngle)
  local x, y = direction:get()
  local step = math.pi/4

  if x == -1 then
    return facingLeft(y, step)
  end

  if x == 0 then
    return facingCenter(y, step, previousAngle)
  end

  if x == 1 then
    return facingRight(y, step)
  end
end

return Calculate