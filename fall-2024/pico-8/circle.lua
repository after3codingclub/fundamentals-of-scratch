
local clr = rnd(10)
local x = rnd(100)
local y = rnd(100)


function _draw()
local randx = rnd(100)
local randy = rnd(100)
local randr = rnd(50)
local randw = rnd(10)

circ(randx, randy, randr, clr) -- draw circle

	if btn(0) then cls() end
	if btn(2) then clr = rnd(10) end
	
if true then		
  x = x-1
		y = y-1
end




end
