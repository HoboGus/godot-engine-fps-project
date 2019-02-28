extends Control

var menu = null
var ply

func _ready():
	$breakshit/btns/fullscreen.pressed = OS.window_fullscreen

func _on_back_pressed():
	if menu != null:
		menu.show()
	queue_free()

func _on_fullscreen_toggled(button_pressed):
	OS.set_window_fullscreen(button_pressed)
	sys.settings.fullscreen = button_pressed
	sys.SaveConfig()
