extends "res://items/item_pickup.gd"

export (int) var armor = 0
export (bool) var bonus = false
export (String) var msg = ""

export (String) var material = "metal"

var ownr = null

func _ready():
	$Area.connect("body_entered", self, "collided")

func MaterialType():
	return material

var broken = false

func BulletHit(damage, attacker, force):
	if armor > 0:
		armor -= damage/2
	elif armor <= 0:
		if !broken:
			broken = true
			common.util_chunks(self.global_transform.origin, self.rotation, "armor1")
			self.queue_free()

#func _process(delta):
#	pass

func collided(body):
	if ownr != null:
		return
	if body is common.PLAYER:
		if bonus == false:
			if common.armor < armor:
				body.SetArmor(armor)
				body.AddNotification(msg + " +" + String(armor))
				queue_free()
		elif bonus:
			body.SetArmor(common.armor + armor)
			body.AddNotification(msg + " +" + String(armor))
			queue_free()
