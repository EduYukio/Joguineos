local Calculate = {}

function Calculate.tileQuadCoords(id, tileData)
  local width = tileData.tileWidth
  local height = tileData.tileHeight
  local columns = tileData.tileColumns

  local x0 = width*((id - 1)%columns)
  local y0 = height*math.floor((id - 1)/columns)

  return x0, y0
end

function Calculate.quadCoords(id, width, height, columns)
  local x0 = width*((id - 1)%columns)
  local y0 = height*math.floor((id - 1)/columns)

  return x0, y0
end

function Calculate.quadDimensions(sprite, spriteSheet)
  local sheetWidth, sheetHeight = spriteSheet:getDimensions()

  local quadWidth = sheetWidth/sprite.properties.columns
  local quadHeight = sheetHeight/sprite.properties.rows

  return quadWidth, quadHeight
end

return Calculate