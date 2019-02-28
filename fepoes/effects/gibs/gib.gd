extends KinematicBody

var vel = Vector3(0,0,0)

var bounce = 3

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func Load(data):
	bounce = 0

func TakeDamage(dmg, attacker):
	vel = -attacker.global_transform.basis.z.normalized()*dmg + Vector3(0, dmg/2, 0)
	bounce = 2

func _physics_process(delta):
	var grav = common.norm_grav
	vel.y += delta*grav
	
	vel.x = lerp(vel.x, 0, 3*delta)
	vel.z = lerp(vel.z, 0, 3*delta)
	
	if is_on_floor():
		vel = vel/2
		if bounce > 0:
			vel.y = 2
			bounce -= 1
		if get_slide_count() > 0:
			var col = self.get_slide_collision(get_slide_count() - 1)
		#	self.global_transform.origin = col.get_position()
			self.rotation.x = col.get_normal().x
	
	self.move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(45))