
local NewDiagram = require("objects/diagram")

local self = {}
local api = {}

function api.MousePressed(x, y, button)
	if button == 2 then
		self.selectedPoint = false
		return
	end
	if self.selectedPoint and self.hoveredPoint then
		self.currentDiagram.AddElement(self.selectedPoint, self.hoveredPoint, self.elementType)
		return
	end
	self.selectedPoint = self.hoveredPoint
end

function api.MouseReleased(x, y, button)
	if self.selectedPoint and self.hoveredPoint then
		self.currentDiagram.AddElement(self.selectedPoint, self.hoveredPoint, self.elementType)
		self.selectedPoint = false
	end
end

function api.Update(dt)
	self.hoveredPoint = self.currentDiagram and self.currentDiagram.GetPointAt(x, y)
	if util.Eq(self.selectedPoint, self.hoveredPoint) then
		self.hoveredPoint = false
	end
end

function api.Initialize(world)
	self = {
		world = world,
		elementType = Global.LINE
	}
	
	local def = {
		points = {{0, 500}, {500, 0}, {0, 0}, {310, 500}, {300, 450}},
		lines = {util.ExtendLine({{0, 500}, {500, 0}}, Global.LINE_LENGTH)},
		circles = {{0, 0, 500}},
	}
	
	self.currentDiagram = NewDiagram(def, self.world)
end

function api.Draw(drawQueue)
	if self.currentDiagram then
		self.currentDiagram.Draw(drawQueue, self.selectedPoint, self.hoveredPoint, self.elementType)
	end
end

return api
