extends Control

var default_div_color : Color

signal select_div

func _ready() -> void:
	default_div_color = Main.default_div_color
	_load_map()

#Generate the division buttons on the map
func _load_map(new_map_name: String = "Japan"):
	###Main.current_map = new_map_name
	Main.set_divisions(new_map_name)
	create_division_buttons()
	
	#Adjust division placements if necessary
	if Main.current_map_name == "Japan":
		%JapanMap.visible = true
		%Map.visible = false
		adjust_hokkaido_okinawa()
	else:
		%Map.visible = true
		%JapanMap.visible = false

#Create division buttons
func create_division_buttons():
	clear_division_buttons()
	var current_map_name : String = Main.current_map_name
	
	if current_map_name == "Japan":
		if %JapanMap.get_child_count() > 0:
			return
	for i in range(Main.num_divisions):
		var div_num = i + 1
		var new_btn = Main.DIV_BTN.instantiate()
		var div_name = Main.get_division_name(div_num)
		
		new_btn.name = "%d%sBtn" % [div_num, div_name]
		new_btn.div_num = div_num
		new_btn.add_to_group("division_buttons")
		if current_map_name == "Japan":
			new_btn.texture_normal = load("res://maps/%s/divisions/%d %s.png" % [current_map_name, i+1, div_name])
			%JapanMap.add_child(new_btn)
		else:
			new_btn.texture_normal = load(Maps.div_file_names[i])
			%Map.add_child(new_btn)
		new_btn.self_modulate = default_div_color
		new_btn.button_down.connect(_select_division.bind(div_num)) #this must be done after button is added to tree

func _select_division(div_num :int) -> void:
	emit_signal("select_div", div_num)

#Clear division buttons
func clear_division_buttons():
	for div in %Map.get_children():
		div.queue_free()

#func set_map_rotation() -> void: #Deprecated
	#var new_rotation : float = 0
	#match (Main.current_map):
		#"Japan":
			#new_rotation = 27.2
		#_:
			#new_rotation = 0.0
	#%Map.rotation = new_rotation

#------------Used to adjust maps----------------

#Adjust Hokkaido and Okinawa
func adjust_hokkaido_okinawa():
	var hokkaido = $JapanMap/"1HokkaidoBtn"
	hokkaido.scale = Vector2(0.87,0.87)
	hokkaido.position = Vector2(101, 70)
	
	var okinawa = $JapanMap/"47OkinawaBtn"
	okinawa.position = Vector2(100,50)
