
local shapes = util.LoadDefDirectory("defs/shapes")

local angles = {}
local shapesWithAngleIndex = {}
local angleToIndex = {}
local shapeNames = {}

for name, data in pairs(shapes) do
	if not angleToIndex[data.characteristicAngle] then
		shapesWithAngleIndex[#shapesWithAngleIndex + 1] = {}
		angleToIndex[data.characteristicAngle] = #shapesWithAngleIndex
		angles[#angles + 1] = data.characteristicAngle
		if data.characteristicAngle > math.pi/2 + 0.00000001 then
			print("characteristicAngles must be acute")
			bla = bla[1]
		end
	end
	local index = angleToIndex[data.characteristicAngle]
	local indexMap = shapesWithAngleIndex[index]
	data.name = name
	data.angleIndex = index
	indexMap[#indexMap + 1] = data
	shapeNames[#shapeNames + 1] = name
end

shapeNames = {
	"triangle",
	"square",
	"hexagon",
	"octagon",
	"pentagon",
}

local collectiveHumanName = {
	-- The existence of pentagon is hidden!
	triangle = "Triangles",
	square = "Squares",
	hexagon = "Hexagons",
	octagon = "Octagons",
}

local data = {
	shapes = shapes,
	shapesWithAngleIndex = shapesWithAngleIndex,
	angles = angles,
	shapeNames = shapeNames,
	collectiveHumanName = collectiveHumanName,
}

return data
