
local names = util.GetDefDirList("resources/images/levels", "png")
local data = {}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/levels/" .. names[i] .. ".png",
		form = "image",
		xScale = 1,
		yScale = 1,
		xOffset = 0,
		yOffset = 0,
	}
end

return data
