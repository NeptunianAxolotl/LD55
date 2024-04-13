
local function GetPointAt(self, world, pos)
	local bestDistSq = false
	local bestPoint = false
	for i = 1, #self.points do
		local point = self.points[i]
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


local function AgeElement(self, element, ReqFunction)
	if ReqFunction(element) then
		return false
	end
	return self.presentAge
end

local function AddPoint(self, point)
	if not DiagramHandler.InBounds(point) then
		return
	end
	for i = 1, #self.points do
		if util.Eq(point, self.points[i]) then
			return
		end
	end
	self.points[#self.points + 1] = point
end

local function AddLine(self, newLine)
	if Global.DEBUG_PRINT_CLICK_POS then
		print("line {{" .. newLine[1][1] .. ", " .. newLine[1][2] .. "}, {" .. newLine[2][1] .. ", " .. newLine[2][2] .. "}},")
	end
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
	self.presentAge = self.presentAge + 1
	self.lineAge[#self.lineAge + 1] = AgeElement(self, newLine, DiagramHandler.IsLineRequired)
end

local function AddCircle(self, newCircle)
	if Global.DEBUG_PRINT_CLICK_POS then
		print("circle {" .. newCircle[1] .. ", " .. newCircle[2] .. ", " .. newCircle[3] .. "},")
	end
	for i = 1, #self.circles do
		local intersect = util.GetCircleIntersectionPoints(self.circles[i], newCircle)
		if intersect then
			AddPoint(self, intersect[1])
			AddPoint(self, intersect[2])
		end
	end
	for i = 1, #self.lines do
		local intersect = util.GetCircleLineIntersectionPoints(newCircle, self.lines[i])
		if intersect then
			AddPoint(self, intersect[1])
			AddPoint(self, intersect[2])
		end
	end
	self.circles[#self.circles + 1] = newCircle
	self.presentAge = self.presentAge + 1
	self.circleAge[#self.circleAge + 1] = AgeElement(self, newCircle, DiagramHandler.IsCircleRequired)
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
		love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], math.max(0.2, math.pow(0.9, self.presentAge - age)))
	else
		love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 0.9)
	end
end

local function NewDiagram(def, world)
	local self = {}
	
	self.points = def.points
	self.lines = def.lines
	self.circles = def.circles
	self.lineAge = {}
	self.circleAge = {}
	self.presentAge = 0
	
	for i = 1, #self.lines do
		self.lineAge[#self.lineAge + 1] = AgeElement(self, self.lines[i], DiagramHandler.IsLineRequired)
	end
	for i = 1, #self.circles do
		self.circleAge[#self.circleAge + 1] = AgeElement(self, self.circles[i], DiagramHandler.IsCircleRequired)
	end
	
	function self.GetPointAt(pos)
		return GetPointAt(self, world, pos)
	end
	
	function self.AddElement(u, v, elementType)
		return AddElement(self, u, v, elementType)
	end
	
	function self.ContainsLine(line)
		return util.ListContains(self.lines, line, util.EqLine)
	end
	
	function self.ContainsCircle(circle)
		return util.ListContains(self.circles, circle, util.EqCircle)
	end
	
	function self.Draw(drawQueue, selectedPoint, hoveredPoint, elementType)
		drawQueue:push({y=10; f=function()
			love.graphics.setLineWidth(4)
			
			love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 0.9)
			for i = 1, #self.lines do
				local line = self.lines[i]
				SetAgeAppropriateColor(self, self.lineAge[i])
				love.graphics.line(line[1][1], line[1][2], line[2][1], line[2][2])
			end
			
			for i = 1, #self.circles do
				local circle = self.circles[i]
				SetAgeAppropriateColor(self, self.circleAge[i])
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
			local initialPoints = DiagramHandler.GetInitialPointCount()
			for i = 1, #self.points do
				local point = self.points[i]
				if util.Eq(point, selectedPoint) then
					love.graphics.circle('fill', point[1], point[2], 15)
				elseif util.Eq(point, hoveredPoint) then
					love.graphics.circle('fill', point[1], point[2], 16)
				else
					love.graphics.circle('fill', point[1], point[2], (i <= initialPoints) and 6 or 3)
				end
			end
		end})
	end
	
	return self
end

return NewDiagram
