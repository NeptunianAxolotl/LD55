
--local EffectDefs = util.LoadDefDirectory("effects")
local Font = require("include/font")

local self = {}
local api = {}

function api.GetDistanceSqToPlayer(pos)
	return util.DistSqVectors(pos, self.playerPos)
end

function api.GetVectorToPlayer(pos)
	return util.UnitTowards(pos, self.playerPos)
end

function api.GetPlayerPos()
	return self.playerPos
end

local function CheckForDamage()
	local enemy = EnemyHandler.GetClosestEnemy(self.playerPos, self.playerRadius)
	if not enemy then
		return
	end
	enemy.DealPlayerDamage()
end

function api.GetPlayerFacing()
	local mousePos = self.world.GetMousePosition()
	return util.UnitTowards(self.playerPos, mousePos)
end

function api.InSelectRange(pos)
	return api.GetDistanceSqToPlayer(pos) < math.pow(PowerHandler.GetDrawRange(), 2)
end

function api.GetHealthProp()
	return math.max(0, self.health / PowerHandler.GetPlayerMaxHealth())
end

function api.DealDamage(damage)
	if self.hitLeeway > 0 then
		return
	end
	self.hitLeeway = PowerHandler.GetPlayerHitLeeway()
	self.health = self.health - damage
	if self.health <= 0 then
		self.world.SetGameOver(false, "You Died")
	end
end

function api.Update(dt)
	local mousePos = self.world.GetMousePosition()
	local maxSpeed = PowerHandler.GetPlayerSpeed() * PowerHandler.GetGeneralSpeedModifier()
	local wantedSpeed = maxSpeed
	local dist = util.DistVectors(self.playerPos, mousePos) - 50
	wantedSpeed = math.max(0, math.min(dist*10, wantedSpeed))
	
	local wantedVelocity = util.Mult(wantedSpeed, util.UnitTowards(self.playerPos, mousePos))
	if dist > 0 then
		self.playerRotation = util.Angle(wantedVelocity)
	end
	
	CheckForDamage()
	
	if self.health < PowerHandler.GetPlayerMaxHealth() then
		if self.hitLeeway <= 0 then
			self.health = self.health + PowerHandler.GetPlayerHealthRegen()*dt
		end
	end
	if self.hitLeeway > 0 then
		self.hitLeeway = math.max(self.hitLeeway - dt, 0)
	end
	
	self.playerSpeed = util.Average(self.playerSpeed, wantedVelocity, 0.6)
	self.playerPos = util.Add(util.Mult(dt, self.playerSpeed), self.playerPos)
	local worldDistance = util.AbsVal(self.playerPos)
	if worldDistance > Global.PLAYER_MOVE_RADIUS then
		local factor = (worldDistance - Global.PLAYER_MOVE_RADIUS)/50
		local pushDir = util.UnitTowards(self.playerPos, {0, 0})
		pushDir = util.SetLength(factor*maxSpeed*dt , pushDir)
		self.playerPos = util.Add(pushDir, self.playerPos)
	end
end

function api.Draw(drawQueue)
	drawQueue:push({y=40; f=function()
		Resources.DrawImage("wizard_base", self.playerPos[1], self.playerPos[2], self.playerRotation + math.pi/2)
		local hoveredPoint = DiagramHandler.GetHoveredPoint()
		if hoveredPoint and not api.InSelectRange(hoveredPoint) then
			love.graphics.setLineWidth(2)
			love.graphics.setColor(Global.RED_COL[1], Global.RED_COL[2], Global.RED_COL[3], 0.8)
			love.graphics.circle('line', self.playerPos[1], self.playerPos[2], PowerHandler.GetDrawRange(), 64)
		end
	end})
end

function api.DrawInterface()
end

function api.Initialize(world)
	self = {
		playerPos = world.GetLevelData().playerPos,
		playerSpeed = {0, 0},
		playerRotation = 0,
		playerRadius = 25,
		animationTimer = 0,
		hitLeeway = 0,
		health = PowerHandler.GetPlayerMaxHealth(),
		world = world
	}
end

return api
