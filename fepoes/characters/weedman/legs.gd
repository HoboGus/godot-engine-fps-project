extends Spatial

var collision = null
export(NodePath) var ply = null
var kickin = 0

var hit = false

func _ready():
	collision = $Armature/Skeleton/BoneAttachment/Area
	var tmp = get_node(ply)
	ply = tmp
	#collision.connect("body_entered", self, "collided")
	#collision.connect("body_exited", self, "uncollided")
	pass

#func _process(delta):

func hit():
	ply.ViewKick(5)
	
func do_kick(force, sideforce):
	
	var bodies = collision.get_overlapping_bodies()
	
	var dir = -ply.global_transform.basis.z.normalized()
	var sidedir = -ply.global_transform.basis.x.normalized()
	
	ply.DropGrabbedObj(15)
	
	for ent in bodies:
		
		if ent.has_method("Punch"):
			ent.Punch(dir, force*10)
			hit()
		elif ent.get_class() == "RigidBody":
			ent.apply_impulse(dir, Vector3(0,1,0)*(force*0.7))
			ent.apply_impulse(dir, dir*force)
			ent.apply_impulse(dir, sidedir*sideforce)
			hit()

func Kick():
	if ply.is_on_floor():
		$AnimationPlayer.play("kick3", 0.1, 1, false)
		ply.vel.x = 0
		ply.vel.z = 0
	else:
		$AnimationPlayer.play("kick4", 0.1, 1, false)
		ply.view_bob = 15
		ply.ViewKick(-5)
