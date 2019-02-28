extends "res://viewmodel.gd"

var reloading = false

func check_reloading():
	if reloading and mag >= max_mag or common.ammo_inventory[self_wep.ammo].amount <= 0:
		animki.play("reload_finish", 0, 1, false)
	elif reloading and mag < max_mag:
		load_shell()

func load_shell():
	animki.play("shell_load", 0, 1, false)
	next_fire = common.time + animki.current_animation_length/2
	mag += 1
	common.ammo_inventory[self_wep.ammo].amount -= 1

func start_reloading():
	if common.ammo_inventory.has(self_wep.ammo) and mag < max_mag and common.ammo_inventory[self_wep.ammo].amount > 0:
		animki.play("reload_start", 0, 1, false)
		next_fire = common.time + animki.current_animation_length
		reloading = true

func Reload():
	if common.ammo_inventory.has(self_wep.ammo) and common.ammo_inventory[self_wep.ammo].amount > 0:
		if mag == 0:
			if !reloading and animki != null:
				animki.play("reload_single1", 0, 1, false)
				mag += 1
				common.ammo_inventory[self_wep.ammo].amount -= 1
				next_fire = common.time + 0.85
		elif mag < max_mag and mag >= 1:
			start_reloading()

func SecondFire():
	
	reloading = false
	ply.ShootBullet( self.accuracy, 10 )
	
	ply.ViewPunch( 20 )
	ply.ShakeScreen( 0.2, 5 )
	
	animki.play("fire2", 0, 1, false)
	next_fire = common.time + animki.current_animation_length
	
	var m = preload("res://effects/dragonbreath_muzzle.tscn").instance()
	muzzle.add_child(m)

func Fire():
	reloading = false
	ply.ShootBullet( self.accuracy, self.bullet_num )
	ply.ViewPunch( self.view_punch )
		
	if animki != null:
		animki.play("fire", 0, 1, false)
		next_fire = common.time + delay
		
		reloading = false
			
		var m = common.muzzle2.instance()
		muzzle.add_child(m)
		mag -= 1
		
func OnHolster():
	reloading = false