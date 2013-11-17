input = {}

input.partition			= nil  		-- a MOAIPartition, to grab touch events
input.key 			 	= nil
input.grab 			 	= false
input.subscribers    	= {}	    -- entities can subscribe to input events

local ONE_STEP = 10
local SWIPE_TRESHOLD = 15

local touches	= {}
local joystick	= nil	-- touches can become a fixed joystick on screen

local function move_to(direction)
	for i, subscriber in pairs(input.subscribers) do
		if not subscriber.moved then
			if (direction == "right") then
				subscriber:LeftOrRight(1)
			elseif (direction == "left") then
				subscriber:LeftOrRight(-1)
			elseif (direction == "up") then
				subscriber:UpOrDown(-1)
			elseif (direction == "down") then
				subscriber:UpOrDown(1)
			end
		end
	end
end

local function move_to_2d(vector)
	for i, subscriber in pairs(input.subscribers) do
		if not subscriber.moved then
			subscriber:move(vector)
		end
	end
end

local function stop_running()
	input.key = nil
	for i, subscriber in pairs(input.subscribers) do
		subscriber:stopRunning()
	end
end

local function going_somewhere(key, move)
	if move then
		input.key = key
		if key==32 then
			input.grab=true
		elseif (key==113 or key==357) then
			move_to("up")
		elseif (key==97 or key==359) then
			move_to("down")
		elseif (key==111 or key==356) then
			move_to("left")
		elseif (key==112 or key==358) then
			move_to("right")
		end
	end
end



-- should return a vector (x,y) => left: (-1,0), right (1,0), up (0,-1), down (0,1), no-move (0,0)
local function direction(startX, startY, endX, endY)
	
	local vector = Vector2d:new(startX, startY, endX, endY)
	local distance = vector:length()
	
	print("direction: ", startX, startY, endX, endY, distance)
	
	if (distance > SWIPE_TRESHOLD) then
		if vector:is_x_major() then
			return vector:unit_x()
		else
			return vector:unit_y()
		end
	else
		print("no swipe")
		return Vector2d:zero()
	end
end


local function big_delta(touch_old, touch_current, move)
	print("checking big_delta")
	local vector = direction(touch_old.start_loc.x, touch_old.start_loc.y, touch_current.start_loc.x, touch_current.start_loc.y)
	if move and vector:is_swipe() then
		move_to_2d(vector)
	end
	return vector:is_swipe()
end

local function swipe(touch, move)
	print("checking swipe")
	local vector = direction(touch.start_loc.x, touch.start_loc.y, touch.end_loc.x, touch.end_loc.y)
	if move and vector:is_swipe() then
		move_to_2d(vector)
	end
	return vector:is_swipe()
end


-- someone 'points' at location x,y on the screen
local function pointCallback (x, y)
--	print("pointCallback ", x,y)
--	local wx,wy = hud_layer:wndToWorld ( x, y )

-- 	-- this function is called when the touch is registered (before clickCallback)
-- 	-- or when the mouse cursor is moved
--	print(hud_layer:wndToWorld ( x, y ))
-- 
-- --	print("pointCallback", mouseX, mouseY)
-- -- 	if tap_count>0 then
-- -- 		print("pointCallback, tap-count:", tap_count)
-- -- 		endX, endY = mouseX, mouseY
-- -- 		touches[tap_count].end_loc = {x=endX, y=endY}
-- -- 		
-- -- --		swipe_direction(tap_count)
-- -- 	end
-- 	
end



local function worldXY(x,y)
	return hud_layer:wndToWorld ( x, y )
end


local function touchDownCallback ( idx, wx, wy)
	print("touchDownCallback ", wx,wy,idx)
	local startX, startY = wx,wy

	function onDraw ( index, xOff, yOff, xFlip, yFlip )
		if (touches[idx] and startX and startY) then
		    MOAIDraw.drawCircle ( startX+touches[idx].joystick.x, startY+touches[idx].joystick.y, 20)
		    MOAIDraw.drawCircle ( startX, startY, 64)
		end
	end
	
	-- record touch location
	touches[idx] = { start_loc, end_loc }
	touches[idx].start_loc = {x=wx, y=wy}
	touches[idx].joystick = { x=0, y=0 }

	if joystick then
		-- there is already a joystick on screen, so check big_delta between touches
		if not big_delta(joystick, touches[idx], true) then
			-- not big enough, remove the joystick (tapped twice)
			print("removing prop")
			hud_layer:removeProp(joystick.prop)
						
		end
	else
		-- draw and init a joystick
		scriptDeck = MOAIScriptDeck.new ()
		scriptDeck:setRect ( -64, -64, 64, 64 )
		scriptDeck:setDrawCallback ( onDraw )

		touches[idx].prop = MOAIProp2D.new ()
		touches[idx].prop:setDeck ( scriptDeck )
		hud_layer:insertProp ( touches[idx].prop )
	end
		
		
end

local function touchMoveCallback(idx, wx, wy)
	print("touchMoveCallback", idx)
	touches[idx].end_loc = {x=wx, y=wy}
	if swipe(touches[idx], true) then
		-- swipe detected
		if joystick then
			-- already on screen, so start a new on
			local startX, startY = wx,wy

			function onDraw ( index, xOff, yOff, xFlip, yFlip )
				if (startX and startY) then
				    MOAIDraw.drawCircle ( startX+touches[idx].joystick.x, startY+touches[idx].joystick.y, 20)
				    MOAIDraw.drawCircle ( startX, startY, 64)
				end

			end

			hud_layer:removeProp(joystick.prop)
			joystick = nil
			
			-- draw a new joystick
			touches[idx].joystick = { x=0, y=0 }

			scriptDeck = MOAIScriptDeck.new ()
			scriptDeck:setRect ( -64, -64, 64, 64 )
			scriptDeck:setDrawCallback ( onDraw )

			touches[idx].prop = MOAIProp2D.new ()
			touches[idx].prop:setDeck ( scriptDeck )
			hud_layer:insertProp ( touches[idx].prop )
			
		end
	end
end



local function touchUpCallback ( idx, wx, wy)
	print("touchUpCallback ", wx,wy,idx)
	local startX, startY = wx,wy
	touches[idx].end_loc = {x=wx, y=wy}
	
	stop_running()

	if swipe(touches[idx], false) then
		-- swipe complete
		hud_layer:removeProp(touches[idx].prop)
	else
		if joystick then
			-- do nothing, big delta was handled in touchDown
			if not big_delta(joystick, touches[idx], false) then
				joystick = nil
			else
			end
			
		else
			-- touch was a tap, so fixate this touch so it becomes a joystick
			print("fix the joystick")
			joystick = touches[idx]
			
		end
	end

end



local function init_callbacks()
	
	if MOAIInputMgr.device.pointer then
		-- mouse input
		MOAIInputMgr.device.pointer:setCallback ( pointCallback )
		MOAIInputMgr.device.mouseLeft:setCallback ( clickCallback )
		
	else
		-- touch input
		MOAIInputMgr.device.touch:setCallback ( 
			-- this is called on every touch event
			function ( eventType, idx, x, y, tapCount )

				if idx<3 then
					local wx,wy = worldXY(x, y ) -- first set location of the touch
					if eventType == MOAITouchSensor.TOUCH_DOWN then
						touchDownCallback ( idx, wx, wy)
					elseif eventType == MOAITouchSensor.TOUCH_UP then
						touchUpCallback ( idx, wx, wy )
					elseif eventType == MOAITouchSensor.TOUCH_MOVE then
						touchMoveCallback(idx, wx, wy)
					end
				else
					for i,touch in pairs(touches) do
						hud_layer:removeProp(touch.prop)
					end
				end
			end
		)
	end	
	
end


function input:createHud(viewport)
	
	init_callbacks()
	
	hud_layer = MOAILayer2D.new ()
	hud_layer:setViewport ( viewport )

	input.partition = MOAIPartition.new ()
	hud_layer:setPartition ( input.partition )

	return hud_layer
end


function input:createButtons()

	if(MOAIInputMgr.device.keyboard) then
	
	    MOAIInputMgr.device.keyboard:setCallback(
	        function(key,down)
				
	            if down==true then
					-- pushed down key
				else
					-- key up
	            end
	        end
	    )
	end	
	
end
