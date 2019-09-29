local Update = {}

function Update.control(entity, dt, currentMotion, direction)
  if entity.control then
    return entity.control:update(dt, currentMotion, direction)
  end
end

function Update.movement(entity, dt, newMotion, currentPosition)
  if entity.movement then
    return entity.movement:update(dt, newMotion, currentPosition)
  end
end

function Update.position(entity, newPosition)
  if entity.position then
    entity.position:update(newPosition)
  end
end

function Update.body(entity, entities)
  if entity.body then
    entity.body:update(entity, entities)
  end
end

return Update