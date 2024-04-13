
local data = {
	humanName = "Square Time",
	description = [[Can you make a square?

The sketch is a bit lopsided, but thems the breaks.]],
	background = "level4",
	defaultElement = Global.Line,
	chalkLimit = 5,
	points = {
		{841, 799},
		{1094, 653},
	},
	lines = {
	},
	circles = {
	},
	chalkLimit = 12,
	bounds = {{0,0}, {Global.PLAY_WIDTH, Global.PLAY_HEIGHT}},
	win = {
		lines = {
			{{948, 400}, {695, 546}},
			{{948, 400}, {1094, 653}},
			{{841, 799}, {695, 546}},
			{{841, 799}, {1094, 653}},
		},
		circles = {
		},
	},
}

return data
