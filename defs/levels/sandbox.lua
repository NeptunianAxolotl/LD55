
local offset = 5 + 1/3
local baseLine = {{-1689 - offset, 100}, {-1689 - offset, 200}}
local baseCircle = {-1650 - offset, 0, 260}

local data = {
	humanName = "Make a Triangle",
	noGrimoire = true,
	startingLevel = 100,
	noEnemies = true,
	description = [[Do it.

Click the point that makes sense and then click the other point.

Nothing bad will happen]],
	background = "mainlevel",
	defaultElement = Global.LINE,
	chalkLimit = 1,
	permanentLines = {
		true,
		true,
	},
	permanentCircles = {
		true,
		true,
	},
	playerPos = {420, 60},
	cameraPos = {200, -100},
	lines = {
		util.RotateLineAroundOrigin(baseLine, -0.5),
		util.RotateLineAroundOrigin(baseLine, -4.45),
		{{-1610.1577296428, 586.71673754537}, {-1465.243533975, 533.91223116629}},
		{{-194.04038921213, -162.69827460791}, {0, 0}},
		{{-194.04038921213, -162.69827460791}, {237.92103356828, -86.694769114262}},
		--{{-1363.677045083, 1037.8966042714}, {-1240.9461110255, 944.48590988699}},
		--{{-1465.243533975, 533.91223116629}, {-1610.1577296428, 586.71673754537}},
		--{{191.23054830218, -1703.0194719499}, {174.01979895498, -1549.7477194744}},
		--{{-1610.1577296428, 586.71673754537}, {-1096.1841611021, 598.84813653741}},
		--{{536.67993474294, 637.38888465937}, {726.36188876842, 326.05510249559}},
	},
	circles = {
		util.RotateCircleAroundOrigin(baseCircle, -0.5),
		util.RotateCircleAroundOrigin(baseCircle, -4.45),
		{0, 0, 253.22401388086},
		{237.92103356828, -86.694769114262, 438.59685773817},
		--{0, 0, 280.0564316319},
		--{536.67993474294, 637.38888465937, 364.5654503643},
		--{901.1438761658, 645.99138440302, 364.5654503643},
	},
	chalkLimit = 1,
	win = {
		lines = {},
		circles = {},
	}
}

return data
