local class = require 'lib/middleclass'

Willy = class('Willy') 

function id(x,y)
	return "x" .. x .. "y" .. y
end

function Willy:initialize(x,y)
	self.i     = nil
	self.strip = 4
	self.x = x
	self.y = y
		
	local tileDeck = Moai:cachedTileDeck(zxp.imgpath .. "willy.png", self.strip, 1, 16)
	self.prop  = Moai:createProp(layer, tileDeck, x, y, 16)	
	Moai:createAnimation(self.strip, self.prop)
	
	self.id   = id(x,y)
end
