extends "res://viewmodel.gd"

func CanSecondaryFire():
	if next_fire > common.time:
		return false
	else:
		return true

func CanFire():
	if next_fire > common.time:
		return false
	else:
		return true
	
func Fire():
	if animki != null:
		animki.play("flip2", 0.1, 1, false)
		next_fire = common.time + 0.5
		
func SecondFire():
	if animki != null:
		animki.play("flip1", 0.1, 1, false)
		next_fire = common.time + 0.5
		
func Kick():
	next_fire = common.time + 0.5
	#if animki != null:
	#	animki.play("kick", 0.1, 1, false)