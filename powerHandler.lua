
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

function api.GetSpawnAffinityRadius()
	return Global.AFFINITY_RADIUS
end

function api.GetMaxShapes()
	return 10
end

function api.GetMaxShapesType(name)
	return self.maxShapes[name]
end

--------------------------------------------------
-- Progression and UI
--------------------------------------------------

function api.CanUpgradeAnything()
	return false -- If I have enough gathered elements
end

function api.CanUpgradeElement(element)
	if not (element and self.progress[element]) then
		return
	end
	return api.GetProgress(element) >= api.GetRequirement(element)
end

function api.GetLevel(element)
	return self.level[element]
end

function api.GetRequirement(element)
	return 2 + api.GetLevel(element)
end

function api.GetProgress(element)
	return self.progress[element]
end

function api.IsAutomatic(element)
	return self.autoUpgrade[element]
end

function api.UpgradeElement(element)
	if not api.CanUpgradeElement(element) then
		return
	end
	self.progress[element] = self.progress[element] - api.GetRequirement(element)
	self.level[element] = self.level[element] + 1
	for name, _ in pairs(self.progress) do
		if name ~= element then
			self.progress[name] = 0
		end
	end
end

function api.ToggleAutomatic(element)
	if not (element and self.progress[element]) then
		return
	end
	self.autoUpgrade[element] = not self.autoUpgrade[element]
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end


function api.Initialize(world)
	self = {
		world = world,
		maxShapes = {
			triangle = 6,
			square = 2,
			hexagon = 1,
			octagon = 0,
		},
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
		},
		level = {
			water = 1,
			air = 1,
			earth = 1,
			fire = 1,
			life = 1,
			ice = 1,
			lightning = 1,
			chalk = 1,
		},
		progress = {
			water = 0,
			air = 0,
			earth = 0,
			fire = 0,
			life = 0,
			ice = 0,
			lightning = 0,
			chalk = 0,
		},
		autoUpgrade = {
			water = false,
			air = false,
			earth = false,
			fire = false,
			life = false,
			ice = false,
			lightning = false,
			chalk = false,
		},
	}
	
	for name, data in pairs(self.progress) do
		self.progress[name] = math.floor(math.random()*10)
	end
end

return api
