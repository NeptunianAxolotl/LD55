


local function NewEnemy(world, enemyDef, position, size)
	local self = {}
	
	self.pos = position
	self.velocity = {0, 0}
	self.def = enemyDef
	self.size = size * (0.9 + math.random()*0.2)
	self.drawSizeMult = math.sqrt(self.size)
	self.energy = self.def.maxEnergy * self.size
	self.maxEnergy = self.energy
	self.destroyed = false
	
	if self.def.init then
		self.def.init(self)
	end
	
	function self.GetRadius()
		if self.destroyed then
			return 0
		end
		return self.drawSizeMult * self.def.baseRadius
	end
	
	function self.GetWeight()
		return self.size * self.def.weightMult
	end
	
	function self.EnergyProp()
		if self.destroyed then
			return 0
		end
		return math.max(0, self.energy/self.maxEnergy)
	end
	
	function self.DealPlayerDamage()
		PlayerHandler.DealDamage(self.size*self.def.baseDamage*(self.EnergyProp()*0.66 + 0.34))
	end
	
	function self.DrainEnergy(energy, minProp)
		if self.destroyed then
			return 0
		end
		if self.energy < (minProp or 0) then
			return 0
		end
		local prop = math.min(1, (self.energy - (minProp or 0)) / energy)
		self.energy = self.energy - energy
		if self.energy < (minProp or 0) then
			self.energy = (minProp or 0)
		end
		return prop
	end
	
	function self.Destroy()
		self.destroyed = true
	end
	
	function self.Update(dt)
		if self.destroyed then
			return true
		end
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
