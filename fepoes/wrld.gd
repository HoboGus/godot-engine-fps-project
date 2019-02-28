extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	$ply.LevelStartNotification("Последний приход", 2, 4)
	sys.level_name = "Last Trip"

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
