extends "res://viewmodel.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var scope = false
var prefov = 70
var tofov = 15

func CanSecondaryFire():
	return true

func ScopeIn():
	prefov = ply.camera.fov
	ply.camera.fov = tofov
	ply.sense_mul = 0.5
	hide()
	
func ScopeOut():
	ply.camera.fov = prefov
	ply.sense_mul = 1
	show()

func Think():
	if !scope:
		$scope.hide()
	else:
		$scope.show()
		$scope/rect1.rect_size.x = (OS.window_size.x-OS.window_size.y)/2
		$scope/rect1.rect_size.y = OS.window_size.y
		$scope/rect2.rect_size.x = 4 + (OS.window_size.x-OS.window_size.y)/2
		$scope/rect2.rect_size.y = OS.window_size.y

func Fire():
	ply.ShootBullet( self.accuracy, self.bullet_num )
	ply.ViewPunch( self.view_punch )
	if animki != null:
		animki.play("fire", 0, 1, false)
		next_fire = common.time + delay
		
		var m = common.muzzle4.instance()
		muzzle.add_child(m)
		
		mag -= 1
		if mag <= 0:
			if scope:
				ScopeOut()
				scope = false

func OnReload():
	if scope:
		ScopeOut()
		scope = false

func SecondFire():
	if scope:
		ScopeOut()
	else:
		ScopeIn()
	scope = !scope

func Kick():
	next_fire = common.time + 0.5
	if scope:
		ScopeOut()
		scope = false
	if animki != null:
		animki.play("kick", 0.1, 1, false)

func Holster():
	ScopeOut()
	scope = false
	if animki != null:
		animki.play("holster", 0.1, 1, false)
		next_fire = common.time + animki.current_animation_length
		common.UpdateMagData(weapon, mag)