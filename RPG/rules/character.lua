return function (ruleset)

  local r = ruleset.record

  r:new_property('character', {
    name = "Character",
    max_hp = 15,
    hp = 15,
    damage = 10,
    resistance = 0,
    enraged = false,
    appearance = "none"
  })

  r:new_property('monster', {})
  r:new_property('player', {})

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
        resistance = spec.resistance,
        appearance = spec.appearance
      })

      if spec.category == "monster" then
        r:set(e, 'monster', {})
      elseif spec.category == "player" then
        r:set(e, 'player', {})
      end

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

  function ruleset.define:get_resistance(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'resistance')
    end
  end

  function ruleset.define:get_enraged(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'enraged')
    end
  end

  function ruleset.define:set_enraged(e, enraged)
    function self.when()
      return r:is(e, 'character') and r:is(e, "monster")
    end
    function self.apply()
      return r:set(e, 'character', {enraged = enraged})
    end
  end

  function ruleset.define:set_damage(e, amount)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', { damage = amount} )
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
      local dmg_after_mitigation = math.max(amount - e.resistance, 0)
      if dmg_after_mitigation > 0 then
        hp = hp - dmg_after_mitigation
        r:set(e, 'character', 'hp', hp)
      end
      return dmg_after_mitigation
    end
  end

  function ruleset.define:remove_if_dead(e, atlas, unit_array, unit_index)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      if e.hp <= 0 then
        atlas:remove(e)
        for i = unit_index + 1, #unit_array do
          unit_array[i-1] = unit_array[i]
        end
        unit_array[#unit_array] = nil
      end
    end
  end

  function ruleset.define:enrage_if_dying(e, atlas)
    function self.when()
      return r:is(e, 'character') and r:is(e, "monster")
    end
    function self.apply()
      if e.enraged then return false end

      local hp_perc = e.hp/e.max_hp
      if hp_perc > 0 and hp_perc <= 0.3 then
        e.enraged = true
        e.damage = e.damage*2
        atlas:enrage_monster(e)
        return true
      end
      return false
    end
  end
end