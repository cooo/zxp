level_loader = {}
level_loader.folder = "levels/"
level_loader.worlds = {}
debug = false


level_loader.object_map = {
	W     = "willy",
	w     = "wall"
	
--	X     = "object x",
--	Y     = "object Y"
}


local start_sections = { "[ZXP]", "[world]", "[level]", "[map]" }
local end_sections = { "[/ZXP]", "[/world]", "[/level]", "[/map]" }

local function print_d(s)
	if debug then
		print(s)
	end
end

function remove_eols(s)
    return s
        :gsub('\r\n','')
        :gsub('\r', '')
end

local function parse(file)
	local world = {}
	local level = {}
	level.map = {}
	local sections = {}
	local current_section = nil
	local line_number = 0
	for line in io.lines(file) do
		line = remove_eols(line)

		line_number = line_number + 1
	  	if (#line==0) or line:starts_with(";") then
			-- skip empty lines or lines that start with ;
			print_d("skip " .. line)
			
		elseif line:is_found_in(start_sections) then

			table.insert(sections, line)
			print_d(line .. " starts")
			current_section = line
			if (current_section == "[world]") then
				world.levels = {}
			end
			
		elseif line:is_found_in(end_sections) then
			local section = table.remove(sections)
			print_d(section .. " ends")
			if (section == "[world]") then
				table.insert(level_loader.worlds, world)
				world = {}
			elseif (section == "[level]") then
				table.insert(world.levels, level)
				level = {}
				level.map = {}
			elseif (section == "[map]") then
				-- do nothing
			end

		elseif (current_section == "[world]") then
			print_d(current_section .. ": " .. line)
			if line:starts_with("Name") then
				world.name = line:get_after("Name=")
			elseif line:starts_with("Author") then
				world.by = line:get_after("Author=")
			elseif line:starts_with("Date") then
				world.year = line:get_after("Date=")
			end

		elseif (current_section == "[level]") then
			print_d(current_section .. ": " .. line)
			if line:starts_with("Name") then
				level.name = line:get_after("Name=")
			elseif line:starts_with("LevelTime") then
				level.time = line:get_after("LevelTime=")
			end

		elseif (current_section == "[map]") then
			table.insert(level.map, line:dice())
		end
		
	end
	
end


function level_loader:load()
	files = MOAIFileSystem.listFiles( level_loader.folder )
	for k, file in ipairs(files) do
		if not (file == "levels.lua") then
			parse(level_loader.folder .. file)
		end
	end
end

function lookup(letter)
	object = level_loader.object_map[letter]
	if object then
		return object
	else
		if letter~="space" then
 			print("cannot find " .. letter)
		end
		return "space"
	end
end

