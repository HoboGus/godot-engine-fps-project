extends Control

var menu = null
var ply
var save_game = null

func GetSaveName(sname):
	save_game.open("user://"+sname+".save", File.READ)
	while not save_game.eof_reached():
		
		var current_line = parse_json(save_game.get_line())
		if current_line["savename"] == null: 
			return "None"
		else:
			return current_line["savename"]

func _ready():
	save_game = File.new()
	if not save_game.file_exists("user://save1.save"):
		$breakshit1/Control/slot1.text = "Empty Slot 1"
		$breakshit1/Control/slot1.disabled = true
		$breakshit1/Control/slot1/delete.queue_free()
	else:
		$breakshit1/Control/slot1.text = "1. "+GetSaveName("save1")
		
	if not save_game.file_exists("user://save2.save"):
		$breakshit1/Control/slot2.text = "Empty Slot 2"
		$breakshit1/Control/slot2.disabled = true
		$breakshit1/Control/slot2/delete.queue_free()
	else:
		$breakshit1/Control/slot2.text = "2. "+GetSaveName("save2")
		
	if not save_game.file_exists("user://save3.save"):
		$breakshit1/Control/slot3.text = "Empty Slot 3"
		$breakshit1/Control/slot3.disabled = true
		$breakshit1/Control/slot3/delete.queue_free()
	else:
		$breakshit1/Control/slot3.text = "3. "+GetSaveName("save3")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func delete_save1():
	var dir = Directory.new()
	if dir.file_exists("user://save1.save"):
		dir.remove("user://save1.save")
		$breakshit1/Control/slot1.text = "Empty Slot 1"
		$breakshit1/Control/slot1.disabled = true
		$breakshit1/Control/slot1/delete.queue_free()

func _on_back_pressed():
	if menu != null:
		menu.show()
	queue_free()

func _on_slot1_pressed():
	common.LoadGame("save1")
	if menu != null and menu.has_method("_on_continue_pressed"):
		menu._on_continue_pressed()

func _on_slot2_pressed():
	common.LoadGame("save2")
	if menu != null and menu.has_method("_on_continue_pressed"):
		menu._on_continue_pressed()

func _on_slot3_pressed():
	common.LoadGame("save3")
	if menu != null and menu.has_method("_on_continue_pressed"):
		menu._on_continue_pressed()

func _on_quicksave_pressed():
	common.LoadGame("quicksave")
	if menu != null and menu.has_method("_on_continue_pressed"):
		menu._on_continue_pressed()

func delete_save2():
	var dir = Directory.new()
	if dir.file_exists("user://save2.save"):
		dir.remove("user://save2.save")
		$breakshit1/Control/slot2.text = "Empty Slot 2"
		$breakshit1/Control/slot2.disabled = true
		$breakshit1/Control/slot2/delete.queue_free()

func delete_save3():
	var dir = Directory.new()
	if dir.file_exists("user://save3.save"):
		dir.remove("user://save3.save")
		$breakshit1/Control/slot3.text = "Empty Slot 3"
		$breakshit1/Control/slot3.disabled = true
		$breakshit1/Control/slot3/delete.queue_free()
