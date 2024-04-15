
local EnemyDefs = require("defs/enemyDefs")
local NewEnemy = require("objects/enemy")

local self = {}
local api = {}

local function GetSpawnSize()
	local draw = math.pow((self.spawnSize - math.random()*self.spawnSize), 1.8)
	draw = math.floor(draw + 1)
	return draw
end

local function GetSpawnPosAndType()
	local affinityPos = ShapeHandler.GetAffinityPos()
	local affinityRadius = PowerHandler.GetSpawnAffinityRadius()
	local pos = util.RandomPointInAnnulus(affinityRadius, affinityRadius + 100)
	local angle = util.Angle(pos)
	
	local octant = math.max(1, math.min(8, math.floor(angle*8/(2*math.pi) + 1)))
	pos = util.SetLength(Global.ENEMY_SPAWN_RADIUS * 0.5, pos)
	pos = util.Add(pos, util.RandomPointInCircle(Global.ENEMY_SPAWN_WIGGLE))
	pos = util.SetLength(Global.ENEMY_SPAWN_RADIUS, pos)
	print("octant", octant, EnemyDefs.order[octant])
	return pos, EnemyDefs.order[octant]
end

local function SpawnEnemy()
	local size = GetSpawnSize()
	local pos, enemyType = GetSpawnPosAndType()
	print("enemyType", enemyType)
	local new = NewEnemy(self.world, EnemyDefs.defs[enemyType], pos, size)
	
	IterableMap.Add(self.enemies, new)
end

local function SpawnEnemiesUpdate(dt)
	self.spawnTimer = self.spawnTimer + dt*Global.ENEMY_SPAWN_MULT
	while self.spawnTimer > self.spawnRate do
		SpawnEnemy()
		self.spawnTimer = self.spawnTimer - self.spawnRate
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

function api.Update(dt)
	SpawnEnemiesUpdate(dt)
	IterableMap.ApplySelf(self.enemies, "Update", dt)
	self.spawnRate = self.spawnRate - 0.008*self.spawnRate*dt
	self.spawnSize = self.spawnSize + 0.006*dt
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.enemies, "Draw", drawQueue)
end

function api.Initialize(world, levelIndex, mapDataOverride)
	self = {
		world = world,
		enemies = IterableMap.New(),
		spawnRate = 8,
		spawnSize = 0.3,
		spawnTimer = 0,
	}
end

return api