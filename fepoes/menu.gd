extends Spatial

var load_menu = preload("res://load_menu.tscn")
var setting_menu = preload("res://settings_menu.tscn")

var l

var mouse_lag_x = 0
var mouse_lag_y = 0

var delay = 0

var camlerp = 1


func _ready():
	#print(common.Dice(10))
	delay = common.time + 2
	pass

func _process(delta):
	
	$fade.color = Color(0, 0, 0, camlerp)
	camlerp = lerp(camlerp, 0, 2*delta)
	
	#$rotator.rotate_y(0.3*delta)
	#$rotator.rotate_y((cos(2 * common.time)*0.0005))
	$rotator.rotate_x((cos(0.5 * common.time)*0.0005))
	$rotator.rotate_z((cos(2 * common.time)*0.0005))
	
	$rotator/Camera.rotate_x(-mouse_lag_x*0.5)
	$rotator/Camera.rotate_y(-mouse_lag_y*0.5)
	
	$rotator/Camera.translation.z = 2.5 + 15*camlerp
	$rotator/Camera.translation.y = 1 + 5*camlerp
	
	if Input.is_action_just_pressed("quickload"):
		common.LoadGame("quicksave")

func _on_Button_pressed():
	common.GameStartupVars()
	sys.goto_scene("res://wrld.tscn")

#func _input(event):
#	if event is InputEventMouseMotion and delay < common.time:
#		mouse_lag_y = ( (event.relative.x * 0.01) * 0.05)
#		mouse_lag_x = ( (event.relative.y * 0.01) * 0.05)

func _on_quit_pressed():
	get_tree().quit()


func _on_load_pressed():
	$cntr.hide()
	l = load_menu.instance()
	$cntr.add_child(l)
	l.menu = $cntr


func _on_settings_pressed():
	$cntr.hide()
	l = setting_menu.instance()
	$cntr.add_child(l)
	l.menu = $cntr
