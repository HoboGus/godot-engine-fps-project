extends "res://items/item_pickup.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var collision = null
var gun_owner = null
var empty = false

var muzzle = null
var shel = null

var time = 0

export(String) var shell = "9mm"
export(int) var dmg = 5
export(int) var number = 1
export(int) var spread = 5

export(NodePath) var mag = null

export(String) var weapon = "pp2000"

func _ready():
	if has_node("muzzle"):
		muzzle = $muzzle
	if has_node("muzzle/ray"):
		$muzzle/ray.set_enabled(false)
	if has_node("shell"):
		shel = $shell
	collision = $Area
	collision.connect("body_entered", self, "collided")
	#self.connect("body_entered", self, "hit")
	#collision.connect("body_exited", self, "uncollided")
	
	if empty:
		if mag != null:
			get_node(mag).hide()
	
	time = common.time + 10
	
	if gun_owner != null and gun_owner is common.NPC:
		self.mode = MODE_STATIC
	elif gun_owner == null:
		self.mode = MODE_RIGID

func MaterialType():
	return "metal"

func DropShell():
	if shel == null:
		return
	var shelll = common.shells[shell].s.instance()
	sys.current_scene.add_child(shelll)
	shelll.global_transform = shel.global_transform
	var randmul = rand_range(0.4, 0.5)
	shelll.apply_impulse( Vector3(0,0,0), Vector3(0, randmul/3, 0) + self.global_transform.basis.x.normalized()*randmul )
	shelll.rotate_y(deg2rad(rand_range(-40, 40)))
	shelll.rotate_z(deg2rad(rand_range(-40, 40)))

func ShootBullet():
	if muzzle == null:
		return
	var tr = $muzzle/ray
	tr.set_enabled(true)
	for i in range(number):
		tr.rotation_degrees = Vector3(0,0,0)
		tr.rotation_degrees.x = rand_range(-spread, spread)
		tr.rotation_degrees.y = rand_range(-spread, spread)
		tr.force_raycast_update()
		if tr.is_colliding():
			var ent = tr.get_collider()
			var dir = ent.global_transform.origin - tr.get_collision_point()
			
			common.util_trace($muzzle.global_transform.origin, tr.get_collision_point(), "trace1")
			
			if ent.has_method("TakeDamage"):
				ent.TakeDamage(dmg, gun_owner)
			
			if ent.has_method("BulletHit"):
				ent.BulletHit(dmg, gun_owner, dmg/3)
				
			if ent.get_class() == "RigidBody": 
				ent.apply_impulse(Vector3(0,0,0), -self.global_transform.basis.z.normalized()*(dmg/3))
				
			if ent.get_class() == "StaticBody" and !ent is common.HIT_BOX and !ent is common.PROP_STATIC:
				var hole = common.hole_scene.instance()
				sys.current_scene.add_child(hole)
				hole.look_at(tr.get_collision_normal()*15, Vector3(0,1,0) )
				hole.translation = tr.get_collision_point()
				
			if ent.has_method("MaterialType"):
				if ent.MaterialType() == "metal":
					common.util_hit(tr.get_collision_point(), tr.get_collision_normal(), "sparks")
				elif ent.MaterialType() == "blood":
					common.util_hit(tr.get_collision_point(), tr.get_collision_normal(), "blood")
				else:
					common.util_hit(tr.get_collision_point(), tr.get_collision_normal(), "dust")
			else:
				common.util_hit(tr.get_collision_point(), tr.get_collision_normal(), "dust")
	tr.set_enabled(false)

func UpdateState():
	if gun_owner != null and gun_owner is common.NPC:
		self.mode = MODE_STATIC
	elif gun_owner == null:
		self.mode = MODE_RIGID

func hit(body):
	
	if body.has_method("Stun"):
		var dir = linear_velocity.normalized()
		var forward = -body.global_transform.basis.z.normalized()
		
		var target_pos = body.global_transform.origin
		var pos = self.global_transform.origin
		var dir2 = (target_pos - pos).normalized()
		
		if ( linear_velocity.length() > 20 ) and dir2.dot(dir) >= cos(deg2rad(180/2)):
			body.Punch(dir, linear_velocity.length()/2)
			body.TakeDamage(15, self)
			body.Stun()
	

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
		"velocity_x": self.linear_velocity.x,
		"velocity_y": self.linear_velocity.y,
		"velocity_z": self.linear_velocity.z,
		"ang_vel_x" : self.angular_velocity.x,
		"ang_vel_y" : self.angular_velocity.y,
		"ang_vel_z" : self.angular_velocity.z,
		"is_empty" : self.empty
	}
	return save_dict

func Load(data):
	self.empty = bool(data["is_empty"])
	if empty:
		if mag != null:
			get_node(mag).hide()

func _process(delta):
	
	if time < common.time:
		if empty:
			self.queue_free()

func BulletHit(damage, attacker, force):
	if damage > 5 and gun_owner != null:
		gun_owner.DropWeapon()

func collided(ply):
	var wep = common.weapons[weapon]
	
	if ply is common.NPC:
		hit(ply)
		apply_impulse( Vector3(0,0,0), linear_velocity*-1 )
		return
	
	if !ply is common.PLAYER or gun_owner != null:
		return 
	if ply.HasWeapon(weapon):
		if weapon != null and ply.CanTakeAmmo(wep.ammo, wep.default_ammo) and not empty:
			if weapon == "pp2000" and ply.HasWeapon(weapon) and !ply.HasWeapon("dualpp2000"):
				ply.StoreWeapon("dualpp2000")
			elif weapon == "deagle" and ply.HasWeapon(weapon) and !ply.HasWeapon("akimbo_deagle"):
				ply.StoreWeapon("akimbo_deagle")
			else:
				ply.StoreWeapon(weapon)
			self.queue_free()
	else:
		ply.StoreWeapon(weapon)
		self.queue_free()
	