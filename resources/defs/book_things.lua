
local names = util.GetDefDirList("resources/images/book", "png")
local data = {}

for i = 1, #names do
	data[#data + 1] = {
		name = names[i],
		file = "resources/images/book/" .. names[i] .. ".png",
		form = "image",
		xScale = 0.35,
		yScale = 0.35,
		xOffset = 0.5,
		yOffset = 0.5,
	}
end

return data
