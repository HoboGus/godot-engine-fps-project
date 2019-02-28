extends Node

var loader
var wait_frames
var time_max = 100 # msec
var current_scene

var saveload = false
var savename = ""

var progress = 0

var loading = false

var loading_screen = preload("res://loading_screen.tscn")

var level_name = "None"

var ai_disabled = false

#shit is stored in settings.cfg file and loaded on startup
var settings = {
	fullscreen = false
}

func SaveConfig():
	var cfg = File.new()
	cfg.open("user://settings.cfg", File.WRITE)
	cfg.store_var(settings)
	cfg.close()

func LoadConfig():
	var cfg = File.new()
	cfg.open("user://settings.cfg", File.READ)
	
	if not cfg.file_exists("user://settings.cfg"):
		SaveConfig()
		return
	else:
		settings = cfg.get_var()

func _ready():
	LoadConfig()
	
	var root = get_tree().get_root()
	current_scene = get_tree().get_current_scene()
	
	if OS.window_fullscreen != settings.fullscreen:
		OS.window_fullscreen = settings.fullscreen
	

func _process(delta):
	if loader == null:
		set_process(false)
		return
	if wait_frames > 0:
		wait_frames -= 1
		return
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else:
			loader = null
			break
			
func update_progress():
	progress = float(loader.get_stage()) / loader.get_stage_count()

func set_new_scene(scene_resource):
	
	Engine.set_time_scale(1.0)
	loading = false
	
	common.time = 0
	
	current_scene.free()
	current_scene = scene_resource.instance()
	current_scene.name = "lvl"
	get_node("/root").add_child(current_scene)
	
	if saveload:
		common.LoadNodes(savename)
	
func goto_scene_load(path, sname):
	
	var w = loading_screen.instance()
	current_scene.add_child(w)
	
	loader = ResourceLoader.load_interactive(path)
	saveload = true
	loading = true
	progress = 0
	savename = sname
	if loader == null:
		return
	set_process(true)
	
	wait_frames = 1

func goto_scene(path):
	
	var w = loading_screen.instance()
	current_scene.add_child(w)
	
	loader = ResourceLoader.load_interactive(path)
	saveload = false
	loading = true
	progress = 0
	if loader == null:
		return
	set_process(true)
	
	wait_frames = 1