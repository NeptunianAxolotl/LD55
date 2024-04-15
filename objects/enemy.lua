


local function NewEnemy(world, enemyDef, position, size)
	local self = {}
	
	self.pos = position
	self.velocity = {0, 0}
	self.push = false
	self.def = enemyDef
	self.size = size * (0.9 + math.random()*0.2)
	self.drawSizeMult = math.sqrt(self.size)
	self.energy = self.def.maxEnergy * self.size
	self.maxEnergy = self.energy
	self.destroyed = false
	self.speedMult = 1
	
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
		PlayerHandler.DealDamage((self.size + 0.5*math.max(0, self.size - 1))*self.def.baseDamage*(self.EnergyProp()*0.66 + 0.34))
	end
	
	function self.PushFrom(circle)
		local distSq = util.DistSqVectors(circle, self.pos)
		local range = circle[3] + Global.PUSH_RANGE_EXTRA
		if distSq > range*range then
			return
		end
		local dist = math.sqrt(distSq)
		local factor = math.max(0.35, math.min(0.75, (1 - dist / range)))
		local towards = util.UnitTowards(circle, self.pos)
		local force = Global.CIRCLE_PUSH_FORCE * factor / self.GetWeight()
		if self.push then
			self.push = util.Add(self.push, util.SetLength(force, towards))
		else
			self.push = util.SetLength(force, towards)
		end
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
		local soundNum = math.floor(love.math.random(1,5))
		SoundHandler.PlaySound("capture_"..soundNum)
	end
	
	function self.Update(dt)
		if self.destroyed then
			return true
		end
		self.def.update(self, dt)
		self.speedMult = self.speedMult + dt*Global.SPEED_RAMP_UP
		local distanceMult = util.AbsVal(self.pos)
		if distanceMult < Global.WORLD_RADIUS then
			distanceMult = 1
		else
			distanceMult = 1 + (distanceMult - Global.WORLD_RADIUS) / Global.SPEEDY_ELEMENT_RADIUS
		end
		self.pos = util.Add(self.pos, util.Mult(dt * PowerHandler.GetEnemySpeedModifier() * distanceMult * self.speedMult, self.velocity))
		if self.push then
			self.pos = util.Add(self.pos, util.Mult(dt, self.push))
			self.push = util.Mult(1 - dt*Global.CIRCLE_PUSH_EXPONENT, self.push)
			if util.AbsValSq(self.push) < 50 then
				self.push = false
			end
		end
	end
	
	function self.Draw(drawQueue, selectedPoint, hoveredPoint, elementType)
		drawQueue:push({y=18; f=function()
			self.def.draw(self, drawQueue)
		end})
	end
	
	return self
end

return NewEnemy
