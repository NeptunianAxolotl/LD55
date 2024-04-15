
local data = {
	speed = 85,
	image = "earth",
	maxEnergy = 3,
	baseRadius = 25,
	baseDamage = 10,
	weightMult = 2,
	init = function (self)
		self.animSpeed = 0.9 + math.random()*0.2
		self.animation = math.random()
	end,
	update = function (self, dt)
		self.animation = self.animation + dt*self.animSpeed
		if self.animation >= 1 then
			if not GameHandler.IsGameOver() then
				self.wantedDir = PlayerHandler.GetVectorToPlayer(self.pos, 150 * self.speedMult)
			end
			self.animation = self.animation - 1
		end
		if self.wantedDir then
			local speed = (1.2 - self.animation)*self.def.speed*(0.6 + 0.4*self.EnergyProp())
			local wantedVelocity = util.Mult(speed, self.wantedDir)
			self.velocity = util.Average(self.velocity, wantedVelocity, 0.7)
		end
	end,
	draw = function (self, drawQueue)
		local anim = self.animation*math.pi*2
		local scale = self.drawSizeMult
		Resources.DrawImage("earth", self.pos[1], self.pos[2], anim, self.EnergyProp()*0.95 + 0.5, scale)
	end,
}

return data
