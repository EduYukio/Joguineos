return function (ruleset)

  function ruleset.define:remove_from_array(e, array, index) --luacheck: no unused
    function self.when()
      return true
    end
    function self.apply()
      for i = index + 1, #array do
        array[i-1] = array[i]
      end
      array[#array] = nil
    end
  end
end