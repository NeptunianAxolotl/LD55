
local data = {
	defaultElement = Global.LINE,
	points = {
		{0, 500},
		{500, 0},
		{0, 0},
		{310, 500},
		{300, 450},
	},
	lines = {
		{{0, 500}, {500, 0}},
	},
	circles = {
		{0, 0, 500}
	},
	chalkLimit = 1,
	bounds = {{0,0}, {Global.PLAY_WIDTH, Global.PLAY_HEIGHT}},
}

return data
