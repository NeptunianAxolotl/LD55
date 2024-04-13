
local data = {
	humanName = "Fancy Buisness",
	description = [[Whew that circle was a bit much.

Lets all calm down with a nice semi-circle.

Press X or Space to toggle your tools, because you'll need both for this one.]],
	background = "level3",
	defaultElement = Global.Line,
	chalkLimit = 5,
	points = {
		{686, 737},
		{1109, 739},
	},
	lines = {
		{{686, 737}, {1109, 739}},
	},
	circles = {
	},
	chalkLimit = 1,
	bounds = {{0,0}, {Global.PLAY_WIDTH, Global.PLAY_HEIGHT}},
	win = {
		lines = {
			{{686, 737}, {1109, 739}},
		},
		circles = {
			{897.5, 738, 211.50236405298},
		},
	},
}

return data
