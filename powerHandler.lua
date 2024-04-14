
MusicHandler = require("musicHandler")

local self = {}
local api = {}
local world


--------------------------------------------------
-- API
--------------------------------------------------

function api.GetSafeLineCapacity()
	return 2
	--return self.powers.safeLines*2 + 6
end

function api.GetLineFadeTime()
	return 4
	--return self.powers.fadeTime*3 + 10
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
