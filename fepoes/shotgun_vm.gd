extends "viewmodel.gd"

func _ready():
	animki = $AnimationPlayer
	weapon = "shotgun"
	x_mod = 1
	y_mod = -1
	z_mod = -5
	view_punch = 2
	accuracy = 1
	bullet_num = 1
	fov = 70

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
