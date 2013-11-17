local class = require 'lib/middleclass'

Wall = class('Wall') 

function id(x,y)
	return "x" .. x .. "y" .. y
end

function Wall:initialize(x,y)
	self.i      = nil
	self.width  = 8
	self.height = 8
	self.x = x
	self.y = y
		
	local quad = Moai:cachedTexture(zxp.imgpath .. "wall.png", self.width, self.height)
	self.prop  = Moai:createProp(layer, quad, x, y)
	
	self.id   = id(x,y)
end
