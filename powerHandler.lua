
MusicHandler = require("musicHandler")

local self = {}
local api = {}
local world


--------------------------------------------------
-- API
--------------------------------------------------

function api.GetSafeLineCapacity()
	return self.power.safeLines*2 + 8
end

function api.GetLineFadeTime()
	return self.power.fadeTime*3 + 10
end

function api.GetPlayerSpeed()
	return (self.power.speed*1.5 + 10) * Global.PLAYER_SPEED
end

function api.GetDrawRange()
	return 430
end

function api.GetShapePower()
	return 10 + self.power.shapePower
end

function api.GetPlayerMaxHealth()
	return 100 + 10*self.power.health
end

function api.GetPlayerHealthRegen()
	return 2 + self.power.regen
end

function api.GetPlayerHitLeeway()
	return 0.3
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end


function api.Initialize(world)
	self = {
		world = world,
		power = {
			safeLines = 0,
			fadeTime = 0,
			chalkMax = 0,
			health = 0,
			regen = 0,
			speed = 0,
			push = 0,
			attract = 0,
			shapePower = 0,
			slow = 0,
		}
	}
end

return api
