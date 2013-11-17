local class = require 'lib/middleclass'

Vector2d = class('Vector2d') 

function Vector2d:initialize(startX, startY, endX, endY)
	self.x = endX - startX
	self.y = endY - startY
end

function Vector2d:zero()
	return Vector2d:new(0,0,0,0)
end

function Vector2d:unit_x()
	return Vector2d:new(0,0,(math.abs(self.x)/self.x),0)
end

function Vector2d:unit_y()
	return Vector2d:new(0,0,0,-(math.abs(self.y)/self.y))
end

function Vector2d:length()
  return math.sqrt(self.x*self.x + self.y*self.y)
end

function Vector2d:is_x_major()
  return (math.abs(self.x) > math.abs(self.y))
end

function Vector2d:is_swipe()
  return not (self.x==0 and self.y==0)
end
