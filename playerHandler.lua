
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

function api.GetPlayerFacing()
	local mousePos = self.world.GetMousePosition()
	return util.UnitTowards(self.playerPos, mousePos)
end

function api.InSelectRange(pos)
	return api.GetDistanceSqToPlayer(pos) < math.pow(PowerHandler.GetDrawRange(), 2)
end

function api.Update(dt)
	local mousePos = self.world.GetMousePosition()
	local wantedSpeed = PowerHandler.GetPlayerSpeed()
	local dist = util.DistVectors(self.playerPos, mousePos) - 50
	wantedSpeed = math.max(0, math.min(dist*10, wantedSpeed))
	
	local wantedVelocity = util.Mult(wantedSpeed, util.UnitTowards(self.playerPos, mousePos))
	if dist > 0 then
		self.playerRotation = util.Angle(wantedVelocity)
	end
	
	self.playerSpeed = util.Average(self.playerSpeed, wantedVelocity, 0.6)
	self.playerPos = util.Add(util.Mult(dt, self.playerSpeed), self.playerPos)
end

function api.Draw(drawQueue)
	drawQueue:push({y=50; f=function()
		Resources.DrawImage("wizard_base", self.playerPos[1], self.playerPos[2], self.playerRotation + math.pi/2)
		local hoveredPoint = DiagramHandler.GetHoveredPoint()
		if hoveredPoint and not api.InSelectRange(hoveredPoint) then
			love.graphics.setLineWidth(1)
			love.graphics.setColor(Global.RED_COL[1], Global.RED_COL[2], Global.RED_COL[3], 0.5)
			love.graphics.circle('line', self.playerPos[1], self.playerPos[2], PowerHandler.GetDrawRange(), 64)
		end
	end})
end

function api.DrawInterface()
end

function api.Initialize(world)
	self = {
		playerPos = {0, 0},
		playerSpeed = {0, 0},
		playerRotation = 0,
		animationTimer = 0,
		world = world
	}
end

return api
