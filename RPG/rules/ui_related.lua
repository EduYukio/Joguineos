return function (ruleset)

  function ruleset.define:add_ui_sprites(array, units)
    function self.when()
      return true
    end
    function self.apply()
      for _, unit in pairs(units) do
        array:add(unit.name, unit.pos, unit.appearance)
      end
    end
  end

  function ruleset.define:add_ui_lives(array, atlas, units)
    function self.when()
      return true
    end
    function self.apply()
      for _, unit in pairs(units) do
        local spr = atlas:get(unit)
        array:add(spr, unit.hp, unit.max_hp)
      end
    end
  end
end