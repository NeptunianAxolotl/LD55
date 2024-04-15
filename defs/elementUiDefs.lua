
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
			return "Move " .. PercentInc(PowerHandler.GetPlayerSpeed() / Global.PLAYER_SPEED) .. "% faster"
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
			return "Spirits moves " .. PercentInc(1 / PowerHandler.GetEnemySpeedModifier()) .. "% slower"
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
