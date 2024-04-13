
local self = {}
local api = {}

function api.GetCameraTransform()
	return self.cameraTransform
end

function api.Update(dt)
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(false, 
		{
			{pos = self.levelData.bounds[1], xOff = 20, yOff = 20},
			{pos = self.levelData.bounds[2], xOff = 20, yOff = 20},
		}
	)
	self.cameraPos[1] = cameraX
	self.cameraPos[2] = cameraY
	self.cameraScale = cameraScale
	Camera.UpdateTransform(self.cameraTransform, self.cameraPos[1], self.cameraPos[2], self.cameraScale)
end

function api.Initialize(world, levelData)
	self = {
		world = world,
		levelData = levelData,
	}
	
	self.cameraTransform = love.math.newTransform()
	self.cameraPos = {0, 0}
	Camera.Initialize({
		windowPadding = {left = 0.16, right = 0, top = 0, bot = 0},
	})
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(false, 
		{
			{pos = levelData.bounds[1], xOff = 20, yOff = 20},
			{pos = levelData.bounds[2], xOff = 20, yOff = 20},
		}
	)
	self.cameraPos[1] = cameraX
	self.cameraPos[2] = cameraY
	self.cameraScale = cameraScale
	Camera.UpdateTransform(self.cameraTransform, cameraX, cameraY, cameraScale)
end

return api
