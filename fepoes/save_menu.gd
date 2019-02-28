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
	else:
		$breakshit1/Control/slot1.text = "1. "+GetSaveName("save1")
		
	if not save_game.file_exists("user://save2.save"):
		$breakshit1/Control/slot2.text = "Empty Slot 2"
	else:
		$breakshit1/Control/slot2.text = "2. "+GetSaveName("save2")
		
	if not save_game.file_exists("user://save3.save"):
		$breakshit1/Control/slot3.text = "Empty Slot 3"
	else:
		$breakshit1/Control/slot3.text = "3. "+GetSaveName("save3")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_back_pressed():
	if menu != null:
		menu.show()
	queue_free()

func SaveSlot(slot):
	common.SaveGame("save"+String(slot))
	if menu != null:
		menu.show()
	ply.AddNotification("Game Saved")
	queue_free()

func _on_slot1_pressed():
	SaveSlot(1)

func _on_slot2_pressed():
	SaveSlot(2)

func _on_slot3_pressed():
	SaveSlot(3)
