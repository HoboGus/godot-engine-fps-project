extends KinematicBody

export(NodePath) var nav
export(NodePath) var raycast
export(NodePath) var animki
export(NodePath) var head
export(NodePath) var head_box

export(NodePath) var los_start

enum { STATE_IDLE, STATE_PATROL, STATE_MOVE, STATE_GAY, STATE_ATTACK, STATE_DYING, STATE_DEAD }

export (int) var los_fov = 0
export (int) var los_range = 0

var path = []

var max_health = 60
var health = 60

var vel = Vector3()
var add_vel = Vector3()

var alert = 0
var panic = 0

var move_type = "walk"

const MAX_SLOPE_ANGLE = 40

var moving = false

export(String) var weapon = ""
var weapon_ent = null
export(int) var armor_amount = 0

var limb_off = preload("res://effects/gibs/limb_off.tscn")
var meat_chunk = preload("res://effects/gibs/gibb.tscn")
var small_meat_chunk = preload("res://effects/gibs/small_gib.tscn")

var gibs = {
	
	"head" : {
		gib = {
			"ebalo" : {
					gib = preload("res://effects/gibs/ebalo1.tscn"),
					parented = true,
					ang = Vector3(-90, 0, 0), pos = Vector3(0, -0.05, 0.15),
					needs_nextgib = false
				}
		},
		limb = false,
		lethal = true,
		state = STATE_DEAD,
		to_hide = ["Armature/Skeleton/head"],
		to_show = null,
		next_part = null,
		prevpart = null,
		animations = ["death3", "death_headshot"],
		back_animations = ["death_forward", "death3"],
		drop_weapon = false
	},
	"guts" : {
		gib = {
			"guts" : {
					gib = preload("res://effects/gibs/guts.tscn"),
					parented = true,
					ang = Vector3(-90, 0, 0), pos = Vector3(0, -0.3, -0.3),
					needs_nextgib = false
				}
		},
		limb = false,
		lethal = false,
		state = STATE_DYING,
		to_hide = null,
		to_show = null,
		next_part = null,
		prevpart = null,
		animations = ["death_guts1", "death_guts2"],
		back_animations = null,
		drop_weapon = false
	},
	"nuts" : {
		gib = null,
		limb = false,
		lethal = false,
		state = STATE_DYING,
		to_hide = null,
		to_show = null,
		next_part = null,
		prevpart = null,
		animations = ["death_nutshot"],
		back_animations = null,
		drop_weapon = false
	},
	"larm" : {
		gib = {
			"arm" : {
					gib = preload("res://effects/gibs/thug/left_arm.tscn"),
					parented = false,
					ang = Vector3(0, 0, 0), pos = Vector3(0, 0, 0),
					needs_nextgib = true
				}
			},
		limb = true,
		lethal = true,
		state = null,
		to_hide = ["Armature/Skeleton/left_arm", "Armature/Skeleton/left_arm_piece"],
		to_show = null,
		next_part = "lhand",
		prevpart = "none",
		animations = ["death2"],
		back_animations = null,
		drop_weapon = false
	},
	"lhand" : {
		gib = {
			"hand" : {
					gib = preload("res://effects/gibs/thug/left_hand.tscn"),
					parented = false,
					ang = Vector3(0, 0, 0), pos = Vector3(0, 0, 0),
					needs_nextgib = false
				}
			},
		limb = true,
		lethal = false,
		state = null,
		to_hide = ["Armature/Skeleton/left_hand"],
		to_show = ["Armature/Skeleton/left_arm_piece"],
		next_part = "lpalm",
		prevpart = "larm",
		animations = null,
		back_animations = null,
		drop_weapon = false
	},
	"rarm" : {
		gib = {
			"arm" : {
					gib = preload("res://effects/gibs/thug/right_arm.tscn"),
					parented = false,
					ang = Vector3(0, 0, 0), pos = Vector3(0, 0, 0),
					needs_nextgib = true
				}
			},
		limb = true,
		lethal = true,
		state = null,
		to_hide = ["Armature/Skeleton/right_arm", "Armature/Skeleton/right_arm_piece"],
		to_show = null,
		next_part = "rhand",
		prevpart = "none",
		animations = ["death2"],
		back_animations = null,
		drop_weapon = false
	},
	"rhand" : {
		gib = {
			"hand" : {
					gib = preload("res://effects/gibs/thug/right_hand.tscn"),
					parented = false,
					ang = Vector3(0, 0, 0), pos = Vector3(0, 0, 0),
					needs_nextgib = false
				}
			},
		limb = true,
		lethal = false,
		state = null,
		to_hide = ["Armature/Skeleton/right_hand"],
		to_show = ["Armature/Skeleton/right_arm_piece"],
		next_part = "rpalm",
		prevpart = "rarm",
		animations = null,
		back_animations = null,
		drop_weapon = true
	},
	"lleg" : {
		gib = {
			"leg" : {
					gib = preload("res://effects/gibs/thug/left_leg.tscn"),
					parented = false,
					ang = Vector3(0, 0, 0), pos = Vector3(0, 0, 0),
					needs_nextgib = true
				}
			},
		limb = true,
		lethal = true,
		state = null,
		to_hide = ["Armature/Skeleton/left_leg", "Armature/Skeleton/left_leg_piece"],
		to_show = null,
		next_part = "lfoot",
		prevpart = "none",
		animations = ["no_legs_fall"],
		back_animations = null,
		drop_weapon = false
	},
	"lfoot" : {
		gib = {
			"foot" : {
					gib = preload("res://effects/gibs/thug/left_foot.tscn"),
					parented = false,
					ang = Vector3(0, 0, 0), pos = Vector3(0, 0, 0),
					needs_nextgib = false
				}
			},
		limb = true,
		lethal = true,
		state = null,
		to_hide = ["Armature/Skeleton/left_foot"],
		to_show = ["Armature/Skeleton/left_leg_piece"],
		next_part = "lboot",
		prevpart = "lleg",
		animations = null,
		back_animations = null,
		drop_weapon = false
	},
	"rleg" : {
		gib = {
			"leg" : {
					gib = preload("res://effects/gibs/thug/right_leg.tscn"),
					parented = false,
					ang = Vector3(0, 0, 0), pos = Vector3(0, 0, 0),
					needs_nextgib = true
				}
			},
		limb = true,
		lethal = true,
		state = null,
		to_hide = ["Armature/Skeleton/right_leg", "Armature/Skeleton/right_leg_piece"],
		to_show = null,
		next_part = "rfoot",
		prevpart = "none",
		animations = ["no_legs_fall"],
		back_animations = null,
		drop_weapon = false
	},
	"rfoot" : {
		gib = {
			"foot" : {
					gib = preload("res://effects/gibs/thug/right_foot.tscn"),
					parented = false,
					ang = Vector3(0, 0, 0), pos = Vector3(0, 0, 0),
					needs_nextgib = false
				}
			},
		limb = true,
		lethal = true,
		state = null,
		to_hide = ["Armature/Skeleton/right_foot"],
		to_show = ["Armature/Skeleton/right_leg_piece"],
		next_part = "rboot",
		prevpart = "rleg",
		animations = null,
		back_animations = null,
		drop_weapon = false
	}
	
}

var gibbs = {
	
	"head" : false,
	"guts" : false,
	"nuts" : false,
	"lhand" : false,
	"rhand" : false,
	"larm" : false,
	"rarm" : false,
	"lfoot" : false,
	"rfoot" : false,
	"lleg" : false,
	"rleg" : false,
	"lpalm" : false,
	"rpalm" : false,
	"lboot" : false,
	"rboot" : false
	
}

var hit_anims = ["hit_1", "hit_2"]

export var state = 0
export(String) var team = "enemy"

var ready = 0

var gib1 = preload("res://effects/gibs/gib1.tscn")
var smallchunk = preload("res://effects/gibs/gibb.tscn")

var cut_part_blood = preload("res://effects/prtcls/bloodeffect1.tscn")

var blood_cloud = preload("res://effects/prtcls/bloodcloud.tscn")

var head_node = null
var headbox_node = null

var dmg_dir = 1

export(NodePath) var skel
var skeleton

func _ready():
	for i in gibs.keys():
		if gibs[i].to_show != null:
			for p in gibs[i].to_show:
				if get_node(p) != null:
					get_node(p).hide()
	
	skeleton = get_node(skel)
	
	head_node = get_node(head)
	headbox_node = get_node(head_box)
	
	if armor_amount > 0:
		SetArmor(armor_amount)
	var tr = get_node(raycast)
	tr.add_exception(head_node)
	tr.add_exception(headbox_node)
	
	if weapon != "":
		SetWeapon(weapon)
	
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
		"state" : state,
		"health" : self.health,
		"nav" : nav,
		"velx" : vel.x,
		"add_velx" : add_vel.x,
		"vely" : vel.y,
		"add_vely" : add_vel.y,
		"velz" : vel.z,
		"add_velz" : add_vel.z,
		"anim" : $AnimationPlayer.assigned_animation,
		"anim_pos" : $AnimationPlayer.current_animation_position,
		"gibbs" : to_json(self.gibbs),
		"cur_path" : current_path,
		"path" : to_json(path),
		"team" : team,
		"weapon" : weapon,
		"armor" : GetArmor()
	}
	return save_dict
	
var nxt_hit = 0
var last_attacker = null

func IsFacing(target):
	var pos = self.global_transform.origin
	var target_pos = target.global_transform.origin
	var dir = (target_pos - pos).normalized()
	var forward = -self.global_transform.basis.z.normalized()
	
	if dir.dot(forward) > cos(deg2rad(180/2)):
		return true
	return false

func MaterialType():
	return "blood"

func TakeDamage(dmg, attacker):
	last_attacker = attacker
	self.health -= dmg
	var target_pos = attacker.global_transform.origin
	var pos = self.global_transform.origin
	
	panic = common.time + 5
	move_type = "run"
	
	#if attacker.GetTeam() == "player":
	#	team = "enemy"
	
	NotifySquad(pos)
	
	if dmg > max_health*3:
		FullGibs()
	
	current_path = 0
	path = []
	
	UpdateVelocity(Vector3(0, 0, 0))
	
	if IsAlive() and !IsDying():
		if IsFacing(attacker):
			if nxt_hit < common.time:
				$AnimationPlayer.play(hit_anims[randi() % hit_anims.size()], 0, 1, false)
				nxt_hit = common.time + $AnimationPlayer.current_animation_length/6
				next_fire = common.time + $AnimationPlayer.current_animation_length
			rotate_towards(target_pos)
		else:
			StartPatrol()

var armr = preload("res://items/armor.tscn")

func Fire():
	if weapon_ent != null:
		weapon_ent.ShootBullet()
		weapon_ent.DropShell()
		var m = common.npc_muzzle1.instance()
		weapon_ent.muzzle.add_child(m)

func DropWeapon():
	var gun_att = $Armature/Skeleton/gun_att/offset
	if weapon == "":
		return
	if IsAlive() and !IsDying():
		UpdateState(STATE_IDLE)
		$AnimationPlayer.play("drop_weapon1", 0, 1, false)
		next_fire = common.time + $AnimationPlayer.current_animation_length
	
	if weapon_ent != null:
		weapon_ent.add_to_group("save")
		gun_att.remove_child(weapon_ent)#gun_att.call_deferred("remove_child", weapon_ent)
		sys.current_scene.add_child(weapon_ent)
		weapon_ent.global_transform = gun_att.global_transform
		weapon_ent.gun_owner = null
		weapon_ent.UpdateState()
		weapon_ent.apply_impulse( Vector3(0,0,0), -gun_att.global_transform.basis.z.normalized()*3 + Vector3(0,2,0))
		weapon_ent = null
		weapon = ""

func SetWeapon(wep):
	weapon = wep
	if weapon_ent != null: 
		weapon_ent.queue_free()
	if weapon == "":
		return
	weapon_ent = common.weapons[weapon].wm.instance()
	weapon_ent.gun_owner = self
	weapon_ent.remove_from_group("save")
	$Armature/Skeleton/gun_att/offset.add_child(weapon_ent)
	weapon_ent.translation = $Armature/Skeleton/gun_att/offset.translation

var armor_ent = null

func GetArmor():
	if armor_ent == null:
		return 0
	else:
		return armor_ent.armor

func SetArmor(amount):
	if armor_ent == null:
		armor_ent = armr.instance()
		armor_ent.mode = RigidBody.MODE_STATIC
		armor_ent.ownr = self
		armor_ent.set_collision_layer_bit(5, false)
		armor_ent.set_collision_mask_bit(5, false)
		armor_ent.set_collision_layer_bit(4, true)
		armor_ent.set_collision_mask_bit(4, true)
		$Armature/Skeleton/chest_att2/offset.add_child(armor_ent)
		armor_ent.scale = Vector3(0.8, 0.8, 1.2)
		armor_ent.remove_from_group("save")
		armor_ent.armor = amount
	else:
		armor_ent.armor = amount

func Load(data):
	self.health = int(data["health"])
	SetWeapon(data["weapon"])
	if self.health <= 0:
		OnDeath()
	
	if data["state"] == STATE_PATROL:
		StartPatrol()
	else:
		UpdateState(data["state"])
	
	#print(states.keys()[data["state"]])
	
	self.nav = data["nav"]
	if data["anim"] != "":
		self.SetAnimTime(data["anim"], data["anim_pos"])
	var dict_parse = parse_json(data["gibbs"])
	for i in dict_parse.keys():
		if gibbs.has(i):
			gibbs[i] = dict_parse[i]
			
	for i in gibbs.keys():
		SetBodyPart(i, dict_parse[i])
	
	current_path = data["cur_path"]
	path = parse_json(data["path"])
	
	team = data["team"]
	
	vel.x = float(data["velx"])
	vel.y = float(data["vely"])
	vel.z = float(data["velz"])
	add_vel.x = float(data["add_velx"])
	add_vel.y = float(data["add_vely"])
	add_vel.z = float(data["add_velz"])
	
	if int(data["armor"]) > 0:
		SetArmor(int(data["armor"]))
	
func UpdateState(s):
	reset_aim()
	UpdateVelocity(Vector3(0,0,0))
	state = s

func IsDying():
	if state != STATE_DYING:
		return false
	elif state == STATE_DYING:
		return true

var next_fire = 0

func CanFire():
	if next_fire < common.time and nxt_hit < common.time:
		return true
	else:
		return false

func IsAlive():
	if state != STATE_DEAD:
		return true
	elif state == STATE_DEAD:
		return false
	
func SetBodyPart(part, b):
	
	self.gibbs[part] = b
	
	if b == false or !gibs.has(part):
		return
	
	if gibs[part].next_part != null:
		SetBodyPart(gibs[part].next_part, true)
	
	if gibs[part].to_show != null:
		for i in gibs[part].to_show:
			get_node(i).show()
	
	if gibs[part].to_hide != null:
		for i in gibs[part].to_hide:
			get_node(i).hide()
	
	if gibs[part].lethal:
		OnDeath()
	
	#if part == "guts":
	#	var gut = gibs[part].gib.instance()
	#	guts_node.add_child(gut)
	#	#gut.translation = guts_node.translation
	#	gut.play_guts()

func HasPart(bodypart):
	if bodypart != "none" and gibbs[bodypart] == true:
		return false
	return true

var ludicrous_gibs = preload("res://effects/gibs/ludicrous_gibs.tscn")

func BodyPartDamage(bodypart, hitbox, attacker):
	
	var target_pos = attacker.global_transform.origin
	var dist = self.global_transform.origin.distance_to(target_pos)
	
	var dir = (target_pos - self.global_transform.origin).normalized()
	var forward = -self.global_transform.basis.z.normalized()
	
	if dir.dot(forward) > cos(deg2rad(180/2)):
		dmg_dir = 1
	else:
		dmg_dir = 2
	
	if gibbs[bodypart] == true:
		return
	
	if !gibs[bodypart].lethal and gibs[bodypart].drop_weapon == true:
		DropWeapon()
	
	if IsAlive():
		if gibs[bodypart].animations != null and IsFacing(attacker):
			if !IsDying():
				if gibs[bodypart].animations.size() > 1:
					$AnimationPlayer.play(gibs[bodypart].animations[randi() % gibs[bodypart].animations.size()], 0)
				elif gibs[bodypart].animations.size() == 1:
					$AnimationPlayer.play(gibs[bodypart].animations[0], 0)
				next_fire = common.time + $AnimationPlayer.current_animation_length
		elif gibs[bodypart].animations == null and IsFacing(attacker):
			if gibs[bodypart].lethal:
				$AnimationPlayer.play("death_headshot", 0)
		
		if gibs[bodypart].back_animations != null and !IsFacing(attacker):
			if !IsDying():
				if gibs[bodypart].back_animations.size() > 1:
					$AnimationPlayer.play(gibs[bodypart].back_animations[randi() % gibs[bodypart].back_animations.size()], 0)
				elif gibs[bodypart].back_animations.size() == 1:
					$AnimationPlayer.play(gibs[bodypart].back_animations[0], 0)
				next_fire = common.time + $AnimationPlayer.current_animation_length
		elif gibs[bodypart].back_animations == null and !IsFacing(attacker):
			if gibs[bodypart].lethal:
				$AnimationPlayer.play("death_forward", 0)
	
	if gibs[bodypart].state != null:
		if IsAlive():
			UpdateState(gibs[bodypart].state)
	else:
		if gibs[bodypart].animations != null:
			UpdateState(STATE_IDLE)
	
	if gibs[bodypart].limb:
		var limppiece = limb_off.instance()
		hitbox.get_parent().add_child(limppiece)
		limppiece.ownerr = self
		limppiece.bodypart = gibs[bodypart].prevpart
		limppiece.global_transform = hitbox.get_parent().global_transform
		limppiece.scale = Vector3(2,2,2)
	
	if bodypart == "head":
		
		for i in range(5):
			var chunk = small_meat_chunk.instance()
			sys.current_scene.add_child(chunk)
			chunk.global_transform = hitbox.get_parent().global_transform
			chunk.vel = -attacker.global_transform.basis.z.normalized()*35 + common.VectorRandom()*5
			chunk.rotation = common.VectorRandom()
			chunk.scale = Vector3(2,2,2)+common.VectorRandom2()*2
		
		if IsFacing(attacker):
			if dist < 4:
				var effect = cut_part_blood.instance()
				$Armature/Skeleton/head_att.add_child(effect)
				effect.translation = headbox_node.translation
				var gib = ludicrous_gibs.instance()
				attacker.camera.add_child(gib)
				gib.translation.z = -0.5
				gib.translation.y = -0.05
				gib.rotation.y = deg2rad(180)
				SetBodyPart(bodypart, true)
				return
	
	if gibs[bodypart].gib != null: 
		
		var gibss = gibs[bodypart].gib
		for g in gibs[bodypart].gib:
			
			if gibss[g].needs_nextgib == true and gibs[bodypart].next_part != null and !HasPart(gibs[bodypart].next_part):
				SetBodyPart(bodypart, true)
				return
			
			var gib = gibss[g].gib.instance()
			if gibss[g].parented:
				hitbox.get_parent().add_child(gib)
				gib.global_transform = hitbox.get_parent().global_transform
			else:
				sys.current_scene.add_child(gib)
				gib.global_transform = hitbox.get_parent().global_transform
				gib.vel = -hitbox.get_parent().global_transform.basis.z.normalized()*10 + Vector3(0,5,0)
			if gibss[g].ang != Vector3(0, 0, 0):
				gib.rotation_degrees = gibss[g].ang
			if gibss[g].pos != Vector3(0, 0, 0):
				gib.translation = gibss[g].pos
	
	SetBodyPart(bodypart, true)

var aim_offset = 0

func rotate_towards(pos):
	
	var rotation = atan2((pos.z - self.global_transform.origin.z), (pos.x - self.global_transform.origin.x))
	set_rotation_degrees( Vector3(0, (rad2deg(rotation)+90)*-1, 0) )

func aim_for(pos):
	rotate_towards(pos)
	var dist = head_node.global_transform.origin.distance_to(pos)
	
	var q =  Quat(deg2rad((head_node.global_transform.origin.y-(pos.y))*(dist*0.2))*-1, 0, 0, 1)
	
	var spineid = skeleton.find_bone("spine.001")
	var t = Transform(q).orthonormalized()
	skeleton.set_bone_custom_pose(spineid, t)

func reset_aim():
	var spineid = skeleton.find_bone("spine.001")
	var t = Transform(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1), Vector3(0, 0, 0) )
	skeleton.set_bone_custom_pose(spineid, t)

func UpdateVelocity(velocity):
	vel.x = velocity.x
	vel.z = velocity.z
	vel.y += velocity.y

func GetTeam():
	return self.team
	
func SetAnimTime(a, t):
	$AnimationPlayer.play(a)
	$AnimationPlayer.seek(t, true)

func Jump(force):
	if is_on_floor():
		vel.y = force

func Punch(dir, force):
	if IsAlive():
		add_vel = dir*force
		Jump(4)
	else:
		add_vel = dir*force/2
		Jump(2)
	#self.health -= force
	
func GetRayCastEnt(rang):
	var tr = get_node(raycast)
	tr.cast_to = Vector3(0, 0, -rang)
	tr.force_raycast_update()
	
	if tr.is_colliding():
		var ent = tr.get_collider()
		return ent

func MeleeCheck(damage):
	
	var bodies = $Armature/Skeleton/gun_att/Area.get_overlapping_bodies()
	
	for ent in bodies:
		if ent is common.PLAYER:
			ent.TakeDamage(damage, self)
			#ent.ShakeScreen( 0.1, 5 )

func KickCheck():
	
	var bodies = $Armature/Skeleton/lfoot_att/Area.get_overlapping_bodies()
	
	for ent in bodies:
		if ent is common.PLAYER:
			ent.TakeDamage(15, self)
			ent.ShakeScreen( 0.1, 5 )

func Stun():
	if IsAlive() and !IsDying():
		UpdateState(STATE_ATTACK)
		$AnimationPlayer.play("stun1", 0.1, 1, false)
		next_fire = common.time + $AnimationPlayer.current_animation_length

func Melee(target):
	var target_pos = target.global_transform.origin
	UpdateState(STATE_ATTACK)
	rotate_towards(target_pos)
	if weapon != "":
		$AnimationPlayer.play("melee1", 0.1, 1, false)
	else:
		$AnimationPlayer.play("kick", 0.1, 1, false)
	next_fire = common.time + $AnimationPlayer.current_animation_length

func Attack(target):
	var target_pos = target.GetHeadPos()
	UpdateState(STATE_ATTACK)
	aim_for(target_pos)
	$AnimationPlayer.play("fire_smg1", 0.1, 1, false)
	
	next_fire = common.time + $AnimationPlayer.current_animation_length

func GetHeadPos():
	return get_node(los_start).global_transform.origin + Vector3(0, 0.1, 0)

var last_seen_pos = Vector3(0,0,0)
var last_seen_enemy = null

var next_enemy_check = 0

func IsCrouching():
	return false

func CanSee(target):
	if sys.ai_disabled:
		return
	
	if target.IsAlive(): #and is_instance_valid(target):
		
		var lospos = get_node(los_start)
		
		var target_pos = target.GetHeadPos()
		
		var pos = lospos.global_transform.origin
		var dir = (target_pos - pos).normalized()
		var forward = -lospos.global_transform.basis.z.normalized()
		var dist = pos.distance_to(target_pos)
		
		if dist <= los_range:
			if dir.dot(forward) >= cos(deg2rad(360/2)):
				var ray_pos = pos + (-self.global_transform.basis.z.normalized()*0.5)
				
				var space_state = get_world().direct_space_state
				if target.IsCrouching():
					target_pos = target_pos-Vector3(0, 1, 0)
				var tr = space_state.intersect_ray(ray_pos, target_pos)
				#draw_shiet2(ray_pos, target_pos)
				
				if tr:
					var ent = tr.collider
					if ent == target:
						last_seen_pos = tr.position
						return true
	return false

func SeesEnemy():
	if sys.ai_disabled or IsDying() or !IsAlive():
		return
	
	var pos = self.global_transform.origin
	
	var chars = get_tree().get_nodes_in_group("chars")
	for ent in chars:
		if ent != self:
			var target_pos = ent.global_transform.origin
			if ent.has_method("GetTeam") and ent.GetTeam() != self.GetTeam() and ent.IsAlive():
				if CanSee(ent):
					return ent
	return null

func NotifySquad(self_pos):
	
	var pos = self.global_transform.origin
	
	var chars = get_tree().get_nodes_in_group("chars")
	for ent in chars:
		if ent != self and ent.has_method("GetTeam") and ent.GetTeam() == self.GetTeam() and ent.IsAlive() and ent is common.NPC:
			var target_pos = ent.global_transform.origin
			if pos.distance_to(target_pos) < los_range:
				if ent.state == STATE_IDLE:
					ent.StartPatrol()

var current_path = 0
var next_vec = Vector3(0, 1, 0)
var lerpvec = Vector3(0, 1, 0)

func PathProcess(delta):
	
	if (path.size() > 1) and path.size() > current_path+1:
		
		var cur_pos = self.transform.origin
		var pathdir = next_vec - cur_pos
		
		var angle = cur_pos.angle_to(pathdir)
		var forward = pathdir.normalized()
		
		if $AnimationPlayer.current_animation != "run_1":
			$AnimationPlayer.play("run_1", 0.1, 1, false)
		
		if self.transform.origin.distance_to(next_vec) <= 2:
			#if path[current_path+1].y > cur_pos.y:
			#	Jump(10)
			current_path += 1
			next_vec = path[current_path]
			
			rotate_towards(next_vec)
			UpdateVelocity(-self.global_transform.basis.z.normalized()*5)
	
	elif path.size() <= current_path or (self.transform.origin.distance_to(next_vec) > 1 and self.get_floor_velocity().length() < 10):
		pass
	else:
		StartPatrol()

var m = SpatialMaterial.new()

func draw_shiet(start, end):
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	var im = $b/draw
	im.set_material_override(m)
	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	im.add_vertex(start)
	im.add_vertex(end)
	im.end()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for x in path:
			im.add_vertex(x)
	im.end()

func draw_shiet2(start, end):
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	var im = $b/draw
	im.set_material_override(m)
	im.clear()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	im.add_vertex(start)
	im.add_vertex(end)
	im.end()

func SetPath(path_start, path_end):
	var n = get_node(nav)
	var p = n.get_simple_path(path_start, path_end, true)
	next_vec = path_start
	current_path = 0
	path = Array(p)
	#path.invert()
	
	#draw_shiet(path_start, path_end)
	
	UpdateState(STATE_MOVE)
	next_fire = common.time + path.size()*0.3

func GoToPoint(destination):
	var n = get_node(nav)
	var p = n.get_simple_path(self.global_transform.origin, destination, true)
	next_vec = self.global_transform.origin
	current_path = 0
	path = Array(p)
	
	UpdateState(STATE_MOVE)
	next_fire = common.time + path.size()*0.3

func CheckRayCast():
	var tr = get_node(raycast)
	
	return tr.is_colliding()

var rand_delay = 0

func StartPatrol():
	if sys.ai_disabled:
		return
	
	if state == STATE_PATROL or !CanFire():
		return
	current_path = 0
	path = []
	UpdateState(STATE_PATROL)
	
	if move_type == "walk":
		UpdateVelocity(-self.global_transform.basis.z.normalized()*1)
		if $AnimationPlayer.current_animation != "walk_1":
			$AnimationPlayer.play("walk_1", 0.1, 1, false)
	elif move_type == "run":
		UpdateVelocity(-self.global_transform.basis.z.normalized()*5)
		if $AnimationPlayer.current_animation != "run_1":
			$AnimationPlayer.play("run_1", 0.1, 1, false)

func PushStuff(bodies):
	for ent in bodies:
		if ent.get_class() == "StaticBody":
			return false
		if ent.has_method("Punch"):
			ent.Punch(-self.global_transform.basis.z.normalized(), 5)
		elif ent.get_class() == "RigidBody":
			ent.apply_impulse(-self.global_transform.basis.z.normalized(), -self.global_transform.basis.z.normalized()*1)
	return true

func CheckShit():
	var bodies = $Area.get_overlapping_bodies()
	var bodynum = bodies.size()
	if bodynum > 0:
		PushStuff(bodies)

func Patrol(delta):
	
	var forward = -self.global_transform.basis.z.normalized()
	
	if CanFire():
		if move_type == "walk":
			UpdateVelocity(forward*1)
			if $AnimationPlayer.current_animation != "walk_1":
				$AnimationPlayer.play("walk_1", 0.1, 1, false)
		elif move_type == "run":
			UpdateVelocity(forward*5)
			if $AnimationPlayer.current_animation != "run_1":
				$AnimationPlayer.play("run_1", 0.1, 1, false)
	
	if self.is_on_wall() and CanFire():
		self.rotate_y(deg2rad(rand_range(-65, 65)))
		UpdateVelocity(forward*1)

var grav_vel = Vector3(0,1,0)

func Move(delta):
	if IsAlive() and !IsDying() and CanFire():
		CheckShit()
	
	var grav = common.norm_grav
	vel.y += delta*grav
	
	add_vel.y = lerp(add_vel.y, 0, 5*delta)
	add_vel.x = lerp(add_vel.x, 0, 5*delta)
	add_vel.z = lerp(add_vel.z, 0, 5*delta)
	
	self.move_and_slide(vel+add_vel, Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func OnDeath():
	$full_col.set_disabled(true)
	self.set_collision_layer_bit(3, true)
	#self.set_collision_mask_bit(3, false)
	
	self.set_collision_layer_bit(1, false)
	self.set_collision_mask_bit(1, false)
	self.set_collision_layer_bit(6, false)
	self.set_collision_mask_bit(6, false)
	UpdateVelocity(Vector3(0,0,0))
	if health > 0:
		health = 0
	UpdateState(STATE_DEAD)
	DropWeapon()

func FullGibs():
	
	for i in range(3):
		var gib = gib1.instance()
		get_tree().get_root().add_child(gib)
		gib.global_transform.origin = self.global_transform.origin + Vector3(0, 2, 0)
		var randx = rand_range(0, 1)
		var randy = rand_range(0, 1)
		var randz = rand_range(0, 1)
		
		gib.apply_impulse( gib.global_transform.origin, Vector3(randx, randy, randz )*2)
		
		var bld = blood_cloud.instance()
		get_tree().get_root().add_child(bld)
		bld.global_transform.origin = self.global_transform.origin + Vector3(0, 2, 0)
		
		
	self.queue_free()

func _process(delta):
	
	if IsAlive() and !IsDying() and CanFire():
		if next_enemy_check < common.time:
			var enemy = SeesEnemy()
			if enemy != null:
				var target_pos = enemy.GetHeadPos()
				var pos = GetHeadPos()
				var dist = pos.distance_to(target_pos)
				if weapon != "" and dist <= 20 and dist > 4:
					Attack(enemy)
				elif dist <= 4:
					Melee(enemy)
				else:
					GoToPoint(target_pos)
			next_enemy_check = common.time + 2
		if next_enemy_check > common.time and state != STATE_PATROL:
			StartPatrol()
	
	if self.health <= 0:
		if IsAlive():
			
			if IsFacing(last_attacker):
				$AnimationPlayer.play("death2", 0)
			else:
				$AnimationPlayer.play("death_forward", 0)
			
			OnDeath()
			
	if self.health <= -300:
		self.FullGibs()

func _physics_process(delta):
	Move(delta)
	if sys.ai_disabled:
		if vel.length() > 1:
			UpdateVelocity(Vector3(0,0,0))
		return
	match state:
		STATE_PATROL:
			Patrol(delta)
		STATE_MOVE:
			PathProcess(delta)