
local data = {
	humanName = "CIRCLE ME UP!!!",
	description = [[Please make me a circle.

We need it to summon demons.

I have EXTREMELY PARTICULAR feelings about WHERE THE CIRCLE IS PLACED.

Do not disappoint me.]],
	background = "level2",
	defaultElement = Global.CIRCLE,
	chalkLimit = 1,
	lockTool = true,
	points = {
		{830, 540},
		{1150, 540},
	},
	lines = {
	},
	circles = {
	},
	chalkLimit = 1,
	bounds = {{0,0}, {Global.PLAY_WIDTH, Global.PLAY_HEIGHT}},
	win = {
		lines = {
		},
		circles = {
			{830, 540, 320},
		},
	},
}

return data
