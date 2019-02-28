extends StaticBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export(bool) var flamable = false
export(bool) var breakable = false
export(int) var health = 5
export(String) var chunks = "pot1"

export(bool) var useable = false
export(NodePath) var node_to_use = null
export(String) var func_to_call = "OnUse"

signal prop_on_break

func _ready():
	pass

export(String) var material = "concrete"

func OnUse(usr):
	if useable:
		get_node(node_to_use).call(func_to_call)

func MaterialType():
	return material

var broken = false

func TakeDamage(damage, attacker):
	if !breakable:
		return
	if health > 0:
		health -= damage
	elif health <= 0 or damage >= health:
		if !broken:
			broken = true
			common.util_chunks(self.global_transform.origin, self.rotation, chunks)
			emit_signal("prop_on_break")
			self.queue_free()

func BulletHit(damage, attacker, force):
	TakeDamage(damage, attacker)

func Ignite():
	if !flamable:
		return
	else:
		var fire = common.fire1.instance()
		self.add_child(fire)
	

#func _process(delta):
#	
#
