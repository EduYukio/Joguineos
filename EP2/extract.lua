local Extract = {}

function Extract.mapLayers(map, type)
  local t = {}

  for _, layer in ipairs(map.layers) do
    if (layer.type == type) then
      table.insert(t, layer)
    end
  end

  return t
end

function Extract.sprites(objectLayer)
  local t = {}

  for _, object in ipairs(objectLayer.objects) do
    if (object.type == "sprite") then
      table.insert(t, object)
    end
  end

  return t
end

function Extract.frames(sprite)
  local t = {}

  for frame_token in sprite.properties.frames:gmatch("%d+") do
    local frame = tonumber(frame_token)

    table.insert(t, frame)
  end

  return t
end

return Extract