
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
	cameraPos = {450, -110},
	lines = {
		util.RotateLineAroundOrigin(baseLine, -0.5),
		util.RotateLineAroundOrigin(baseLine, -4.45),
	},
	circles = {
		util.RotateCircleAroundOrigin(baseCircle, -0.5),
		util.RotateCircleAroundOrigin(baseCircle, -4.45),
	},
	chalkLimit = 1,
	win = {
		lines = {},
		circles = {},
	}
}

return data
