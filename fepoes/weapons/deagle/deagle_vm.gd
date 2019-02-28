extends "res://viewmodel.gd"

func DropShell():
	var shelll = common.shells[shell].s.instance()
	sys.current_scene.add_child(shelll)
	shelll.global_transform = attshell.global_transform
	var randmul = rand_range(0.5, 0.7)
	shelll.apply_impulse( Vector3(0,0,0), self.global_transform.basis.y.normalized()*randmul*0.8 )
	shelll.rotate_y(deg2rad(rand_range(-40, 40)))
	shelll.rotate_z(deg2rad(rand_range(-40, 40)))

func Fire():
	ply.ShootBullet( self.accuracy, self.bullet_num )
	ply.ViewPunch( self.view_punch )
	if animki != null:
		if mag == 1:
			animki.play("fire_last", 0, 1, false)
		else:
			animki.play("fire", 0, 1, false)
		next_fire = common.time + delay
		
		var m = common.muzzle1.instance()
		muzzle.add_child(m)
		
		DropShell()
		mag -= 1