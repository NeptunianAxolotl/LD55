

local function PullEnemies(enemyID, enemy, index, self, dt)
	local distSq = util.DistSqVectors(enemy.pos, self.midPoint)
	if distSq > self.effectRangeSq then
		return
	end
	local dist = math.sqrt(distSq)
	local towards = util.UnitTowards(enemy.pos, self.midPoint)
	local distFactor = math.min(0.73, (self.effectRange - dist)/self.effectRange)
	local force = distFactor*self.def.pullForce*(0.8*self.PowerProp() + 0.2)/enemy.GetWeight()
	enemy.pos = util.Add(enemy.pos, util.Mult(force*dt, towards))
	
	if distFactor >= 0.72 then
		local energyFactor = (0.66 + 0.34*enemy.EnergyProp())
		local prop = enemy.DrainEnergy(self.magnitude*dt*self.def.drainForce)
		local drainMult = math.min(1, self.lifetime*1.5)
		self.power = self.power - self.def.drainCost*dt*energyFactor*prop*drainMult
		if enemy.EnergyProp() == 0 and not enemy.destroyed then
			GameHandler.AddScore(enemy.size)
			PowerHandler.AddProgress(enemy.def.name, enemy.size)
			enemy.Destroy()
		end
	end
end

local data = {
	characteristicAngle = math.pi*2/5, -- At most pi/2, this is the angle between involved lines.
	powerMult = 5,
	drainCost = 1,
	drainForce = 2,
	affinityMult = 15,
	affinityDirectionMult = 15,
	idleDischargeMult = 0.1,
	glowSizeMult = 1.8,
	init = function (self)
		self.effectRange = Global.ENEMY_SPAWN_RADIUS + Global.WORLD_RADIUS
		self.effectRangeSq = self.effectRange*self.effectRange
	end,
	update = function (self, dt)
		local enemies = EnemyHandler.GetEnemies()
		IterableMap.Apply(enemies, PullEnemies, self, dt)
		self.power = self.power - 3*dt*Global.SHAPE_IDLE_DRAIN_MULT
	end,
	color = {0, 0, 0},
}

local vertRadius = 1/ (2 * math.sin(36*math.pi/180))
local vertAngle = math.pi*2/5
local vertSides = 5

function data.ExpectedLines(corner, u, v)
	local radiusVector = util.SetLength(vertRadius * util.AbsVal(u), util.Average(u, v))
	local origin = util.Add(corner, radiusVector)
	local vertices = {}
	for i = 1, vertSides do
		vertices[i] = util.Add(origin, util.RotateVector(radiusVector, i*vertAngle))
	end
	return vertices
end

return data
