extends RigidBody

var explode = preload("res://weapons/explosion.tscn")

func _ready():
	self.connect("body_entered", self, "hit")

func hit(body):
	var e = explode.instance()
	sys.current_scene.add_child(e)
	e.global_transform = self.global_transform
	self.queue_free()
