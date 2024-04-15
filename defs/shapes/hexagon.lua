
local data = {
	characteristicAngle = math.pi/3, -- At most pi/2, this is the angle between involved lines.
	powerMult = 3,
	drainCost = 1,
	drainForce = 2,
	affinityMult = 15,
	affinityDirectionMult = 2.5,
	idleDischargeMult = 0.15,
	glowSizeMult = 1.8,
	init = function (self)
		self.effectRange = self.radius*2
		self.effectRangeSq = self.effectRange*self.effectRange
	end,
	update = function (self, dt)
		self.power = self.power - dt*0.5*Global.SHAPE_IDLE_DRAIN_MULT
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
