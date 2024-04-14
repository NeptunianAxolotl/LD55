


local function NewEnemy(world, enemyDef, position)
	local self = {}
	
	self.pos = position
	self.velocity = {0, 0}
	self.def = enemyDef
	
	if self.def.init then
		self.def.init(self)
	end
	
	function self.Update(dt)
		self.def.update(self, dt)
		self.pos = util.Add(self.pos, util.Mult(dt, self.velocity))
	end
	
	function self.Draw(drawQueue, selectedPoint, hoveredPoint, elementType)
		drawQueue:push({y=18; f=function()
			self.def.draw(self, drawQueue)
		end})
	end
	
	return self
end

return NewEnemy
