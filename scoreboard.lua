require "objects/number"

scoreboard = {}
scoreboard.one_second_timer = nil
scoreboard.score = 0
--scoreboard.number_lua = nil
scoreboard.matrix = {}


function scoreboard:createScoreboard(viewport)
	local scoreboard_layer = MOAILayer2D.new ()
	scoreboard_layer:setViewport ( viewport )
	
	return scoreboard_layer
end

function scoreboard:tick()
	scoreboard.score = scoreboard.score + 1
end

function scoreboard:load()
	print('load')
	self.one_second_timer         = nil
--	scoreboard.number_lua = loadfile( zxp.objpath .. "number.lua" )
	
	scoreboard.one_second_timer = Moai:createLoopTimer(1.0, scoreboard.tick)
end


function scoreboard.Create(name, x, y, i)
	x = x or 0
	y = y or 0

	local digit = Digit:new(x,y,i)
	digit.type = name
	scoreboard.matrix[digit.id] = digit

	return digit
end

-- finds a digit on the scoreboard and change it to i, create it if not found
local function find_or_create(name, x, y, i)
	if scoreboard.matrix[id( x,y )] then
		local number = scoreboard.matrix[id( x,y )]
		number:show_digit( i )
	else
		scoreboard.Create( name, x, y, i )
	end
end


local function draw_on_board(str, x)
	
	if (x>=0) then
		local board_to_get = {}
		string.gsub(str, "(.)", 
			function(x) 
				table.insert(board_to_get, x) 
			end
		)

		for i, digit in pairs(board_to_get) do
			find_or_create( "number", x+i, 0, digit )
		end
	end
end



function scoreboard:update()
	
	if zxp.done then
		scoreboard.tick()
	end

	draw_on_board(string.rjust(self.score,    4, "0"),  3)

	-- update the matrix
	for i, digit in pairs(self.matrix) do
		digit:update()
	end
end

