return function (ruleset)

  local r = ruleset.record

  r:new_property('character', {name = "Character", max_hp = 15, hp = 15, damage = 10, appearance = "none"})

  function ruleset.define:new_character(spec)
    function self.when()
      return true
    end
    function self.apply()
      local e = ruleset:new_entity()
      r:set(e, 'character', {
        name = spec.name,
        max_hp = spec.max_hp,
        hp = spec.max_hp,
        damage = spec.damage,
        appearance = spec.appearance
      })
      return e
    end
  end

  function ruleset.define:get_name(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'name')
    end
  end

  function ruleset.define:get_max_hp(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'max_hp')
    end
  end

  function ruleset.define:get_hp(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'hp')
    end
  end

  function ruleset.define:get_damage(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'damage')
    end
  end

  function ruleset.define:get_appearance(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'appearance')
    end
  end

  function ruleset.define:take_damage(e, amount)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      local hp = e.hp
      hp = hp - amount
      r:set(e, 'character', 'hp', hp)
    end
  end

  function ruleset.define:die(e, atlas, monsters, monster_index)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      atlas:remove(e)
      for i = monster_index + 1, #monsters do
        monsters[i-1] = monsters[i]
      end
      monsters[#monsters] = nil
    end
  end
end