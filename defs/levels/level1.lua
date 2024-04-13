
local data = {
	humanName = "Make a Triangle",
	description = [[Do it.

Click the point that makes sense and then click the other point.

Nothing bad will happen]],
	background = "level1",
	defaultElement = Global.LINE,
	chalkLimit = 1,
	lockTool = true,
	points = {
		{770, 630},
		{1110, 670},
		{1030, 400},
	},
	lines = {
		{{770, 630}, {1110, 670}},
		{{1110, 670}, {1030, 400}},
	},
	circles = {
	},
	bounds = {{0,0}, {Global.PLAY_WIDTH, Global.PLAY_HEIGHT}},
	win = {
		lines = {
			{{770, 630}, {1110, 670}},
			{{1110, 670}, {1030, 400}},
			{{770, 630}, {1030, 400}},
		},
		circles = {
		},
	},
}

return data
