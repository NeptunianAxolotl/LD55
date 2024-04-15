
local enemies = util.LoadDefDirectory("defs/enemies")

for name, def in pairs(enemies) do
	def.name = name
end

local elementOrderAroundCircle = {
	"lightning",
	"air",
	"ice",
	"water",
	"life",
	"earth",
	"chalk",
	"fire",
}

local data = {
	defs = enemies,
	order = elementOrderAroundCircle,
}

return data
