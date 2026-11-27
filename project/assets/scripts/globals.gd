extends Node

var hex_Gray : String = "#737373" #was Color.DIM_GRAY
var hex_Red : String = "#E60000"
var hex_Blue : String = "#0000ff"
var hex_Yellow : String = "#ffff00"
var hex_Green : String = "#00af00"
var hex_Purple : String = "#a200ff"
var hex_Orange : String = "#ff8400" #was ff8a00
var hex_LBlue : String = "#00fff0"
var hex_Pink : String = "#ff00c6" #was fa6eff
var hex_LGreen : String = "#80ff00"
var hex_Navy : String = "#00004e"
var hex_Black : String = "#0a0a0a"
#var hex_Burgundy : String = "#910050" #too hard to say, no markers
#var hex_Brown : String = "#da3f00" #too similar to red/orange to some students

var teamColors = ["None", "Red", "Blue", "Yellow", "Green", "Purple", "Orange", "Light Blue", "Pink", "Light Green", "Navy"]
var hexColors = [hex_Gray, hex_Red, hex_Blue, hex_Yellow, hex_Green,
	hex_Purple, hex_Orange, hex_LBlue, hex_Pink, hex_LGreen, hex_Navy]

var COLORS : Array[Color]= [Color.html(hex_Gray), Color.html(hex_Red), Color.html(hex_Blue), 
Color.html(hex_Yellow), Color.html(hex_Green), Color.html(hex_Purple), Color.html(hex_Orange), 
Color.html(hex_LBlue), Color.html(hex_Pink), Color.html(hex_LGreen), Color.html(hex_Navy)]

var ROOT : Node
#var map_rotation : float = 27.2 #default to Japan map rotation
var divisions : Array[String]
var DIV_BTN = preload("res://division_button.tscn")
var default_div_color : Color = Color.DIM_GRAY #The color an uncaptured division will be
var num_teams : int = 8
var max_teams : int = 10
var team10_color : String = "Navy"

var scores : Array[int]
var num_attacks : Array[int]
var num_battles : Array[int]
var num_battles_won : Array[int]

var selected_division : Node
var selected_div_color : int
var selected_div_num : int
var div_colors : Array[int]

var paused : bool = false

var current_map_name : String
var current_map : Map

var map_options : Array[String]		#Array of Map names to load in menu

var num_divisions : int = 47	#default to Japan

func _ready() -> void:
	set_divisions()
	scores.resize(max_teams)
	scores.fill(0)
	div_colors.resize(divisions.size())
	div_colors.fill(0)
	num_attacks.resize(max_teams)
	num_attacks.fill(0)
	num_battles.resize(max_teams)
	num_battles.fill(0)
	num_battles_won.resize(max_teams)
	num_battles_won.fill(0)
	set_map_options()

func set_num_teams(new_num_teams):
	num_teams = new_num_teams
		
func set_team10_color(newColor : String):
	team10_color = newColor
	var new_hex : String = "#0"
	if (newColor == "Black"):
		new_hex = hex_Black
	else:
		new_hex = hex_Navy
		
	teamColors.pop_back()
	teamColors.push_back(team10_color)
	#print(teamColors)
	hexColors.pop_back()
	hexColors.push_back(new_hex)
	#print(hexColors)
	COLORS.pop_back()
	COLORS.push_back(Color.html(new_hex))

#Record who first attacked
func record_attack(attacker_num: int):
	num_attacks[attacker_num-1] += 1

#Record how many battles each team was in
func record_battle(team1: int, team2: int):
	num_battles[team1-1] += 1
	num_battles[team2-1] += 2

#Record number of wins in battle
func record_battle_winner(team_num: int):
	num_battles_won[team_num-1] += 1

func get_division_name(division_num: int):
	return divisions[division_num - 1]

#Get list of divisions of chosen map (prefectures, states, etc.)
func set_divisions(map_name: String = "Japan"):
	current_map_name = map_name
	var new_div = Maps.get_map_division(map_name)
	divisions.clear()
	divisions.assign(new_div)
	num_divisions = divisions.size()

#Select a division to be taken/colored
func select_division(division :Node):
	selected_division = division
	selected_div_num = int(division.name)
	#print(division.name)
	selected_div_color = div_colors[selected_div_num-1]

func set_color(div_num: int, team_num: int):
	div_colors[div_num - 1] = team_num

func get_bbColor(team_num: int):
	var team_color_hex : String = hexColors[team_num]
	var team_color : String = teamColors[team_num]
	if (team_color == "Navy" or team_color == "Black"):
		return "[color=%s][outline_color=white]%s[/outline_color][/color]" % [team_color_hex, team_color]
	else:
		return "[color=%s]%s[/color]" % [team_color_hex, team_color]

func set_map_options():
	map_options = ["Japan", "World", "US"]

func pause():
	return !paused

func fullscreen():
	var mode := DisplayServer.window_get_mode()
	var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
