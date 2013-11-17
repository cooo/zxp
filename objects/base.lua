local base = {}

base.x = 0
base.y = 0
base.img = nil
base.type = nil
base.moved = false
base.debug = false
base.scale = 32
base.callback = nil
base.width  = 32
base.height = 32
base.prop   = nil


function id(x,y)
	return "x" .. x .. "y" .. y
end

function base:setPos( x, y )
	base.x = x
	base.y = y
end

function base:setImage(img)
	base.img = img
end

function base:getImage()
	return base.img
end

function base:getPos()
	return base.x, base.y
end

-- move something in x,y direction
function base:doMove(x,y)
	local xr,yr = base:getPos()

	base.prop:setLoc (Moai:x_and_y(xr+x, yr+y) )
end


function base:remove()
	layer:removeProp(self.prop)
end

return base