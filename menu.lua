menu = {}

menu.show       = false

function menu.pressed(key)
	return key=="m"
end

function menu.execute()
	if menu.show then
		menu.show = false
		-- show a menu layer
	else
		menu.show = true
	end
end

return menu
