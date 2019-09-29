--luacheck: globals love

local Body = require "class"()

function Body:_init(size)
  if not size then
    self.size = 8
  else
    self.size = size
  end
end

local function handleCollision(other, distance, sumOfRadiuses)
  local intersectionLength = sumOfRadiuses - distance:length()
  local outDirection = distance:normalized()

  local x2 = other.position.point
  other.position.point = x2 + outDirection*intersectionLength

  if other.movement then
    local v2 = other.movement.motion
    other.movement.motion = v2 - (outDirection*v2)*outDirection
  end
end

function Body:update(entity, entities)
  for _, other in ipairs(entities) do
    if not entity.body then return end

    local otherSize
    if other.body then
      otherSize = other.body.size
    else
      otherSize = 8
    end

    local sumOfRadiuses = self.size + otherSize
    local distance = other.position.point - entity.position.point

    if distance:length() < sumOfRadiuses then
      handleCollision(other, distance, sumOfRadiuses)
      -- return?
    end
  end
end

return Body