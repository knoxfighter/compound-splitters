data:extend
({
  {
    type = "technology",
    name = "compound-splitters",
    icon = "__compoundsplitters__/graphics/item-group/compound-splitters.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "cs-express-transport-belt"
      },
      {
        type = "unlock-recipe",
        recipe = "compound-splitter-endcap"
      },
	  {
        type = "unlock-recipe",
        recipe = "compound-splitter-lane"
      },
      {
        type = "unlock-recipe",
        recipe = "compound-splitter-priority-totem"
      },
      {
        type = "unlock-recipe",
        recipe = "compound-splitter-round-robin-totem"
      },
      {
        type = "unlock-recipe",
        recipe = "compound-splitter-buffer"
      }
    },
    prerequisites = {"logistics-3", "automation-3"},
    unit =
    {
      count = 400,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"alien-science-pack", 1}
      },
      time = 60
    },
    upgrade = false,
    order = "i-e-c"
  },
})