
local data = {
	characteristicAngle = math.pi/3, -- At most pi/2, this is the angle between involved lines.
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
