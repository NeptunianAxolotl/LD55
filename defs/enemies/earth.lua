
local data = {
	speed = 120,
	image = "earth",
	maxEnergy = 3,
	baseRadius = 25,
	baseDamage = 7,
	weightMult = 1,
	init = function (self)
		self.animSpeed = 0.9 + math.random()*0.2
		self.animation = math.random()
	end,
	update = function (self, dt)
		self.animation = self.animation + dt*self.animSpeed
		if self.animation >= 1 and not GameHandler.IsGameOver() then
			if not GameHandler.IsGameOver() then
				self.wantedDir = PlayerHandler.GetVectorToPlayer(self.pos)
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
		local scale = {self.drawSizeMult*(1 + math.sin(anim -0.5)*0.1), self.drawSizeMult*(1 + math.cos(anim)*0.06)}
		Resources.DrawImage("earth", self.pos[1], self.pos[2], false, self.EnergyProp()*0.95 + 0.5, scale)
	end,
}

return data
