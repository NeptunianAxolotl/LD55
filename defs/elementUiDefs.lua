
local function PercentInc(value)
	return util.Round(100*(value - 1))
end

local elementUiDefs = {
	water = {
		humanName = "Water",
		descFunc = function ()
			return "Regenerate " .. util.Round(10*PowerHandler.GetPlayerHealthRegen()) .. " health every 10 seconds"
		end,
		image = "water_icon",
	},
	air = {
		humanName = "Air",
		descFunc = function ()
			if not PowerHandler.UseMixedSpeed() then
				return "Move " .. PercentInc(PowerHandler.GetPlayerSpeed() / Global.PLAYER_SPEED) .. "% faster"
			end
			local upMod = PowerHandler.GetRawAirSpeed()
			return "Move " .. PercentInc(upMod) .. "% faster, elementals are " .. PercentInc(0.5 + 0.5 * upMod) .. "% faster"
		end,
		bottomText = function ()
			if not PowerHandler.UseMixedSpeed() then
				return false
			end
			return "Your speed: " .. util.Round(PowerHandler.GetPlayerSpeed() * 100 / Global.PLAYER_SPEED) .. "%"
		end,
		image = "air_icon",
	},
	earth = {
		humanName = "Earth",
		descFunc = function ()
			return "Sustain " .. math.floor(PowerHandler.GetSafeLineCapacity()) .. " lines, excess fade after " .. util.Round(PowerHandler.GetLineFadeTime()) .. "s"
		end,
		image = "earth",
	},
	fire = {
		humanName = "Fire",
		descFunc = function ()
			return "Sigils are " .. PercentInc(PowerHandler.GetShapePower() / Global.BASE_SHAPE_POWER) .. "% more powerful"
		end,
		image = "fire_icon",
	},
	life = {
		humanName = "Life",
		descFunc = function ()
			return "Maximum health is " .. util.Round(PowerHandler.GetPlayerMaxHealth())
		end,
		image = "life_icon",
	},
	ice = {
		humanName = "Ice",
		descFunc = function ()
			if not PowerHandler.UseMixedSpeed() then
				return "Elementals move " .. PercentInc(1 / PowerHandler.GetEnemySpeedModifier()) .. "% slower"
			end
			local downMod = PowerHandler.GetRawIceSpeed()
			return "Slow elementals by " .. PercentInc(downMod) .. "%, you by " .. PercentInc(1 / (0.5 + 0.5 / downMod)) .. "%"
		end,
		bottomText = function ()
			if not PowerHandler.UseMixedSpeed() then
				return false
			end
			return "Elemental speed: " .. util.Round(PowerHandler.GetEnemySpeedModifier() * 100) .. "%"
		end,
		image = "ice",
	},
	lightning = {
		humanName = "Lightning",
		descFunc = function ()
			return "Sustain more sigils and unlocks new ones"
		end,
		image = "lightning_icon",
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

return {
	def = elementUiDefs,
	uiOrder = elementList,
}
