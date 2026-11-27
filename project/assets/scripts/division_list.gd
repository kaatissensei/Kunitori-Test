### This code controls the popup list that appears in the bottom right.

extends HBoxContainer

var divisions

func _ready() -> void:
	#Grab the list from globals
	generate_list()

#Populate the list
func generate_list():
	if $DivList1.get_child_count() > 0:
		_reset_list()
	divisions = Main.divisions
	var div3 = ceil(divisions.size() / 3.0)
	for i in range(1, divisions.size()+1):
		var textbox = RichTextLabel.new()
		textbox.text = "%d. %s" % [i, divisions[i-1]]
		textbox.set_v_size_flags(3)
		textbox.scroll_active = false
		textbox.clip_contents = false
		
		#Put the divisions in one of 3 columns
		if i <= div3:
			%DivisionList.get_child(0).add_child(textbox)
		elif i <= 2 * div3:
			%DivisionList.get_child(1).add_child(textbox)
		else:
			%DivisionList.get_child(2).add_child(textbox)
		
	#Add extra to make even
	var blankbox = RichTextLabel.new()
	blankbox.text = ""
	blankbox.set_v_size_flags(3)
	blankbox.scroll_active = false
	%DivisionList.get_child(2).add_child(blankbox)

func _reset_list() -> void:
	for div1_entry in $DivList1.get_children():
		div1_entry.queue_free()
	for div2_entry in $DivList2.get_children():
		div2_entry.queue_free()
	for div3_entry in $DivList3.get_children():
		div3_entry.queue_free()

func _show_division_list() -> void:
	%DivisionList.get_parent().visible = true
	%DivListBtn.visible = false

func _hide_division_list():
	%DivisionList.get_parent().visible = false
	%DivListBtn.visible = true
