extends Control

#Will I ever need variables?
var map_name : String
var texture_file_path : String

func load_map_option(new_name : String) -> void:
	map_name = new_name
	$VBox/MapLabel.text = map_name
	texture_file_path = "res://maps/%s/%s_Map.png" % [map_name, map_name]
	if FileAccess.file_exists(texture_file_path):
		$VBox/MapImage.texture = load(texture_file_path)
		$VBox/MapImage.material = load("res://RainbowShaderMat.tres")
		$VBox/MapImage.material.set_shader_parameter("angle", 242.0)
	self.pressed.connect(Main.ROOT._switch_maps.bind(map_name))

func _choose_map() -> void:
	pass
