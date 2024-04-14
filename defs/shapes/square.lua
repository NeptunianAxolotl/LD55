
local data = {
	characteristicAngle = math.pi/2, -- At most pi/2, this is the angle between involved lines.
}

function data.ExpectedLines(origin, u, v)
	local vertices = {
		origin,
		util.Add(origin, u),
		util.Add(util.Add(origin, v), u),
		util.Add(origin, v),
	}
	return vertices
end


return data
