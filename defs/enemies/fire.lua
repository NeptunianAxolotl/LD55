
local data = {
	speed = 135,
	image = "fire_1",
	maxEnergy = 3,
	baseRadius = 25,
	baseDamage = 7,
	weightMult = 1,
	init = function (self)
		self.animSpeed = 0.9 + math.random()*0.2
		self.animation = math.random()
		self.animation_1 = math.random()
		self.animation_2 = math.random()
		self.animation_3 = math.random()
	end,
	update = function (self, dt)
		self.animation = self.animation + dt*self.animSpeed
		self.animation_1 = (self.animation_1 + dt*self.animSpeed)%0.5
		self.animation_2 = (self.animation_2 + dt*self.animSpeed)%0.5
		self.animation_3 = (self.animation_3 + dt*self.animSpeed)%0.5
		if self.animation >= 1 then
			if not GameHandler.IsGameOver() then
				self.wantedDir = PlayerHandler.GetVectorToPlayer(self.pos, 150 * (self.speedMult - 1))
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
		local anim_1 = self.animation_1*math.pi*4
		local anim_2 = self.animation_2*math.pi*4
		local anim_3 = self.animation_3*math.pi*4
		local scale_1 = {self.drawSizeMult*(1 + math.sin(anim_1 -0.5)*0.1), self.drawSizeMult*(1 + math.cos(anim_1)*0.06)}
		local scale_2 = {self.drawSizeMult*(1 + math.sin(anim_2 -0.5)*0.1), self.drawSizeMult*(1 + math.cos(anim_2)*0.06)}
		local scale_3 = {self.drawSizeMult*(1 + math.sin(anim_3 -0.5)*0.1), self.drawSizeMult*(1 + math.cos(anim_3)*0.06)}
		Resources.DrawImage("fire_1", self.pos[1], self.pos[2], false, self.EnergyProp()*0.95 + 0.5, scale_1)
		Resources.DrawImage("fire_2", self.pos[1], self.pos[2], false, self.EnergyProp()*0.95 + 0.5, scale_2)
		Resources.DrawImage("fire_3", self.pos[1], self.pos[2], false, self.EnergyProp()*0.95 + 0.5, scale_3)
	end,
}

return data
