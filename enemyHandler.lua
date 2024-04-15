
local EnemyDefs = require("defs/enemyDefs")
local NewEnemy = require("objects/enemy")

local self = {}
local api = {}

local function GetSpawnSize()
	local draw = math.pow((self.spawnSize - math.random()*self.spawnSize), 1.5)
	draw = math.floor(draw + 1)
	return draw
end

local function GetSpawnPosAndType()
	local affinityPos = ShapeHandler.GetAffinityPos()
	local affinityRadius = PowerHandler.GetSpawnAffinityRadius()
	local pos = util.Add(affinityPos, util.RandomPointInAnnulus(affinityRadius, affinityRadius + 100))
	local angle = util.Angle(pos)
	
	local octant = math.max(1, math.min(8, math.floor(angle*8/(2*math.pi) + 1)))
	pos = util.SetLength(Global.ENEMY_SPAWN_RADIUS * 0.5, pos)
	pos = util.Add(pos, util.RandomPointInCircle(Global.ENEMY_SPAWN_WIGGLE))
	pos = util.SetLength(Global.ENEMY_SPAWN_RADIUS*(Global.TEST_ENEMIES and 0.1 or 1), pos)
	return pos, EnemyDefs.order[octant]
end

local function SpawnEnemy()
	local size = GetSpawnSize()
	local pos, enemyType = GetSpawnPosAndType()
	--print("enemyType", enemyType)
	local new = NewEnemy(self.world, EnemyDefs.defs[enemyType], pos, size)
	
	IterableMap.Add(self.enemies, new)
end

local function SpawnEnemiesUpdate(dt)
	self.spawnTimer = self.spawnTimer + dt * Global.ENEMY_SPAWN_MULT * self.difficulty * ((4 + ShapeHandler.GetShapeCount()) / 8)
	self.spawnTimer = self.spawnTimer + dt * 4 * math.sqrt(ShapeHandler.GetShapeTypeCount("hexagon"))
	self.spawnTimer = self.spawnTimer + dt * 18 * ShapeHandler.GetShapeTypeCount("octagon")
	if Global.TEST_ENEMIES then
		self.spawnTimer = self.spawnTimer + dt*5
	end
	while self.spawnTimer > 1 / self.spawnFrequency do
		SpawnEnemy()
		self.spawnTimer = self.spawnTimer - 1 / self.spawnFrequency
	end
end

local function ClosestToWithDist(data, maxDist, maxDistSq, pos, filterFunc)
	if data.destroyed then
		return false
	end
	if filterFunc and not filterFunc(data) then
		return false
	end
	local distSq = util.DistSqVectors(data.pos, pos)
	--if maxDistSq and distSq > maxDistSq*8 then
	--	return false
	--end
	local dist = math.sqrt(distSq) - data.GetRadius()
	if maxDist and dist > maxDist then
		return false
	end
	return dist
end

function api.GetClosestEnemy(pos, maxDist, filterFunc)
	local other = IterableMap.GetMinimum(self.enemies, ClosestToWithDist, maxDist, maxDist and maxDist*maxDist, pos, filterFunc)
	if not other then
		return
	end
	return other
end

function api.GetEnemies()
	return self.enemies
end

function api.CountEnemies()
	return IterableMap.Count(self.enemies)
end

function api.PushEnemiesFrom(circle)
	IterableMap.ApplySelf(self.enemies, "PushFrom", circle)
end

function api.GetSpawnParameters()
	return self.lifetime
end

function api.Update(dt)
	if self.noEnemies then
		return
	end
	local tutorial = GameHandler.GetTutorial()
	if tutorial and tutorial.noEnemySpawn then
		return
	end
	SpawnEnemiesUpdate(dt)
	IterableMap.ApplySelf(self.enemies, "Update", dt)
	
	if not GameHandler.IsGameOver() then
		self.lifetime = self.lifetime + dt
	end
	self.spawnFrequency = math.min(3, self.spawnFrequency*(1 + 0.0004*dt) + 0.0003*dt)
	self.spawnSize = self.spawnSize + 0.0011*dt
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.enemies, "Draw", drawQueue)
end

function api.Initialize(world, difficulty)
	self = {
		world = world,
		lifetime = 0,
		enemies = IterableMap.New(),
		spawnFrequency = 0.125,
		spawnSize = 0.7,
		spawnTimer = 0,
		noEnemies = world.GetLevelData().noEnemies,
		difficulty = difficulty,
	}
end

return api