
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

local function TryToPlaceElement(u, v)
	local success = self.currentDiagram.AddElement(u, v, self.elementType)
	if not success then
		return
	end
	self.moves = self.moves + 1
	api.CheckVictory()
end

function api.InBounds(pos)
	return util.DistSq(0, 0, pos[1], pos[2]) < Global.WORLD_RADIUS * Global.WORLD_RADIUS
end

function api.CheckVictory()
	if #self.levelData.win.lines == 0 and #self.levelData.win.circles == 0 then
		return
	end
end

function api.RespondToRemovedShape(edges, shapeId)
	if self.currentDiagram then
		self.currentDiagram.RespondToRemovedShape(edges, shapeId)
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
	if self.hoveredPoint and not PlayerHandler.InSelectRange(self.hoveredPoint) then
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
	if self.selectedPoint and self.hoveredPoint and PlayerHandler.InSelectRange(self.hoveredPoint) then
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

function api.GetHoveredPoint()
	return self.hoveredPoint
end

function api.Update(dt)
	self.hoveredPoint = self.currentDiagram and self.currentDiagram.GetPointAtMouse(x, y)
	if util.Eq(self.selectedPoint, self.hoveredPoint) then
		self.hoveredPoint = false
	end
	self.currentDiagram.Update(dt)
end

function api.Initialize(world, levelData)
	self = {
		world = world,
		elementType = levelData.defaultElement or Global.LINE,
		levelData = levelData,
		moves = 0,
	}
	
	self.currentDiagram = NewDiagram(levelData, self.world)
end

function api.Draw(drawQueue)
	if self.currentDiagram then
		self.currentDiagram.Draw(drawQueue, self.selectedPoint, self.hoveredPoint, self.elementType)
	end
	drawQueue:push({y=0; f=function()
		Resources.DrawImage("stonecircle", 0, 0)
	end})
	drawQueue:push({y=12; f=function()
		Resources.DrawImage("elementenvironments", 0, 0)
	end})
	drawQueue:push({y=50; f=function()
		local bounds = self.levelData.bounds
		love.graphics.setLineWidth(4)
		love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 1)
		love.graphics.circle("line", 0, 0, Global.WORLD_RADIUS, 500)
		Resources.DrawImage("fog", 0, 0)
	end})
end

return api
