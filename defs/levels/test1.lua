
local offset = 5 + 1/3
local baseLine = {{-1689 - offset, 100}, {-1689 - offset, 200}}
local baseCircle = {-1650 - offset, 0, 260}

local firstTutorialLine = {
	{194.04038921205, 162.69827460784},
	{237.92103356828, -86.694769114262},
}

local secondTutorialPoint = {745.88596184244, -442.652686401}
local secondTutorialSquare = {
	{745.88596184244, -442.652686401},
	{313.92453906203, -518.65619189465},
	{237.92103356828, -86.694769114262},
	{669.88245634869, -10.691263620614},
}

local firstCircle = {669.88245634869, -10.691263620614, 438.59685773817}
local secondCircle = {313.92453906203, -518.65619189465, 438.59685773817}

local function SkipTutorial()
	return ShapeHandler.TotalShapesCreated() > 4
end

local data = {
	tutorial = {
		{
			points = firstTutorialLine,
			pointsIfSelected = firstTutorialLine,
			text = [[Click one flashing point then the other to inscribe a line.
It is time to begin the summoning.
]],
			noEnemySpawn = true,
			progressFunc = function (self, dt)
				self.tutorialLinger = 0
				return SkipTutorial() or DiagramHandler.ElementExists(firstTutorialLine, Global.LINE)
			end,
		},
		{
			text = [[Excellent, that line created a triangle sigil.
(click to continue)]],
			noEnemySpawn = true,
			progressClick = true,
			progressFunc = function (self, dt)
				return SkipTutorial()
			end,
		},
		{
			text = [[Only triangles with equal side lengths are sigils.
(click to continue)]],
			noEnemySpawn = true,
			progressClick = true,
			progressFunc = function (self, dt)
				return SkipTutorial()
			end,
		},
		{
			text = [[Now inscribe a circle clicking by a flashing point then clicking the corner of the triangle.]],
			points = {
				{669.88245634869, -10.691263620614},
			},
			pointsIfSelected = {
				{237.92103356828, -86.694769114262},
			},
			noEnemySpawn = true,
			progressFunc = function (self, dt)
				return SkipTutorial() or DiagramHandler.ElementExists(firstCircle, Global.CIRCLE)
			end,
		},
		{
			text = [[Now inscribe a second circle]],
			points = {
				{313.92453906203, -518.65619189465},
			},
			pointsIfSelected = {
				{237.92103356828, -86.694769114262},
			},
			noEnemySpawn = true,
			progressFunc = function (self, dt)
				return SkipTutorial() or DiagramHandler.ElementExists(secondCircle, Global.CIRCLE)
			end,
		},
		{
			text = [[Outstanding, now complete the square by linking up these three points.]],
			noEnemySpawn = true,
			points = {
				{745.88596184244, -442.652686401},
				{313.92453906203, -518.65619189465},
				{669.88245634869, -10.691263620614},
			},
			pointsIfSelected = {
				{745.88596184244, -442.652686401},
				{313.92453906203, -518.65619189465},
				{669.88245634869, -10.691263620614},
			},
			progressFunc = function (self, dt)
				return SkipTutorial() or ShapeHandler.ShapeAt("square", secondTutorialSquare)
			end,
		},
		{
			text = [[The summoning has begun. Triangles absorb elementals.
Squares weaken them so they are easier to absorb.
(click to continue)]],
			noEnemySpawn = true,
			progressClick = true,
			progressFunc = function (self, dt)
				return SkipTutorial()
			end,
		},
		{
			text = [[Lines and circles may only be inscribed from existing points.
Press Space to toggle between the two.
(click to continue)]],
			progressClick = true,
			progressFunc = function (self, dt)
				return SkipTutorial()
			end,
		},
		{
			text = [[The elementals are coming! Sigils are temporary!
Draw more sigils!
(click to continue)]],
			progressClick = true,
			progressFunc = function (self, dt)
				return SkipTutorial()
			end,
		},
	},
	background = "stonecircle",
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
	playerPos = {320, 0},
	cameraPos = {450, -200},
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
