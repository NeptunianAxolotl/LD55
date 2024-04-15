
local ShapeDefs = require("defs/shapeDefs")
local NewShape = require("objects/shape")

local self = {}
local api = {}

function api.AddShape(shapeDef, vertices, edges, definingLines)
	local new = NewShape(self.world, self.nextShapeID, shapeDef, vertices, edges, definingLines)
	IterableMap.Add(self.shapes, self.nextShapeID, new)
	self.nextShapeID = self.nextShapeID + 1
	self.shapesCreated = self.shapesCreated + 1
  
  local soundNum = math.floor(love.math.random(1,8))
  SoundHandler.PlaySound("draw_"..soundNum)
	
	if api.GetShapeTypeCount(shapeDef.name) > PowerHandler.GetMaxShapesType(shapeDef.name) then
		api.DestroyOldestShape(shapeDef.name)
    SoundHandler.PlaySound("shape_vanish")
	end
end

function api.GetCompareVertices(vertices, doPrint)
	local minVertex = 1
	for i = 2, #vertices do
		if vertices[i][1] < vertices[minVertex][1] or 
				(vertices[i][1] == vertices[minVertex][1] and vertices[i][2] < vertices[minVertex][2]) then
			minVertex = i
		end
	end
	local secondMinVertex = false
	for i = 1, #vertices do
		if i ~= minVertex then
			if not secondMinVertex then
				secondMinVertex = i
			elseif vertices[i][1] < vertices[secondMinVertex][1] or 
					(vertices[i][1] == vertices[secondMinVertex][1] and vertices[i][2] < vertices[secondMinVertex][2]) then
				secondMinVertex = i
			end
		end
	end
	local direction = ((secondMinVertex > minVertex) and 1) or -1
	if minVertex == 1 and secondMinVertex > 2 then
		direction = -1
	end
	if secondMinVertex == 1 and minVertex > 2 then
		direction = 1
	end
	
	if doPrint then
		print('min vert', minVertex, secondMinVertex, direction)
		util.PrintTable(vertices)
	end
	
	local cur = minVertex
	local compare = {}
	for i = 1, #vertices do
		compare[i] = vertices[cur]
		cur = ((cur + direction) - 1)%(#vertices) + 1
	end
	return compare
end

local function ShapeMatches(shape, shapeType, compareVertices, compareN)
	if shape.def.name ~= shapeType then
		return false
	end
	for i = 1, compareN do
		if not util.VeryApproxEq(shape.compareVertices[i], compareVertices[i]) then
			return false
		end
	end
	return true
end

function api.ShapeAt(shapeType, vertices)
	local compareVertices = api.GetCompareVertices(vertices)
	local compareN = #compareVertices
	return IterableMap.GetFirstSatisfies(self.shapes, ShapeMatches, shapeType, compareVertices, compareN)
end

local function ShapePartialMatch(shape, shapeType, compareVertices, compareN)
	if shape.def.name ~= shapeType then
		return false
	end
	for i = 1, compareN do
		if util.VeryApproxEq(shape.compareVertices[i], compareVertices[i]) then
			local left = (i - 2)%compareN + 1
			local gradLeft = util.GradientPoints(compareVertices[i], compareVertices[left])
			local gradLeftOther = util.GradientPoints(shape.compareVertices[i], shape.compareVertices[left])
			if gradLeft == gradLeftOther or util.VeryApproxEqNumber(gradLeft, gradLeftOther) then
				local right = i%compareN + 1
				local gradRight = util.GradientPoints(compareVertices[i], compareVertices[right])
				local gradRightOther = util.GradientPoints(shape.compareVertices[i], shape.compareVertices[right])
				if gradRight == gradRightOther or util.VeryApproxEqNumber(gradRight, gradRightOther) then
					return true
				end
			end
		end
	end
	return false
end

function api.ShapePartialAt(shapeType, vertices)
	print("shapeType", shapeType)
	local compareVertices = api.GetCompareVertices(vertices)
	local compareN = #compareVertices
	return IterableMap.GetFirstSatisfies(self.shapes, ShapePartialMatch, shapeType, compareVertices, compareN)
end

local function OldestShapeOfType(shape, shapeType)
	if shape.def.name ~= shapeType then
		return false
	end
	return shape.id
end

function api.DestroyOldestShape(shapeType)
	local shape = IterableMap.GetMinimum(self.shapes, OldestShapeOfType, shapeType)
	shape.NotifyDestroy()
	IterableMap.Remove(self.shapes, shape.iterableMapKey)
end

local function GetCachedAffinityPos()
	if not IterableMap.IsStale(self.shapes) then
		return self.affinityPos
	end
	if api.GetShapeTypeCount("octagon") > 0 then
		self.affinityPos = {0, 0}
		return self.affinityPos
	end
	IterableMap.ResetStale(self.shapes)
	if api.GetShapeCount() == 0 then
		self.affinityPos = {0, 0}
		return self.affinityPos
	end
	self.posAcc = {0, 0}
	self.affinityAcc = 0
	IterableMap.ApplySelf(self.shapes, "ContributeSpawnAffinity", self)
	if self.affinityAcc == 0 then
		self.affinityPos = {0, 0}
		return self.affinityPos
	end
	self.affinityPos = util.Mult(1/self.affinityAcc, self.posAcc)
	local size = util.AbsVal(self.affinityPos)
	if size > Global.AFFINITY_MAX_RADIUS then
		self.affinityPos = util.SetLength(Global.AFFINITY_MAX_RADIUS, self.affinityPos)
	end
	return self.affinityPos
end

function api.GetAffinityPos()
	return GetCachedAffinityPos()
end

function api.Update(dt)
	IterableMap.ApplySelf(self.shapes, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.shapes, "Draw", drawQueue)
end

function api.DrawInBook(midX, midY)
	IterableMap.ApplySelf(self.shapes, "DrawInBook", midX, midY)
end

local function NameMatches(shape, name)
	return shape.def.name == name
end

function api.GetShapeTypeCount(name)
	return IterableMap.FilterCount(self.shapes, NameMatches, name)
end

function api.GetShapeCount()
	return IterableMap.Count(self.shapes)
end

function api.AddTotalMagnitude(magnitude)
	self.totalCreatedMagnitude = self.totalCreatedMagnitude + magnitude
end

function api.GetTotalCreatedMagnitude()
	return self.totalCreatedMagnitude
end

function api.TotalShapesCreated()
	return self.shapesCreated
end

function api.Initialize(world, levelData)
	self = {
		world = world,
		shapes = IterableMap.New(),
		nextShapeID = 0,
		affinityPos = {0, 0},
		shapesCreated = 0,
		totalCreatedMagnitude = 0
	}
end

return api
