
local offset = 5 + 1/3
local baseLine = {{-1689 - offset, 100}, {-1689 - offset, 200}}
local baseCircle = {-1650 - offset, 0, 260}

local data = {
	humanName = "Make a Triangle",
	description = [[Do it.

Click the point that makes sense and then click the other point.

Nothing bad will happen]],
	background = "mainlevel",
	defaultElement = Global.LINE,
	chalkLimit = 1,
	playerPos = {1020, 550},
	cameraPos = {950, 550},
	permanentLines = {
		true,
		true,
	},
	permanentCircles = {
		true,
		true,
	},
	lines = {
		util.RotateLineAroundOrigin(baseLine, -0.5),
		util.RotateLineAroundOrigin(baseLine, -4.45),
		{{-1610.1577296428, 586.71673754537}, {-1096.1841611021, 598.84813653741}},
		{{536.67993474294, 637.38888465937}, {726.36188876842, 326.05510249559}},
	},
	circles = {
		util.RotateCircleAroundOrigin(baseCircle, -0.5),
		util.RotateCircleAroundOrigin(baseCircle, -4.45),
		{536.67993474294, 637.38888465937, 364.5654503643},
		{901.1438761658, 645.99138440302, 364.5654503643},
	},
	chalkLimit = 1,
	win = {
		lines = {},
		circles = {},
	}
}

return data
