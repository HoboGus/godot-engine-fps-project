extends "res://viewmodel.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var heat = 0

func _ready():
	hide()	#little hack to prevent flickering
	$Armature/Skeleton/lighterb/fire.emitting = false
	$Armature/Skeleton/lighterb/fire/OmniLight.hide()
	
	$Armature/Skeleton/lighterb/firecol.connect("body_entered", self, "fire_collided")
	
	if weapon != null:
		self_wep = common.weapons[weapon]
	if anim != null:
		animki = get_node(anim)

func fire_collided(body):
	if body.has_method("Ignite") and $Armature/Skeleton/lighterb/fire/OmniLight.visible:
		body.Ignite()

func set_lighter(b):
	$Armature/Skeleton/lighterb/fire.emitting = b
	if b:
		$Armature/Skeleton/lighterb/fire/OmniLight.show()
	else:
		$Armature/Skeleton/lighterb/fire/OmniLight.hide()

func Think():
	$Armature/Skeleton/lighterb/fire/OmniLight.light_energy = rand_range(0.6, 1)
	if $Armature/Skeleton/lighterb/fire/OmniLight.visible:
		heat += 0.1
	else:
		heat = 0
	if heat > 60:
		heat = 0
		animki.play("overheat", 0, 1, false)
		next_fire = common.time + animki.current_animation_length

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

func SecondFire():
	if animki != null and $Armature/Skeleton/lighterb/fire/OmniLight.visible:
		animki.play("use2", 0.2, 1, false)
		next_fire = common.time + animki.current_animation_length

func Fire():
	if animki != null and !$Armature/Skeleton/lighterb/fire/OmniLight.visible:
		animki.play("use1", 0, 1, false)
		next_fire = common.time + animki.current_animation_length
