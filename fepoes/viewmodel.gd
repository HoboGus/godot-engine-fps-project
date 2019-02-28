extends Spatial

export(NodePath) var anim

export(String) var weapon = null

export(String) var shell = "9mm"

export(int) var damage = 10
export(int) var force = 5

export(float) var x_mod = 0
export(float) var y_mod = -0.3
export(float) var z_mod = 0.3
export var fov = 35

export var can_fire = true

export var automatic = false
export(float) var delay = 1.2

export(bool) var coolreloading = false

export(float) var view_punch = 8
export(float) var accuracy = 1
export(float) var bullet_num = 1

export(float) var gunlag = 0.2

export var max_mag = 20
var mag = 0

var animki = null

var deploytime = 0

var self_wep = null

var next_fire = 0
var next_sec_fire = 0

var attshell = null
var muzzle = null

var ply = null

func _ready():
	hide()	#little hack to prevent flickering
	if can_fire and bullet_num > 0:
		attshell = $Armature/Skeleton/att_shell/offset
		muzzle = $Armature/Skeleton/att_muzzle/offset
	
	if weapon != null:
		self_wep = common.weapons[weapon]
	if anim != null:
		animki = get_node(anim)

func Think():
	pass
	#do shit

func _process(delta):
	Think()
	if deploytime < 5:
		deploytime += 1
	if deploytime == 5:
		show()
		deploytime = 6

func DropShell():
	var shelll = common.shells[shell].s.instance()
	sys.current_scene.add_child(shelll)
	shelll.global_transform = attshell.global_transform
	var randmul = rand_range(0.5, 0.7)
	shelll.apply_impulse( Vector3(0,0,0), Vector3(0, randmul/3, 0) + self.global_transform.basis.x.normalized()*randmul )
	shelll.rotate_y(deg2rad(rand_range(-40, 40)))
	shelll.rotate_z(deg2rad(rand_range(-40, 40)))

func CanFire():
	if next_fire > common.time or mag <= 0:
		return false
	else:
		return true

func CanSecondaryFire():
	if next_sec_fire > common.time or !common.ammo_inventory.has(self_wep.secondary_ammo) or common.ammo_inventory[self_wep.secondary_ammo].amount <= 0:
		return false
	else:
		return true

func DropGun(empty, dir):
	if self_wep.wm != null:
		var drop = self_wep.wm.instance()
		drop.empty = empty
		sys.current_scene.add_child(drop)
		drop.global_transform = attshell.global_transform
		drop.apply_impulse( Vector3(0,0,0), dir.normalized()*7 )

func throw_gun():
	if self_wep.wm != null:
		var drop = self_wep.wm.instance()
		drop.empty = true
		sys.current_scene.add_child(drop)
		drop.global_transform = $Armature/Skeleton/att_hand/offset.global_transform
		drop.apply_impulse( Vector3(0,0,0), -self.global_transform.basis.z*35 )
		ply.ViewKick(-5)

func Deploy():
	if animki != null:
		animki.play("deploy", 0.1, 1, false)
		next_fire = common.time + animki.current_animation_length
		mag = common.GetMagData(weapon)

func OnHolster():
	pass

func Holster():
	OnHolster()
	if animki != null:
		animki.play("holster", 0.1, 1, false)
		next_fire = common.time + animki.current_animation_length
		common.UpdateMagData(weapon, mag)

func FireCallback(ent, tr):
	common.util_trace(muzzle.global_transform.origin, tr.get_collision_point(), "trace1")

func Fire():
	ply.ShootBullet( self.accuracy, self.bullet_num )
	ply.ViewPunch( self.view_punch )
	if animki != null:
		animki.play("fire", 0, 1, false)
		next_fire = common.time + delay
		
		var m = common.muzzle1.instance()
		muzzle.add_child(m)
		
		DropShell()
		mag -= 1
		if mag <= 0 and coolreloading:
			DropLoad()
		#elif mag <= 0 and !coolreloading:
		#	Reload()

func Rld():
	if common.ammo_inventory.has(self_wep.ammo) and common.ammo_inventory[self_wep.ammo].amount >= max_mag:
		
		if animki != null:
			animki.play("reload_cool2", 0.1, 1, false)
			next_fire = common.time + animki.current_animation_length
			ply.ViewKick(3)
		if common.ammo_inventory[self_wep.ammo].amount >= max_mag:
			mag = max_mag
			common.ammo_inventory[self_wep.ammo].amount -= max_mag
	elif common.ammo_inventory.has(self_wep.ammo) and common.ammo_inventory[self_wep.ammo].amount < max_mag:
		Reload()

func OnReload():
	pass

func Reload():
	if common.ammo_inventory.has(self_wep.ammo) and mag < max_mag and common.ammo_inventory[self_wep.ammo].amount > 0:
		OnReload()
		if animki != null:
			animki.play("reload", 0.1, 1, false)
			next_fire = common.time + animki.current_animation_length
			
		if common.ammo_inventory[self_wep.ammo].amount >= (max_mag - mag):
			var magsub = max_mag - mag
			mag = mag + magsub
			common.ammo_inventory[self_wep.ammo].amount -= magsub
		elif common.ammo_inventory[self_wep.ammo].amount < (max_mag - mag):
			mag += common.ammo_inventory[self_wep.ammo].amount
			common.ammo_inventory[self_wep.ammo].amount = 0

func droptimergay():
	DropGun(true, self.global_transform.basis.x)

func DropLoad():
	if common.ammo_inventory.has(self_wep.ammo) and common.ammo_inventory[self_wep.ammo].amount > max_mag:
		if animki != null:
			animki.play("reload_cool1", 0.1, 1, false)
			mag = max_mag
			common.ammo_inventory[self_wep.ammo].amount -= max_mag
			next_fire = common.time + animki.current_animation_length
			var droptimer = get_tree().create_timer(0.4, true)
			droptimer.connect("timeout", self, "droptimergay")


func Kick():
	next_fire = common.time + 0.5
	if animki != null:
		animki.play("kick", 0.1, 1, false)

func GetMag():
	return self.mag