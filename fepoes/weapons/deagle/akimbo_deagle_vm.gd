extends "res://viewmodel.gd"

var muzzle2 = null
var attshell2 = null

func _ready():
	hide()	#little hack to prevent flickering
	if can_fire and bullet_num > 0:
		attshell = $Armature/Skeleton/att_shell/offset
		muzzle = $Armature/Skeleton/att_muzzle/offset
		attshell2 = $Armature/Skeleton/att_shell2/offset
		muzzle2 = $Armature/Skeleton/att_muzzle2/offset
	
	ply = self.get_parent().get_parent().get_parent().get_parent()
	
	if weapon != null:
		self_wep = common.weapons[weapon]
	if anim != null:
		animki = get_node(anim)

func Deploy():
	if animki != null:
		if common.has_deagles:
			animki.play("deploy", 0.1, 1, false)
		else:
			animki.play("deploy_firsttime", 0.1, 1, false)
			common.has_deagles = true
		next_fire = common.time + animki.current_animation_length
		mag = common.GetMagData(weapon)

func DropShell():
	var shelll = common.shells[shell].s.instance()
	sys.current_scene.add_child(shelll)
	shelll.global_transform = attshell.global_transform
	var randmul = rand_range(0.5, 0.7)
	shelll.apply_impulse( Vector3(0,0,0), self.global_transform.basis.y.normalized()*randmul*0.8 )
	shelll.rotate_y(deg2rad(rand_range(-40, 40)))
	shelll.rotate_z(deg2rad(rand_range(-40, 40)))

func DropShell2():
	var shelll = common.shells[shell].s.instance()
	get_tree().get_root().add_child(shelll)
	shelll.global_transform = attshell2.global_transform
	var randmul = rand_range(0.5, 0.7)
	shelll.apply_impulse( Vector3(0,0,0), self.global_transform.basis.y.normalized()*randmul*0.8 )
	shelll.rotate_y(deg2rad(rand_range(-40, 40)))
	shelll.rotate_z(deg2rad(rand_range(-40, 40)))

var left = false

func FireCallback(ent, tr):
	if left:
		common.util_trace(muzzle2.global_transform.origin, tr.get_collision_point(), "trace1")
	else:
		common.util_trace(muzzle.global_transform.origin, tr.get_collision_point(), "trace1")

func CanSecondaryFire():
	return true

func FireLeft():
	left = true
	
	ply.ShootBullet( self.accuracy, self.bullet_num )
	ply.ViewPunch( self.view_punch )
	
	var m = common.muzzle1.instance()
	muzzle2.add_child(m)
	$fire.play()
	DropShell2()
	
	mag -= 1

func FireRight():
	left = false
	
	ply.ShootBullet( self.accuracy, self.bullet_num )
	ply.ViewPunch( self.view_punch )
	
	var m = common.muzzle1.instance()
	muzzle.add_child(m)
	$fire2.play()
	DropShell()
	
	mag -= 1

var combo = 0
var next_combo = 0

func Think():
	if next_combo < common.time:
		combo = 0

func do_kick():
	
	var bodies = $Armature/Skeleton/att_muzzle/Area.get_overlapping_bodies()
	
	var dir = -ply.global_transform.basis.z.normalized()
	var sidedir = -ply.global_transform.basis.x.normalized()
	
	for ent in bodies:
		if ent.has_method("Punch"):
			ent.Punch(dir, 10)
			ent.TakeDamage(15, self)
		elif ent.get_class() == "RigidBody":
			if ent.has_method("TakeDamage"):
				ent.TakeDamage(15, self)
			ent.apply_impulse(dir, Vector3(0,1,0)*(4*0.7))
			ent.apply_impulse(dir, dir*5)

func do_kick2():
	
	var bodies = $Armature/Skeleton/att_muzzle2/Area.get_overlapping_bodies()
	
	var dir = -ply.global_transform.basis.z.normalized()
	var sidedir = -ply.global_transform.basis.x.normalized()
	
	for ent in bodies:
		if ent.has_method("Punch"):
			ent.Punch(dir, 10)
			ent.TakeDamage(15, self)
		elif ent.get_class() == "RigidBody":
			if ent.has_method("TakeDamage"):
				ent.TakeDamage(15, self)
			ent.apply_impulse(dir, Vector3(0,1,0)*(4*0.7))
			ent.apply_impulse(dir, dir*5)

func SecondFire():
	if combo == 0 or combo == 4:
		animki.play("gunkata1", 0, 1, false)
		next_fire = common.time + 0.3
		next_combo = common.time + 0.6
		combo = 1
		ply.ViewKick(-3)
		#ply.view_bob = -5
	elif combo == 1:
		animki.play("gunkata6", 0, 1, false)
		next_fire = common.time + 0.15
		next_combo = common.time + 0.4
		combo = 2
		ply.ViewKick(-3)
		#ply.view_bob = -5
	elif combo == 2:
		animki.play("gunkata3", 0, 1, false)
		next_fire = common.time + 0.25
		next_combo = common.time + 0.6
		combo = 3
		ply.ViewKick(-3)
		#ply.view_bob = -5

func Fire():
	if combo == 1:
		animki.play("gunkata2", 0, 1, false)
		next_fire = common.time + 0.2
		next_combo = common.time + 0.4
		combo = 2
		return
	elif combo == 3:
		animki.play("gunkata4", 0, 1, false)
		next_fire = common.time + 0.2
		next_combo = common.time + 0.5
		combo = 4
		return
	elif combo == 2:
		animki.play("gunkata7", 0, 1, false)
		next_fire = common.time + 0.4
		next_combo = common.time + 0.6
		combo = 0
		return
	elif combo == 4:
		animki.play("gunkata5", 0, 1, false)
		next_fire = common.time + 0.4
		next_combo = common.time + 0.6
		combo = 0
		return
	ply.ShootBullet( self.accuracy, self.bullet_num )
	ply.ViewPunch( self.view_punch )
	if animki != null:
		left = !left
		if left:
			if mag <= 2:
				animki.play("fire_1_empty", 0, 1, false)
			else:
				animki.play("fire_1", 0, 1, false)
			next_fire = common.time + delay
			
			var m = common.muzzle1.instance()
			muzzle.add_child(m)
			
			DropShell()
		else:
			if mag <= 1:
				animki.play("fire_2_empty", 0, 1, false)
			else:
				animki.play("fire_2", 0, 1, false)
			next_fire = common.time + delay
			
			var m = common.muzzle1.instance()
			muzzle2.add_child(m)
			
			DropShell2()
	mag -= 1
