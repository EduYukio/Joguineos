
return {
  title = 'Slime Infestation',
  initial_gold = 30,
  waves = {
    { order = {"slime"},
      quantity = {2},
    },
    { order = {"golem", "bat"},
      quantity = {5, 15},
    },
    { order = {"slime", "bat", "slime", "golem", "blinker", "summoner"},
      quantity = {2, 2, 3, 2, 1, 1},
    },
  }
}

