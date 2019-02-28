extends Spatial

export(NodePath) var particles = null

export(float) var lifetime = 2

var time = 0

func _ready():
	
	time = common.time + lifetime
	
	for part in self.get_children():
		if part.get_class() == "Particles":
			part.one_shot = true
			part.emitting = true

func _process(delta):
	if time < common.time:
		self.queue_free()
