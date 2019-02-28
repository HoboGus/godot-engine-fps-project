extends RigidBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export(bool) var flamable = false
export(bool) var breakable = false
export(int) var health = 5
export(String) var chunks = "pot1"

func _ready():
	self.connect("body_entered", self, "collided")

export(String) var material = "concrete"

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
			self.queue_free()

func BulletHit(damage, attacker, force):
	TakeDamage(damage, attacker)

func Ignite():
	if !flamable:
		return
	else:
		var fire = common.fire1.instance()
		self.add_child(fire)

func collided(body):
	
	if body.has_method("TakeDamage"):
		var dir = linear_velocity.normalized()
		var forward = -body.global_transform.basis.z.normalized()
		
		var target_pos = body.global_transform.origin
		var pos = self.global_transform.origin
		var dir2 = (target_pos - pos).normalized()
		
		if ( linear_velocity.length() > 5 or angular_velocity.length() > 5 ) and dir2.dot(dir) >= cos(deg2rad(180/2)):
			body.TakeDamage(linear_velocity.length()*4, self)
	
	if body.has_method("Punch"):
		var dir = linear_velocity.normalized()
		var forward = -body.global_transform.basis.z.normalized()
		
		var target_pos = body.global_transform.origin
		var pos = self.global_transform.origin
		var dir2 = (target_pos - pos).normalized()
		
		if ( linear_velocity.length() > 5 or angular_velocity.length() > 5 ) and dir2.dot(dir) >= cos(deg2rad(180/2)):
			body.Punch(linear_velocity.normalized(), linear_velocity.length())
	

#func _process(delta):
#	
#
