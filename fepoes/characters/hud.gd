extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var ply = null
var menu_scene = preload("res://pause_menu.tscn")
var m = null

func _ready():
	ply = get_parent()
	

func deploy_menu():
	m = menu_scene.instance()
	get_tree().get_root().add_child(m)
	m.ply = ply

func _process(delta):
	if !get_tree().paused:
		if Input.is_action_just_pressed("quicksave"):
			common.SaveGame("quicksave")
			ply.AddNotification("Quicksaving...")
		if Input.is_action_just_pressed("quickload"):
			ply.LevelStartNotification("", 0, 0)
			common.LoadGame("quicksave")
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
			if m != null:
				m.queue_free()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = true
			deploy_menu()
