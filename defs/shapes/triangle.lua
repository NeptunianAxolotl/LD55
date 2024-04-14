
local data = {
	characteristicAngle = math.pi/3, -- At most pi/2, this is the angle between involved lines.
}

function data.ExpectedLines(origin, u, v)
	local verticies = {
		origin,
		util.Add(origin, u),
		util.Add(origin, v),
	}
	return verticies
end


return data
