
local offset = 5 + 1/3
local baseLine = {{-1689 - offset, 100}, {-1689 - offset, 200}}
local baseCircle = {-1650 - offset, 0, 260}

local firstTutorialLine = {
	{194.04038921205, 162.69827460784},
	{237.92103356828, -86.694769114262},
}

local basis = {{500, 0}, {0, 0}}

local data = {
	background = "stonecircle",
	defaultElement = Global.LINE,
	startingLevel = 100,
	chalkLimit = 1,
	permanentLines = {
		true,
		true,
		true,
		true,
		true,
		true,
	},
	permanentCircles = {
		true,
		true,
	},
	playerPos = {320, 0},
	cameraPos = {450, -200},
	lines = {
		util.RotateLineAroundOrigin(baseLine, -0.5),
		util.RotateLineAroundOrigin(baseLine, -4.45),
		util.RotateLineAroundOrigin(basis, 0),
		util.RotateLineAroundOrigin(basis, math.pi/4),
		util.RotateLineAroundOrigin(basis, math.pi/2),
		util.RotateLineAroundOrigin(basis, math.pi*3/4),
		--{{-1363.677045083, 1037.8966042714}, {-1240.9461110255, 944.48590988699}},
		--{{-1465.243533975, 533.91223116629}, {-1610.1577296428, 586.71673754537}},
		--{{191.23054830218, -1703.0194719499}, {174.01979895498, -1549.7477194744}},
		--{{-1610.1577296428, 586.71673754537}, {-1096.1841611021, 598.84813653741}},
		--{{536.67993474294, 637.38888465937}, {726.36188876842, 326.05510249559}},
	},
	circles = {
		util.RotateCircleAroundOrigin(baseCircle, -0.5),
		util.RotateCircleAroundOrigin(baseCircle, -4.45),
		{0, 0, 500},
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
