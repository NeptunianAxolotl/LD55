
local EnemyDefs = require("defs/enemyDefs")
local ShapeDefs = require("defs/shapeDefs")

local self = {}
local api = {}
local world


--------------------------------------------------
-- Helpers
--------------------------------------------------

local function UpdateAutomaticUpgrade()
	for i = 1, #EnemyDefs.order do
		local name = EnemyDefs.order[i]
		if api.IsAutomatic(name) and api.CanUpgradeElement(name) then
			api.UpgradeElement(name)
			return
		end
	end
end

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
-- API
--------------------------------------------------

function api.GetSafeLineCapacity()
	return self.level.earth + 8 + math.max(0, self.level.earth - 4)
end

function api.GetLineFadeTime()
	return self.level.earth + 6
end

function api.GetPlayerSpeed()
	return ((self.level.air - 1)*Global.SPEED_SCALING + Global.SPEED_SCALING*0.5*math.max(0, self.level.air - 4) + 1) * Global.PLAYER_SPEED
end

function api.GetDrawRange()
	if self.level.chalk == 2 then
		return Global.BASE_DRAW_RANGE*1.22
	end
	return Global.BASE_DRAW_RANGE + math.sqrt((self.level.chalk - 1) + 0.5*math.max(0, self.level.chalk - 3))*(70 + 5*math.max(0, self.level.chalk - 6))
end

function api.GetShapePower()
	return Global.BASE_SHAPE_POWER + (self.level.fire - 1) + math.max(0, self.level.fire - 3)*0.5
end

function api.GetPlayerMaxHealth()
	return Global.BASE_PLAYER_HEALTH + 10*(self.level.life - 1) + 5*math.max(0, self.level.life - 3) + 10*math.max(0, self.level.life - 6)
end

function api.GetPlayerHealthRegen()
	return 2 + 0.5*(self.level.water - 1) + 0.5*math.max(0, self.level.water - 3) + 1.5*math.max(0, self.level.water - 6)
end

function api.GetGeneralSpeedModifier()
	return 1 / ((self.level.ice - 1)*Global.SPEED_SCALING + Global.SPEED_SCALING*0.5*math.max(0, self.level.ice - 4) + 1)
end

function api.GetPlayerHitLeeway()
	return 0.8
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
	UpdateAutomaticUpgrade()
end

function api.IsAutomatic(element)
	return self.autoUpgrade[element]
end

local function NotifyUpgrade(element)
	if element == "lightning" then
		UpdateMaxShapes()
    SoundHandler.PlaySound("grimoire_level_up")
	elseif element == "life" then
		PlayerHandler.UpdateMaxHealth()
    SoundHandler.PlaySound("grimoire_level_up_2")
	end
end

function api.UpgradeElement(element)
	if Global.FREE_UPGRADES then
		self.level[element] = self.level[element] + 1
		NotifyUpgrade(element)
		return
	end
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
	NotifyUpgrade(element)
end

function api.ToggleAutomatic(element)
	if not (element and self.progress[element]) then
		return
	end
	local save = self.world.GetPersistentData()
	self.autoUpgrade[element] = not self.autoUpgrade[element]
	save.autoUpgrade[element] = self.autoUpgrade[element]
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
	UpdateAutomaticUpgrade()
end

function api.Initialize(world)
	local startingLevel = world.GetLevelData().startingLevel or 1
	self = {
		world = world,
		baseMaxShapes = {
			triangle = 6,
			square = 2,
			hexagon = 0.500001,
			octagon = 0.125001,
		},
		maxShapesPerLevel = {
			triangle = 1,
			square = 0.6666667,
			hexagon = 0.500001,
			octagon = 0.125001,
		},
		level = {
			water = startingLevel,
			air = startingLevel,
			earth = startingLevel,
			fire = startingLevel,
			life = startingLevel,
			ice = 1,
			lightning = startingLevel,
			chalk = startingLevel,
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
	local save = self.world.GetPersistentData()
	if save.autoUpgrade then
		self.autoUpgrade = util.CopyTable(save.autoUpgrade)
	else
		save.autoUpgrade = util.CopyTable(self.autoUpgrade)
	end
	
	self.currentMaxShapes = {}
	self.totalMaxShapes = 8
	UpdateMaxShapes()
	self.initialMaxShapes = self.totalMaxShapes
	
	for name, data in pairs(self.progress) do
		self.progress[name] = math.floor(math.random()*Global.RANDOM_TESTING_ELEMENTS)
	end
end

return api
