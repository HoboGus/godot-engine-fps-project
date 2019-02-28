extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func check_trace(pos, target_pos):
	var space_state = get_world().direct_space_state
	var tr = space_state.intersect_ray(pos+Vector3(0,1,0), target_pos)
	
	if tr:
		var ent = tr.collider
		if ent.get_class() != "StaticBody":
			return true

func check_ents():
	
	var bodies = $Area.get_overlapping_bodies()
	var space_state = get_world().direct_space_state
	var pos = self.global_transform.origin
	
	for ent in bodies:
		var dist = pos.distance_to(ent.global_transform.origin)
		var dir = ent.global_transform.origin - pos
			
		if dist < ($Area/col.shape.radius/2) and check_trace(pos, ent.global_transform.origin):
			if ent.has_method("TakeDamage"):
				ent.TakeDamage((200-dist*19), self)
			#if ent.has_method("BulletHit"):
			#	ent.BulletHit((250-dist*19), self, (250-dist*19))
			
			if ent.has_method("Punch"):
				ent.Punch(dir, 30)
			elif ent.get_class() == "RigidBody":
				ent.apply_impulse(dir, dir.normalized()*30)
				
		if ent.has_method("ShakeScreen"):
			ent.ShakeScreen(0.5, (30 - dist)/5 )
	
	#self.queue_free()

func _ready():
	pass
