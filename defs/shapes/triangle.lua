
local data = {
	characteristicAngle = math.pi/3, -- At most pi/2, this is the angle between involved lines.
	powerMult = 1,
	color = {0.2, 0.4, 0.8},
}

function data.ExpectedLines(origin, u, v)
	local vertices = {
		origin,
		util.Add(origin, u),
		util.Add(origin, v),
	}
	return vertices
end


return data
