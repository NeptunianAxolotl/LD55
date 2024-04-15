
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
	PrintLine("Score: " .. self.score, 2, xOffset + 20, 20, "left", 280)
	PrintLine("Tool: " .. tool, 2, xOffset + 20, 60, "left", 280)
	PrintLine("Chalk: " .. chalkRemaining, 2, xOffset + 20, 100, "left", 280)
	PrintLine("Enemies: " .. EnemyHandler.CountEnemies(), 2, xOffset + 20, 160, "left", 280)
	
	
	local over, _, _, overType = self.world.GetGameOver()
	if over then
		PrintLine(overType, 1, 400, 120, "center", 250)
	end
end

local function DrawPowerMenu()
	local windowX, windowY = 2000, 1100
	local overX = windowX*0.2
	local overWidth = windowX*0.6
	local overY = windowY*0.15
	local overHeight = windowY*0.6
	
	local mousePos = self.world.GetMousePositionInterface()
	
	InterfaceUtil.DrawButton(500, 100, 100, 1000, mousePos, "POWER", false, false, false)
	
	InterfaceUtil.DrawPanel(overX, overY, overWidth, overHeight*1.12)
		
	Font.SetSize(0)
	love.graphics.setColor(Global.TEXT_MENU_COL[1], Global.TEXT_MENU_COL[2], Global.TEXT_MENU_COL[3], 0.8)
	love.graphics.printf("Grimoire", overX, overY + overHeight * 0.04, overWidth, "center")
	
	Font.SetSize(2)
	
	
	
--		love.graphics.printf([[
--'p' to unpause
--'ctrl+m' to toggle music
--'ctrl+r' to reset the level
--'ctrl+n' for next level
--'ctrl+p' for previous level
--'ctrl+j' to toggle level editor
--'ctrl+l' to load custom level]], overX + overWidth*0.02, overY + overHeight * 0.3 , overWidth*0.96, "center")
end

local function BottomInterface(transBottom)
	local mousePos = self.world.GetMousePositionInterface(transBottom)
	
	self.hovered = InterfaceUtil.DrawButton(1480, 1010, 180, 70, mousePos, "Grimoire", false, PowerHandler.CanUpgrade(), false, 2, 12)
	self.hovered = InterfaceUtil.DrawButton(1710, 1010, 180, 70, mousePos, "Menu", false, PowerHandler.CanUpgrade(), false, 2, 12)
	
	if PlayerHandler.GetHealthProp() < 1 then
		InterfaceUtil.DrawBar({0.3, 1, 0.3}, {0.3, 0.3, 0.3}, PlayerHandler.GetHealthProp(), false, false, {600, 1020}, {800, 60})
	end
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
end

function api.DrawInterface(transMid, transTopLeft, transBottom)
	love.graphics.replaceTransform(transTopLeft)
	DrawLeftInterface()
	love.graphics.replaceTransform(transBottom)
	BottomInterface(transBottom)
	love.graphics.replaceTransform(transMid)
	DrawPowerMenu()
end

function api.Initialize(world)
	self = {
		world = world,
		score = 0,
		hovered = false,
		menuOpen = false,
		powersOpen = true,
	}
	
	--self.world.SetMenuState(self.menuOpen or self.powersOpen)
end

return api
