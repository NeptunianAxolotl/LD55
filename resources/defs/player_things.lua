
local names = util.GetDefDirList("resources/images/player", "png")
local data = {}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/player/" .. names[i] .. ".png",
		form = "image",
		xScale = 1,
		yScale = 1,
		xOffset = 0.5,
		yOffset = 55/80,
	}
end

return data
