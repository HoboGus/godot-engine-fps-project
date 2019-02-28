extends KinematicBody

const norm_grav = -28
var vel = Vector3()

export(String) var team = "player"

var floor_bool

var view_bob = 0

var crouch_lerp = 0

var next_fire = 0

var deaccel = 15

var area_bool = false

var MAX_SPEED = 25
var WALK_SPEED = 10
var JUMP_SPEED = 10.5

const ACCEL = 4

const MAX_SLOPE_ANGLE = 55

var camera
var camera_holder
var vm
var vm_cam
var timer

var current_weapon = "hands"

var moving = false

var isplayer = true

const MOUSE_SENSITIVITY = 0.08

var sense_mul = 1

var viewpunch = 0

var viewpunch2time = 0
var viewpunch2mul = 1
var viewpunch2 = 0
var vm_bob = 0

var crouch_bool = false

var falling = false

var start_fade = 0
var start_fade2 = 0

var yaw = 0
var pitch = 0

var hull_transform = Transform(Vector3(0.4, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 0.4), Vector3(0, 0, 0) )

func _ready():
	
	camera = $Rotation/Camera
	camera_holder = $Rotation
	vm_cam = $Rotation/Camera/ViewportContainer/Viewport/Camera
	
	if common.wep_to_select == null or !HasWeapon(common.wep_to_select):
		SelectWeapon("hands")
	else:
		SelectWeapon(common.wep_to_select)
		
	timer = $Timer
	#$crouch_ray.connect("body_entered", self, "collided")
	#$crouch_ray.connect("body_exited", self, "uncollided")
	
	timer.connect("timeout", self, "DeployTimer")
	
	$Rotation/eyetrace.add_exception($crouch_ray)
	$Rotation/eyetrace.add_exception($collider)
	$Rotation/eyetrace.add_exception($collider_crouch)
	$Rotation/eyetrace.add_exception($Rotation/legs)
	$Rotation/eyetrace.add_exception(self)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func GetTeam():
	return self.team

func GetHeadPos():
	return camera_holder.global_transform.origin - Vector3(0, 0.3, 0)

func IsCrouching():
	return crouch_bool

func SetEyeAngle(x, y, z):
	camera_holder.rotation_degrees.x = x
	camera_holder.rotation_degrees.y = y
	camera_holder.rotation_degrees.z = z

func IsAlive():
	if common.health > 0:
		return true
	else:
		return false

func Save():
	var save_dict = {
		"filename" : "ply",
		"path" : self.get_path(),
		"pos_x" : self.global_transform.origin.x, 
		"pos_y" : self.global_transform.origin.y, 
		"pos_z" : self.global_transform.origin.z, 
		"ang_x" : self.rotation.x,
		"ang_y" : self.rotation.y,
		"ang_z" : self.rotation.z,
		"tr_x" : self.translation.x,
		"tr_y" : self.translation.y,
		"tr_z" : self.translation.z,
		"eyeang_x" : camera_holder.rotation_degrees.x,
		"eyeang_y" : camera_holder.rotation_degrees.y,
		"eyeang_z" : camera_holder.rotation_degrees.z,
		"curwep" : current_weapon,
		"curslot" : cur_slot,
		"health" : common.health,
		"armor" : common.armor,
		"mag" : vm.mag,
		"has_golden_deagle" : common.has_deagles
	}
	return save_dict

#ViewPunch
func ViewPunch(punch):
	viewpunch = punch
	self.rotate_y( rand_range(-punch*0.005, punch*0.005) ) 
	
	if pitch+punch*0.5 < 70:
		pitch += punch*0.5 
		camera_holder.rotation.x += punch*0.005
	
	#ShakeScreen(0.3, 30)
#

var shake_time = 0
var shake_power = 0
var shake_lerp = 0

func ShakeScreen(duration, power):
	shake_time = common.time + duration
	shake_power = power

func ViewKick(punch):
	viewpunch2mul = punch
	viewpunch2time = common.time + 0.2

func GetEyeTrace():
	var tr = $Rotation/eyetrace
	tr.rotation_degrees = Vector3(0,0,0)
	tr.force_raycast_update()
	if tr.is_colliding():
		var HitPos = tr.get_collision_point()
		var HitNormal = tr.get_collision_normal()
		var Entity = tr.get_collider()
		var rtrn = [HitPos, HitNormal, Entity]
		return rtrn
	else:
		return null

var material = "blood"

func MaterialType():
	return material

func ShootBullet(spread, number):
	
	for i in range(number):
		var tr = $Rotation/eyetrace
		tr.rotation_degrees = Vector3(0,0,0)
		tr.rotation_degrees.x = rand_range(-spread, spread)
		tr.rotation_degrees.y = rand_range(-spread, spread)
		tr.force_raycast_update()
		if tr.is_colliding():
			var ent = tr.get_collider()
			var dir = ent.global_transform.origin - tr.get_collision_point()
			
			vm.FireCallback(ent, tr)
			
			if ent.has_method("BulletHit"):
				ent.BulletHit(vm.damage, self, vm.force)
				
			if ent.get_class() == "RigidBody": 
				ent.apply_impulse(Vector3(0,0,0), -camera_holder.global_transform.basis.z.normalized()*(vm.force*0.5))
				
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

var vm2 = null

var grabbed_obj = null
var last_wep = ""

func Ressurect(weapon):
	dead = false
	$hud_center/wasted.hide()
	vm2 = common.weapons[weapon].vm 
	var new_vm = vm2.instance()                              #new vm instance
	vm_cam.add_child(new_vm)                                 #attach it to the player
	vm = new_vm
	vm_cam.fov = vm.fov
	current_weapon = vm.weapon                               #set current weapon variable
	vm.Deploy() 

func DeployTimer():
	var new_vm = vm2.instance()                              #new vm instance
	vm_cam.add_child(new_vm)                                 #attach it to the player
		
	if vm:
		vm.queue_free()                                          #delete the old one
	vm = new_vm
	vm_cam.fov = vm.fov
	current_weapon = vm.weapon                               #set current weapon variable
		
	vm.ply = self
	vm.Deploy()                                              #deploy new weapon

var switch_delay = 0

func SelectWeapon(weapon):
	
	DropGrabbedObj(0.5)
	
	if switch_delay > common.time:
		return 
	if vm:
		if common.weapons[weapon] != null and vm.weapon != weapon and next_fire < common.time:              #check if such weapon exists, if it isnt selected and we can change right now
			vm2 = common.weapons[weapon].vm                                                                 #load new vm scene
			vm.Holster()                                                                                    #holster current weapon
			if vm.animki != null:
				switch_delay = common.time + vm.animki.current_animation_length
				timer.wait_time = vm.animki.current_animation_length
				timer.start()
			else:
				switch_delay = common.time + 0.2
				DeployTimer()
	else:
		vm2 = common.weapons[weapon].vm   
		DeployTimer()

func SwitchWeapon(weapon):   #instant weapon switching
	vm2 = common.weapons[weapon].vm 
	DeployTimer()

var notification_time = 0

var fadelerp = 1
var fadelerp2 = 0

func LevelStartNotification(text, fadedelay, textdelay):
	if sys.saveload:
		fadelerp = 1
		fadelerp2 = 0
		$fade/levelname.text = ""
		return
	fadelerp = 1
	fadelerp2 = 0
	start_fade = common.time + fadedelay
	start_fade2 = common.time + textdelay
	$fade/levelname.text = text

func AddNotification(text):
	$hud_center/notification.text = text
	$hud_center/notification.show()
	notification_time = common.time + 1.5

func CanTakeAmmo(ammo, amount):
		if (common.ammo_inventory.has(ammo) and common.ammo_inventory[ammo].amount < common.ammo[ammo].max_ammo) or !common.ammo_inventory.has(ammo):
			return true
		else:
			return false

func GiveAmmo(ammo, amount):
	if ammo != "none":
		
		var aammo = 0
		
		if common.ammo_inventory.has(ammo):
			aammo = min( common.ammo[ammo].max_ammo, common.ammo_inventory[ammo].amount + amount )
			common.ammo_inventory[ammo].amount = aammo
		else:
			common.ammo_inventory[ammo] = {}
			aammo = min( common.ammo[ammo].max_ammo, 0 + amount )
			common.ammo_inventory[ammo].amount = aammo
		
		AddNotification( "+"+String(amount)+" "+common.ammo[ammo].good_name+" acquired")
	

func HasWeapon(weapon):
	var wep = common.weapons[weapon]
	if common.weapons_inventory[wep.slot].has(weapon):
		return true
	else:
		return false

func StoreWeapon(weapon):
	if common.weapons[weapon] != null:
		var wep = common.weapons[weapon]
		if common.weapons_inventory[wep.slot].has(weapon) and wep.ammo != "none":
			GiveAmmo(wep.ammo, wep.default_ammo)
		else:
			common.weapons_inventory[wep.slot].insert(common.weapons_inventory[wep.slot].size(), weapon)
			GiveAmmo(wep.ammo, 0)
			if wep.ammo != "none":
				common.UpdateMagData(weapon, wep.default_ammo)
			AddNotification(common.weapons[weapon].good_name+" acquired")
			if wep.coolness > common.weapons[current_weapon].coolness:
				SelectWeapon(weapon)

var nxt_grab = 0

func Grab(ent):
	if grabbed_obj != null or nxt_grab > common.time:
		return
	last_wep = current_weapon
	SelectWeapon("hands")
	ent.mode = RigidBody.MODE_STATIC
	grabbed_obj = ent
	nxt_grab = common.time + 0.2

func DropGrabbedObj(force):
	if grabbed_obj != null:
		grabbed_obj.mode = RigidBody.MODE_RIGID
		grabbed_obj.apply_impulse(Vector3(0,0,0), -camera_holder.global_transform.basis.z.normalized() * force)
		grabbed_obj = null
		nxt_grab = common.time + 0.2

func Attack():
	
	if grabbed_obj != null and last_wep != "":
		DropGrabbedObj(15)
		SelectWeapon(last_wep)
	
	if vm.CanFire():
		if vm.has_method("Fire"):
			#self.ShootBullet( vm.accuracy, vm.bullet_num ) #первый аргумент это разброс, второй количество
			#self.ViewPunch( vm.view_punch )
			vm.Fire()
			
func SecondaryAttack():
	
	if grabbed_obj != null and last_wep != "":
		DropGrabbedObj(0.5)
		SelectWeapon(last_wep)
	
	if vm.CanSecondaryFire():
		if vm.has_method("SecondFire"):
			vm.SecondFire()

func CheckCrouch():
	var bodies = $crouch_ray.get_overlapping_bodies()
	var bodynum = bodies.size()
	if bodynum > 0:
		area_bool = true
	else:
		area_bool = false

func Use():
	var start = self.global_transform.origin
	var tr = self.GetEyeTrace() 
	if tr == null:
		return
	var end = tr[0]
	var ent = tr[2]
	
	if tr != null and start.distance_to(end) <= 4:
		if ent.has_method("OnUse"):
			ent.OnUse(self)
		if grabbed_obj == null:
			if ent is RigidBody:
				Grab(ent)

var bob_mod = 0
var mouse_lag_x = 0
var mlag_x = 0
var mouse_lag_y = 0
var mlag_y = 0

func TakeDamage(dmg, attacker):
	if common.armor <= 0:
		common.health -= dmg
	elif common.armor > 0:
		common.health -= dmg/2
		common.armor -= dmg
	ViewPunch(dmg/2)
	ViewKick(rand_range(-dmg, dmg))

func AddHealth(health):
	if IsAlive():
		var h = min( 100, common.health + health )
		common.health = h

func SetArmor(armor):
	common.armor = armor

func handle_weapon(delta):
	
	if self.moving:
		vm_bob = lerp(vm_bob, (cos(10 * common.time)*0.1), 10*delta)
	else:
		vm_bob = lerp(vm_bob, 0, 25*delta)
		
	bob_mod = lerp(bob_mod, (camera_holder.rotation.x*0.2)*-1, 8*delta)
	
	mlag_x = lerp(mlag_x, mouse_lag_x, 5*delta)
	mlag_y = lerp(mlag_y, mouse_lag_y, 5*delta)
	
	var vm_shake = shake_power*0.01
	
	vm.translation.x = vm.x_mod+((mlag_x*-1)*vm.gunlag) + (rand_range(-vm_shake, vm_shake)*shake_lerp)
	vm.translation.y = vm.y_mod+(mlag_y*vm.gunlag) + (rand_range(-vm_shake, vm_shake)*shake_lerp)
	vm.translation.z = vm.z_mod-bob_mod + vm_bob
	
	vm.rotation.z = (mlag_x*vm.gunlag)*-1
	
	if vm.next_fire < common.time and vm.can_fire:
		match vm.automatic:
			false:
				if Input.is_action_just_pressed("primary_attack"):
					self.Attack()
				if Input.is_action_just_pressed("secondary_attack"):
					self.SecondaryAttack()
			true:
				if Input.is_action_pressed("primary_attack"):
					self.Attack()
				if Input.is_action_just_pressed("secondary_attack"):
					self.SecondaryAttack()
				
	if Input.is_action_just_pressed("reload") and vm.next_fire < common.time:
		if vm.coolreloading and GetEyeTrace() != null and (GetEyeTrace()[2].has_method("IsAlive") and GetEyeTrace()[2].IsAlive()):
			vm.Rld()
		else:
			vm.Reload()

var max_slots = 0
var cur_slot = 0
var cur_slot_pos = 0

func process_slots(slot):
	max_slots = common.weapons_inventory[slot].size()
	
	if max_slots <= 0: return
	
	if cur_slot != slot:
		cur_slot = slot
		cur_slot_pos = 0
	else:
		if max_slots > 1 and cur_slot_pos+1 < max_slots:
			cur_slot_pos = cur_slot_pos + 1
		elif cur_slot_pos+1 >= max_slots:
			cur_slot_pos = 0
		
	var pos = common.weapons_inventory[slot][cur_slot_pos]
	
	if pos != null and common.weapons[pos] != null:
		SelectWeapon(pos)

func Kick():
	if vm.next_fire <= common.time:
		$Rotation/legs.Kick()
		vm.Kick()

func DrawHud(delta):
	#$hud_leftdown/ProgressBar.value = common.health
	
	if start_fade < common.time:
		fadelerp = lerp(fadelerp, 0, 1*delta)
	if start_fade2 < common.time:
		fadelerp2 = lerp(fadelerp2, 0, 2*delta)
	else:
		fadelerp2 = lerp(fadelerp2, 1, 1*delta)
	
	$fade.color = Color(0, 0, 0, fadelerp)
	$fade/levelname.self_modulate = Color(1, 1, 1, fadelerp2)
	
	$fade/levelname.rect_scale.x = lerp($fade/levelname.rect_scale.x, 1.4, 0.2*delta)
	$fade/levelname.rect_scale.y = lerp($fade/levelname.rect_scale.y, 1.4, 0.2*delta)
	
	if common.armor <= 0:
		material = "blood"
		if $hud_leftdown/armor_hud.visible:
			$hud_leftdown/armor_hud.hide()
	elif common.armor > 0:
		material = "metal"
		$hud_leftdown/armor_hud/armor_txt.text = String(round(common.armor))
		if !$hud_leftdown/armor_hud.visible:
			$hud_leftdown/armor_hud.show()
	
	if notification_time < common.time and $hud_center/notification.visible:
		$hud_center/notification.hide()
	
	$hud_leftdown/health_txt.text = String(round(common.health))
	
	$hud_rigtdown/weapon_name.text = common.weapons[current_weapon].good_name
	
	if $hud_rigtdown/ammo_icon.animation != common.weapons[current_weapon].ammo:
		$hud_rigtdown/ammo_icon.animation = common.weapons[current_weapon].ammo
	
	if $hud_rigtdown/secondary_ammo_hud/ammo_icon.animation != common.weapons[current_weapon].secondary_ammo:
		$hud_rigtdown/secondary_ammo_hud/ammo_icon.animation = common.weapons[current_weapon].secondary_ammo
	
	if common.ammo_inventory.has(common.weapons[current_weapon].secondary_ammo):
		$hud_rigtdown/secondary_ammo_hud/ammo2.text = String(common.ammo_inventory[common.weapons[current_weapon].secondary_ammo].amount)
		if !$hud_rigtdown/secondary_ammo_hud.visible:
			$hud_rigtdown/secondary_ammo_hud.show()
	else:
		if $hud_rigtdown/secondary_ammo_hud.visible:
			$hud_rigtdown/secondary_ammo_hud.hide()
	
	if common.ammo_inventory.has(common.weapons[current_weapon].ammo):
		$hud_rigtdown/ammo.text = String(vm.mag)+" / "+String(common.ammo_inventory[common.weapons[current_weapon].ammo].amount)
		$hud_center/crosshair.show()
	elif common.weapons[current_weapon].ammo == "none":
		$hud_rigtdown/ammo.text = ""
		$hud_center/crosshair.hide()
	else:
		$hud_rigtdown/ammo.text = String(vm.mag)+" / 0"
		$hud_center/crosshair.show()

var dead = false

func process_dead(delta):
	if !dead:
		dead = true
		#$hud_center/wasted.show()
		$hud_center/crosshair.hide()
		vm.DropGun(true, -camera_holder.global_transform.basis.z.normalized())
		vm.queue_free()
		DropGrabbedObj(15)
	camera_holder.rotation_degrees.z = lerp(camera_holder.rotation_degrees.z, 45, 5*delta)
	camera_holder.rotation_degrees.x = lerp(camera_holder.rotation_degrees.x, 0, 5*delta)
	crouch_lerp = lerp(crouch_lerp, 1, 5*delta)
	camera_holder.translation.y = (-2.5*crouch_lerp)

func _process(delta):
	
	viewpunch = lerp(viewpunch, 0, 5*delta)
	
	if !dead:
		camera_holder.translation.y = 0.5+(-1.5*crouch_lerp)
	$collider_crouch.translation.y = (-2*crouch_lerp)
	
	if viewpunch2time > common.time:
		viewpunch2 = lerp(viewpunch2, 1, 5*delta)
	else:
		viewpunch2 = lerp(viewpunch2, 0, 5*delta)
	
	if shake_time > common.time:
		shake_lerp = lerp(shake_lerp, 1, 5*delta)
	else:
		shake_lerp = lerp(shake_lerp, 0, 5*delta)
	
	if shake_lerp <= 0.1:
		camera.rotation_degrees.z = 0
		camera.rotation_degrees.y = 0
	
	camera.rotation_degrees.z = view_bob*0.5 + ((cos( ( shake_power*10 )* common.time)*2)*shake_lerp)
	camera.rotation_degrees.x = viewpunch+(viewpunch2mul*viewpunch2)
	camera.rotation_degrees.y = ((cos(shake_power*20 * common.time)*0.5)*shake_lerp)
	
	vm_cam.global_transform = camera.global_transform
	#vm_cam.rotation_degrees = camera.rotation_degrees
	
	if common.health <= 0:
		process_dead(delta)
		return
		
	DrawHud(delta)
	
	if vm and vm is common.VIEW_MODEL:
		handle_weapon(delta)
		
	if Input.is_action_just_pressed("kick"):
		Kick()
		
	if Input.is_action_just_pressed("use"):
		self.Use()

	if Input.is_action_pressed("crouch") or area_bool:
		crouch_lerp = lerp(crouch_lerp, 1, 15*delta)
		crouch_bool = true
	else:
		crouch_bool = false
		if !area_bool:
			crouch_lerp = lerp(crouch_lerp, 0, 15*delta)
	
	if Input.is_action_just_pressed("wep_slot1"):
		process_slots(1)
	if Input.is_action_just_pressed("wep_slot2"):
		process_slots(2)
	if Input.is_action_just_pressed("wep_slot3"):
		process_slots(3)
	if Input.is_action_just_pressed("wep_slot4"):
		process_slots(4)
	if Input.is_action_just_pressed("wep_slot5"):
		process_slots(5)
	if Input.is_action_just_pressed("wep_slot6"):
		process_slots(6)
	if Input.is_action_just_pressed("wep_slot7"):
		process_slots(7)
	if Input.is_action_just_pressed("wep_slot8"):
		process_slots(8)
	if Input.is_action_just_pressed("wep_slot9"):
		process_slots(9)
	if Input.is_action_just_pressed("wep_slot0"):
		process_slots(0)
	
	if Input.is_action_pressed("move_left"):
		view_bob = lerp(view_bob, -3, 5*delta)
	if Input.is_action_pressed("move_right"):
		view_bob = lerp(view_bob, 3, 5*delta)
	elif not Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		view_bob = lerp(view_bob, 0, 5*delta)

func Push(to_vel):
	vel = vel+to_vel

func _physics_process(delta):
	CheckCrouch()
	
	if grabbed_obj != null:
		grabbed_obj.global_transform.origin = camera_holder.global_transform.origin + (-camera_holder.global_transform.basis.z.normalized() * 3)
	
	var dir = Vector3()
	
	if IsAlive():
		var cam_xform = camera.get_global_transform()
		
		if Input.is_action_pressed("move_forward"):
			dir += -cam_xform.basis.z.normalized()
		if Input.is_action_pressed("move_back"):
			dir += cam_xform.basis.z.normalized()
		if Input.is_action_pressed("move_left"):
			dir += -cam_xform.basis.x.normalized()
		if Input.is_action_pressed("move_right"):
			dir += cam_xform.basis.x.normalized()
	
	floor_bool = is_on_floor()
	
	if dir.length() > 0:
		moving = true
	else:
		moving = false
	
	if is_on_floor():
		deaccel = 15
		
		#if falling:
			#falling = false
			#if -40 < vel.y:
			#	TakeDamage(vel.y, self)
		
		if Input.is_action_just_pressed("move_jump") and !area_bool:
			vel.y = JUMP_SPEED
			deaccel = 10
		#falling = true
	
	dir.y = 0
	dir = dir.normalized()
	
	var grav = norm_grav
	vel.y += delta*grav
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	
	if Input.is_action_pressed("walk") or Input.is_action_pressed("crouch") or area_bool == true:
		if floor_bool == true:
			target *= WALK_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = deaccel
	
	#hull_transform.origin = self.global_transform.origin + Vector3(0, 0.3, 0)
	#self.global_transform = hull_transform
	if moving and $step_ray.is_colliding():
		var step_normal=$step_ray.get_collision_normal()
		if (rad2deg(acos(step_normal.dot(Vector3(0,1,0))))< MAX_SLOPE_ANGLE):
			vel.y = 5
	
	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
	
	#if !crouch_bool and is_on_floor() and is_on_wall():
		#	print(test_move(hull_transform, vel*delta))
		#	self.global_transform.origin = (self.global_transform.origin + dir) + Vector3(0, 0.3, 0)

var last_x_rot = 0

func _input(event):
	if common.health <= 0:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		yaw = rad2deg(self.get_rotation().y)
		pitch = rad2deg(camera_holder.get_rotation().x)
		
		yaw = fmod( yaw - event.relative.x * (MOUSE_SENSITIVITY*sense_mul), 360)
		pitch = max(min( pitch - event.relative.y * (MOUSE_SENSITIVITY*sense_mul), 70), -70)
		
		self.set_rotation(Vector3(0, deg2rad(yaw), 0))
		camera_holder.set_rotation(Vector3(deg2rad(pitch), 0, 0))
		
		if camera_holder.get_rotation().x != last_x_rot:
			mouse_lag_y = ( (event.relative.y * MOUSE_SENSITIVITY) * 0.03)
			last_x_rot = camera_holder.get_rotation().x
		else:
			mouse_lag_y = 0
		mouse_lag_x = ( (event.relative.x * MOUSE_SENSITIVITY) * 0.03)