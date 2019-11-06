
local UI_Info = require 'common.class' ()
local PALETTE_DB = require 'database.palette'
local Vec = require 'common.vec'

function UI_Info:_init(position)
  self.position = position
  self.title_font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.text_font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 24)
  self.title_font:setFilter('nearest', 'nearest')
  self.text_font:setFilter('nearest', 'nearest')
  self.gold = 0
  self.hovered_box = nil
  self.hovered_appearance = nil

  -- local sq = 32
  -- local x0 = 680
  -- local y0 = 171
  -- local h_gap = sq*1.5
  -- local v_gap = sq*1.5
  self.tower_infos = {
    archer1 = {
      name = "Archer",
      damage = "Low",
      range = "High",
      targets = "1",
      special = "None",
    },
    knight1 = {
      name = "Knight",
      damage = "High",
      range = "Low",
      targets = "1",
      special = "None",
    },
    mage1 = {
      name = "Mage",
      damage = "Medium",
      range = "Medium",
      targets = "3",
      special = "None",
    },
    sword = {
      name = "Sword",
      damage = "None",
      range = "1 square",
      targets = "1",
      special = "Increases the damage of a tower",
    },
    cthullu = {
      name = "Cthullu",
      damage = "None",
      range = "Medium",
      targets = "3",
      special = "Slows enemies a bit",
    },
    ghost = {
      name = "Ghost",
      damage = "None",
      range = "Medium",
      targets = "1",
      special = "Slows enemies a lot",
    },
    farmer = {
      name = "Farmer",
      damage = "None",
      range = "None",
      targets = "None",
      special = "Produces 3 gold each 5 seconds",
    },
    archer2 = {
      name = "Marksman",
      damage = "Medium",
      range = "High",
      targets = "1",
      special = "None",
    },
    knight2 = {
      name = "Lord Knight",
      damage = "Very High",
      range = "Low",
      targets = "1",
      special = "None",
    },
    mage2 = {
      name = "Archmage",
      damage = "High",
      range = "Medium",
      targets = "3",
      special = "None",
    },
  }

  self.upgrade_infos = {
    archer2 = {
      name = "Archer_Upgrade",
      description = "Increases archers damage",
    },
    knight2 = {
      name = "Knight_Upgrade",
      description = "Increases knights damage",
    },
    mage2 = {
      name = "Mage_Upgrade",
      description = "Increases mages damage",
    },
    castle2 = {
      name = "Castle_Upgrade",
      description = "Increases the castle health",
    },
  }

  self.monster_infos = {
    slime = {
      name = "Slime",
    },
    bat = {
      name = "Bat",
    },
    golem = {
      name = "Golem",
    },
    blinker = {
      name = "Blinker",
    },
    summoner = {
      name = "Summoner",
    },
  }
end

function UI_Info:draw()
  local g = love.graphics
  g.push()

  g.setColor(PALETTE_DB.pure_white)
  g.line(734,40, 734,560)

  g.setColor(PALETTE_DB.white)

  g.translate((self.position+Vec(-18, -12)):get())
  g.print("Information:")
  g.setColor(PALETTE_DB.pure_white)
  g.rectangle('line', -40,45, 260, 180)

  if self.hovered_box then
    g.setColor(PALETTE_DB.white)

    g.translate(-30, 55)

    g.setFont(self.text_font)
    local index = self.hovered_appearance
    local wrap_limit = 240
    local line_gap = 25
    if self.hovered_category == "tower" then
      local info = self.tower_infos
      g.printf("Damage:  " .. info[index].damage, 0, 0, wrap_limit)
      g.printf("Range:   " .. info[index].range, 0, line_gap, wrap_limit)
      g.printf("Targets: " .. info[index].targets, 0, line_gap*2, wrap_limit)
      g.printf("Special: " .. info[index].special, 0, line_gap*3, wrap_limit)

    elseif self.hovered_category == "upgrade" then
      local info = self.upgrade_infos
      g.printf(info[index].description, 0, 0, wrap_limit)
    end
    g.setFont(self.title_font)
  end
  love.graphics.origin()
  g.translate((self.position+Vec(-4, 220)):get())
  g.setColor(PALETTE_DB.white)
  g.print("Monsters:")
  love.graphics.origin()

  -- for i, box in ipairs(self.boxes) do
  --   g.setColor(PALETTE_DB.gray)
  --   g.rectangle('line', box:get_rectangle())

  --   local name = self.sprites[i].name
  --   local available = self.sprites[i].available
  --   if not available or self.gold < p.cost[name] then
  --     g.setColor(0, 0, 0, 0.8)
  --     local x, y, w, h = box:get_rectangle()
  --     g.rectangle('fill', x+1, y+1, w-2,h-2)
  --   end
  -- end

  g.pop()
end

return UI_Info

