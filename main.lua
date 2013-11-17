FRAMES = 15

require("gameloop")
frame_counter = 0

local function forever(dt)
	gameloop:update()
	gameloop:draw()
end

local function newLoopingTimer ( spanTime, func )
	local timer = MOAITimer.new()
	timer:setSpan( spanTime )
	timer:setMode( MOAITimer.LOOP )
	timer:setListener( MOAITimer.EVENT_TIMER_LOOP, 
		function()
			func( spanTime )
		end
	)
	timer:start()
	return timer
end

-- do this once
gameloop:load()

-- do this forever
local gameLoopTimer = newLoopingTimer ( 1/FRAMES, forever )
