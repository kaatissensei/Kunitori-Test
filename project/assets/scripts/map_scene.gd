extends Node2D

@onready var ATTACK_TIMER = $AttackTimer
@onready var COLOR_WHEEL : Control = %ColorPickerWheel

var fade_wait : float = 1.0
var fade_duration : float = 1.0
var tween
var max_teams : int = 10

var default_width : float = 830
var default_full_width : float = 1000
	
#For tracking attacker and defender during an attack
var attacker_num : int = 0
var defender_num : int = 0

func _ready() -> void:
	Main.ROOT = self
	Main.current_map = load("res://maps/Japan/Japan_Map.tres")
	#Set up color wheel
	COLOR_WHEEL.change_color.connect(change_color)
	COLOR_WHEEL.visible = false
	update_scores()
	#Set up signal to select division
	%BG.select_div.connect(_select_division)

func _select_division(div_num :int) -> void:
	#var div_name : String
	var division : Node
	if (Main.current_map_name == "Japan"):
		division = %JapanMap.get_child(div_num - 1)
	else:
		division = %Map.get_child(div_num - 1)
	
	if (!Main.paused):
		Main.paused = true
		Main.select_division(division)
		#Highlight selected division
		var highlight_shader = ShaderMaterial.new()
		highlight_shader.shader = load("res://glow.gdshader")
		division.set_material(highlight_shader)
		
		#Highlight score buttons and wait for color selection
		COLOR_WHEEL.visible = true
		COLOR_WHEEL.position = get_local_mouse_position()
		COLOR_WHEEL.z_index = 100
		
		#print(Main.get_division_name(div_num))

func change_color(team_num :int):
	var pref = Main.selected_division
	var div_num = int(pref.name)
	var div_name = pref.name.replace("Btn", "").substr(str(div_num).length())
	var old_team = 0
	
	if (Main.div_colors[div_num - 1] == 0): #If pref has no color
		var div_color = Main.div_colors[div_num-1]
		#If same color is chosen, turn gray
		if team_num == div_color:
			team_num = 0
		pref.material = null
		pref.self_modulate = Main.COLORS[team_num]
		
		Main.scores[team_num - 1] += 1
		#print("Team Num: %s" % team_num)
		%Announcement.text = "%s takes %s (%d)" % [Main.get_bbColor(team_num), div_name, div_num]
		%Announcement.announce()
		#print("Team %d takes %s!" % [team_num, div_name])
	elif (Main.div_colors[div_num-1] == team_num):
		#Turn back to gray
		old_team = Main.div_colors[div_num-1]
		team_num = 0
		pref.material = null
		pref.self_modulate = Main.COLORS[0]
		Main.scores[old_team-1] -= 1
	elif (Main.div_colors[div_num-1] != team_num): #Confirm not selecting same color
		old_team = Main.div_colors[div_num-1]
		_ready_attack(old_team, team_num)

		#print("Team %d takes %s from Team %d" % [team_num, div_name, old_team])
	##Display message
	else:
		pass
		#print(Main.div_colors)
	
	Main.set_color(div_num, team_num)
	update_scores()

func update_scores():
	for i in range(Main.max_teams):
		%ScoreGrid.get_child(i).get_child(0).text = "%d" % Main.scores[i]

func _open_reset_confirmation():
	%ResetConfirmation.visible = true
func _close_reset_confirmation():
	%ResetConfirmation.visible = false

func _reset_colors():
	var default_color : Color = Main.default_div_color
	for btn in get_tree().get_nodes_in_group("division_buttons"):
		btn.self_modulate = default_color
	Main.div_colors.fill(0)
	Main.scores.fill(0)
	update_scores()
	_close_reset_confirmation()

func _fullscreen():
	Main.fullscreen()

func _change_num_teams(number: int) -> void:
	Main.set_num_teams(number)
	var curr_map = Main.current_map
	#Change size if more than 8 teams
	if number <= 8:
		if (curr_map.scores_horizontal):
			%ScoreGrid.columns = 4
			%Scores.size = Vector2(default_width, curr_map.scores_size.y)
		else:
			%Scores.size = Vector2(curr_map.scores_size.x, default_width)
			%Scores.position = curr_map.scores_position
	else: #9-10
		if (Main.current_map.scores_horizontal):
			%ScoreGrid.columns = 5
			%Scores.size.x = default_full_width
		else:
			%Scores.size = Vector2(curr_map.scores_size.x, default_full_width)
			%Scores.position.y = curr_map.scores_position.y - (default_full_width - default_width)
	
	#Make splats visible
	for i in range(1, max_teams):
		if i < Main.num_teams:
			%ScoreGrid.get_child(i).visible = true
		else:
			%ScoreGrid.get_child(i).visible = false
	
	#Wait a frame, then adjust Grid
	await get_tree().process_frame
	%ScoreGrid.size = %ScoreGrid.get_parent_area_size() #/ curr_map.scores_scale
	%ScoreGrid.position = Vector2.ZERO
	
	%Team10ColorPicker.visible = number == 10
	%Team10Buffer.visible = number == 10

###WIP
func _switch_maps(new_map_name: String):
	var map_folder = "res://maps/%s/" % new_map_name
	var is_japan : bool = new_map_name == "Japan"

	%Map.visible = !is_japan
	%MapBG.visible = !is_japan
	%JapanBG.visible = is_japan
	%JapanMap.visible = is_japan
	
	if (!is_japan):
		#Get map object
		Main.current_map_name = new_map_name
		var file_path = map_folder + "%s_Map.tres" % new_map_name
		var new_map : Map = load(file_path)
		Main.current_map = new_map
		#Set map backgrounds
		if new_map.ROUTES:
			%MapBG/Routes.texture = load(new_map.ROUTES)
		if new_map.OUTLINE:
			%MapBG/Outline.texture = load(new_map.OUTLINE)
		if new_map.NUMBERS:
			%MapBG/Numbers.texture = load(new_map.NUMBERS)
		else:
			%MapBG/Numbers.texture = null
		#Set divisions (not Japan)------------
		%BG._load_map(new_map_name)

		for div in %JapanMap.get_children():
			div.queue_free()
		
		#Create list for bottom right button
		%DivisionList.generate_list()
		
		#Set Scores placement
		move_scores(new_map)
		_start_game()

func move_scores(map : Map):
	if map.scores_horizontal:
		if Main.num_teams > 8:
			%ScoreGrid.columns = 5
		else:
			%ScoreGrid.columns = 4
	else:
		%ScoreGrid.columns = 2
		
	%Scores.position = map.scores_position
	%Scores.size = map.scores_size
	%Scores.scale = Vector2.ONE * map.scores_scale
	#var new_y = default_full_width if (Main.num_teams > 8) else default_width
	#%ScoreGrid.size = Vector2(map.scores_size.x / map.scores_scale, new_y)
	await get_tree().process_frame
	%ScoreGrid.size = %ScoreGrid.get_parent_area_size()
	%ScoreGrid.set_position(Vector2.ZERO)
	

func _show_settings() -> void:
	%Settings.visible = true

func _hide_settings() -> void:
	%Settings.visible = false


func _start_game() -> void:
	%MainMenu.visible = false
	%Settings.visible = true

###------------------Attack Code--------------------------\
func _ready_attack(def_num: int, atk_num: int) -> void:
	defender_num = def_num	#Numbers 1-10
	attacker_num = atk_num	#Numbers 1-10
	
	Main.record_battle(defender_num, attacker_num)
	Main.record_attack(attacker_num)
	
		#%AttackOverlay##%AttackBtn#%AttackBtn#%InklingL#%InklingR
	for node in get_tree().get_nodes_in_group("attackBtns"):
		node.visible = true
	
	%InklingLeftColor.self_modulate = Main.COLORS[attacker_num]
	%InklingLeft.position.x = -600
	%InklingRightColor.self_modulate = Main.COLORS[defender_num]
	%InklingRight.position.x = 250
	%AttackAnnouncement.text = "%s attacks %s!" % [Main.get_bbColor(attacker_num), Main.get_bbColor(defender_num)]

func is_attack_successful():
	return randf() < 0.5

func _attack() -> void:
	if is_attack_successful():
		#Briefly change attackBtn to OK
		select_victor(attacker_num)
		Main.record_battle_winner(attacker_num)
	else:
		#Briefly change attackBtn to No
		select_victor(defender_num)
		Main.record_battle_winner(defender_num)

func _right_wins():
	select_victor(defender_num)
func _left_wins():
	select_victor(attacker_num)

func select_victor(winner_num: int):
	var pref = Main.selected_division
	var div_num = Main.selected_div_num
	var div_name = Main.get_division_name(div_num)
	
	await play_attack_animation(winner_num == attacker_num)
	
	%AttackOverlay.visible = false
	
	Main.div_colors[div_num - 1] = winner_num
	
	#Check if winner was attacker (or defender)
	if winner_num == attacker_num:
		#Change pref color
		pref.material = null
		pref.self_modulate = Main.COLORS[winner_num]
		
		#Set value in div_colors
		Main.div_colors[div_num-1] = winner_num
		#Subtract 1pt from former team
		Main.scores[defender_num - 1] -= 1
		Main.scores[winner_num - 1] += 1
		update_scores()
		
		%Announcement.text = "%s takes %s (%d) from %s" % [Main.get_bbColor(winner_num), div_name, div_num,
		Main.get_bbColor(defender_num)]
		%Announcement.announce()
		
	else:
		pref.material = null
		%Announcement.text = "%s keeps %s (%d)!" % [Main.get_bbColor(defender_num), div_name, div_num]
		%Announcement.announce()

func play_attack_animation(left_wins: bool):
	if tween:
		tween.kill()
		
	tween = %AttackOverlay.create_tween().set_parallel(true)
	var time : float = 0.5
	var winner_text : String
	
	#Move Inklings back
	%AttackBtn.get_parent().visible = false
	tween.tween_property(%InklingLeft, "position:x", -800,time).from(-600)
	#tween.set_parallel()
	tween.parallel().tween_property(%InklingRight, "position:x", 450,time).from(250)
	#tween.kill()
	
	#Inklings rush towards each other
	#tween = get_tree().create_tween()
	tween.chain().tween_property(%InklingLeft, "position:x", -170,time * 0.8)
	#tween.set_parallel()
	tween.parallel().tween_property(%InklingRight, "position:x", -170,time * 0.8)
	await run_attack_timer(time * 1.7)
	#tween.tween_interval(1.7)
	#tween.kill()
	
	if left_wins:
		winner_text = Main.get_bbColor(attacker_num)
		%InklingRightColor.get_parent().visible = false
	else:
		winner_text = Main.get_bbColor(defender_num)
		%InklingLeftColor.get_parent().visible = false
	
	%AttackAnnouncement.text = "%s wins!" % winner_text
		
	await run_attack_timer(1.2)
	
	if tween and tween.is_valid():
		tween.kill()

func run_attack_timer(new_wait_time: float):
	ATTACK_TIMER.wait_time = new_wait_time
	ATTACK_TIMER.start()
	await ATTACK_TIMER.timeout

func _on_credits_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _change_team10_color(new_10_color: String) -> void:
	Main.set_team10_color(new_10_color)
	
	%NavyScore.self_modulate = Main.COLORS[10]
	%NavyBtn.use_parent_material = (new_10_color !="Navy")
	%BlackBtn.use_parent_material = (new_10_color !="Black")
