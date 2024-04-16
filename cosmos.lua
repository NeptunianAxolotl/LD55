
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
  else
    MusicHandler.StartCurrentTrack()
	end
end

function api.MusicEnabled()
	return self.musicEnabled
end

function api.MusicVolumeChange(change)
	self.musicVolume = self.musicVolume * change
end

function api.GetMusicVolume()
	return self.musicVolume
end

function api.EffectsVolumeChange(change)
	self.effectsVolume = self.effectsVolume * change
end

function api.GetEffectsVolume()
	return self.effectsVolume
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
	return (self.grabInput and self.mouseScrollSpeed) or 0, self.keyScrollSpeed
end

function api.GetPersistentData()
	return self.persistentDataTable
end

function api.ToggleGrabInput()
	self.grabInput = not self.grabInput
	love.mouse.setGrabbed(self.grabInput)
end

function api.ScrollSpeedChange(change)
	self.mouseScrollSpeed = self.mouseScrollSpeed * change
	self.keyScrollSpeed = self.keyScrollSpeed * change
end

function api.SetDifficulty(newDifficulty)
	self.difficultySetting = newDifficulty
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
	local name = "screenshots/screenshot_" .. math.floor(math.random()*100000) .. "_.png"
	print("working", love.filesystem.getWorkingDirectory())
	print("save", love.filesystem.getSaveDirectory())
	print("name", name)
	love.graphics.captureScreenshot(name)
	if EffectsHandler and PlayerHandler then
		Delay.Add(1, function ()
			local pos = PlayerHandler and PlayerHandler.GetPlayerPos()
			if pos then
				EffectsHandler.SpawnEffect("mult_popup", util.Add({0, -100}, pos), {
					text = "Screenshot saved to " .. love.filesystem.getSaveDirectory() .. "/" .. name,
					velocity = {0, -2}
				})
			end
		end)
	end
end

function api.GetRealTime()
	return self.realTime
end

--------------------------------------------------
-- Input
--------------------------------------------------

function api.KeyPressed(key, scancode, isRepeat)
	if key == "n" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		api.SwitchLevel(true)
		return true
	end
	if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
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
		persistentDataTable = {},
		realTime = 0,
		inbuiltLevelIndex = Global.DEBUG_MODE_START_LEVEL or 1,
		musicEnabled = true,
		musicVolume = 1,
		effectsVolume = 1,
		mouseScrollSpeed = Global.MOUSE_SCROLL_MULT,
		keyScrollSpeed = Global.KEYBOARD_SCROLL_MULT,
		grabInput = Global.MOUSE_SCROLL_MULT > 0,
		difficultySetting = 1,
	}
	love.mouse.setGrabbed(self.grabInput)
	self.curLevelData = LevelDefs[LevelOrder[self.inbuiltLevelIndex]]
	MusicHandler.Initialize(api)
	SoundHandler.Initialize(api)
	World.Initialize(api, self.curLevelData, self.difficultySetting)
end

return api
