local Get = {}

function Get.currentPosition(entity)
  if entity.position then
    return entity.position.point
  end
end

function Get.currentMotion(entity)
  if entity.movement then
    return entity.movement.motion
  end
end

return Get