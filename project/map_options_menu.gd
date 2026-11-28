extends Panel

var MAP_OPTION = preload("res://map_option.tscn")

func _load_map_options() -> void:
	visible = true
	for map_name in Main.map_options:
		print(map_name)
		var new_map_option = MAP_OPTION.instantiate()
		new_map_option.load_map_option(map_name)
		$Panel/Margin/OptionsGrid.add_child(new_map_option)
