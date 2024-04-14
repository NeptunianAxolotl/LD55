
local World = require("world")
SoundHandler = require("soundHandler")
MusicHandler = require("musicHandler")

local LevelDefs = util.LoadDefDirectory("defs/levels")
local LevelOrder = require("defs/levelList")

local self = {}
local api = {}

-- Cosmos handles the world level, restarting the world,
-- and things that persist between worlds.

--------------------------------------------------
-- Music
--------------------------------------------------

function api.ToggleMusic()
	self.musicEnabled = not self.musicEnabled
	if not self.musicEnabled then
		MusicHandler.StopCurrentTrack()
	end
end

function api.MusicEnabled()
	return self.musicEnabled
end

--------------------------------------------------
-- Resets etc
--------------------------------------------------

function api.RestartWorld()
	World.Initialize(api, self.curLevelData, self.difficultySetting)
end

function api.LoadLevelByTable(levelTable)
	self.curLevelData = levelTable
	World.Initialize(api, self.curLevelData, self.difficultySetting)
end

function api.SwitchLevel(goNext)
	self.inbuiltLevelIndex = math.max(1, math.min(#LevelOrder, self.inbuiltLevelIndex + (goNext and 1 or -1)))
	self.curLevelData = LevelDefs[LevelOrder[self.inbuiltLevelIndex]]
	World.Initialize(api, self.curLevelData, self.difficultySetting)
end

function api.GetScrollSpeeds()
	return self.mouseScrollSpeed, self.keyScrollSpeed
end

--------------------------------------------------
-- Draw
--------------------------------------------------

function api.Draw()
	World.Draw()
end

function api.ViewResize(width, height)
	World.ViewResize(width, height)
end

function api.TakeScreenshot()
	love.filesystem.createDirectory("screenshots")
	print("working", love.filesystem.getWorkingDirectory())
	print("save", love.filesystem.getSaveDirectory())
	love.graphics.captureScreenshot("screenshots/screenshot_" .. math.floor(math.random()*100000) .. "_.png")
end

function api.GetRealTime()
	return self.realTime
end

--------------------------------------------------
-- Input
--------------------------------------------------

function api.KeyPressed(key, scancode, isRepeat)
	if key == "r" then
		api.RestartWorld()
		return true
	end
	if key == "m" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.ToggleMusic()
		return true
	end
	if key == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.TakeScreenshot()
		return true
	end
	if key == "n" then
		api.SwitchLevel(true)
		return true
	end
	if key == "p" then
		api.SwitchLevel(false)
		return true
	end
	return World.KeyPressed(key, scancode, isRepeat)
end

function api.MousePressed(x, y, button)
	return World.MousePressed(x, y, button)
end

function api.MouseReleased(x, y, button)
	return World.MouseReleased(x, y, button)
end

function api.MouseMoved(x, y, dx, dy)
	World.MouseMoved(x, y, dx, dy)
end

--------------------------------------------------
-- Update and Initialize
--------------------------------------------------

function api.Update(dt, realDt)
	self.realTime = self.realTime + realDt
	MusicHandler.Update(realDt)
	SoundHandler.Update(realDt)
	World.Update(dt)
end

function api.Initialize()
	self = {
		realTime = 0,
		inbuiltLevelIndex = Global.DEBUG_MODE_START_LEVEL or 1,
		musicEnabled = true,
		mouseScrollSpeed = 0,
		keyScrollSpeed = 1,
		grabInput = false,
		difficultySetting = {},
	}
	love.mouse.setGrabbed(self.grabInput)
	self.curLevelData = LevelDefs[LevelOrder[self.inbuiltLevelIndex]]
	MusicHandler.Initialize(api)
	SoundHandler.Initialize(api)
	World.Initialize(api, self.curLevelData, self.difficultySetting)
end

return api
