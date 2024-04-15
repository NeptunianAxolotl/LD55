
local EnemyDefs = require("defs/enemyDefs")
local ShapeDefs = require("defs/shapeDefs")

local self = {}
local api = {}
local world


--------------------------------------------------
-- API
--------------------------------------------------

function api.GetSafeLineCapacity()
	return self.level.earth + 6 + math.max(0, self.level.earth - 3)
end

function api.GetLineFadeTime()
	return self.level.earth + 6
end

function api.GetPlayerSpeed()
	return ((self.level.air - 1)*0.1 + 0.05*math.max(0, self.level.air - 4) + 1) * Global.PLAYER_SPEED
end

function api.GetDrawRange()
	return Global.BASE_DRAW_RANGE + math.sqrt(self.level.chalk - 1)*50
end

function api.GetShapePower()
	return Global.BASE_SHAPE_POWER + self.level.fire + math.max(0, self.level.fire - 3)*0.5
end

function api.GetPlayerMaxHealth()
	return 100 + 10*(self.level.life - 1) + math.max(0, self.level.life - 3)
end

function api.GetPlayerHealthRegen()
	return 2 + 0.5*(self.level.water - 1) + 0.3*math.max(0, self.level.life - 3)
end

function api.GetGeneralSpeedModifier()
	return 1 / ((self.level.ice - 1)*0.1 + 0.05*math.max(0, self.level.ice - 4) + 1)
end

function api.GetPlayerHitLeeway()
	return 0.3
end

function api.GetSpawnAffinityRadius()
	return Global.AFFINITY_RADIUS
end

function api.GetMaxShapes()
	return self.totalMaxShapes
end

function api.InitialMaxShapes()
	return self.initialMaxShapes
end

function api.GetMaxShapesType(name)
	return self.currentMaxShapes[name]
end

--------------------------------------------------
-- Helpers
--------------------------------------------------

local function UpdateMaxShapes()
	local total = 0
	for i = 1, #ShapeDefs.shapeNames do
		local name = ShapeDefs.shapeNames[i]
		self.currentMaxShapes[name] = math.floor(self.baseMaxShapes[name] + (self.level.lightning - 1)*self.maxShapesPerLevel[name])
		total = total + self.currentMaxShapes[name]
	end
	self.totalMaxShapes = total
end


--------------------------------------------------
-- Progression and UI
--------------------------------------------------

function api.CanUpgradeElement(element)
	if not (element and self.progress[element]) then
		return
	end
	return api.GetProgress(element) >= api.GetRequirement(element)
end

function api.CanUpgradeAnything()
	for i = 1, #EnemyDefs.order do
		local name = EnemyDefs.order[i]
		if api.CanUpgradeElement(name) then
			return true
		end
	end
	return false
end

function api.GetLevel(element)
	return self.level[element]
end

function api.GetRequirement(element)
	return api.GetLevel(element)
end

function api.GetProgress(element)
	return self.progress[element]
end

function api.AddProgress(element, gained)
	self.progress[element] = self.progress[element] + util.Round(gained)
end

function api.IsAutomatic(element)
	return self.autoUpgrade[element]
end

function api.UpgradeElement(element)
	if not api.CanUpgradeElement(element) then
		return
	end
	while api.CanUpgradeElement(element) do
		self.progress[element] = self.progress[element] - api.GetRequirement(element)
		self.level[element] = self.level[element] + 1
	end
	for name, _ in pairs(self.progress) do
		if name ~= element then
			self.progress[name] = 0
		end
	end
	if element == "lightning" then
		UpdateMaxShapes()
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
		baseMaxShapes = {
			triangle = 6,
			square = 2.3333334,
			hexagon = 0.500001,
			octagon = 0.125001,
		},
		maxShapesPerLevel = {
			triangle = 1.3333334,
			square = 0.6666667,
			hexagon = 0.500001,
			octagon = 0.125001,
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
	
	self.currentMaxShapes = {}
	self.totalMaxShapes = 8
	UpdateMaxShapes()
	self.initialMaxShapes = self.totalMaxShapes
	
	for name, data in pairs(self.progress) do
		self.progress[name] = math.floor(math.random()*10)
	end
end

return api
