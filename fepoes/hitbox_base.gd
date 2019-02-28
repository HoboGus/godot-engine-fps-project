extends Node

export(NodePath) var parent = null
export(float) var dmg_mul = 1
export var dmg_threshold = 5
export var health = 0
export(bool) var gib = true

export(String) var bodypart = "none"

var p 

var check = 0

func _ready():
	p = get_node(parent)
	check = common.time + 1

func check_disable():
	if bodypart != "none" and p.gibbs[bodypart] == true:
		$col.set_disabled(true)

func MaterialType():
	return "blood"

func BulletHit(dmg, attacker, force):
	if p is common.NPC and p.HasPart(bodypart):
		if dmg >= dmg_threshold and gib and bodypart != "none":
			if health > 0 and dmg < health:
				health -= dmg*0.7
				p.Punch(-attacker.global_transform.basis.z.normalized(), force/2)
			elif health <= 0 or dmg >= health:
				if bodypart == "head":
					p.Punch(-attacker.global_transform.basis.z.normalized(), force*2)
				else:
					p.Punch(-attacker.global_transform.basis.z.normalized(), force/4)
				p.BodyPartDamage(bodypart, self, attacker)
			
		else:
			if p.IsAlive(): 
				p.Punch(-attacker.global_transform.basis.z.normalized(), force)
			else:
				p.Punch(-attacker.global_transform.basis.z.normalized(), force/4)
	else:
		return
		
	p.TakeDamage(dmg*dmg_mul, attacker)
	check_disable()

func Punch(dir, force):
	p.Punch(dir, force)
	p.TakeDamage(300, self)
	
func TakeDamage(dmg, attacker):
	p.TakeDamage(dmg, attacker)

func IsAlive():
	return p.IsAlive()

func _process(delta):
	if check < common.time:
		check_disable()
