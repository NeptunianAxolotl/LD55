
local data = {
	speed = 125,
	image = "life_main",
	maxEnergy = 3,
	baseRadius = 25,
	baseDamage = 7,
	weightMult = 1,
	init = function (self)
		self.animSpeed = 0.9 + math.random()*0.2
		self.animation = math.random()
		self.animRotate = math.random()
		self.animOffsets = {
			math.random(),
			math.random(),
			math.random(),
		}
	end,
	update = function (self, dt)
		self.animation = self.animation + dt*self.animSpeed
		self.animRotate = self.animRotate + dt*self.animSpeed
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
		local alpha = self.EnergyProp()*0.95 + 0.5
		local anim = self.animation*math.pi*2
		local scale = {self.drawSizeMult*(1 + math.sin(anim -0.5)*0.1), self.drawSizeMult*(1 + math.cos(anim)*0.06)}
		Resources.DrawImage("life_main", self.pos[1], self.pos[2], false, alpha, scale)
		
		for i = 1, #self.animOffsets do
			local rotate = (self.animRotate + self.animOffsets[i])*math.pi*2
			local yComp = math.sin(rotate)
			local pos = util.Add(self.pos, {math.cos(rotate)*22*self.size, yComp*5*self.size + 2})
			local myAlpha = alpha
			if yComp < -0.2 then
				myAlpha = alpha*0.15
			elseif yComp < 0.2 then
				myAlpha = alpha*(yComp + 0.2)*0.85/0.4 + 0.15
			end
			Resources.DrawImage("life_1", pos[1], pos[2], rotate + 2.7*self.animOffsets[i], myAlpha, self.drawSizeMult*1.2)
		end
	end,
}

return data
