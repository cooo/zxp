require "objects/willy"
require "objects/wall"

zxp = {}
zxp.objpath   = "objects/"
zxp.objects   = {}
zxp.imgpath   = "images/"
zxp.done = false
zxp.dead = false
zxp.start_over = false

local register = {}

function id(x,y)
	return "x" .. x .. "y" .. y
end


function zxp.Derive(name)
	return loadfile( zxp.objpath .. name .. ".lua" )()
end

function zxp:setDone()
	zxp.done = true
end

function zxp:find(x,y)
	return zxp.objects[id(x,y)]
end

function zxp:findByID(id)
	return zxp.objects[id]
end


local function registerObjects()
	-- register everything in the zxp.objpath folder
	local files = MOAIFileSystem.listFiles( zxp.objpath )
	for k, file in ipairs(files) do
		if not (file == "base.lua") then
			local obj_name = string.sub(file,1,string.find(file, ".lua") - 1)
			register[obj_name] = loadfile( zxp.objpath .. file )

		end
	end
end

function zxp:Startup()
	level_loader:load()
	registerObjects()
	audio:init()
	scoreboard:load()
	zxp:LevelUp()
end



function zxp:LevelUp()
	layer:clear()
	self.objects = {}
	local xc,yc = camera:getLoc()
	camera:moveLoc(-xc, -yc, 2.0) 

	self.map = MOAIGrid.new()
	self.map:initRectGrid(1,1,32,32)
	

    level = level_loader.worlds[1].levels[1].map
	for y,i in pairs(level) do
		for x,j in pairs(level[y]) do
			zxp.Create( lookup(level[y][x]), x-1, y )
		end
	end
	
	-- 
	zxp.done = false
	zxp.flash = false
	zxp.dead = false

end

function zxp.Create(name, x, y, callback)
	x = x or 0
	y = y or 0
	
	print("Create", name)
	if register[name] then
		print(name, x, y)
		if name=="willy" then
			local willy = Willy:new(x,y)
			willy.type = name
			zxp.objects[willy.id] = willy
		elseif name=="wall" then
			local wall = Wall:new(x,y)
			wall.type = name
			zxp.objects[wall.id] = wall
		end
		

		-- local object = assert(register[name]())
		-- object:load(x,y)
		-- object.type = name
		-- object.id = id(x,y)
		-- object.callback = callback
		-- object:setPos(x,y)
		-- zxp.objects[object.id] = object
		-- return object
	else
		print("Error: Entity " .. name .. " does not exist! ")
	end
end

function zxp:startOver()
	
	print("startOver")

	zxp:LevelUp()
end


function zxp:update(dt)
	frame_counter = frame_counter + 1
	
	for i, object in pairs(zxp.objects) do
		if object.update then
			if not object.moved then
				object:update()
				object.moved = true
			end
		end
	end
	
	if zxp.done then
		if MOAIInputMgr.device.keyboard then
			MOAIInputMgr.device.keyboard:setCallback(nil)
		end
	end
	
	scoreboard:update()
end

function zxp:resetBackground()
	layer:setClearColor(0, 0, 0)
end


function zxp:draw()
	for i, object in pairs(zxp.objects) do
		object.moved = false
	end
	
--	menu:draw()
		
end

