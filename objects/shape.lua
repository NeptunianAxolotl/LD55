
local function RemoveShape(self)
	DiagramHandler.RespondToRemovedShape(self.edges, self.id)
end

local function NewShape(world, shapeID, shapeDef, vertices, edges, definingLines)
	local self = {}
	
	self.midPoint = util.AverageMulti(vertices)
	self.radius = util.DistVectors(vertices[1], self.midPoint)
	self.vertices = vertices
	self.edges = edges
	self.id = shapeID
	self.power = PowerHandler.GetShapePower()*shapeDef.powerMult
	self.maxPower = self.power
	self.animateSpeed = math.random()
	self.animate = math.random()
	self.def = shapeDef
	
	self.magnitude = self.radius/100
	
	-- Shapes are not told which lines they include. They can find them when they need to.
	-- Note that to change this, lines need to tell shapes that they are leaving when they
	-- are destroyed.
	for i = 1, #definingLines do
		definingLines[i].inShapes[#definingLines[i].inShapes + 1] = self.id
	end
	
	if self.def.init then
		self.def.init(self)
	end
	
	function self.PowerProp()
		return math.max(0, self.power / self.maxPower)
	end
	
	function self.Update(dt)
		self.power = self.power - dt*0.1
		self.animateSpeed = ((math.random()*dt*0.1 + self.animateSpeed))%1
		self.animate = (self.animate + (0.6 + math.random()*0.1 + self.animateSpeed)*dt)%1
		
		if self.def.update then
			self.def.update(self, dt)
		end
		
		if self.power <= 0 then
			RemoveShape(self)
			return true
		end
	end
	
	function self.Draw(drawQueue, selectedPoint, hoveredPoint, elementType)
		drawQueue:push({y=8; f=function()
			love.graphics.setLineWidth(13 + math.sin(self.animate*math.pi*2))
			
			love.graphics.setColor(shapeDef.color[1], shapeDef.color[2], shapeDef.color[3], 0.1 + 0.8*self.power/self.maxPower)
			for i = 1, #self.edges do
				local line = self.edges[i]
				love.graphics.line(line[1][1], line[1][2], line[2][1], line[2][2])
			end
		end})
	end
	
	return self
end

return NewShape
