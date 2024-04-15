

local function PullEnemies(enemyID, enemy, index, self, dt)
	local distSq = util.DistSqVectors(enemy.pos, self.midPoint)
	if distSq > self.effectRangeSq then
		return
	end
	local dist = math.sqrt(distSq)
	local towards = util.UnitTowards(enemy.pos, self.midPoint)
	local distFactor = math.min(0.73, (self.effectRange - dist)/self.effectRange)
	local force = distFactor*self.def.pullForce*(0.8*self.PowerProp() + 0.2)
	enemy.pos = util.Add(enemy.pos, util.Mult(force*dt, towards))
	
	if distFactor >= 0.72 then
		local energyFactor = (0.66 + 0.34*enemy.EnergyProp())
		local prop = enemy.DrainEnergy(self.magnitude*dt*self.def.drainForce)
		self.power = self.power - self.def.drainCost*dt*prop*energyFactor
		if enemy.EnergyProp() == 0 and not enemy.destroyed then
			GameHandler.AddScore(1)
			enemy.Destroy()
		end
	end
end


local data = {
	characteristicAngle = math.pi/3, -- At most pi/2, this is the angle between involved lines.
	powerMult = 1,
	drainCost = 2,
	drainForce = 0.4,
	affinityMult = 1,
	idleDischargeMult = 0.2,
	pullForce = 150,
	glowSizeMult = 1,
	color = {0.2, 0.4, 0.8},
	init = function (self)
		self.effectRange = self.radius*2
		self.effectRangeSq = self.effectRange*self.effectRange
	end,
	update = function (self, dt)
		local enemies = EnemyHandler.GetEnemies()
		IterableMap.Apply(enemies, PullEnemies, self, dt)
	end,
}

function data.ExpectedLines(origin, u, v)
	local vertices = {
		origin,
		util.Add(origin, u),
		util.Add(origin, v),
	}
	return vertices
end


return data
