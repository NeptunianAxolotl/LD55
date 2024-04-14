


local function NewShape(world, shapeID, shapeDef, vertices, edges, definingLines)
	local self = {}
	
	self.midPoint = util.AverageMulti(vertices)
	self.radiusSq = util.DistSqVectors(vertices[1], self.midPoint)
	self.vertices = vertices
	self.edges = edges
	self.id = shapeID
	
	-- Shapes are not told which lines they include. They can find them when they need to.
	-- Note that to change this, lines need to tell shapes that they are leaving when they
	-- are destroyed.
	for i = 1, #definingLines do
		definingLines[i].inShapes[#definingLines[i].inShapes + 1] = self.id
	end
	
	function self.Draw(drawQueue, selectedPoint, hoveredPoint, elementType)
		drawQueue:push({y=15; f=function()
			love.graphics.setLineWidth(15)
			
			love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 0.9)
			for i = 1, #self.edges do
				local line = self.edges[i]
				love.graphics.line(line[1][1], line[1][2], line[2][1], line[2][2])
			end
		end})
	end
	
	return self
end

return NewShape
