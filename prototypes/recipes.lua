data:extend
({
  {
    type = "recipe",
    name = "cs-express-transport-belt",
    category = "crafting-with-fluid",	
    enabled = false,
    ingredients =
    {
      {"express-transport-belt", 1},
      {"advanced-circuit", 10},
      {type="fluid", name="lubricant", amount=8}
    },
    energy_required = 10,
    result = "cs-express-transport-belt"
  },
  {
    type = "recipe",
    name = "compound-splitter-endcap",
    enabled = false,
    ingredients =
	{
		{"steel-plate", 8},
		{"electronic-circuit", 4},
	},
    energy_required = 10,
    result = "compound-splitter-endcap"
  },
  {
    type = "recipe",
    name = "compound-splitter-lane",
    category = "crafting-with-fluid",	
    enabled = false,
    ingredients =
    {
      {"iron-gear-wheel", 226},
	  {"steel-plate", 68},
      {"electronic-circuit", 48},
      {"advanced-circuit", 30},
      {type="fluid", name="lubricant", amount=32},
	  {"processing-unit", 40}
    },
    energy_required = 60,
    result = "compound-splitter-lane"
  },
  {
    type = "recipe",
    name = "compound-splitter-priority-totem",
    enabled = false,
    ingredients = {
	{"steel-plate", 8},
	{"electronic-circuit", 4},
	},
    energy_required = 10,
    result = "compound-splitter-priority-totem"
  },
  {
    type = "recipe",
    name = "compound-splitter-round-robin-totem",
    enabled = false,
    ingredients = {
	{"steel-plate", 8},
	{"electronic-circuit", 4},
	},
    energy_required = 10,
    result = "compound-splitter-round-robin-totem"
  },
    {
    type = "recipe",
    name = "compound-splitter-buffer",
    enabled = false,
    ingredients =
    {
      {"steel-chest", 1},
      {"electronic-circuit", 3}
    },
    energy_required = 10,
    result = "compound-splitter-buffer"
  }
})