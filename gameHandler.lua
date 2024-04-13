
local Font = require("include/font")

local EffectsHandler = require("effectsHandler")
local Resources = require("resourceHandler")
MusicHandler = require("musicHandler")

local self = {}
local api = {}
local world

--------------------------------------------------
-- Updating
--------------------------------------------------

--------------------------------------------------
-- API
--------------------------------------------------

function api.ToggleMenu()
	--self.menuOpen = not self.menuOpen
	--world.SetMenuState(self.menuOpen)
end

function api.MousePressed(x, y)
end

--------------------------------------------------
-- Draw
--------------------------------------------------

local function PrintLine(text, size, x, y, align, width)
	Font.SetSize(size)
	love.graphics.setColor(Global.TEXT_COL[1], Global.TEXT_COL[2], Global.TEXT_COL[3], 1)
	love.graphics.printf(text, x, y, width or 240, align or "left")
	if size == 1 then
		return y + 60
	elseif size == 2 then
		return y + 60
	elseif size == 3 then
		return y + 60
	elseif size == 4 then
		return y + 25
	end
	return y + 60
end

local function DrawLeftInterface()
	local levelData = self.world.GetLevelData()
	local offset = 30
	local xOffset = 0
	offset = PrintLine(levelData.humanName, 3, xOffset, offset, "center", 280)
	offset = PrintLine(levelData.description or "missing description", 4, xOffset + 20, offset, "left", 250)
	
	if self.world.GetGameOver() then
		offset = PrintLine(levelData.winMessage or "Win?!?!?", 4, 400, 120, "center", 250)
	end
	
	local chalkRemaining = (self.world.GetLevelData().chalkLimit - DiagramHandler.GetMoves())
	local tool = (DiagramHandler.GetTool() == Global.LINE and "Line") or "Circle"
	
	local windowX, windowY = love.window.getMode()
	PrintLine("Tool: " .. tool, 4, xOffset + 20, windowY - 250, "left", 250)
	PrintLine("Chalk: " .. chalkRemaining, 4, xOffset + 20, windowY - 215, "left", 250)
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end

function api.DrawInterface()
	DrawLeftInterface()
end

function api.Initialize(world)
	self = {
		world = world
	}
end

return api
