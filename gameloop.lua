require("lib/strings")
require("lib/vector2d")
require("lib/audio")
require("lib/moai_extensions")	-- helpful stuff

require("zxp")
require("camera")
require("levels/load")
require("input")
require("scoreboard")


gameloop = {}
gamePaused = false
STAGE_WIDTH = 256 -- (iPhone4=960, iPhone5=1136, iPad3+=2048)
STAGE_HEIGHT = 192 -- (iPhone4=640, iPhone5=640, iPad3+=1536)


local function onDraw ( index, xOff, yOff, xFlip, yFlip )
	MOAIGfxDevice.setPenColor ( 1, 0, 0, 1 )
	MOAIDraw.drawRect(-64, 64, 64, -64)
end

function gameloop:load()
		
	local SCREEN_WIDTH = MOAIEnvironment.verticalResolution or 256*4
	local SCREEN_HEIGHT = MOAIEnvironment.horizontalResolution or 192*4
	print ( "System: ", MOAIEnvironment.osBrand )
	print ( "Resolution: " .. SCREEN_WIDTH .. "x" .. SCREEN_HEIGHT )
	
	-- 2.
	MOAISim.openWindow ( "ZXP", SCREEN_WIDTH, SCREEN_HEIGHT ) -- window/device size
	
	-- 3.
	local viewport = MOAIViewport.new ()
	viewport:setSize ( SCREEN_WIDTH, SCREEN_HEIGHT ) -- window/device size
	viewport:setScale ( STAGE_WIDTH, STAGE_HEIGHT ) -- size of the "app"
	
	-- 4. 
	layer = MOAILayer2D.new ()
	layer:setViewport ( viewport )

	hud_layer = input:createHud(viewport)
	scoreboard_layer = scoreboard:createScoreboard(viewport)

	input:createButtons()
	
	camera:init(layer)

	-- 6.
	MOAIRenderMgr.setRenderTable ( { layer, hud_layer, scoreboard_layer } )

	-- 7
	-- start other engines here
	zxp:Startup()
end


function gameloop:update(dt)
	if gamePaused then return end
	
	if not zxp.start_over then
		zxp:update(dt)
	else
		zxp:startOver()
	end
end

function gameloop:draw()
	zxp:draw()
end
