
local ShapeDefs = require("defs/shapeDefs")

local function GetPointAtMouse(self, world, pos)
	local bestDistSq = false
	local bestPoint = false
	for i = 1, #self.points do
		if not self.points[i].destroyed then
			local point = self.points[i].geo
			local distSq = world.MouseNearWorldPos(point, 20)
			if distSq and ((not bestDistSq) or distSq < bestDistSq) then
				bestDistSq = distSq
				bestPoint = point
			end
		end
	end
	return bestPoint
end

local function GetOtherLine(line, pairOfLines)
	if pairOfLines[1].id == line.id then
		return pairOfLines[2]
	end
	return pairOfLines[1]
end

local function AddPoint(self, point)
	if not DiagramHandler.InBounds(point) then
		return false
	end
	for i = 1, #self.points do
		if (not self.points[i].destroyed) and util.Eq(point, self.points[i].geo) then
			return true, true, self.points[i]
		end
	end
	local newPoint = {
		geo = point,
		elements = {},
		destroyed = false,
		id = self.newID,
	}
	self.newID = self.newID + 1
	self.points[#self.points + 1] = newPoint
	return true, false, newPoint
end

local function DestroyPoint(self, point)
	local myID = point.id
	point.destroyed = true
	for i = 1, #point.elements do
		if not util.ListRemoveMutable(point.elements[i].points, myID) then
			print("List remove could not find in points for removing point", myID)
		end
	end
	-- Points are never destroyed when they are still intersecting lines, so do not
	-- search through notable angles.
end

local function CleanUpOrphanedPoints(self)
	local i = 1
	while i <= #self.points do
		if #self.points[i].elements < 2 then
			self.points[#self.points] = self.points[i]
			self.points[#self.points] = nil
		else
			i = i + 1
		end
	end
end

local function GetNewElement(u, v, elementType)
	if elementType == Global.LINE then
		return {u, v}
	elseif elementType == Global.CIRCLE then
		return {u[1], u[2], util.DistVectors(u, v)}
	end
end

local function InitElement(self, data)
	data.circles = {}
	data.lines = {}
	data.points = {}
	data.destroyed = false
	if data.isLine then
		data.notableAngles = {}
		data.inShapes = {}
	end
	data.id = self.newID
	self.newID = self.newID + 1
	return data
end

local function DestroyElement(self, element, doPointDestroy)
	local myID = element.id
	element.destroyed = true -- Element will fade out, so is not fully removed.
	local elementType = (self.isLine and "lines") or "circles"
	for i = 1, #element.points do
		if not util.ListRemoveMutable(element.circles[i].elements, myID) then
			print("List remove could not find in points", myID)
		end
	end
	for i = 1, #element.lines do
		if not util.ListRemoveMutable(element.lines[i][elementType], myID) then
			print("List remove could not find in lines", myID)
		end
	end
	for i = 1, #element.circles do
		if not util.ListRemoveMutable(element.circles[i][elementType], myID) then
			print("List remove could not find in circles", myID)
		end
	end
	if data.notableAngles then
		for i = 1, #data.notableAngles do
			local angleID = data.notableAngles[i].id
			local other = GetOtherLine(element, data.notableAngles.lines)
			if not util.ListRemoveMutable(other.notableAngles, angleID) then
				print("List remove could not find in notableAngles", myID)
			end
		end
	end
	if doPointDestroy then
		CleanUpOrphanedPoints(self)
	end
end

local function ElementAlreadyExists(self, newElement, elementType)
	if elementType == Global.LINE then
		for i = 1, #self.lines do
			if (not self.lines[i].destroyed) and util.EqLine(newElement, self.lines[i].geo) then
				return self.lines[i]
			end
		end
	elseif elementType == Global.CIRCLE then
		for i = 1, #self.circles do
			if (not self.circles[i].destroyed) and util.EqCircle(newElement, self.circles[i].geo) then
				return self.circles[i]
			end
		end
	end
	return false
end

local function GetPointAtPos(self, pos)
	for i = 1, #self.points do
		if (not self.points[i].destroyed) and util.Eq(pos, self.points[i].geo) then
			return self.points[i]
		end
	end
	return false
end

local function IsAngleInteresting(angle)
	for i = 1, #ShapeDefs.angles do
		if util.ApproxEqNumber(angle, ShapeDefs.angles[i]) then
			return i
		end
	end
	return false
end

local function AddIntersectionPoint(self, newElement, otherElement, pointPos)
	local inBounds, alreadyExists, point = AddPoint(self, pointPos)
	if not inBounds then
		return
	end
	if Global.DEBUG_PRINT_POINT then
		print("point {" .. pointPos[1] .. ", " .. pointPos[2] .. "}, ")
	end
	if not alreadyExists then
		otherElement.points[#otherElement.points + 1] = point
		point.elements[#point.elements + 1] = otherElement
	end
	newElement.points[#newElement.points + 1] = point
	point.elements[#point.elements + 1] = newElement
	if newElement.isLine and otherElement.isLine then
		local angle = util.GetAngleBetweenLines(newElement.geo, otherElement.geo)
		local angleType = IsAngleInteresting(angle)
		if angleType then
			local angleStats = {
				point = point,
				lines = {
					newElement,
					otherElement,
				},
				angleType = angleType,
				id = self.newID,
			}
			self.newID = self.newID + 1
			newElement.notableAngles[#newElement.notableAngles + 1] = angleStats
			otherElement.notableAngles[#otherElement.notableAngles + 1] = angleStats
		end
	end
end

local function AddLine(self, newLine, isPermanent)
	if Global.DEBUG_PRINT_LINE then
		print("line {{" .. newLine[1][1] .. ", " .. newLine[1][2] .. "}, {" .. newLine[2][1] .. ", " .. newLine[2][2] .. "}},")
	end
	newLine = util.ExtendLine(newLine, Global.LINE_LENGTH)
	local newElement = InitElement(self, {
		geo = newLine,
		isLine = true,
	})
	for i = 1, #self.circles do
		if (not self.circles[i].destroyed) then
			local intersect = util.GetCircleLineIntersectionPoints(self.circles[i].geo, newLine)
			if intersect then
				AddIntersectionPoint(self, newElement, self.circles[i], intersect[1])
				AddIntersectionPoint(self, newElement, self.circles[i], intersect[2])
			end
		end
	end
	for i = 1, #self.lines do
		if (not self.lines[i].destroyed) then
			local intersect = util.GetBoundedLineIntersection(self.lines[i].geo, newLine)
			if intersect then
				AddIntersectionPoint(self, newElement, self.lines[i], intersect)
			end
		end
	end
	self.lines[#self.lines + 1] = newElement
	return newElement
end

local function AddCircle(self, newCircle, isPermanent)
	if Global.DEBUG_PRINT_CIRCLE then
		print("circle {" .. newCircle[1] .. ", " .. newCircle[2] .. ", " .. newCircle[3] .. "},")
	end
	local newElement = InitElement(self, {
		geo = newCircle,
		isCircle = true,
	})
	for i = 1, #self.circles do
		if (not self.circles[i].destroyed) then
			local intersect = util.GetCircleIntersectionPoints(self.circles[i].geo, newCircle)
			if intersect then
				AddIntersectionPoint(self, newElement, self.circles[i],intersect[1])
				AddIntersectionPoint(self, newElement, self.circles[i],intersect[2])
			end
		end
	end
	for i = 1, #self.lines do
		if (not self.lines[i].destroyed) then
			local intersect = util.GetCircleLineIntersectionPoints(newCircle, self.lines[i].geo)
			if intersect then
				AddIntersectionPoint(self, newElement, self.lines[i],intersect[1])
				AddIntersectionPoint(self, newElement, self.lines[i],intersect[2])
			end
		end
	end
	self.circles[#self.circles + 1] = newElement
end

local function MatchPotentialShape(self, shape, corner, mainVector, otherVector)
	print("Maybe found", shape.name)
	local verticies = shape.ExpectedLines(corner, mainVector, otherVector)
	for i = 1, #verticies do
		if not GetPointAtPos(self, verticies[i]) then
			return false
		end
	end
	local edges = {}
	for i = 1, #verticies do
		local prev = i - 1
		if prev == 0 then
			prev = #verticies
		end
		edges[#edges + 1] = {verticies[prev], verticies[i]}
	end
	local foundLines = {}
	for i = 1, #edges do
		local line = ElementAlreadyExists(self, edges[i], Global.LINE)
		if not line then
			return false
		end
		foundLines[#foundLines + 1] = line
	end
	print("Actually found", shape.name)
	ShapeHandler.AddShape(shape, verticies, edges, foundLines)
end

local function FindShape(self, angleType, corner, mainEdge, otherEdge)
	local potentialShapes = ShapeDefs.shapesWithAngleIndex[angleType]
	local mainVector = util.Subtract(mainEdge, corner)
	local otherVector = util.Subtract(otherEdge, corner)
	for i = 1, #potentialShapes do
		MatchPotentialShape(self, potentialShapes[i], corner, mainVector, otherVector)
	end
end

local function CheckForShapeFromSegment(self, mainLine, mainCorner, mainPoint)
	local reqLengthSq = util.DistSqVectors(mainCorner.point.geo, mainPoint.geo)
	local otherLine = GetOtherLine(mainLine, mainCorner.lines)
	for i = 1, #otherLine.notableAngles do
		local otherCorner = otherLine.notableAngles[i]
		if otherCorner.angleType == mainCorner.angleType and otherCorner.id ~= mainCorner.id then
			if util.ApproxEqNumber(util.DistSqVectors(otherCorner.point.geo, mainCorner.point.geo), reqLengthSq) then
				FindShape(self, mainCorner.angleType, mainCorner.point.geo, mainPoint.geo, otherCorner.point.geo)
			end
		end
	end
end

local function CheckNewLineForShapes(self, mainLine)
	for i = 1, #mainLine.notableAngles do
		local primary = mainLine.notableAngles[i]
		for j = 1, #mainLine.notableAngles do
			local secondary = mainLine.notableAngles[j]
			-- Shapes have the loop back around, so we are only interested in segments that
			-- have the same interesting angle on both end.
			if primary.angleType == secondary.angleType and primary.id < secondary.id then
				CheckForShapeFromSegment(self, mainLine, primary, secondary.point)
			end
		end
	end
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
		local newLine = AddLine(self, newElement)
		CheckNewLineForShapes(self, newLine)
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
	
	function self.GetPointAtMouse(pos)
		return GetPointAtMouse(self, world, pos)
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
