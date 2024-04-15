
local data = {
	speed = 120,
	image = "air_1",
	maxEnergy = 3,
	baseRadius = 25,
	baseDamage = 7,
	weightMult = 1,
	init = function (self)
		self.animSpeed = 0.9 + math.random()*0.2
		self.animation = math.random()
		self.flipAnim = math.random()
	end,
	update = function (self, dt)
		self.animation = self.animation + dt*self.animSpeed
		self.flipAnim = (self.flipAnim + dt*self.animSpeed*3.5)%1
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
		local scale = {self.drawSizeMult*(1 + math.sin(anim -0.5)*0.02), self.drawSizeMult*(1 + math.cos(anim)*0.03)}
		local toDraw = "air_1"
		if self.flipAnim < 0.33 then
			toDraw = "air_1"
		elseif self.flipAnim < 0.66 then
			toDraw = "air_2"
		else
			toDraw = "air_3"
		end
		Resources.DrawImage(toDraw, self.pos[1], self.pos[2], false, self.EnergyProp()*0.95 + 0.5, scale)
	end,
}

return data
