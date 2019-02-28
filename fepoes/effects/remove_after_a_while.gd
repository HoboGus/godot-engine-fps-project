extends Node

export(float) var delay = 30

var time = 0

func _ready():
	time = common.time + delay
	pass

func _process(delta):
	if time < common.time:
		self.queue_free()
