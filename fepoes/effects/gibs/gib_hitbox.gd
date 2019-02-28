extends Node

export(NodePath) var parent = null

export(NodePath) var mesh1 = null
export(NodePath) var mesh2 = null
export(NodePath) var mesh3 = null

export var max_health = 50
export var health = 50

export(bool) var gib = false

var p 

var check = 0

func _ready():
	p = get_node(parent)
	check = common.time + 1

func check_disable():
	if health <= 0:
		p.queue_free()
		#$col.set_disabled(true)

func MaterialType():
	return "blood"

func BulletHit(dmg, attacker, force):
	health -= dmg
	
	if p.has_method("TakeDamage"):
		p.TakeDamage(dmg, attacker)
	
	if !gib:
		if health < max_health/2 and health > max_health/4:
			get_node(mesh1).hide()
			get_node(mesh2).show()
			
		if health < max_health/4:
			get_node(mesh1).hide()
			get_node(mesh2).hide()
			get_node(mesh3).show()
	
	check_disable()

func _process(delta):
	if check < common.time:
		check_disable()
