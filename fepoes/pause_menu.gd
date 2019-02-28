extends Control

var save_menu = preload("res://save_menu.tscn")
var load_menu = preload("res://load_menu.tscn")
var setting_menu = preload("res://settings_menu.tscn")
var s
var l
var ply

func _ready():
	pass

func to_mainmenu():
	get_tree().paused = false
	sys.goto_scene("res://menu.tscn")
	queue_free()


func _on_continue_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	queue_free()


func _on_save_pressed():
	self.hide()
	s = save_menu.instance()
	self.add_child(s)
	s.menu = self
	s.ply = ply

func _on_load_pressed():
	self.hide()
	l = load_menu.instance()
	self.add_child(l)
	l.menu = self
	l.ply = ply

func _on_settings_pressed():
	self.hide()
	l = setting_menu.instance()
	self.add_child(l)
	l.menu = self
	l.ply = ply
