extends "res://items/item_pickup.gd"

export (int) var health = 0
export (String) var msg = ""

func _ready():
	$Area.connect("body_entered", self, "collided")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func collided(body):
	if body is common.PLAYER and common.health < 100:
		body.AddHealth(health)
		body.AddNotification(msg + " +" + String(health))
		queue_free()