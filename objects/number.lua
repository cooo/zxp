local class = require 'lib/middleclass'

Digit = class('Digit') 

function id(x,y)
	return "x" .. x .. "y" .. y
end

function Digit:initialize(x,y,i)
	self.i     = nil
	self.strip = 10
	
	local path     = zxp.imgpath .. "numbers_white.png"
	local tileDeck = Moai:cachedTileDeck(path, 1, self.strip, 16)
	
	self.id   = id(x,y)
	self.prop = Moai:createProp(scoreboard_layer, tileDeck, x, y, 16)
	
	self:show_digit(i)
end

function Digit:show_digit(i)
	self.i = i + 1
end

function Digit:update()
	self.prop:setIndex(self.i)
end
