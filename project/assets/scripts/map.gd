### This is the map object that will contain properties for each map
### Map position, size, and backgrounds, and Scores position and size can be set here
class_name Map extends Resource

@export var map_name : String: 
	set(inspector_map_name):
		map_name = inspector_map_name
		load_tres()

@export var divisions : Array[String]

#Background elements
#By default, found in file res://maps/[Map name]/map_bg
@export var ROUTES : String = ""	#[map_name]_routes.png
@export var OUTLINE : String = ""	#[map_name]_outline.png
@export var NUMBERS : String = ""	#[map_name]_numbers.png

#Map position/size adjustments
@export var map_position : Vector2 = Vector2(0.0,0.0)	#position offset
@export var map_rotation : float = 0.0
@export var map_scale : float = 1.0	#size multiplier

#Scores position/size adjustments
@export var scores_size : Vector2 = Vector2(0.0,0.0)
@export var scores_position : Vector2 = Vector2(0.0,0.0)
@export var scores_scale : float = 1.0
@export var scores_horizontal : bool = true

func _init(config := {}):
	# Merge defaults with provided config
	for key in config.keys():
		if has_variable(key):
			self.set(key, config[key])
	

func load_tres() -> void:

	divisions = Maps.get_divisions_from_files(map_name)
	
	if map_scale <= 0.0:
		map_scale = 1.0
	if scores_scale <= 0.0:
		scores_scale = 1.0
	
	var map_folder : String = "res://maps/%s/map_bg/" % map_name
	var route_file : String = map_folder + "%s_routes.png" % map_name
	var outline_file : String = map_folder + "%s_outline.png" % map_name
	var numbers_file : String = map_folder + "%s_numbers.png" % map_name
	if(ResourceLoader.exists(route_file)):
		ROUTES = route_file
	if(ResourceLoader.exists(outline_file)):
		OUTLINE = outline_file
	if(ResourceLoader.exists(numbers_file)):
		print("numbers")
		NUMBERS = numbers_file
	else:
		print(numbers_file + " not found")

#func set_textures(texture_array: Array[String]):
	#if (ResourceLoader.exists(texture_array[0])):
		#ROUTES = load(texture_array[0])
	#
	#OUTLINE = load(texture_array[1])

# Helper to check if variable exists
func has_variable(var_name: String) -> bool:
	return var_name in self #.get_property_list().map(func(p): return p.name)
