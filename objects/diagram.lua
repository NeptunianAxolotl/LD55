
local Resources = require("resourceHandler")
local Font = require("include/font")

local function GetPointAt(self, world, pos)
	for i = 1, #self.points do
		local point = self.points[i]
		if world.MouseNearWorldPos(point, 20) then
			return point
		end
	end
	return false
end

local function GetNewElement(u, v, elementType)
	if elementType == Global.LINE then
		return {u, v}
	elseif elementType == Global.CIRCLE then
		return {u, util.DistVectors(u, v)}
	end
end

local function ElementAlreadyExists(self, newElement, elementType)
	if elementType == Global.LINE then
		for i = 1, #self.lines do
			if util.EqLine(newElement, self.lines[i]) then
				return true
			end
		end
	elseif elementType == Global.CIRCLE then
		for i = 1, #self.circles do
			if util.EqCircle(newElement, self.circles[i]) then
				return true
			end
		end
	end
	return false
end

local function AddPoint(self, point)
	for i = 1, #self.points do
		if util.Eq(point, self.points[i]) then
			return
		end
	end
	self.points[#self.points + 1] = point
end

local function AddLine(self, newLine)
	newLine = util.ExtendLine(newLine, Global.LINE_LENGTH)
	for i = 1, #self.circles do
		local intersect = util.GetCircleLineIntersectionPoints(self.circles[i], newLine)
		if intersect then
			AddPoint(self, intersect[1])
			AddPoint(self, intersect[2])
		end
	end
	for i = 1, #self.lines do
		local intersect = util.GetBoundedLineIntersection(self.lines[i], newLine)
		if intersect then
			AddPoint(self, intersect)
		end
	end
	self.lines[#self.lines + 1] = newLine
end

local function AddElement(self, u, v, elementType)
	local newElement = GetNewElement(u, v, elementType)
	if not newElement then
		return
	end
	if ElementAlreadyExists(self, newElement, elementType) then
		return
	end
	if elementType == Global.LINE then
		AddLine(self, newElement)
	elseif elementType == Global.CIRCLE then
		AddCircle(self, newElement)
	end
end

local function NewDiagram(def, world)
	local self = {}
	
	self.points = def.points
	self.lines = def.lines
	self.circles = def.circles
	
	function self.GetPointAt(pos)
		return GetPointAt(self, world, pos)
	end
	
	function self.AddElement(u, v, elementType)
		return AddElement(self, u, v, elementType)
	end
	
	function self.Draw(drawQueue, selectedPoint, hoveredPoint, elementType)
		drawQueue:push({y=10; f=function()
			love.graphics.setLineWidth(4)
			
			love.graphics.setColor(1, 1, 1, 0.9)
			for i = 1, #self.lines do
				local line = self.lines[i]
				love.graphics.line(line[1][1], line[1][2], line[2][1], line[2][2])
			end
			
			for i = 1, #self.circles do
				local circle = self.circles[i]
				love.graphics.circle('line', circle[1], circle[2], circle[3], math.floor(math.max(32, math.min(160, circle[3]*0.8))))
			end
			
			if selectedPoint then
				love.graphics.setColor(1, 1, 1, 0.3)
				local target = hoveredPoint or world.GetMousePosition()
				if elementType == Global.LINE then
					local line = util.ExtendLine({selectedPoint, target}, Global.LINE_LENGTH)
					love.graphics.line(line[1][1], line[1][2], line[2][1], line[2][2])
				elseif elementType == Global.CIRCLE then
					local radius = util.DistVectors(selectedPoint, target)
					love.graphics.circle('line', selectedPoint[1], selectedPoint[2], radius)
				end
			end
			
			
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.setLineWidth(2)
			for i = 1, #self.points do
				local point = self.points[i]
				if util.Eq(point, selectedPoint) then
					love.graphics.circle('fill', point[1], point[2], 15)
				elseif util.Eq(point, hoveredPoint) then
					love.graphics.circle('fill', point[1], point[2], 16)
				else
					love.graphics.circle('fill', point[1], point[2], 10)
				end
			end
		end})
	end
	
	return self
end

return NewDiagram
