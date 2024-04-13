
local NewDiagram = require("objects/diagram")

local self = {}
local api = {}

local function ProcessLines(lines)
	local newLines = {}
	for i = 1, #lines do
		newLines[#newLines + 1] = util.ExtendLine(lines[i], Global.LINE_LENGTH)
	end
	return newLines
end

local function LinesSatisfied()
	if not self.currentDiagram then
		return false
	end
	local reqLines = self.levelData.win.lines
	if not reqLines then
		return true
	end
	for i = 1, #reqLines do
		if not self.currentDiagram.ContainsLine(reqLines[i]) then
			return false
		end
	end
	return true
end

local function CirclesSatisfied()
	if not self.currentDiagram then
		return false
	end
	local reqCircles = self.levelData.win.circles
	if not reqCircles then
		return true
	end
	for i = 1, #reqCircles do
		if not self.currentDiagram.ContainsCircle(reqCircles[i]) then
			return false
		end
	end
	return true
end

local function TryToPlaceElement(u, v)
	local success = self.currentDiagram.AddElement(u, v, self.elementType)
	if not success then
		return
	end
	self.moves = self.moves + 1
	api.CheckVictory()
end

function api.InBounds(pos)
	local bounds = self.levelData.bounds
	return util.PosInRectangle(pos, bounds[1][1], bounds[1][2], bounds[2][1] - bounds[1][1], bounds[2][2] - bounds[1][2])
end

function api.CheckVictory()
	if #self.levelData.win.lines == 0 and #self.levelData.win.circles == 0 then
		return
	end
	if LinesSatisfied() and CirclesSatisfied() then
		self.world.SetGameOver(true, "Made Shape")
	end
end

function api.GetMoves()
	return self.moves
end

function api.GetTool()
	return self.elementType
end

function api.MousePressed(x, y, button)
	if button == 2 then
		self.selectedPoint = false
		return
	end
	if self.selectedPoint and self.hoveredPoint then
		TryToPlaceElement(self.selectedPoint, self.hoveredPoint)
		self.selectedPoint = false
		return
	end
	self.selectedPoint = self.hoveredPoint
end

function api.MouseReleased(x, y, button)
	if self.selectedPoint and self.hoveredPoint then
		TryToPlaceElement(self.selectedPoint, self.hoveredPoint)
		self.selectedPoint = false
	end
end

function api.KeyPressed(key, scancode, isRepeat)
	if (key == "x" or key == "space") and not self.levelData.lockTool then
		if self.elementType == Global.LINE then
			self.elementType = Global.CIRCLE
		elseif self.elementType == Global.CIRCLE then
			self.elementType = Global.LINE
		end
	end
end

function api.Update(dt)
	self.hoveredPoint = self.currentDiagram and self.currentDiagram.GetPointAt(x, y)
	if util.Eq(self.selectedPoint, self.hoveredPoint) then
		self.hoveredPoint = false
	end
end

function api.GetInitialPointCount()
	return self.initialPoints
end

function api.Initialize(world, levelData)
	self = {
		world = world,
		elementType = levelData.defaultElement or Global.LINE,
		levelData = levelData,
		moves = 0,
		initialPoints = #levelData.points,
	}
	
	local def = {
		points = util.CopyTable(levelData.points),
		lines = ProcessLines(levelData.lines),
		circles = util.CopyTable(levelData.circles),
	}
	
	self.currentDiagram = NewDiagram(def, self.world)
end

function api.Draw(drawQueue)
	if self.currentDiagram then
		self.currentDiagram.Draw(drawQueue, self.selectedPoint, self.hoveredPoint, self.elementType)
	end
	drawQueue:push({y=0; f=function()
		local bounds = self.levelData.bounds
		love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 1)
		love.graphics.rectangle("line", bounds[1][1], bounds[1][2], bounds[2][1] - bounds[1][1], bounds[2][2] - bounds[1][2])
		
		if self.levelData.background then
			Resources.DrawImage(self.levelData.background, bounds[1][1], bounds[1][2])
		end
	end})
end

return api
