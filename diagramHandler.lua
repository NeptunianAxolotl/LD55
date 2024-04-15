
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
	if util.DistSqVectors(u, v) < 100 then
		return
	end
	local elementSwitch = self.currentDiagram.CheckElementTypeSwitch(self.selectedPoint, self.hoveredPoint, self.elementType)
	local success = self.currentDiagram.AddElement(u, v, elementSwitch)
	if not success then
		return false
	end
	self.moves = self.moves + 1
	PlayerHandler.DoAction(elementSwitch)
	return true
end

function api.InBounds(pos)
	return util.DistSq(0, 0, pos[1], pos[2]) < Global.WORLD_RADIUS * Global.WORLD_RADIUS
end


function api.ElementExists(element, elementType)
	return self.currentDiagram.ElementExists(element, elementType)
end

function api.PointExists(point)
	return self.currentDiagram.PointExists(point)
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
		local elementSwitch = self.currentDiagram.CheckElementTypeSwitch(self.selectedPoint, self.hoveredPoint, self.elementType)
		self.currentDiagram.Draw(drawQueue, self.selectedPoint, self.hoveredPoint, elementSwitch)
	end
	drawQueue:push({y=0; f=function()
		Resources.DrawImage("stonecircle", 0, 0)
		local bounds = self.levelData.bounds
		love.graphics.setLineWidth(5)
		love.graphics.setColor(45/255, 48/255, 61/255, 0.5)
		love.graphics.circle("line", 0, 0, Global.WORLD_RADIUS - 8, 500)
	end})
	drawQueue:push({y=12; f=function()
		Resources.DrawImage("elementenvironments", 0, 0)
	end})
	drawQueue:push({y=50; f=function()
		Resources.DrawImage("fog", 0, 0)
	end})
end

return api
