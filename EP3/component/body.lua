--luacheck: globals love

local Body = require "class"()

function Body:_init(size)
	if not size then
	  self.size = 8
	else
	  self.size = size
	end
end

local function handleCollision(entity, distance, sumOfRadiuses)
  local intersectionLength = sumOfRadiuses - distance:length()
  local outDirection = distance:normalized()

  local x2 = entity.position.point
  entity.position.point = x2 + outDirection*intersectionLength

  local v2 = entity.movement.motion
  entity.movement.motion = v2 - (outDirection*v2)*outDirection
end

function Body:update(entity, entities)
	for _, other in ipairs(entities) do
	  local distance = entity.position.point - other.position.point
	  local sumOfRadiuses = self.size + other.body.size

	  if distance:length() < sumOfRadiuses then
	    handleCollision(entity, distance, sumOfRadiuses)
	    -- return?
	  end
	end
end

return Body