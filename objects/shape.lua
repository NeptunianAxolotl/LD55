
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
	
	local drawVerts = {}
	for i = 1, #self.vertices do
		drawVerts[#drawVerts + 1] = self.vertices[i][1]
		drawVerts[#drawVerts + 1] = self.vertices[i][2]
	end
	
	self.compareVertices = ShapeHandler.GetCompareVertices(self.vertices)
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
	
	function self.ContributeSpawnAffinity(handler)
		local affinity = self.magnitude*self.def.affinityMult
		handler.posAcc = util.Add(handler.posAcc, util.Mult(affinity, self.midPoint))
		handler.affinityAcc = handler.affinityAcc + affinity
	end
	
	function self.PowerProp()
		return math.max(0, self.power / self.maxPower)
	end
	
	function self.NotifyDestroy()
			RemoveShape(self)
	end
	
	function self.Update(dt)
		self.animateSpeed = ((math.random()*dt*0.1 + self.animateSpeed))%1
		self.animate = (self.animate + (0.6 + math.random()*0.1 + self.animateSpeed)*dt)%1
		if GameHandler.ShapesAreInactive() then
			return
		end
		local discharge = math.max(0, math.min(1, (ShapeHandler.GetShapeCount() - 1)/8))
		self.power = self.power - dt*self.def.idleDischargeMult*Global.SHAPE_IDLE_DRAIN_MULT*(0.2 + 0.8*discharge)
		
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
			love.graphics.setLineWidth((13 + math.sin(self.animate*math.pi*2))*self.def.glowSizeMult)
			
			local alpha = 0.25 + 0.65*self.power/self.maxPower
			love.graphics.setColor(shapeDef.color[1], shapeDef.color[2], shapeDef.color[3], alpha*0.25)
			love.graphics.polygon("fill", drawVerts)
			love.graphics.setColor(shapeDef.color[1], shapeDef.color[2], shapeDef.color[3], alpha)
			love.graphics.polygon("line", drawVerts)
			--for i = 1, #self.edges do
			--	local line = self.edges[i]
			--	love.graphics.line(line[1][1], line[1][2], line[2][1], line[2][2])
			--end
		end})
	end
	
	function self.DrawInBook(midX, midY)
		if not self.bookDrawVerts then
			local verts = {}
			for i = 1, #drawVerts, 2 do
				verts[#verts + 1] = Global.BOOK_SCALE*drawVerts[i] + midX
				verts[#verts + 1] = Global.BOOK_SCALE*drawVerts[i + 1] + midY
			end
			self.bookDrawVerts = verts
		end
		love.graphics.setLineWidth(5)
		love.graphics.setColor(shapeDef.color[1], shapeDef.color[2], shapeDef.color[3], 0.1)
		love.graphics.polygon("fill", self.bookDrawVerts)
		--love.graphics.setColor(shapeDef.color[1], shapeDef.color[2], shapeDef.color[3], 0.4)
		--love.graphics.polygon("line", self.bookDrawVerts)
	end
	
	return self
end

return NewShape
