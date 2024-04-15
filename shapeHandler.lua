
local ShapeDefs = require("defs/shapeDefs")
local NewShape = require("objects/shape")

local self = {}
local api = {}

function api.AddShape(shapeDef, vertices, edges, definingLines)
	local new = NewShape(self.world, self.nextShapeID, shapeDef, vertices, edges, definingLines)
	IterableMap.Add(self.shapes, self.nextShapeID, new)
	self.nextShapeID = self.nextShapeID + 1
	
	if api.GetShapeTypeCount(shapeDef.name) > PowerHandler.GetMaxShapes(shapeDef.name) then
		
	end
end

function api.GetCompareVertices(vertices)
	local minVertex = 1
	for i = 1, #vertices do
		if vertices[i][1] < vertices[minVertex][1] or 
				(vertices[i][1] == vertices[minVertex][1] and vertices[i][2] < vertices[minVertex][2]) then
			minVertex = i
		end
	end
	local secondMinVertex = (minVertex)%(#vertices) + 1
	for i = 1, #vertices do
		if i ~= minVertex then
			if vertices[i][1] < vertices[secondMinVertex][1] or 
					(vertices[i][1] == vertices[secondMinVertex][1] and vertices[i][2] < vertices[secondMinVertex][2]) then
				secondMinVertex = i
			end
		end
	end
	print("minVertex", minVertex, secondMinVertex)
	local direction = ((secondMinVertex > minVertex) and 1) or -1
	if minVertex == 1 and secondMinVertex > 2 then
		direction = -1
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

function api.GetAffinityPos()
	if api.GetShapeCount() then
		return {0, 0}
	end
	
end

function api.GetCompareVertices(vertices)
	local minVertex = 1
	for i = 1, #vertices do
		if vertices[i][1] < vertices[minVertex][1] or 
				(vertices[i][1] == vertices[minVertex][1] and vertices[i][2] < vertices[minVertex][2]) then
			minVertex = i
		end
	end
	local secondMinVertex = (minVertex)%(#vertices) + 1
	for i = 1, #vertices do
		if i ~= minVertex then
			if vertices[i][1] < vertices[secondMinVertex][1] or 
					(vertices[i][1] == vertices[secondMinVertex][1] and vertices[i][2] < vertices[secondMinVertex][2]) then
				secondMinVertex = i
			end
		end
	end
	local direction = ((secondMinVertex > minVertex) and 1) or -1
	if minVertex == 1 and secondMinVertex > 2 then
		direction = -1
	end
	
	local cur = minVertex
	local compare = {}
	for i = 1, #vertices do
		compare[i] = vertices[cur]
		cur = ((cur + direction) - 1)%(#vertices) + 1
	end
	return compare
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
	local compareVertices = api.GetCompareVertices(vertices)
	local compareN = #compareVertices
	return IterableMap.GetFirstSatisfies(self.shapes, ShapePartialMatch, shapeType, compareVertices, compareN)
end

function api.Update(dt)
	IterableMap.ApplySelf(self.shapes, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.shapes, "Draw", drawQueue)
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

function api.Initialize(world, levelData)
	self = {
		world = world,
		shapes = IterableMap.New(),
		nextShapeID = 0,
	}
end

return api
