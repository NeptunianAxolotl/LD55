
MusicHandler = require("musicHandler")

local self = {}
local api = {}
local world

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.AddScore(score)
	self.score = self.score + score
end

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
	--offset = PrintLine(levelData.humanName, 3, xOffset, offset, "center", 280)
	--offset = PrintLine(levelData.description or "missing description", 4, xOffset + 20, offset, "left", 280)
	--
	--if self.world.GetGameOver() then
	--	offset = PrintLine([[You Win!
	--
	--Press N for the next level.
	--]], 4, 400, 120, "center", 250)
	--end
	--
	
				love.graphics.setColor(Global.LINE_COL[1], Global.LINE_COL[2], Global.LINE_COL[3], 0.95)
	local chalkRemaining = (self.world.GetLevelData().chalkLimit - DiagramHandler.GetMoves())
	local tool = (DiagramHandler.GetTool() == Global.LINE and "Line") or "Circle"
	
	local windowX, windowY = love.window.getMode()
	PrintLine("Score: " .. self.score, 2, xOffset + 20, 80, "left", 280)
	PrintLine("Tool: " .. tool, 2, xOffset + 20, 120, "left", 280)
	PrintLine("Chalk: " .. chalkRemaining, 2, xOffset + 20, 160, "left", 280)
	
	local over, _, _, overType = self.world.GetGameOver()
	if over then
		PrintLine(overType, 1, 400, 120, "center", 250)
	end
end

local function DrawHealth()
	if PlayerHandler.GetHealthProp() >= 1 then
		return
	end
	InterfaceUtil.DrawBar({0.3, 1, 0.3}, {0.3, 0.3, 0.3}, PlayerHandler.GetHealthProp(), false, false, {600, 1020}, {800, 60})
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end

function api.DrawInterface()
	DrawLeftInterface()
	DrawHealth()
end

function api.Initialize(world)
	self = {
		world = world,
		score = 0,
	}
end

return api
