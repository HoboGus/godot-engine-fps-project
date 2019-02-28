extends Node

#vm is the viewmodel scene
#wm is world model
#slot is slot ye
#coolness is used for autoswitch on pickup

var weapons = {
		"hands" : {
			vm = preload("res://vm_base.tscn"),
			wm = null,
			good_name = "No weapon",
			slot = 1,
			coolness = 0,
			ammo = "none",
			secondary_ammo = "none"
		},
		"lighter" : {
			vm = preload("res://weapons/lighter/lighter.tscn"),
			wm = null,
			good_name = "Lighter",
			slot = 1,
			coolness = 0,
			ammo = "none",
			secondary_ammo = "none",
			default_ammo = 0
		},
		"bong" : {
			vm = preload("res://weapons/bong/bong_vm.tscn"),
			wm = preload("res://weapons/bong/bong.tscn"),
			good_name = "Bong",
			slot = 0,
			coolness = 5,
			ammo = "none",
			secondary_ammo = "none",
			default_ammo = 0
		},
		"shotgun" : {
			vm = preload("res://weapons/remington/shotgun_vm.tscn"),
			wm = preload("res://weapons/remington/shotgun_wm.tscn"),
			good_name = "Shotgun",
			ammo = "shells",
			secondary_ammo = "none",
			default_ammo = 6,
			slot = 4,
			coolness = 10
		},
		"spas" : {
			vm = preload("res://weapons/spas/spas_vm.tscn"),
			wm = preload("res://weapons/remington/shotgun_wm.tscn"),
			good_name = "Automatic Shotgun",
			ammo = "shells",
			secondary_ammo = "vog",
			default_ammo = 8,
			slot = 4,
			coolness = 20
		},
		"ak12" : {
			vm = preload("res://weapons/ak12/ak12_vm.tscn"),
			wm = preload("res://weapons/ak12/ak12_wm.tscn"),
			good_name = "Assault Rifle",
			ammo = "rifle",
			secondary_ammo = "vog",
			default_ammo = 30,
			slot = 3,
			coolness = 15
		},
		"vyhlop" : {
			vm = preload("res://weapons/vyhlop/vyhlop_vm.tscn"),
			wm = preload("res://weapons/vyhlop/vyhlop_wm.tscn"),
			good_name = "Sniper Rifle",
			ammo = "sniper",
			secondary_ammo = "none",
			default_ammo = 5,
			slot = 5,
			coolness = 35
		},
		"pp2000" : {
			vm = preload("res://weapons/pp2000/pp_vm.tscn"),
			wm = preload("res://items/weapons/pp2000_wm.tscn"),
			good_name = "SMG",
			ammo = "smg",
			secondary_ammo = "none",
			default_ammo = 20,
			slot = 2,
			coolness = 1
		},
		"dualpp2000" : {
			vm = preload("res://weapons/pp2000/dual_pp_vm.tscn"),
			wm = preload("res://items/weapons/pp2000_wm.tscn"),
			good_name = "Akimbo SMG",
			ammo = "smg",
			secondary_ammo = "none",
			default_ammo = 40,
			slot = 2,
			coolness = 5
		},
		"deagle" : {
			vm = preload("res://weapons/deagle/deagle_vm.tscn"),
			wm = preload("res://weapons/deagle/deagle_wm.tscn"),
			good_name = ".50 Handcannon",
			ammo = "50cal",
			secondary_ammo = "none",
			default_ammo = 7,
			slot = 2,
			coolness = 10
		},
		"akimbo_deagle" : {
			vm = preload("res://weapons/deagle/akimbo_deagle_vm.tscn"),
			wm = preload("res://weapons/deagle/deagle_wm.tscn"),
			good_name = "Eagle & Hawk",
			ammo = "50cal",
			secondary_ammo = "none",
			default_ammo = 14,
			slot = 2,
			coolness = 30
		}
}

var muzzle1 = preload("res://effects/Particle.tscn")
var muzzle2 = preload("res://effects/shotgun_muzzle.tscn")
var muzzle3 = preload("res://effects/rifle_muzzle.tscn")
var muzzle4 = preload("res://effects/vyhlop_muzzle.tscn")

var npc_muzzle1 = preload("res://effects/npc_muzzle1.tscn")

var fire1 = preload("res://effects/fire1.tscn")

var shells = {
	"9mm" : {
		s = preload("res://effects/shell9mm.tscn")
	},
	"buckshot" : {
		s = preload("res://effects/shell_buckshot.tscn")
	},
	"rifle" : {
		s = preload("res://effects/rifleshell.tscn")
	}
}

var ammo = {
	"shells" : {
		good_name = "Shotgun shells",
		max_ammo = 30
	},
	"rifle" : {
		good_name = "Rifle ammo",
		max_ammo = 120
	},
	"sniper" : {
		good_name = "Sniper rounds",
		max_ammo = 25
	},
	"smg" : {
		good_name = "SMG ammo",
		max_ammo = 200
	},
	"50cal" : {
		good_name = ".50 rounds",
		max_ammo = 64
	},
	"vog" : {
		good_name = "Grenade",
		max_ammo = 3
	}
}

var weapons_inventory = {
	0 : [],
	1 : ["hands", "lighter"],
	2 : [],
	3 : [],
	4 : [],
	5 : [],
	6 : [],
	7 : [],
	8 : [],
	9 : []
}

var ammo_inventory = {
}

func UpdateMagData(weapon, mag):
	if ammo_inventory.has(weapons[weapon].ammo):
		ammo_inventory[weapons[weapon].ammo][weapon] = {}
		ammo_inventory[weapons[weapon].ammo][weapon].mag = mag

func GetMagData(weapon):
	if ammo_inventory.has(weapons[weapon].ammo):
		if weapon in ammo_inventory[weapons[weapon].ammo]:
			return ammo_inventory[weapons[weapon].ammo][weapon].mag
		else:
			return 0
	else:
		return 0

const VIEW_MODEL = preload("viewmodel.gd")
const NPC = preload("res://npc_base.gd")
const PLAYER = preload("res://characters/player.gd")
const AMMO_BOX = preload("res://items/ammo_box.gd")
const HIT_BOX = preload("res://hitbox_base.gd")
const SHELL = preload("res://effects/shell_base.gd")
const EFFECT = preload("res://effects/remove_after_a_while.gd")
const ITEM = preload("res://items/item_pickup.gd")
const PROP_STATIC = preload("res://props/static_prop.gd")
const PROP_PHYSICS = preload("res://props/physics_prop.gd")

const norm_grav = -24.8

var health = 100
var armor = 0
var time = 0

var has_deagles = false

func strip_ammo():
	ammo_inventory = {}
	
func strip_weapons():
	weapons_inventory = {
		0 : [],
		1 : ["hands", "lighter"],
		2 : [],
		3 : [],
		4 : [],
		5 : [],
		6 : [],
		7 : [],
		8 : [],
		9 : []
	}

var wep_to_select = null

func GameStartupVars():
	health = 100
	armor = 0
	time = 0
	wep_to_select = null
	strip_ammo()
	strip_weapons()

func UpdateTransitionData(wep):
	wep_to_select = wep

func _process(delta):
	time += delta

func GetPos(node):
	return node.global_transform.origin
	
func GetNodeSaveData(ent):
	#######saving rigid body data
	if ent.get_class() == "RigidBody" and !ent.has_method("Save"):
		var save_dict = {
			"filename" : ent.get_filename(),
			"name" : ent.name,
			"parent" : ent.get_parent().get_path(),
			"pos_x" : ent.global_transform.origin.x, 
			"pos_y" : ent.global_transform.origin.y, 
			"pos_z" : ent.global_transform.origin.z, 
			"ang_x" : ent.rotation.x,
			"ang_y" : ent.rotation.y,
			"ang_z" : ent.rotation.z,
			"velocity_x": ent.linear_velocity.x,
			"velocity_y": ent.linear_velocity.y,
			"velocity_z": ent.linear_velocity.z,
			"ang_vel_x" : ent.angular_velocity.x,
			"ang_vel_y" : ent.angular_velocity.y,
			"ang_vel_z" : ent.angular_velocity.z,
			"tr_x" : ent.translation.x,
			"tr_y" : ent.translation.y,
			"tr_z" : ent.translation.z
		}
		return save_dict
	
	if ent.has_method("Save"):
		return ent.Save()
	elif ent.get_class() != "RigidBody":
		var save_dict = {
			"filename" : ent.get_filename(),
			"name" : ent.name,
			"parent" : ent.get_parent().get_path(),
			"pos_x" : ent.global_transform.origin.x, 
			"pos_y" : ent.global_transform.origin.y, 
			"pos_z" : ent.global_transform.origin.z, 
			"ang_x" : ent.rotation.x,
			"ang_y" : ent.rotation.y,
			"ang_z" : ent.rotation.z,
			"tr_x" : ent.translation.x,
			"tr_y" : ent.translation.y,
			"tr_z" : ent.translation.z
		}
		return save_dict

func SaveGame(filename):
	var save_game = File.new()
	save_game.open("user://"+filename+".save", File.WRITE)
	
	#var date = OS.get_datetime(false)
	
	var lvl_data = {
		"filename" : "level_data",
		"levelpath" : sys.current_scene.filename,
		"savename" : sys.level_name
	}
	
	save_game.store_line( to_json(lvl_data) )
	
	var save_nodes = get_tree().get_nodes_in_group("save")
	for ent in save_nodes:
		var node_data = GetNodeSaveData(ent)
		save_game.store_line(to_json(node_data))
		if ent is PLAYER:
			save_game.store_var(weapons_inventory)
			save_game.store_var(ammo_inventory)
	
	save_game.close()
	
func LoadNodes(filename):
	var save_game = File.new()
	if not save_game.file_exists("user://"+filename+".save"):
		return
	
	save_game.open("user://"+filename+".save", File.READ)
	
	var save_nodes = get_tree().get_nodes_in_group("save")
	for ent in save_nodes:
		if ent and !ent is PLAYER:
			ent.free()
	
	while not save_game.eof_reached():
		
		var current_line = parse_json(save_game.get_line())
		if current_line == null: 
			return
			
		if current_line["filename"] != "ply" and current_line["filename"] != "level_data":
			var new_object = load(current_line["filename"]).instance()
			new_object.name = current_line["name"]
			get_node(current_line["parent"]).add_child(new_object)
			
			new_object.global_transform.origin.x = float(current_line["pos_x"])
			new_object.global_transform.origin.y = float(current_line["pos_y"])
			new_object.global_transform.origin.z = float(current_line["pos_z"])
				
			new_object.rotation.x = float(current_line["ang_x"])
			new_object.rotation.y = float(current_line["ang_y"])
			new_object.rotation.z = float(current_line["ang_z"])
			
			new_object.translation.x = float(current_line["tr_x"])
			new_object.translation.y = float(current_line["tr_y"])
			new_object.translation.z = float(current_line["tr_z"])
			
			
			if new_object.has_method("Load"):
				new_object.Load(current_line)
				
			if new_object.get_class() == "RigidBody":
				new_object.linear_velocity.x = float(current_line["velocity_x"])
				new_object.linear_velocity.y = float(current_line["velocity_y"])
				new_object.linear_velocity.z = float(current_line["velocity_z"])
					
				new_object.angular_velocity.x = float(current_line["ang_vel_x"])
				new_object.angular_velocity.y = float(current_line["ang_vel_y"])
				new_object.angular_velocity.z = float(current_line["ang_vel_z"])
				
		elif current_line["filename"] == "ply":
			var ply = get_node(current_line["path"])
				
			ply.global_transform.origin.x = float(current_line["pos_x"])
			ply.global_transform.origin.y = float(current_line["pos_y"])
			ply.global_transform.origin.z = float(current_line["pos_z"])
				
			ply.rotation.x = float(current_line["ang_x"])
			ply.rotation.y = float(current_line["ang_y"])
			ply.rotation.z = float(current_line["ang_z"])
				
			health = current_line["health"]
			armor = current_line["armor"]
			
			has_deagles = current_line["has_golden_deagle"]
			
			ply.current_weapon = current_line["curwep"]
			ply.cur_slot = current_line["curslot"]
				
			if ply.dead:
				ply.Ressurect(ply.current_weapon)
			else:
				ply.SwitchWeapon(ply.current_weapon)
				
			ply.vm.mag = current_line["mag"]
				
			ply.SetEyeAngle(current_line["eyeang_x"], current_line["eyeang_y"], current_line["eyeang_z"])
				
			weapons_inventory = save_game.get_var()
			ammo_inventory = save_game.get_var()
			
			ply.AddNotification("Game loaded")
			
	
	save_game.close()
	
func LoadGame(filename):
	
	var save_game = File.new()
	save_game.open("user://"+filename+".save", File.READ)
	
	if not save_game.file_exists("user://"+filename+".save"):
		return
		
	while not save_game.eof_reached():
		
		var current_line = parse_json(save_game.get_line())
		if current_line["filename"] == "level_data": 
			sys.goto_scene_load( current_line["levelpath"], filename )
			return
		
	
func Dice(d):
	return randi() % d + 1

func VectorRandom():
	return Vector3(rand_range(-1, 1), rand_range(-1, 1), rand_range(-1, 1))

func VectorRandom2():
	var rand = rand_range(0, 1)
	return Vector3(rand, rand, rand)

var chunks = {
	"armor1" : preload("res://effects/gibs/items/armor_chunks.tscn"),
	"pot1" : preload("res://effects/gibs/items/pot_chunks.tscn"),
	"toilet_back" : preload("res://effects/gibs/props/toilet_back_chunks.tscn"),
	"toilet_krshka" : preload("res://effects/gibs/props/toilet_krshka.tscn")
}

var tracers = {
	"trace1" : preload("res://effects/trace.tscn")
}

var hit_effects = {
	"blood" : preload("res://effects/prtcls/bloodhit.tscn"),
	"dust" : preload("res://effects/hitpuff.tscn"),
	"sparks" : preload("res://effects/sparks_hit.tscn")
}

var hole_scene = preload("res://effects/bullet_hole.tscn")

func util_chunks(pos, ang, gib):
	var p = chunks[gib].instance()
	sys.current_scene.add_child(p)
	p.global_transform.origin = pos
	p.rotation = ang

func util_trace(start, end, trname):
	
	var dist = start.distance_to(end)
	var trace = tracers[trname].instance()
	
	sys.current_scene.add_child(trace)
	
	trace.global_transform.origin = start
	trace.time = common.time+dist*0.004
	trace.look_at(end, Vector3(0, 1, 0))

func util_hit(pos, normal, effect):
	var hit = hit_effects[effect].instance()
	
	sys.current_scene.add_child(hit)
	
	hit.global_transform.origin = pos
	#hit.rotation = normal
	#print(normal)
	hit.look_at(pos+normal*1.1, Vector3(0, 1, 0.1))