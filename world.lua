
EffectsHandler = require("effectsHandler")
DialogueHandler = require("dialogueHandler")
DiagramHandler = require("diagramHandler")
ShadowHandler = require("shadowHandler")
ShapeHandler = require("shapeHandler")
PowerHandler = require("powerHandler")
PlayerHandler = require("playerHandler")
EnemyHandler = require("enemyHandler")

LevelHandler = require("levelHandler")

InterfaceUtil = require("utilities/interfaceUtilities")
Delay = require("utilities/delay")

CameraHandler = require("cameraHandler")
Camera = require("utilities/cameraUtilities")

ChatHandler = require("chatHandler")
DeckHandler = require("deckHandler")
GameHandler = require("gameHandler") -- Handles the gamified parts of the game, such as score, progress and interface.

local PriorityQueue = require("include/PriorityQueue")

local self = {}
local api = {}

function api.SetMenuState(newState)
	self.menuState = newState
end

function api.ToggleMenu()
	self.menuState = not self.menuState
end

function api.GetPaused()
	return self.paused or self.menuState
end

function api.GetGameOver()
	return self.gameWon or self.gameLost, self.gameWon, self.gameLost, self.overType
end

function api.GetLifetime()
	return self.lifetime
end

function api.Restart()
	self.cosmos.RestartWorld()
end

function api.GetCosmos()
	return self.cosmos
end

function api.SetGameOver(hasWon, overType)
	if self.gameWon or self.gameLost then
		return
	end
	
	if hasWon then
		self.gameWon = true
	else
		self.gameLost = true
		self.overType = overType
	end
end

function api.GetLevelData()
	return self.levelData
end

--------------------------------------------------
-- Input
--------------------------------------------------

function api.KeyPressed(key, scancode, isRepeat)
	if key == "escape" then
		api.ToggleMenu()
	end
	if key == "p" then
		api.ToggleMenu()
	end
	if api.GetGameOver() and not Global.ACT_IN_GAME_OVER then
		return -- No doing actions
	end
	if DiagramHandler.KeyPressed(key, scancode, isRepeat) then
		return
	end
	if GameHandler.KeyPressed and GameHandler.KeyPressed(key, scancode, isRepeat) then
		return
	end
end

function api.MousePressed(x, y, button)
	if GameHandler.MousePressed(x, y, button) then
		return
	end
	if api.GetPaused() then
		return
	end
	local uiX, uiY = self.interfaceTransform:inverse():transformPoint(x, y)
	
	if api.GetGameOver() and not Global.ACT_IN_GAME_OVER then
		return -- No doing actions
	end
	if DialogueHandler.MousePressedInterface(uiX, uiY, button) then
		return
	end
	-- Send event to game components
	x, y = CameraHandler.GetCameraTransform():inverse():transformPoint(x, y)
	if DiagramHandler.MousePressed(x, y, button) then
		return
	end
	
	if Global.DEBUG_PRINT_CLICK_POS and button == 1 then
		print("{" .. (math.floor(x)) .. ", " .. (math.floor(y)) .. "},")
		return true
	end
end

function api.MouseReleased(x, y, button)
	if api.GetGameOver() and not Global.ACT_IN_GAME_OVER then
		return -- No doing actions
	end
	-- Send event to game components
	x, y = CameraHandler.GetCameraTransform():inverse():transformPoint(x, y)
	if DiagramHandler.MouseReleased(x, y, button) then
		return
	end
end

function api.MouseMoved(x, y, dx, dy)
	
end

--------------------------------------------------
-- Transforms
--------------------------------------------------

function api.WorldToScreen(pos)
	local x, y = CameraHandler.GetCameraTransform():transformPoint(pos[1], pos[2])
	return {x, y}
end

function api.ScreenToWorld(pos)
	local x, y = CameraHandler.GetCameraTransform():inverse():transformPoint(pos[1], pos[2])
	return {x, y}
end

function api.ScreenToInterface(pos)
	local x, y = self.interfaceTransform:inverse():transformPoint(pos[1], pos[2])
	return {x, y}
end

function api.GetMousePositionInterface()
	local x, y = love.mouse.getPosition()
	return api.ScreenToInterface({x, y})
end

function api.GetMousePosition()
	local x, y = love.mouse.getPosition()
	return api.ScreenToWorld({x, y})
end

function api.WorldScaleToScreenScale()
	local m11 = CameraHandler.GetCameraTransform():getMatrix()
	return m11
end

function api.GetOrderMult()
	return self.orderMult
end

function api.MouseNearWorldPos(pos, radius)
	local distSq = util.DistSqVectors(pos, api.GetMousePosition())
	return (distSq < radius*radius) and distSq
end

function api.GetCameraExtents(buffer)
	local screenWidth, screenHeight = love.window.getMode()
	local topLeftPos = api.ScreenToWorld({0, 0})
	local botRightPos = api.ScreenToWorld({screenWidth, screenHeight})
	buffer = buffer or 0
	return topLeftPos[1] - buffer, topLeftPos[2] - buffer, botRightPos[1] + buffer, botRightPos[2] + buffer
end

function api.GetPhysicsWorld()
	return PhysicsHandler.GetPhysicsWorld()
end

local function UpdateCamera(dt)
	CameraHandler.Update(dt)
end

--------------------------------------------------
-- Updates
--------------------------------------------------

function api.ViewResize(width, height)
end

function api.Update(dt)
	GameHandler.Update(dt)
	if api.GetPaused() then
		UpdateCamera(dt)
		return
	end
	
	self.lifetime = self.lifetime + dt
	Delay.Update(dt)
	InterfaceUtil.Update(dt)
	--ShadowHandler.Update(api)

	PowerHandler.Update(api)
	DiagramHandler.Update(dt)
	ShapeHandler.Update(dt)
	PlayerHandler.Update(dt)
	EnemyHandler.Update(dt)
	ChatHandler.Update(dt)
	EffectsHandler.Update(dt)
	UpdateCamera(dt)
end

function api.Draw()
	local preShadowQueue = PriorityQueue.new(function(l, r) return l.y < r.y end)
	local drawQueue = PriorityQueue.new(function(l, r) return l.y < r.y end)

	-- Draw world
	love.graphics.replaceTransform(CameraHandler.GetCameraTransform())
	while true do
		local d = preShadowQueue:pop()
		if not d then break end
		d.f()
	end
	
	--ShadowHandler.DrawGroundShadow(self.cameraTransform)
	EffectsHandler.Draw(drawQueue)
	DiagramHandler.Draw(drawQueue)
	ShapeHandler.Draw(drawQueue)
	PlayerHandler.Draw(drawQueue)
	EnemyHandler.Draw(drawQueue)
	
	love.graphics.replaceTransform(CameraHandler.GetCameraTransform())
	while true do
		local d = drawQueue:pop()
		if not d then break end
		d.f()
	end
	--ShadowHandler.DrawVisionShadow(CameraHandler.GetCameraTransform())
	
	local windowX, windowY = love.window.getMode()
	if windowX/windowY > 16/9 then
		self.interfaceTransform:setTransformation(0, 0, 0, windowY/1100, windowY/1100, 0, 0)
	else
		self.interfaceTransform:setTransformation(0, 0, 0, windowX/2000, windowX/2000, 0, 0)
	end
	love.graphics.replaceTransform(self.interfaceTransform)
	
	-- Draw interface
	GameHandler.DrawInterface()
	EffectsHandler.DrawInterface()
	DialogueHandler.DrawInterface()
	ChatHandler.DrawInterface()
	
	love.graphics.replaceTransform(self.emptyTransform)
end

function api.Initialize(cosmos, levelData)
	self = {
		levelData = levelData,
	}
	self.cosmos = cosmos
	self.cameraTransform = love.math.newTransform()
	self.interfaceTransform = love.math.newTransform()
	self.emptyTransform = love.math.newTransform()
	self.paused = false
	self.lifetime = Global.DEBUG_START_LIFETIME or 0
	
	Delay.Initialise()
	InterfaceUtil.Initialize()
	EffectsHandler.Initialize(api)
	
	ChatHandler.Initialize(api)
	DialogueHandler.Initialize(api)
	
	PowerHandler.Initialize(api)
	PlayerHandler.Initialize(api)
	EnemyHandler.Initialize(api)
	DiagramHandler.Initialize(api, levelData)
	ShapeHandler.Initialize(api)
	--ShadowHandler.Initialize(api)
	
	DeckHandler.Initialize(api)
	GameHandler.Initialize(api)
	
	CameraHandler.Initialize(api, levelData)
end

return api
