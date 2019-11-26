return function (ruleset)

  local r = ruleset.record

  r:new_property('character', {
    name = "Character",
    max_hp = 15,
    hp = 15,
    damage = 10,
    resistance = 0,
    evasion = 0,
    crit_chance = 0,
    mana = 0,
    max_mana = 0,
    skill_set = {},
    enraged = false,
    crit_ensured = false,
    charmed = false,
    poisoned = false,
    energized = false,
    empowered = false,
    sticky = false,
    appearance = "none",
    p_systems = {},
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
        evasion = spec.evasion,
        mana = spec.max_mana,
        max_mana = spec.max_mana,
        skill_set = spec.skill_set,
        crit_chance = spec.crit_chance,
        appearance = spec.appearance,
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

  function ruleset.define:get_evasion(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'evasion')
    end
  end

  function ruleset.define:get_crit_chance(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'crit_chance')
    end
  end

  function ruleset.define:get_mana(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'mana')
    end
  end

  function ruleset.define:get_max_mana(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'max_mana')
    end
  end

  function ruleset.define:get_skill_set(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'skill_set')
    end
  end

  function ruleset.define:get_crit_ensured(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'crit_ensured')
    end
  end

  function ruleset.define:get_charmed(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'charmed')
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

  function ruleset.define:get_poisoned(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'poisoned')
    end
  end

  function ruleset.define:get_energized(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'energized')
    end
  end

  function ruleset.define:get_empowered(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'empowered')
    end
  end

  function ruleset.define:get_sticky(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'sticky')
    end
  end

  function ruleset.define:get_p_systems(e)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:get(e, 'character', 'p_systems')
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

  function ruleset.define:set_hp(e, hp)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', { hp = hp} )
    end
  end

  function ruleset.define:set_mana(e, mana)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', { mana = mana} )
    end
  end

  function ruleset.define:set_damage(e, damage)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', { damage = damage} )
    end
  end

  function ruleset.define:set_p_systems(e, p_systems)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      return r:set(e, 'character', { p_systems = p_systems} )
    end
  end

  function ruleset.define:set_crit_ensured(e, crit_ensured)
    function self.when()
      return r:is(e, 'character') and r:is(e, "player")
    end
    function self.apply()
      return r:set(e, 'character', {crit_ensured = crit_ensured})
    end
  end

  function ruleset.define:set_charmed(e, charmed)
    function self.when()
      return r:is(e, 'character') and r:is(e, "monster")
    end
    function self.apply()
      return r:set(e, 'character', {charmed = charmed})
    end
  end

  function ruleset.define:set_poisoned(e, poisoned)
    function self.when()
      return r:is(e, 'character') and r:is(e, "monster")
    end
    function self.apply()
      return r:set(e, 'character', {poisoned = poisoned})
    end
  end

  function ruleset.define:set_energized(e, energized)
    function self.when()
      return r:is(e, 'character') and r:is(e, "player")
    end
    function self.apply()
      return r:set(e, 'character', {energized = energized})
    end
  end

  function ruleset.define:set_empowered(e, empowered)
    function self.when()
      return r:is(e, 'character') and r:is(e, "player")
    end
    function self.apply()
      return r:set(e, 'character', {empowered = empowered})
    end
  end

  function ruleset.define:set_sticky(e, sticky)
    function self.when()
      return r:is(e, 'character') and r:is(e, "monster")
    end
    function self.apply()
      return r:set(e, 'character', {sticky = sticky})
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

  function ruleset.define:take_damage(e, amount, crit)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      local final_dmg
      local hp = e.hp

      if crit then
        final_dmg = amount + 5
      elseif e.charmed then
        final_dmg = math.max(amount, 0)
        e.charmed = false
      else
        final_dmg = math.max(amount - e.resistance, 0)
      end

      if final_dmg > 0 then
        hp = math.max(hp - final_dmg, 0)
        r:set(e, 'character', 'hp', hp)
      end

      return final_dmg
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
        e.damage = e.damage + 5
        atlas:enrage_monster(e)
        return true
      end
      return false
    end
  end


  --Skills
  function ruleset.define:heal(e)
    function self.when()
      return r:is(e, 'character') and r:is(e, 'player')
    end

    function self.apply()
      local heal_amount = 10
      e.hp = math.min(e.hp + heal_amount, e.max_hp)
      e.p_systems.green:emit(60)
    end
  end

  function ruleset.define:war_cry(e)
    function self.when()
      return r:is(e, 'character') and r:is(e, 'player')
    end
    function self.apply()
      e.crit_ensured = true
    end
  end

  function ruleset.define:charm(e)
    function self.when()
      return r:is(e, 'character') and r:is(e, "monster")
    end
    function self.apply()
      e.charmed = true
    end
  end

  function ruleset.define:cast_skill(e, skill)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      if skill == "Heal" then
        e:heal()
      elseif skill == "War Cry" then
        e:war_cry()
      elseif skill == "Charm" then
        e:charm()
      end
    end
  end


  --Items
  function ruleset.define:energy_drink(e)
    function self.when()
      return r:is(e, 'character') and r:is(e, 'player')
    end
    function self.apply()
      e.energized = true
    end
  end

  function ruleset.define:mud_slap(e)
    function self.when()
      return r:is(e, 'character') and r:is(e, 'monster')
    end
    function self.apply()
      e.sticky = true
    end
  end

  function ruleset.define:spinach(e)
    function self.when()
      return r:is(e, 'character') and r:is(e, 'player')
    end
    function self.apply()
      e.empowered = true
    end
  end

  function ruleset.define:bandejaos_fish(e)
    function self.when()
      return r:is(e, 'character') and r:is(e, 'monster')
    end
    function self.apply()
      e.poisoned = true
    end
  end

  function ruleset.define:use_item(e, item)
    function self.when()
      return r:is(e, 'character')
    end
    function self.apply()
      if item == "Energy Drink" then
        e:energy_drink()
      elseif item == "Mud Slap" then
        e:mud_slap()
      elseif item == "Spinach" then
        e:spinach()
      elseif item == "Bandejao's Fish" then
        e:bandejaos_fish()
      end
    end
  end
end