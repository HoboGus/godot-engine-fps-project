extends "res://viewmodel.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

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

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func DropShell2():
	var shelll = common.shells[shell].s.instance()
	get_tree().get_root().add_child(shelll)
	shelll.global_transform = attshell2.global_transform
	var randmul = rand_range(0.5, 0.7)
	shelll.apply_impulse( Vector3(0,0,0), Vector3(0, randmul/3, 0) + self.global_transform.basis.x.normalized()*randmul )
	shelll.rotate_y(deg2rad(rand_range(-40, 40)))
	shelll.rotate_z(deg2rad(rand_range(-40, 40)))

func throw_gun2():
	if self_wep.wm != null:
		var drop = self_wep.wm.instance()
		drop.empty = true
		sys.current_scene.add_child(drop)
		drop.global_transform = $Armature/Skeleton/att_hand2/offset.global_transform
		drop.apply_impulse( Vector3(0,0,0), -self.global_transform.basis.z*35 )

func DropGun(empty, dir):
	if self_wep.wm != null:
		var drop = self_wep.wm.instance()
		drop.empty = empty
		get_tree().get_root().add_child(drop)
		drop.global_transform = attshell.global_transform
		drop.apply_impulse( Vector3(0,0,0), dir.normalized()*7 )
		
		drop = self_wep.wm.instance()
		drop.empty = empty
		get_tree().get_root().add_child(drop)
		drop.global_transform = attshell2.global_transform
		drop.apply_impulse( Vector3(0,0,0), -dir.normalized()*7 )

func DropLoad():
	if common.ammo_inventory.has(self_wep.ammo) and common.ammo_inventory[self_wep.ammo].amount > max_mag:
		if animki != null:
			animki.play("reload_cool1", 0.1, 1, false)
			mag = max_mag
			common.ammo_inventory[self_wep.ammo].amount -= max_mag
			next_fire = common.time + animki.current_animation_length
			var droptimer = get_tree().create_timer(0.2, true)
			droptimer.connect("timeout", self, "droptimergay")

var left = true

func FireCallback(ent, tr):
	if left:
		common.util_trace(muzzle2.global_transform.origin, tr.get_collision_point(), "trace1")
	else:
		common.util_trace(muzzle.global_transform.origin, tr.get_collision_point(), "trace1")

func Fire():
	ply.ShootBullet( self.accuracy, self.bullet_num )
	ply.ViewPunch( self.view_punch )
	if animki != null:
		left = !left
		if left:
			animki.play("fire", 0, 1, false)
			next_fire = common.time + delay
			
			var m = common.muzzle1.instance()
			muzzle.add_child(m)
			
			DropShell()
		else:
			animki.play("fire2", 0, 1, false)
			next_fire = common.time + delay
			
			var m = common.muzzle1.instance()
			muzzle2.add_child(m)
			
			DropShell2()
		
		mag -= 1
		if mag <= 0:
			DropLoad()