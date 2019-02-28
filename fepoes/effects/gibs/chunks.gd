extends "res://effects/remove_after_a_while.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	for chunk in get_children():
		if chunk is RigidBody:
			chunk.apply_impulse(Vector3(0,0,0), common.VectorRandom()*10)
		elif chunk is Particles:
			chunk.one_shot = true
			chunk.emitting = true

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
