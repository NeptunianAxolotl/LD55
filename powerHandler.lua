
MusicHandler = require("musicHandler")

local self = {}
local api = {}
local world


--------------------------------------------------
-- API
--------------------------------------------------

function api.GetSafeLineCapacity()
	return self.powers.safeLines*2 + 6
end

function api.GetLineFadeTime()
	return self.powers.fadeTime*3 + 10
end

function api.GetPlayerSpeed()
	return (self.powers.speed*1.5 + 10) * Global.PLAYER_SPEED
end

function api.GetDrawRange()
	return 430
end

function api.GetShapePower()
	return 10 + self.powers.shapePower
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end


function api.Initialize(world)
	self = {
		world = world,
		powers = {
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
