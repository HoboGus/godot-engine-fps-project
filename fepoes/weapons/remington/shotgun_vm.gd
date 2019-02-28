extends "res://viewmodel.gd"

var reloading = false

func check_reloading():
	if reloading and mag >= max_mag or common.ammo_inventory[self_wep.ammo].amount <= 0:
		animki.play("reload_finish", 0, 1, false)
	elif reloading and mag < max_mag:
		load_shell()

func load_shell():
	animki.play("reload_load", 0.1, 1, false)
	next_fire = common.time + animki.current_animation_length/2
	mag += 1
	common.ammo_inventory[self_wep.ammo].amount -= 1

func Reload():
	if common.ammo_inventory.has(self_wep.ammo) and mag < max_mag and common.ammo_inventory[self_wep.ammo].amount > 0:
		
		if !reloading and animki != null:
			animki.play("reload_start", 0, 1, false)
			next_fire = common.time + animki.current_animation_length
			reloading = true
		elif reloading:
			load_shell()

func OnHolster():
	reloading = false

var combo = 0
var next_combo = 0

func Think():
	if next_combo < common.time:
		combo = 0

func CanSecondaryFire():
	return true

func SecondFire():
	reloading = false
	if combo == 0:
		animki.play("melee1", 0, 1, false)
		next_fire = common.time + 0.5
		next_combo = common.time + 0.8
		combo = 1
		ply.view_bob = -5
	elif combo == 1:
		animki.play("melee2", 0, 1, false)
		next_fire = common.time + 0.3
		next_combo = common.time + 0.8
		combo = 2
		ply.view_bob = 5
	elif combo == 2:
		animki.play("melee3", 0, 1, false)
		next_fire = common.time + 1
		next_combo = common.time + 2
		combo = 0
		ply.ViewKick(-5)

func do_kick(force, sideforce):
	
	var bodies = $Armature/Skeleton/att_muzzle/Area.get_overlapping_bodies()
	
	var dir = -ply.global_transform.basis.z.normalized()
	var sidedir = -ply.global_transform.basis.x.normalized()
	
	#var tr = ply.GetEyeTrace()
	#if tr[2].has_method("BulletHit"):
	#	tr[2].BulletHit(force*10, ply, force*10)
	
	for ent in bodies:
		if ent.has_method("Punch"):
			ent.Punch(dir, force*10)
			ent.TakeDamage(25, self)
			ply.ShakeScreen( 0.1, 20 )
		elif ent.get_class() == "RigidBody":
			if ent.has_method("TakeDamage"):
				ent.TakeDamage(25, self)
			ent.apply_impulse(dir, Vector3(0,1,0)*(force*0.7))
			ent.apply_impulse(dir, dir*force)
			ent.apply_impulse(dir, sidedir*sideforce)
			ply.ShakeScreen( 0.1, 20 )

func shot():
		ply.ShootBullet( self.accuracy, self.bullet_num )
		ply.ViewPunch( self.view_punch )
		next_fire = common.time + delay
		reloading = false
		var m = common.muzzle2.instance()
		muzzle.add_child(m)
		mag -= 1

func Fire():
	
	if combo == 2:
		animki.play("fire_onehand", 0, 1, false)
		next_fire = common.time + 1
		next_combo = common.time + 1
		combo = 0
		return
	
	if combo == 0:
		
		ply.ShootBullet( self.accuracy, self.bullet_num )
		ply.ViewPunch( self.view_punch )
		
		if animki != null:
			animki.play("fire", 0, 1, false)
			next_fire = common.time + delay
			
			reloading = false
			
			var m = common.muzzle2.instance()
			muzzle.add_child(m)
			mag -= 1
		
func Kick():
	next_fire = common.time + 0.5
	reloading = false
	if animki != null:
		animki.play("kick", 0.1, 1, false)