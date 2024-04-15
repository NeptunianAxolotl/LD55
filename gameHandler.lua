
local ShapeDefs = require("defs/shapeDefs")
local ElementUiDefs = require("defs/elementUiDefs")
local HintDefs = require("defs/hints")

local self = {}
local api = {}
local world

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.AddScore(score)
	if not api.IsGameOver() then
		self.score = self.score +  util.Round(score)
	end
end

function api.PanelOpen()
	return self.menuOpen or self.powersOpen
end

local function ToggleBook()
	self.powersOpen = not self.powersOpen
	self.world.SetMenuState(api.PanelOpen())
	self.lastUpgradeCount = PowerHandler.CountUpgrades()
	if not self.powersOpen then
		return
	end
	if not self.hintsLooped then
		self.hintIndex = self.hintIndex + 1
		if self.hintIndex > #HintDefs then
			self.hintsLooped = true
		end
	end
	if self.hintsLooped then
		self.hintIndex = math.floor(math.random()*(#HintDefs)) + 1
	end
end

--------------------------------------------------
-- API
--------------------------------------------------

local function HandleHoverClick()
	if not self.hovered then
		return
	end
	if self.hovered == "Grimoire" then
		ToggleBook()
		self.world.SetMenuState(api.PanelOpen())
	elseif self.hovered == "Menu" then
		self.menuOpen = not self.menuOpen
		self.world.SetMenuState(api.PanelOpen())
	elseif self.hovered == "Auto" then
		PowerHandler.ToggleAutomatic(self.hoveredElement)
	elseif self.hovered == "Consume" then
		PowerHandler.UpgradeElement(self.hoveredElement)
	elseif self.hovered == "Toggle Music" then
		self.world.GetCosmos().ToggleMusic()
	elseif self.hovered == "Music Louder" then
		self.world.GetCosmos().MusicVolumeChange(3/2)
	elseif self.hovered == "Music Softer" then
		self.world.GetCosmos().MusicVolumeChange(2/3)
	elseif self.hovered == "Effects Louder" then
		self.world.GetCosmos().EffectsVolumeChange(7/6)
	elseif self.hovered == "Effects Softer" then
		self.world.GetCosmos().EffectsVolumeChange(6/7)
	elseif self.hovered == "Toggle Edge Scroll" then
		self.world.GetCosmos().ToggleGrabInput()
	elseif self.hovered == "Scroll Speed Up" then
		self.world.GetCosmos().ScrollSpeedChange(7/6)
	elseif self.hovered == "Scroll Speed Down" then
		self.world.GetCosmos().ScrollSpeedChange(6/7)
	elseif self.hovered == "Switch to Sandbox" then
		self.world.GetCosmos().SwitchLevel(true)
	elseif self.hovered == "Switch to Base" then
		self.world.GetCosmos().SetDifficulty(1)
		self.world.GetCosmos().SwitchLevel(false)
	elseif self.hovered == "Switch to Hard" then
		self.world.GetCosmos().SetDifficulty(Global.HARD_DIFFICULTY)
		self.world.GetCosmos().SwitchLevel(false)
	elseif self.hovered == "Switch to Hardest" then
		self.world.GetCosmos().SetDifficulty(Global.HARDER_DIFFICULTY)
		self.world.GetCosmos().SwitchLevel(false)
	elseif self.hovered == "Restart" then
		self.world.Restart()
	elseif self.hovered == "Quit" then
		love.event.quit()
	end
end

function api.MousePressed(x, y)
	if self.hovered then
		HandleHoverClick()
	end
	local tutorial = api.GetTutorial()
	if tutorial and tutorial.progressClick then
		self.tutorialStage = self.tutorialStage + 1
		if not self.tutorial[self.tutorialStage] then
			self.tutorial = false
			self.tutorialStage = false
		end
	end
end

function api.KeyPressed(key, scancode, isRepeat)
	if key == "escape" or key == "p" or key == "m" then
		self.menuOpen = not self.menuOpen
		self.world.SetMenuState(api.PanelOpen())
	end
	if key == "tab" or key == "c" then
		if not self.noGrimoire then
			ToggleBook()
		end
	end
end

function api.GetTutorial()
	if not self.tutorialStage then
		return
	end
	local tutorial = self.tutorial[self.tutorialStage]
	return tutorial
end

local function UpdateTutorial(dt)
	local tutorial = api.GetTutorial()
	if not tutorial then
		return
	end
	while tutorial.progressFunc(self, dt) do
		self.tutorialStage = self.tutorialStage + 1
		if not self.tutorial[self.tutorialStage] then
			self.tutorial = false
			self.tutorialStage = false
			return
		end
		tutorial = api.GetTutorial()
	end
end

function api.ShapesAreInactive()
	if not self.tutorialStage then
		return
	end
	return api.GetTutorial().noEnemySpawn
end

function api.WinTheGame()
	if self.noWin then
		return
	end
	self.world.SetGameOver(true, "The Summoning is Complete")
end

function api.IsGameOver()
	local over = self.world.GetGameOver()
	return over
end

--------------------------------------------------
-- Flying Stuff
--------------------------------------------------

local function DrawFlyingEnemies(transBottom)
	local i = 1
	local flyTime = 1.1
	local endPos = {1480 + 180/2, 1010 + 70/2}
	while i <= #self.flyingEnemies do
		local data = self.flyingEnemies[i]
		if data then
			if self.animDt - data.startTime > flyTime then
				self.flyingEnemies[i] = self.flyingEnemies[#self.flyingEnemies]
				self.flyingEnemies[#self.flyingEnemies] = nil
			else
				local prop = util.SmoothZeroToOne((self.animDt - data.startTime) / flyTime, 4)
				local startPos = self.world.ScreenToInterface(self.world.WorldToScreen(data.pos), transBottom)
				local drawPos = util.Average(startPos, endPos, prop)
				Resources.DrawImage(ElementUiDefs.def[data.enemyType].image, drawPos[1], drawPos[2], 0, 0.45, data.size * (1 - prop) * 0.9 + 0.1)
				i = i + 1
			end
		else
			i = i + 1
		end
	end
end

function api.AddFlyingEnemy(pos, size, enemyType)
	self.flyingEnemies[#self.flyingEnemies + 1] = {
		pos = pos,
		size = size,
		enemyType = enemyType,
		startTime = self.animDt,
	}
end

--------------------------------------------------
-- Draw
--------------------------------------------------

local function PrintLine(text, size, x, y, align, width, col)
	Font.SetSize(size)
	col = col or Global.TEXT_COL
	love.graphics.setColor(col[1], col[2], col[3], 1)
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

local function DrawFloatingStuff()
	local over, _, gameLost, overType = self.world.GetGameOver()
	if over then
		PrintLine(overType or "Game Over", 0, 500, 400, "center", 1000, Global.FLOATING_TEXT_COL)
		if gameLost then
			PrintLine("Press Ctrl+R to to try again", 2, 500, 500, "center", 1000, Global.FLOATING_TEXT_COL)
		end
	end
	
	local tutorial = api.GetTutorial()
	if tutorial then
		PrintLine(tutorial.text, 1, 300, 60, "center", 1400, Global.FLOATING_TEXT_COL)
	end
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
	
	local offset = 1040
	local windowX, windowY = love.window.getMode()
	PrintLine("Score: " .. self.score, 2, xOffset + 24, offset, "left", 800, Global.FLOATING_TEXT_COL)
	offset = offset - 40
	PrintLine("Tool: " .. tool, 2, xOffset + 24, offset, "left", 800, Global.FLOATING_TEXT_COL)
	offset = offset - 40
	
	if self.menuOpen then
		local lifetime = EnemyHandler.GetSpawnParameters()
		PrintLine("Game Time: " .. util.SecondsToString(lifetime), 2, xOffset + 24, offset, "left", 800, Global.FLOATING_TEXT_COL)
		offset = offset - 40
	end
	
	if not api.GetTutorial() then
		offset = 20
		for i = 1, #ShapeDefs.shapeNames do
			local name = ShapeDefs.shapeNames[i]
			if ShapeDefs.collectiveHumanName[name] then
				local maximum = math.floor(PowerHandler.GetMaxShapesType(name))
				if maximum > 0 then
					local count = math.floor(ShapeHandler.GetShapeTypeCount(name))
					PrintLine(ShapeDefs.collectiveHumanName[name] .. ": " .. count .. " / " .. maximum, 2, xOffset + 24, offset, "left", 800, Global.FLOATING_TEXT_COL)
				end
				offset = offset + 40
			end
		end
	end
end

local function DrawElementArea(x, y, element, mousePos)
	local def = ElementUiDefs.def[element] or ElementUiDefs.def['water']
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
	
	local upgrade = InterfaceUtil.DrawButton(x + 120, y + 85 + offset, 140, 46, mousePos, "Consume", not PowerHandler.CanUpgradeElement(element), PowerHandler.CanUpgradeElement(element), Global.FREE_UPGRADES, 3, 6, 4)
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
	for i = 1, #ElementUiDefs.uiOrder do
		DrawElementArea(elementX, elementY, ElementUiDefs.uiOrder[i], mousePos)
		if i%2 == 1 then
			elementX = elementX + elementXOffset
		else
			elementX = elementX - elementXOffset
			elementY = elementY + elementYOffset
		end
	end
	
	local octaX = overX + overWidth/6
	local octaY = 406
	
	Font.SetSize(2)
	PrintLine("Elemental Affinity", 1, overX, octaY - 260, "center", overWidth/3, Global.TEXT_MENU_COL)
	Resources.DrawImage("bookback", octaX - 2, octaY + 2, 0, 1, 1)
	
	PrintLine(HintDefs[self.hintIndex] or "", 3, overX + 40, octaY + 210, "left", overWidth/3 - 80, Global.TEXT_MENU_COL)
	
	ShapeHandler.DrawInBook(octaX, octaY)
	local affinityPos = util.Add({octaX, octaY}, util.Mult(Global.BOOK_SCALE, ShapeHandler.GetAffinityPos()))
	local affinityRadius = PowerHandler.GetSpawnAffinityRadius()*Global.BOOK_SCALE * 0.4
	
	love.graphics.setColor(Global.AFFINITY_COLOR[1], Global.AFFINITY_COLOR[2], Global.AFFINITY_COLOR[3], 0.8)
	love.graphics.circle('fill', affinityPos[1], affinityPos[2], 6)
	love.graphics.setColor(Global.AFFINITY_COLOR[1], Global.AFFINITY_COLOR[2], Global.AFFINITY_COLOR[3], 0.3)
	love.graphics.circle('fill', affinityPos[1], affinityPos[2], affinityRadius, 64)
	
	love.graphics.setLineWidth(4)
	love.graphics.setColor(Global.AFFINITY_COLOR[1], Global.AFFINITY_COLOR[2], Global.AFFINITY_COLOR[3], 1)
	love.graphics.circle('line', octaX - 2, octaY + 2, 184, 200)
	
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
	local mousePos = self.world.GetMousePositionInterface()
	local windowX, windowY = 2000, 1100
	local overX = windowX*0.84
	local overWidth = windowX*0.16
	local overY = windowY*0.1
	local overHeight = windowY*0.7
	InterfaceUtil.DrawPanel(overX, overY, overWidth, overHeight*1.12)
	
	local offset = overY + 20
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Toggle Music", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Music Louder", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Music Softer", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Effects Louder", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Effects Softer", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	
	offset = offset + 20
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Toggle Edge Scroll", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Scroll Speed Up", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Scroll Speed Down", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	
	offset = offset + 20
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Switch to Sandbox", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Switch to Base", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Switch to Hard", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Switch to Hardest", false, false, false, 3, 8, 4) or self.hovered
	offset = offset + 55
	
	local offset = overY + overHeight*1.12 - 20 - 45
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Quit", false, false, false, 3, 8, 4) or self.hovered
	offset = offset - 55
	self.hovered = InterfaceUtil.DrawButton(overX + 20, offset, 270, 45, mousePos, "Restart", false, false, false, 3, 8, 4) or self.hovered

end

local function BottomInterface(transBottom)
	local mousePos = self.world.GetMousePositionInterface(transBottom)
	
	DrawFlyingEnemies(transBottom)
	
	self.hovered = false
	if not self.noGrimoire then
		local flash = (PowerHandler.CountUpgrades() > math.min(7, self.lastUpgradeCount))
		self.hovered = InterfaceUtil.DrawButton(1480, 1010, 180, 70, mousePos, "Grimoire", false, flash and not api.PanelOpen(), false, 2, 12)
	end
	self.hovered = InterfaceUtil.DrawButton(1710, 1010, 180, 70, mousePos, "Menu", false, false, false, 2, 12) or self.hovered
	
	if PlayerHandler.GetHealthProp() < 1 then
		InterfaceUtil.DrawBar({0.3, 1, 0.3}, {0.3, 0.3, 0.3}, PlayerHandler.GetHealthProp(), false, false, {600, 1020}, {800, 60})
	end
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
	self.animDt = self.animDt + dt
	UpdateTutorial(dt)
end

function api.DrawInterface(transMid, transTopLeft, transBottom)
	love.graphics.replaceTransform(transBottom)
	BottomInterface(transBottom)
	love.graphics.replaceTransform(transTopLeft)
	DrawLeftInterface()
	love.graphics.replaceTransform(transMid)
	DrawFloatingStuff()
	if self.powersOpen then
		DrawPowerMenu()
	end
	if self.menuOpen then
		DrawMainMenu()
	end
end

function api.Initialize(world, difficulty)
	local levelData = world.GetLevelData()
	self = {
		flyingEnemies = {},
		world = world,
		score = 0,
		animDt = 0,
		hovered = false,
		menuOpen = false,
		powersOpen = false,
		hintsLooped = false,
		lastUpgradeCount = 0,
		hintIndex = 0,
		noGrimoire = levelData.noGrimoire,
		noWin = levelData.noGrimoire,
		tutorial = difficulty <= 1.2 and levelData.tutorial,
		tutorialStage = difficulty <= 1.2 and levelData.tutorial and 1,
	}
	
	self.world.SetMenuState(api.PanelOpen())
end

return api
