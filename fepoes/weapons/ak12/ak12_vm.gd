extends "res://viewmodel.gd"

var mags = false

var grenade = preload("res://weapons/ak12/grenade.tscn")

func grenade_fire():
	ply.ViewPunch( 5 )
	
	common.ammo_inventory[self_wep.secondary_ammo].amount -= 1
	
	var att = $Armature/Skeleton/att_muzzle/offset2
	
	var g = grenade.instance()
	sys.current_scene.add_child(g)
	g.global_transform = att.global_transform
	g.apply_impulse( Vector3(0,0,0), -self.global_transform.basis.z.normalized()*25 )

func SecondFire():
	animki.play("fire2", 0.1, 1, false)
	next_fire = common.time + animki.current_animation_length

func Fire():
	ply.ShootBullet( self.accuracy, self.bullet_num )
	ply.ViewPunch( self.view_punch )
	if animki != null:
		animki.play("fire", 0, 1, false)
		next_fire = common.time + delay
		
		var m = common.muzzle3.instance()
		muzzle.add_child(m)
		
		DropShell()
		mag -= 1
		#if mag <= 0 and coolreloading:
		#	DropLoad()
		#elif mag <= 0 and !coolreloading:
		#	Reload()

func Reload():
	if common.ammo_inventory.has(self_wep.ammo) and mag < max_mag and common.ammo_inventory[self_wep.ammo].amount > 0:
		
		if animki != null:
			if !mags:
				animki.play("reload", 0.1, 1, false)
			else:
				animki.play("reload_mags", 0.1, 1, false)
			mags = !mags
			next_fire = common.time + animki.current_animation_length
			
		if common.ammo_inventory[self_wep.ammo].amount >= (max_mag - mag):
			var magsub = max_mag - mag
			mag = mag + magsub
			common.ammo_inventory[self_wep.ammo].amount -= magsub
		elif common.ammo_inventory[self_wep.ammo].amount < (max_mag - mag):
			mag += common.ammo_inventory[self_wep.ammo].amount
			common.ammo_inventory[self_wep.ammo].amount = 0