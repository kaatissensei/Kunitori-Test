###This is a global script called with keyword "Maps"
extends Node

var JAPAN_MAP : Map
var japan_prefectures : Array[String]

var div_file_names : Array[String]

var US_MAP : Map
var us_states : Array[String]
var WORLD_MAP: Map
var world_regions : Array[String]

#var country_division : Array[String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_japan()
	#load_world()
	
	us_states = []
	
	#get_divisions_from_files("World")

	#country_division = []


# 
func get_map_division(country_name: String) -> Array[String]:
	match country_name:
		"Japan":
			if japan_prefectures.size() < 1:
				load_japan()
			return japan_prefectures
		_:
			return get_divisions_from_files(country_name)

#Get division names from res://maps/[map_name]/divisions
#Files must match begin with a number and end in a file type.
func get_divisions_from_files(map_name : String = "Japan") -> Array[String]:
	var regex = RegEx.new()
	#Capture everything between a number and space/_ and a . that starts the file type
	regex.compile("(?<=0?\\d[\\s|_])(?<div_name>.*?)(?=\\.)")
	var dir_name : String = "res://maps/%s/divisions/" % map_name
	var file_list = ResourceLoader.list_directory(dir_name)
	#var dir = DirAccess.open("res://maps/$s/divisions/" % map_name)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if dir.current_is_dir():
				#print("Found directory")
			#else:
				#print("Found file")
			#file_name = dir.get_next()
	#else:
		#print("Unable to access file path.")
	
	var division_list : Array[String]
	for div in file_list:
		division_list.push_back(regex.search(div).get_string("div_name").replace("_"," "))
		div_file_names.push_back(dir_name + div.get_file())
		
	return division_list
	

	
func load_japan():
	#%BG/Map.visible = false
	#%BG/MapBG.visible = false
	#%BG/JapanBG.visible = true
	#%BG/JapanMap.visible = true
	Main.current_map_name = "Japan"
	japan_prefectures.assign(["Hokkaido", "Aomori", "Iwate", "Miyagi", "Akita", "Yamagata", "Fukushima", 
		"Ibaraki", "Tochigi", "Gunma", "Saitama", "Chiba", "Tokyo", "Kanagawa",
		"Niigata", "Toyama", "Ishikawa", "Fukui", "Yamanashi", "Nagano", "Gifu", "Shizuoka", "Aichi",
		"Mie", "Shiga", "Kyoto", "Osaka", "Hyogo", "Nara", "Wakayama",
		"Tottori", "Shimane", "Okayama", "Hiroshima", "Yamaguchi",
		"Tokushima", "Kagawa", "Ehime", "Kochi",
		"Fukuoka", "Saga", "Nagasaki", "Kumamoto", "Oita", "Miyazaki", "Kagoshima", "Okinawa"])
	
