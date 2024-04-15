
local function PullEnemies(enemyID, enemy, index, self, dt)
	local distSq = util.DistSqVectors(enemy.pos, self.midPoint)
	if distSq > self.effectRangeSq then
		return
	end
	local prop = enemy.DrainEnergy(self.magnitude*dt*self.def.drainForce, 0.1)
	local drainMult = math.min(1, self.lifetime*1.5)
	self.power = self.power - self.def.drainCost*dt*prop*drainMult
end

local data = {
	characteristicAngle = math.pi/2, -- At most pi/2, this is the angle between involved lines.
	powerMult = 3,
	drainCost = 1,
	drainForce = 2,
	affinityMult = 2,
	idleDischargeMult = 0.12,
	glowSizeMult = 1.3,
	init = function (self)
		self.effectRange = self.radius*1.6
		self.effectRangeSq = self.effectRange*self.effectRange
	end,
	update = function (self, dt)
		local enemies = EnemyHandler.GetEnemies()
		IterableMap.Apply(enemies, PullEnemies, self, dt)
	end,
	color = {209/255, 50/255, 174/255},
}

function data.ExpectedLines(origin, u, v)
	local vertices = {
		origin,
		util.Add(origin, u),
		util.Add(util.Add(origin, v), u),
		util.Add(origin, v),
	}
	return vertices
end


return data
