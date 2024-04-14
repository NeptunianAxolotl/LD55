
local EnemyDefs = require("defs/enemyDefs")
local NewEnemy = require("objects/enemy")

local self = {}
local api = {}

local function SpawnEnemiesUpdate(dt)
	self.spawnTimer = self.spawnTimer + dt
	if self.spawnTimer < self.spawnRate then
		return
	end
	self.spawnTimer = self.spawnTimer - self.spawnRate
	local pos = util.RandomPointInAnnulus(Global.WORLD_RADIUS + 700, Global.WORLD_RADIUS + 900)
	local new = NewEnemy(self.world, EnemyDefs['water'], pos)
	
	IterableMap.Add(self.enemies, new)
end

function api.Update(dt)
	SpawnEnemiesUpdate(dt)
	IterableMap.ApplySelf(self.enemies, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.enemies, "Draw", drawQueue)
end

function api.Initialize(world, levelIndex, mapDataOverride)
	self = {
		world = world,
		enemies = IterableMap.New(),
		spawnRate = 0.5,
		spawnTimer = 0,
	}
end

return api