
local ShapeDefs = require("defs/shapeDefs")

local self = {}
local api = {}
local world

--------------------------------------------------
-- Definitions
--------------------------------------------------

local function PercentInc(value)
	return math.floor(100*(value - 1))
end

local elementUiDefs = {
	water = {
		humanName = "Water",
		descFunc = function ()
			return "Regenerate " .. math.floor(10*PowerHandler.GetPlayerHealthRegen()) .. " health every 10 seconds"
		end,
		image = "water_main",
	},
	air = {
		humanName = "Air",
		descFunc = function ()
			return "Move " .. PercentInc(PowerHandler.GetPlayerSpeed() / Global.PLAYER_SPEED) .. "% faster"
		end,
		image = "air_3",
	},
	earth = {
		humanName = "Earth",
		descFunc = function ()
			return "Sustain " .. math.floor(PowerHandler.GetSafeLineCapacity()) .. " lines, excess fade after " .. math.floor(PowerHandler.GetLineFadeTime()) .. "s"
		end,
		image = "earth",
	},
	fire = {
		humanName = "Fire",
		descFunc = function ()
			return "Sigils are " .. PercentInc(PowerHandler.GetShapePower() / Global.BASE_SHAPE_POWER) .. "% more powerful"
		end,
		image = "fire_1",
	},
	life = {
		humanName = "Life",
		descFunc = function ()
			return "Maximum health is " .. math.floor(PowerHandler.GetPlayerMaxHealth())
		end,
		image = "life_main",
	},
	ice = {
		humanName = "Ice",
		descFunc = function ()
			return "Everything moves at " .. math.floor(100*PowerHandler.GetGeneralSpeedModifier()) .. "% speed"
		end,
		image = "ice",
	},
	lightning = {
		humanName = "Lightning",
		descFunc = function ()
			return "Can sustain " .. PercentInc(PowerHandler.GetMaxShapes() / PowerHandler.InitialMaxShapes()) .. "% more sigils"
		end,
		image = "lightning_2",
	},
	chalk = {
		humanName = "Chalk",
		descFunc = function ()
			return "Draw from " .. PercentInc(PowerHandler.GetDrawRange() / Global.BASE_DRAW_RANGE) .. "% further away"
		end,
		image = "chalk",
	},
}

local elementList = {
	"earth",
	"chalk",
	"life",
	"fire",
	"water",
	"lightning",
	"ice",
	"air",
}


--------------------------------------------------
-- Updating
--------------------------------------------------

function api.AddScore(score)
	self.score = self.score +  util.Round(score)
end

function api.PanelOpen()
	return self.menuOpen or self.powersOpen
end

--------------------------------------------------
-- API
--------------------------------------------------

local function HandleHoverClick()
	if self.hovered == "Grimoire" then
		self.powersOpen = not self.powersOpen
		self.world.SetMenuState(api.PanelOpen())
	elseif self.hovered == "Menu" then
		self.menuOpen = not self.menuOpen
		self.world.SetMenuState(api.PanelOpen())
	elseif self.hovered == "Auto" then
		PowerHandler.ToggleAutomatic(self.hoveredElement)
	elseif self.hovered == "Consume" then
		PowerHandler.UpgradeElement(self.hoveredElement)
	end
end

function api.MousePressed(x, y)
	if self.hovered then
		HandleHoverClick()
	end
end

function api.KeyPressed(key, scancode, isRepeat)
	if key == "escape" or key == "p" or key == "m" then
		self.menuOpen = not self.menuOpen
		self.world.SetMenuState(api.PanelOpen())
	end
	if key == "tab" or key == "c" then
		self.powersOpen = not self.powersOpen
		self.world.SetMenuState(api.PanelOpen())
	end
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
	PrintLine("Score: " .. self.score, 2, xOffset + 20, 20, "left", 800)
	PrintLine("Tool: " .. tool, 2, xOffset + 20, 60, "left", 800)
	PrintLine("Enemies: " .. EnemyHandler.CountEnemies(), 2, xOffset + 20, 160, "left", 280)
	
	local offset = 240
	for i = 1, #ShapeDefs.shapeNames do
		local name = ShapeDefs.shapeNames[i]
		local maximum = math.floor(PowerHandler.GetMaxShapesType(name))
		if maximum > 0 then
			local count = math.floor(ShapeHandler.GetShapeTypeCount(name))
			PrintLine(ShapeDefs.collectiveHumanName[name] .. ": " .. count .. " / " .. maximum, 2, xOffset + 20, offset, "left", 280)
		end
		offset = offset + 30
	end
	
	local over, _, _, overType = self.world.GetGameOver()
	if over then
		PrintLine(overType, 1, 400, 120, "center", 250)
	end
end

local function DrawElementArea(x, y, element, mousePos)
	local def = elementUiDefs[element] or elementUiDefs['water']
	local offset = 4

	--InterfaceUtil.DrawPanel(x + 5, y + 5, 415, 175)
	love.graphics.setColor(Global.TEXT_MENU_COL[1], Global.TEXT_MENU_COL[2], Global.TEXT_MENU_COL[3], 1)
	Font.SetSize(2)
	love.graphics.printf(def.humanName .. " Level " .. PowerHandler.GetLevel(element), x + 12, y + 8, 500, "left")
	Font.SetSize(4)
	love.graphics.printf(def.descFunc(), x + 12, y + 48, 500, "left")
	Font.SetSize(3)
	love.graphics.printf(PowerHandler.GetProgress(element) .. "/" .. PowerHandler.GetRequirement(element), x + 120, y + 135 + offset, 500, "left")
	
	Resources.DrawImage(def.image, x + 60, y + 120 + offset, 0, 1, 1.4)
	
	local upgrade = InterfaceUtil.DrawButton(x + 120, y + 85 + offset, 140, 46, mousePos, "Consume", not PowerHandler.CanUpgradeElement(element), false, false, 3, 6, 4)
	local automatic = InterfaceUtil.DrawButton(x + 280, y + 85 + offset, 90, 46, mousePos, "Auto", not PowerHandler.IsAutomatic(element), false, true, 3, 6, 4)
	if upgrade or automatic then
		self.hovered = upgrade or automatic
		self.hoveredElement = element
	end
end

local function DrawPowerMenu()
	local windowX, windowY = 2000, 1100
	local overX = windowX*0.17
	local overWidth = windowX*0.66
	local overY = windowY*0.12
	local overHeight = windowY*0.64
	
	local mousePos = self.world.GetMousePositionInterface()
	InterfaceUtil.DrawPanel(overX, overY, overWidth, overHeight*1.12)
	Font.SetSize(0)
	--love.graphics.setColor(Global.TEXT_MENU_COL[1], Global.TEXT_MENU_COL[2], Global.TEXT_MENU_COL[3], 0.8)
	--love.graphics.printf("Grimoire", overX, overY + overHeight * 0.04, overWidth, "center")
	
	Font.SetSize(2)
	
	local elementX = overX + overWidth/3
	local elementXOffset = overWidth/3
	local elementY = 150
	local elementYOffset = 190
	for i = 1, #elementList do
		DrawElementArea(elementX, elementY, elementList[i], mousePos)
		if i%2 == 1 then
			elementX = elementX + elementXOffset
		else
			elementX = elementX - elementXOffset
			elementY = elementY + elementYOffset
		end
	end
	
	
--		love.graphics.printf([[
--'p' to unpause
--'ctrl+m' to toggle music
--'ctrl+r' to reset the level
--'ctrl+n' for next level
--'ctrl+p' for previous level
--'ctrl+j' to toggle level editor
--'ctrl+l' to load custom level]], overX + overWidth*0.02, overY + overHeight * 0.3 , overWidth*0.96, "center")
end

local function DrawMainMenu()
	local windowX, windowY = 2000, 1100
	local overX = windowX*0.8
	local overWidth = windowX*0.2
	local overY = windowY*0.15
	local overHeight = windowY*0.6
	InterfaceUtil.DrawPanel(overX, overY, overWidth, overHeight*1.12)

end

local function BottomInterface(transBottom)
	local mousePos = self.world.GetMousePositionInterface(transBottom)
	
	self.hovered = InterfaceUtil.DrawButton(1480, 1010, 180, 70, mousePos, "Grimoire", false, PowerHandler.CanUpgradeAnything() and not api.PanelOpen(), false, 2, 12)
	self.hovered = InterfaceUtil.DrawButton(1710, 1010, 180, 70, mousePos, "Menu", false, false, false, 2, 12) or self.hovered
	
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
	if self.powersOpen then
		DrawPowerMenu()
	end
	if self.menuOpen then
		DrawMainMenu()
	end
end

function api.Initialize(world)
	self = {
		world = world,
		score = 0,
		hovered = false,
		menuOpen = false,
		powersOpen = false,
	}
	
	self.world.SetMenuState(api.PanelOpen())
end

return api
