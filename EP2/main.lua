--luacheck: globals love

local map
function love.load(args)
	local mapName = args[1]
	local mapFile = love.filesystem.load("maps/" .. mapName .. ".lua")
	map = mapFile()
end


function love.draw()
	love.graphics.print(map.luaversion, 200, 200)
end