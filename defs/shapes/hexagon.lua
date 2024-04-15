
local function PullEnemies(enemyID, enemy, index, self, dt)
	local distSq = util.DistSqVectors(enemy.pos, self.midPoint)
	if distSq > self.effectRangeSq then
		return
	end
	local prop = enemy.DrainEnergy(self.magnitude*dt*self.def.drainForce, 0.1)
	self.power = self.power - self.def.drainCost*dt*prop
end


local data = {
	characteristicAngle = math.pi/3, -- At most pi/2, this is the angle between involved lines.
	powerMult = 3,
	drainCost = 1,
	drainForce = 2,
	affinityMult = 10,
	idleDischargeMult = 0.15,
	glowSizeMult = 1.8,
	init = function (self)
		self.effectRange = self.radius*2
		self.effectRangeSq = self.effectRange*self.effectRange
	end,
	update = function (self, dt)
		local enemies = EnemyHandler.GetEnemies()
		IterableMap.Apply(enemies, PullEnemies, self, dt)
	end,
	color = {0.9, 0.9, 0.5},
}

local vertRadius = 1
local vertAngle = math.pi/3
local vertSides = 6

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
