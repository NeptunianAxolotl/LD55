local hugeFont
local bigFont
local medFont
local smallFont

local externalFunc = {}
local _size = 1

function externalFunc.SetSize(size)
	if not bigFont then
		externalFunc.Load()
	end
	if size == 0 then
		love.graphics.setFont(hugeFont)
		_size = 0
	elseif size == 1 then
		love.graphics.setFont(bigFont)
		_size = 1
	elseif size == 2 then
		love.graphics.setFont(medFont)
		_size = 2
	elseif size == 3 then
		love.graphics.setFont(smallFont)
		_size = 3
	elseif size == 4 then
		love.graphics.setFont(smallerFont)
		_size = 4
	end
end

function externalFunc.GetFont()
	if _size == 0 then
		return hugeFont
	elseif _size == 1 then
		return bigFont
	elseif _size == 2 then
		return medFont
	elseif _size == 3 then
		return smallFont
	else
		return smallerFont
	end
end

local FONT = "FreeSansBold.ttf"
--local FONT = "RBNo3.1-Book.otf" -- https://freefontsfamily.com/rbno3-font-free-download/

function externalFunc.Load()
	hugeFont    = love.graphics.newFont('include/fonts/' .. FONT, 64)
	bigFont     = love.graphics.newFont('include/fonts/' .. FONT, 48)
	medFont     = love.graphics.newFont('include/fonts/' .. FONT, 32)
	smallFont   = love.graphics.newFont('include/fonts/' .. FONT, 24)
	smallerFont = love.graphics.newFont('include/fonts/' .. FONT, 18)
end

return externalFunc