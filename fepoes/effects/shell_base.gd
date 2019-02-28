extends RigidBody

export(float) var delay = 0

var time = 0

func _ready():
	time = common.time + delay
	pass

func _process(delta):
	if time < common.time:
		self.queue_free()
