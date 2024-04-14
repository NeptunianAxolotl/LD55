
local self = {}
local api = {}

function api.GetCameraTransform()
	return self.cameraTransform
end

--function api.Update(dt)
--	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(false, 
--		{
--			{pos = self.levelData.bounds[1], xOff = 20, yOff = 20},
--			{pos = self.levelData.bounds[2], xOff = 20, yOff = 20},
--		}
--	)
--	self.cameraPos[1] = cameraX
--	self.cameraPos[2] = cameraY
--	self.cameraScale = cameraScale
--	Camera.UpdateTransform(self.cameraTransform, self.cameraPos[1], self.cameraPos[2], self.cameraScale)
--end

local function UpdateCamera(dt, vector)
	local cameraX, cameraY, cameraScale = Camera.PushCamera(dt, vector, 0.55)
	Camera.UpdateTransform(self.cameraTransform, cameraX, cameraY, cameraScale)
	--if ((cameraX - self.cameraPos[1])*10 < 150 or (cameraX - self.cameraPos[1])*10 > 180) and (cameraX - self.cameraPos[1])*10 > 40 then
	--	print(math.floor((cameraX - self.cameraPos[1])*10))
	--end
	self.cameraPos[1] = cameraX
	self.cameraPos[2] = cameraY
end

function api.GetCameraTransform()
	return self.cameraTransform
end

function api.Update(dt)
	dt = math.min(0.1, dt)
	
	local x, y = love.mouse.getPosition()
	local fullX, fullY = love.window.getMode()
	local cameraVector = {0, 0}
	
	local mouseScroll, keyScroll = self.world.GetCosmos().GetScrollSpeeds()
	
	if x < Global.MOUSE_EDGE then
		cameraVector = util.Add(cameraVector, {-Global.MOUSE_SCROLL*mouseScroll, 0})
	end
	if y < Global.MOUSE_EDGE then
		cameraVector = util.Add(cameraVector, {0,-Global.MOUSE_SCROLL*mouseScroll})
	end
	if x > fullX - Global.MOUSE_EDGE then
		cameraVector = util.Add(cameraVector, {Global.MOUSE_SCROLL*mouseScroll, 0})
	end
	if y > fullY - Global.MOUSE_EDGE then
		cameraVector = util.Add(cameraVector, {0,Global.MOUSE_SCROLL*mouseScroll})
	end
	
	if (love.keyboard.isDown("a") or love.keyboard.isDown("left")) then
		cameraVector = util.Add(cameraVector, {-Global.CAMERA_SPEED*keyScroll, 0})
	end
	if (love.keyboard.isDown("d") or love.keyboard.isDown("right")) then
		cameraVector = util.Add(cameraVector, {Global.CAMERA_SPEED*keyScroll, 0})
	end
	if (love.keyboard.isDown("w") or love.keyboard.isDown("up")) then
		cameraVector = util.Add(cameraVector, {0, -Global.CAMERA_SPEED*keyScroll})
	end
	if (love.keyboard.isDown("s") or love.keyboard.isDown("down")) then
		cameraVector = util.Add(cameraVector, {0, Global.CAMERA_SPEED*keyScroll})
	end
	UpdateCamera(dt, cameraVector)
end

function api.Initialize(world, levelData)
	self = {
		world = world,
		levelData = levelData,
	}
	
	self.cameraTransform = love.math.newTransform()
	self.cameraPos = {0, 0}
	Camera.Initialize({
		windowPadding = {left = 0, right = 0, top = 0, bot = 0},
	})
	
	local cameraPos = world.GetLevelData().cameraPos
	local posTL = util.Add({-500, -500}, cameraPos)
	local posBR = util.Add({500, 500}, cameraPos)
	
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(false, 
		{
			{pos = posTL, xOff = 20, yOff = 20},
			{pos = posBR, xOff = 20, yOff = 20},
		}
	)
	self.cameraPos[1] = cameraX
	self.cameraPos[2] = cameraY
	self.cameraScale = cameraScale
	Camera.UpdateTransform(self.cameraTransform, cameraX, cameraY, cameraScale)
end

return api
