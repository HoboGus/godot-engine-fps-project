extends Spatial

var collision = null

export(String) var ammo = "rifle"
export(int) var amount = 15

func _ready():
	collision = $Area
	collision.connect("body_entered", self, "collided")
	#collision.connect("body_exited", self, "uncollided")
	pass

func Save():
	var save_dict = {
		"filename" : self.get_filename(),
		"name" : self.name,
		"parent" : self.get_parent().get_path(),
		"pos_x" : self.global_transform.origin.x, 
		"pos_y" : self.global_transform.origin.y, 
		"pos_z" : self.global_transform.origin.z, 
		"ang_x" : self.rotation.x,
		"ang_y" : self.rotation.y,
		"ang_z" : self.rotation.z,
		"tr_x" : self.translation.x,
		"tr_y" : self.translation.y,
		"tr_z" : self.translation.z,
		"ammo" : ammo,
		"amount" : amount
	}
	return save_dict

func Load(data):
	self.ammo = data["ammo"]
	self.amount = int(data["amount"])

func collided(body):
	if ammo != null and body is common.PLAYER and body.CanTakeAmmo(ammo, amount):
		body.GiveAmmo(ammo, amount)
		self.queue_free()
	