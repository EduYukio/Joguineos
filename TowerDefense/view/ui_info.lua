
local UI_Info = require 'common.class' ()
local PALETTE_DB = require 'database.palette'
local Vec = require 'common.vec'

function UI_Info:_init(position)
  self.position = position
  self.title_font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 36)
  self.text_font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 24)
  self.small_text_font = love.graphics.newFont('assets/fonts/VT323-Regular.ttf', 20)
  self.title_font:setFilter('nearest', 'nearest')
  self.text_font:setFilter('nearest', 'nearest')
  self.small_text_font:setFilter('nearest', 'nearest')
  self.gold = 0
  self.hovered_box = nil
  self.hovered_appearance = nil

  self.towers_info = {
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
      name = "Elite Knight",
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

  self.upgrades_info = {
    archer2 = {
      name = "Archer_Upgrade",
      description = "Turns all Archers into Marksmen, increasing their damage",
    },
    knight2 = {
      name = "Knight_Upgrade",
      description = "Turns all Knights into Elite Knights, increasing their damage",
    },
    mage2 = {
      name = "Mage_Upgrade",
      description = "Turns all Mages into Archmages, increasing their damage",
    },
    castle2 = {
      name = "Castle_Upgrade",
      description = "Increases the castle health",
    },
  }

  local x0 = 775
  local y0 = 345
  local sq = 32
  local h_gap = 115  + sq*1.5
  local v_gap = 25 + sq*1.5

  self.monsters_info = {
    slime = {
      name = "Slime",
      hp = "Low",
      speed = "Medium",
      pos = Vec(x0, y0),
      appearance = "slime",
    },
    bat = {
      name = "Bat",
      hp = "Low",
      speed = "Fast",
      pos = Vec(x0 + h_gap, y0),
      appearance = "bat",
    },
    golem = {
      name = "Golem",
      hp = "Medium",
      speed = "Low",
      pos = Vec(x0+h_gap/2, y0 + v_gap),
      appearance = "golem",
    },
    blinker = {
      name = "Blinker",
      hp = "High",
      speed = "None",
      special = "    Teleports\n(can't be slowed)",
      pos = Vec(x0 + h_gap, y0 + v_gap*2),
      appearance = "blinker",
    },
    summoner = {
      name = "Summoner",
      hp = "High",
      speed = "Low",
      special = "     Summons\n   4 weaklings",
      pos = Vec(x0, y0 + v_gap*2),
      appearance = "summoner",
    },
  }
end

function UI_Info:draw()
  local g = love.graphics
  g.push()

  g.setColor(PALETTE_DB.pure_white)
  g.line(734,40, 734,560)

  g.setColor(PALETTE_DB.white)

  g.translate((self.position+Vec(20, -12)):get())
  g.setFont(self.title_font)
  g.print("Information:")
  g.setColor(PALETTE_DB.pure_white)
  g.rectangle('line', -73, 45, 312, 180)
  g.translate(-60, 55)

  if self.hovered_box then
    g.setColor(PALETTE_DB.white)

    g.setFont(self.text_font)
    local index = self.hovered_appearance
    local wrap_limit = 292
    local line_gap = 25
    if self.hovered_category == "tower" then
      local info = self.towers_info
      g.printf(info[index].name, 0,-5, wrap_limit, "center")
      g.printf("Damage:  " .. info[index].damage, 0, line_gap, wrap_limit)
      g.printf("Range:   " .. info[index].range, 0, line_gap*2, wrap_limit)
      g.printf("Targets: " .. info[index].targets, 0, line_gap*3, wrap_limit)
      g.printf("Special: " .. info[index].special, 0, line_gap*4, wrap_limit)

    elseif self.hovered_category == "upgrade" then
      local info = self.upgrades_info
      g.printf(info[index].description, 0, 0, wrap_limit)
    end
  end
  love.graphics.origin()
  g.translate((self.position+Vec(46, 220)):get())
  g.setColor(PALETTE_DB.white)
  g.setFont(self.title_font)
  g.print("Monsters:")
  love.graphics.origin()
  local line_gap = 20
  g.setFont(self.small_text_font)
  for _, monster in pairs(self.monsters_info) do
    g.setColor(PALETTE_DB.pure_white)
    local x, y = monster.pos:get()
    if monster.special then
      g.rectangle('line', x-22, y-28, 150, 95)
      g.setColor(PALETTE_DB.white)
      g.print(monster.special, x-15, y+line_gap*1)
    else
      g.rectangle('line', x-22, y-28, 150, 60)
    end

    x = x+27
    y = y-20
    g.setColor(PALETTE_DB.white)
    g.print("HP:  " .. monster.hp, x, y)
    g.print("SPD: " .. monster.speed, x, y+line_gap)
  end

  g.pop()
end

return UI_Info

