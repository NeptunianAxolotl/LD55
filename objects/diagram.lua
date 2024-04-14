
local function GetPointAt(self, world, pos)
	local bestDistSq = false
	local bestPoint = false
	for i = 1, #self.points do
		local point = self.points[i].geo
		local distSq = world.MouseNearWorldPos(point, 20)
		if distSq and ((not bestDistSq) or distSq < bestDistSq) then
			bestDistSq = distSq
			bestPoint = point
		end
	end
	return bestPoint
end

local function GetNewElement(u, v, elementType)
	if elementType == Global.LINE then
		return {u, v}
	elseif elementType == Global.CIRCLE then
		return {u[1], u[2], util.DistVectors(u, v)}
	end
end

local function ElementAlreadyExists(self, newElement, elementType)
	if elementType == Global.LINE then
		for i = 1, #self.lines do
			if util.EqLine(newElement, self.lines[i].geo) then
				return true
			end
		end
	elseif elementType == Global.CIRCLE then
		for i = 1, #self.circles do
			if util.EqCircle(newElement, self.circles[i].geo) then
				return true
			end
		end
	end
	return false
end

local function InitObject(self, data)
	data.circles = {}
	data.lines = {}
	data.points = {}
	data.id = self.newID
	self.newID = self.newID + 1
	return data
end

local function AddPoint(self, point)
	if not DiagramHandler.InBounds(point) then
		return false
	end
	for i = 1, #self.points do
		if util.Eq(point, self.points[i].geo) then
			return true, true, self.points[i]
		end
	end
	local newPoint = {
		geo = point,
		elements = {},
		id = self.newID,
	}
	self.newID = self.newID + 1
	self.points[#self.points + 1] = newPoint
	return true, false, newPoint
end

local function AddIntersectionPoint(self, newElement, otherElement, pointPos)
	local inBounds, alreadyExists, point = AddPoint(self, pointPos)
	if not inBounds then
		return
	end
	if not alreadyExists then
		otherElement.points[#otherElement.points + 1] = point
		point.elements[#point.elements + 1] = otherElement
	end
	newElement.points[#newElement.points + 1] = point
	point.elements[#point.elements + 1] = newElement
end

local function AddLine(self, newLine, isPermanent)
	if Global.DEBUG_PRINT_CLICK_POS then
		print("line {{" .. newLine[1][1] .. ", " .. newLine[1][2] .. "}, {" .. newLine[2][1] .. ", " .. newLine[2][2] .. "}},")
	end
	newLine = util.ExtendLine(newLine, Global.LINE_LENGTH)
	local newElement = InitObject(self, {
		geo = newLine,
		isLine = true,
	})
	for i = 1, #self.circles do
		local intersect = util.GetCircleLineIntersectionPoints(self.circles[i].geo, newLine)
		if intersect then
			AddIntersectionPoint(self, newElement, self.circles[i], intersect[1])
			AddIntersectionPoint(self, newElement, self.circles[i], intersect[2])
		end
	end
	for i = 1, #self.lines do
		local intersect = util.GetBoundedLineIntersection(self.lines[i].geo, newLine)
		if intersect then
			AddIntersectionPoint(self, newElement, self.lines[i], intersect)
		end
	end
	self.lines[#self.lines + 1] = newElement
end

local function AddCircle(self, newCircle, isPermanent)
	if Global.DEBUG_PRINT_CLICK_POS then
		print("circle {" .. newCircle[1] .. ", " .. newCircle[2] .. ", " .. newCircle[3] .. "},")
	end
	local newElement = InitObject(self, {
		geo = newCircle,
		isCircle = true,
	})
	for i = 1, #self.circles do
		local intersect = util.GetCircleIntersectionPoints(self.circles[i].geo, newCircle)
		if intersect then
			AddIntersectionPoint(self, newElement, self.circles[i],intersect[1])
			AddIntersectionPoint(self, newElement, self.circles[i],intersect[2])
		end
	end
	for i = 1, #self.lines do
		local intersect = util.GetCircleLineIntersectionPoints(newCircle, self.lines[i].geo)
		if intersect then
			AddIntersectionPoint(self, newElement, self.lines[i],intersect[1])
			AddIntersectionPoint(self, newElement, self.lines[i],intersect[2])
		end
	end
	self.circles[#self.circles + 1] = newElement
end

local function AddElement(self, u, v, elementType)
	local newElement = GetNewElement(u, v, elementType)
	if not newElement then
		return false
	end
	if ElementAlreadyExists(self, newElement, elementType) then
		return false
	end
	if elementType == Global.LINE then
		AddLine(self, newElement)
	elseif elementType == Global.CIRCLE then
		AddCircle(self, newElement)
	end
	return true
end

local function SetAgeAppropriateColor(self, age)
	if age then
		love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], math.max(0.18,  math.min(0.7, 0.9*math.pow(0.89, self.presentAge - age))))
	else
		love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 0.9)
	end
end

local function NewDiagram(levelData, world)
	local self = {}
	
	self.points = {}
	self.lines = {}
	self.circles = {}
	self.presentAge = 0
	self.newID = 0
	
	for i = 1, #levelData.lines do
		AddLine(self, levelData.lines[i], levelData.permanentLines[i])
	end
	for i = 1, #levelData.circles do
		AddCircle(self, levelData.circles[i], levelData.permanentCircles[i])
	end
	
	function self.GetPointAt(pos)
		return GetPointAt(self, world, pos)
	end
	
	function self.AddElement(u, v, elementType)
		return AddElement(self, u, v, elementType)
	end
	
	function self.Draw(drawQueue, selectedPoint, hoveredPoint, elementType)
		drawQueue:push({y=10; f=function()
			love.graphics.setLineWidth(4)
			
			love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 0.9)
			for i = 1, #self.lines do
				local line = self.lines[i].geo
				love.graphics.line(line[1][1], line[1][2], line[2][1], line[2][2])
			end
			
			for i = 1, #self.circles do
				local circle = self.circles[i].geo
				love.graphics.circle('line', circle[1], circle[2], circle[3], math.floor(math.max(32, math.min(160, circle[3]*0.8))))
			end
			
			if selectedPoint then
				love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 0.3)
				local target = hoveredPoint or world.GetMousePosition()
				if elementType == Global.LINE then
					local line = util.ExtendLine({selectedPoint, target}, Global.LINE_LENGTH)
					love.graphics.line(line[1][1], line[1][2], line[2][1], line[2][2])
				elseif elementType == Global.CIRCLE then
					local radius = util.DistVectors(selectedPoint, target)
					love.graphics.circle('line', selectedPoint[1], selectedPoint[2], radius)
				end
			end
			
			love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 1)
			love.graphics.setLineWidth(0)
			for i = 1, #self.points do
				local point = self.points[i].geo
				if util.Eq(point, selectedPoint) then
					love.graphics.circle('fill', point[1], point[2], 15)
				elseif util.Eq(point, hoveredPoint) then
					love.graphics.circle('fill', point[1], point[2], 16)
				else
					love.graphics.circle('fill', point[1], point[2], 6)
				end
			end
		end})
	end
	
	return self
end

return NewDiagram
