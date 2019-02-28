extends "res://viewmodel.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var exhalesmok = preload("res://effects/prtcls/exhale_smok.tscn")

func _ready():
	hide()	#little hack to prevent flickering
	$Armature/Skeleton/lighterb/fire.emitting = false
	$Armature/Skeleton/bongb/smok.emitting = false
	$Armature/Skeleton/lighterb/fire/OmniLight.hide()
	if weapon != null:
		self_wep = common.weapons[weapon]
	if anim != null:
		animki = get_node(anim)

func set_lighter(b):
	$Armature/Skeleton/lighterb/fire.emitting = b
	if b:
		$Armature/Skeleton/lighterb/fire/OmniLight.show()
	else:
		$Armature/Skeleton/lighterb/fire/OmniLight.hide()

func set_smoke(b):
	$Armature/Skeleton/bongb/smok.emitting = b
	
func exhale():
	#return
	#Engine.set_time_scale(0.5)
	var smok = exhalesmok.instance()
	get_tree().get_root().add_child(smok)
	smok.global_transform = ply.global_transform

func Think():
	$Armature/Skeleton/lighterb/fire/OmniLight.light_energy = rand_range(0.6, 1)

func CanFire():
	if next_fire > common.time:
		return false
	else:
		return true

#func Kick():
#	next_fire = common.time + 0.5

func Fire():
	if animki != null:
		animki.play("use1", 0, 1, false)
		next_fire = common.time + animki.current_animation_length