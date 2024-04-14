
local ShapeDefs = require("defs/shapeDefs")
local NewShape = require("objects/shape")

local self = {}
local api = {}

function api.AddShape(shapeDef, vertices, edges, definingLines)
	local new = NewShape(self.world, self.nextShapeID, shapeDef, vertices, edges, definingLines)
	IterableMap.Add(self.shapes, self.nextShapeID, new)
	self.nextShapeID = self.nextShapeID + 1
end

function api.Update(dt)
	IterableMap.ApplySelf(self.shapes, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.shapes, "Draw", drawQueue)
end

function api.Initialize(world, levelData)
	self = {
		world = world,
		shapes = IterableMap.New(),
		nextShapeID = 0,
	}
end

return api
