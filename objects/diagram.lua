
local ShapeDefs = require("defs/shapeDefs")

local function GetPointAtMouse(self, world, pos)
	local bestDistSq = false
	local bestID = false
	local bestPoint = false
	for i = 1, #self.points do
		if not self.points[i].destroyed then
			local point = self.points[i].geo
			local distSq = world.MouseNearWorldPos(point, Global.CLICK_RADIUS)
			if distSq and ((not bestDistSq) or distSq < bestDistSq) then
				if (math.sqrt(distSq) > Global.CLICK_RECENT_RADIUS) or ((not bestID) or bestID > self.points[i].id) then
					bestID = self.points[i].id
					bestDistSq = distSq
					bestPoint = point
				end
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
			DestroyPoint(self, self.points[i])
			self.points[i] = self.points[#self.points]
			self.points[#self.points] = nil
		else
			i = i + 1
		end
	end
end

local function ElementContainsPoint(element, pointPos)
	for i = 1, #element.points do
		if util.VeryApproxEq(pointPos, element.points[i].geo) then
			return true
		end
	end
	return false
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
	
	self.newestElementCounter = self.newestElementCounter + 1
	data.elementCount = self.newestElementCounter
	
	data.id = self.newID
	self.newID = self.newID + 1
	
	return data
end

local function DestroyElement(self, element, doPointDestroy)
	local myID = element.id
	element.destroyed = true -- Element will fade out, so is not fully removed.
	local elementType = (self.isLine and "lines") or "circles"
	for i = 1, #element.points do
		if not util.ListRemoveMutable(element.points[i].elements, myID) then
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
	if element.notableAngles then
		for i = 1, #element.notableAngles do
			local angleID = element.notableAngles[i].id
			local other = GetOtherLine(element, element.notableAngles[i].lines)
			if not util.ListRemoveMutable(other.notableAngles, angleID) then
				print("List remove could not find in notableAngles", myID)
			end
		end
	end
	if doPointDestroy then
		CleanUpOrphanedPoints(self)
	end
end

local function ElementAlreadyExists(self, newElement, elementType, veryApprox)
	if elementType == Global.LINE then
		for i = 1, #self.lines do
			if (not self.lines[i].destroyed) and util.EqLine(newElement, self.lines[i].geo, veryApprox) then
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
		if (not self.points[i].destroyed) and util.VeryApproxEq(pos, self.points[i].geo) then
			return self.points[i]
		end
	end
	return false
end

local function IsAngleInteresting(angle)
	for i = 1, #ShapeDefs.angles do
		if util.VeryApproxEqNumber(angle, ShapeDefs.angles[i]) then
			return i
		end
	end
	return false
end

local function IsInElements(elements, id)
	if #elements <= 0 then
		return false
	end
	if elements[#elements].id == id then
		return true
	end
	for i = 1, #elements do
		if elements[i].id == id then
			return true
		end
	end
	return false
end

local function AddIntersectionPoint(self, newElement, otherElement, pointPos)
	if not pointPos then
		return
	end
	local inBounds, alreadyExists, point = AddPoint(self, pointPos)
	if not inBounds then
		return
	end
	if not alreadyExists then
		otherElement.points[#otherElement.points + 1] = point
		point.elements[#point.elements + 1] = otherElement
		if Global.DEBUG_PRINT_POINT then
			print("point {" .. pointPos[1] .. ", " .. pointPos[2] .. "}, ")
		end
	end
	if (not alreadyExists) or (not IsInElements(point.elements, newElement.id)) then
		newElement.points[#newElement.points + 1] = point
		point.elements[#point.elements + 1] = newElement
	end
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

local function PossiblyMerge(intersect)
	if not intersect then
		return false
	end
	if not intersect[2] then
		return intersect
	end
	if util.DistSqVectors(intersect[1], intersect[2]) < 25 then
		return {
			util.Average(intersect[1], intersect[2])
		}
	end
	return intersect
end

local function AddLine(self, newLine, isPermanent)
	if Global.DEBUG_PRINT_LINE then
		print("line {{" .. newLine[1][1] .. ", " .. newLine[1][2] .. "}, {" .. newLine[2][1] .. ", " .. newLine[2][2] .. "}},")
	end
	newLine = util.ExtendLine(newLine, Global.LINE_LENGTH)
	local newElement = InitElement(self, {
		geo = newLine,
		isLine = true,
		isPermanent = isPermanent,
	})
	for i = 1, #self.circles do
		if (not self.circles[i].destroyed) then
			local intersect = util.GetCircleLineIntersectionPoints(self.circles[i].geo, newLine)
			intersect = PossiblyMerge(intersect)
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
		isPermanent = isPermanent,
	})
	for i = 1, #self.circles do
		if (not self.circles[i].destroyed) then
			local intersect = util.GetCircleIntersectionPoints(self.circles[i].geo, newCircle)
			intersect = PossiblyMerge(intersect)
			if intersect then
				AddIntersectionPoint(self, newElement, self.circles[i],intersect[1])
				AddIntersectionPoint(self, newElement, self.circles[i],intersect[2])
			end
		end
	end
	for i = 1, #self.lines do
		if (not self.lines[i].destroyed) then
			local intersect = util.GetCircleLineIntersectionPoints(newCircle, self.lines[i].geo)
			intersect = PossiblyMerge(intersect)
			if intersect then
				AddIntersectionPoint(self, newElement, self.lines[i],intersect[1])
				AddIntersectionPoint(self, newElement, self.lines[i],intersect[2])
			end
		end
	end
	self.circles[#self.circles + 1] = newElement
	EnemyHandler.PushEnemiesFrom(newCircle)
end

local function PrintAtPoint(vertices, text)
	local pos = util.AverageMulti(vertices)
	EffectsHandler.SpawnEffect("mult_popup", pos, {
		text = text,
		velocity = {0, 0}
	})
end

local function MatchPotentialShape(self, shape, corner, mainVector, otherVector)
	if PowerHandler.GetMaxShapesType(shape.name) <= 0 then
		return false
	end
	if Global.PRINT_SHAPE_FOUND then
		print("Maybe found", shape.name)
	end
	local vertices = shape.ExpectedLines(corner, mainVector, otherVector)
	for i = 1, #vertices do
		if not GetPointAtPos(self, vertices[i]) then
			return false
		end
	end
	if Global.PRINT_SHAPE_FOUND then
		print("Found vertices")
	end
	if ShapeHandler.ShapePartialAt(shape.name, vertices) then
		if Global.PRINT_SHAPE_FOUND then
			print("Found duplicate")
			PrintAtPoint(vertices, "D")
		end
		return false
	end
	local edges = {}
	local lengthSq = false
	for i = 1, #vertices do
		local prev = i - 1
		if prev == 0 then
			prev = #vertices
		end
		local edge = {vertices[prev], vertices[i]}
		if lengthSq and not util.ExtremelyApproxEqNumber(util.LineLengthSq(edge), lengthSq) then
			if Global.PRINT_SHAPE_FOUND then
				print("Bad Length", lengthSq - util.LineLengthSq(edge))
				PrintAtPoint(vertices, "B")
			end
			return false -- How did we get here? I saw an isosceles triangle once.
		else
			lengthSq = util.LineLengthSq(edge)
			if lengthSq < 1 then
				if Global.PRINT_SHAPE_FOUND then
					print("Length < 1")
					PrintAtPoint(vertices, "<1")
				end
				return false -- ???
			end
		end
		edges[#edges + 1] = edge
	end
	if Global.PRINT_SHAPE_FOUND then
		print("edges")
	end
	local foundLines = {}
	for i = 1, #edges do
		local line = ElementAlreadyExists(self, edges[i], Global.LINE, true)
		if not line then
			if Global.PRINT_SHAPE_FOUND then
				print("Missing Line", i)
			end
			return false
		else
			foundLines[#foundLines + 1] = line
		end
	end
	--print("Found sssssssssssssssssssss")
	--util.PrintTable(ShapeHandler.GetCompareVertices(vertices, true))
	if Global.PRINT_SHAPE_FOUND then
		print("Found foundLines")
	end
	if Global.PRINT_SHAPE_FOUND then
		print("Actually found", shape.name)
	end
	ShapeHandler.AddShape(shape, vertices, edges, foundLines)
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
			if util.VeryApproxEqNumber(util.DistSqVectors(otherCorner.point.geo, mainCorner.point.geo), reqLengthSq) then
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
	local existingElement = ElementAlreadyExists(self, newElement, elementType)
	if existingElement then
		if existingElement.fade and Global.CAN_REFRESH_ELEMENT then
			-- Refresh fade
			existingElement.fade = nil
			self.newestElementCounter = self.newestElementCounter + 1
			existingElement.elementCount = self.newestElementCounter
			return true
		end
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

local function UpdateFadeAndDestroy(self, elements, dt)
	local safeLines = PowerHandler.GetSafeLineCapacity()
	local fadeTime = PowerHandler.GetLineFadeTime()
	local recentSafety = self.newestElementCounter - safeLines
	
	local destroyed = false
	local i = 1
	while i < #elements do
		local element = elements[i]
		local fadeMult = 1
		if element.isLine then
			if element.inShapes and #element.inShapes > 0 then
				fadeMult = Global.SHAPE_LINE_FADE_MULT
				element.maxInShapes = math.max((element.maxInShapes or 0), #element.inShapes)
			elseif (element.maxInShapes or 0) > 0 then
				if (not element.isPermanent) and (not element.destroyed) then
					fadeMult = Global.SHAPE_LINE_ORPHAN_FADE_MULT
				end
			end
		end
		
		if not GameHandler.GetTutorial() then
			if (not element.isPermanent) and (not element.destroyed) and (element.elementCount < recentSafety or fadeMult > 1) and fadeMult > 0 then
				element.fade = (element.fade or 0) + dt*fadeMult
				if element.fade > fadeTime then
					DestroyElement(self, element)
					destroyed = true
				end
			end
		end
		if element.destroyed then
			element.destroyTimer = (element.destroyTimer or 1) - 2.3*dt
			if element.destroyTimer < 0 then
				elements[i] = elements[#elements]
				elements[#elements] = nil
				i = i - 1
			end
		end
		i = i + 1
	end
	if destroyed then
		CleanUpOrphanedPoints(self)
	end
end

local function RespondToRemovedShape(self, edges, shapeID)
	for i = 1, #edges do
		local line = ElementAlreadyExists(self, edges[i], Global.LINE, true)
		if line then
			for j = 1, #line.inShapes do
				if line.inShapes[j] == shapeID then
					line.inShapes[j] = line.inShapes[#line.inShapes]
					line.inShapes[#line.inShapes] = nil
					break
				end
			end
		end
	end
end

local function GetElementOpacity(element, fadeTime)
	if element.destroyTimer then
		return element.destroyTimer * 0.55
	end
	if not element.fade then
		return 0.75
	end
	local prop = 1 - math.pow(1 - (element.fade / fadeTime), 1.8)
	return prop * 0.55 + (1 - prop) * 0.75
end

local function SetElementColor(element, fadeTime, hoveredPoint)
	local col = (hoveredPoint and ElementContainsPoint(element, hoveredPoint) and Global.LINE_HIGHLIGHT_COL) or Global.LINE_COL
	love.graphics.setColor(col[1], col[2], col[3], GetElementOpacity(element, fadeTime))
end

local function IsPointInListOfPoints(pointList, point)
	if not point then
		return false
	end
	for i = 1, #pointList do
		if util.Eq(point, pointList[i]) then
			return true
		end
	end
	return false
end

local function NewDiagram(levelData, world)
	local self = {}
	
	self.points = {}
	self.lines = {}
	self.circles = {}
	self.newestElementCounter = 0
	self.newID = 0
	self.animTimer = 0
	
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
	
	function self.RespondToRemovedShape(edges, shapeId)
		RespondToRemovedShape(self, edges, shapeId)
	end
	
	function self.Update(dt)
		UpdateFadeAndDestroy(self, self.lines, dt)
		UpdateFadeAndDestroy(self, self.circles, dt)
		self.animTimer = (self.animTimer + dt*1.6)%1
	end
	
	function self.CheckElementTypeSwitch(selectedPoint, hoveredPoint, elementType)
		if not (selectedPoint and hoveredPoint) then
			return elementType
		end
		if ElementAlreadyExists(self, GetNewElement(selectedPoint, hoveredPoint, elementType), elementType) then
			if elementType == Global.LINE then
				return Global.CIRCLE
			elseif elementType == Global.CIRCLE then
				return Global.LINE
			end
		end
		return elementType
	end
	
	function self.ElementExists(element, elementType)
		return ElementAlreadyExists(self, element, elementType)
	end
	
	function self.PointExists(pos)
		return GetPointAtPos(self, pos)
	end
	
	function self.Draw(drawQueue, selectedPoint, hoveredPoint, elementType)
		drawQueue:push({y=10; f=function()
			love.graphics.setLineWidth(4)
			local fadeTime = PowerHandler.GetLineFadeTime()
			
			for i = 1, #self.lines do
				local line = self.lines[i].geo
				SetElementColor(self.lines[i], fadeTime, hoveredPoint)
				love.graphics.line(line[1][1], line[1][2], line[2][1], line[2][2])
				if Global.DEBUG_SPECIAL_ANGLES then
					for j = 1, #self.lines[i].notableAngles do
						local notable = self.lines[i].notableAngles[j]
						love.graphics.printf(notable.angleType, notable.point.geo[1], notable.point.geo[2], 30, "right")
					end
				end
				if Global.DEBUG_SHAPES then
					local geo = util.Average(line[1], line[2])
					love.graphics.printf((not self.lines[i].inShapes and "n") or #self.lines[i].inShapes, geo[1], geo[2], 50, "left")
				end
			end
			
			for i = 1, #self.circles do
				local circle = self.circles[i].geo
				SetElementColor(self.circles[i], fadeTime, hoveredPoint)
				love.graphics.circle('line', circle[1], circle[2], circle[3], math.floor(math.max(32, math.min(160, circle[3]*0.8))))
				if Global.DEBUG_SHAPES then
					--love.graphics.printf((not self.circles[i].inShapes and "n") or #self.circles[i].inShapes, circle[1], circle[2], 50, "left")
				end
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
			
			love.graphics.setLineWidth(0)
			for i = 1, #self.points do
				local point = self.points[i].geo
				love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 1)
				if Global.DEBUG_POINT_INTERSECT then
					love.graphics.printf(#self.points[i].elements, point[1], point[2], 30, "right")
				end
				if util.Eq(point, selectedPoint) then
					love.graphics.circle('fill', point[1], point[2], 15)
				elseif util.Eq(point, hoveredPoint) then
					if PlayerHandler.InSelectRange(point) then
						love.graphics.circle('fill', point[1], point[2], 16)
					else
						love.graphics.setColor(Global.RED_COL[1], Global.RED_COL[2], Global.RED_COL[3], 1)
						love.graphics.circle('fill', point[1], point[2], 8)
					end
				else
					love.graphics.circle('fill', point[1], point[2], 6)
				end
			end
			
			local tutorial = GameHandler.GetTutorial()
			if tutorial and tutorial.points then
				love.graphics.setLineWidth(4)
				love.graphics.setColor(Global.POINT_TUTORIAL_COL[1], Global.POINT_TUTORIAL_COL[2], Global.POINT_TUTORIAL_COL[3], 1)
				local radius = 25 + 10*math.sin(self.animTimer*2*math.pi)
				
				local toDraw = (IsPointInListOfPoints(tutorial.points, selectedPoint) and tutorial.pointsIfSelected) or tutorial.points
				for i = 1, #toDraw do
					if not util.Eq(selectedPoint,toDraw[i]) then
						love.graphics.circle('line', toDraw[i][1], toDraw[i][2], radius, 32)
					end
				end
			end
		end})
	end
	
	return self
end

return NewDiagram
