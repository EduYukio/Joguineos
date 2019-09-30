local Update = {}

local InputHandler = require "component/inputHandler"

function Update.control(entity, dt, currentMotion, direction)
  if entity.control and currentMotion then
    return entity.control:update(dt, currentMotion, direction)
  end
end

function Update.movement(entity, dt, newMotion, currentPosition)
  if entity.movement and newMotion and currentPosition then
    return entity.movement:update(dt, newMotion, currentPosition)
  end
end

function Update.position(entity, newPosition)
  if entity.position then
    entity.position:update(newPosition)
  end
end

function Update.body(entity, entities)
  if entity.body and entity.position then
    entity.body:update(entity, entities)
  end
end

function Update.inputHandler()
  return InputHandler.update()
end

return Update