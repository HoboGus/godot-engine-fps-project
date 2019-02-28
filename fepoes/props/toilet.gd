extends "res://props/static_prop.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var open = false

var part1 = true
var part2 = true

func Save():
	var save_dict = {
		"filename" : self.get_filename(),
		"name" : self.name,
		"parent" : self.get_parent().get_path(),
		"pos_x" : self.global_transform.origin.x, 
		"pos_y" : self.global_transform.origin.y, 
		"pos_z" : self.global_transform.origin.z, 
		"ang_x" : self.rotation.x,
		"ang_y" : self.rotation.y,
		"ang_z" : self.rotation.z,
		"tr_x" : self.translation.x,
		"tr_y" : self.translation.y,
		"tr_z" : self.translation.z,
		"open" : open,
		"anim" : $AnimationPlayer.assigned_animation,
		"anim_pos" : $AnimationPlayer.current_animation_position,
		"part1" : part1,
		"part2" : part2
	}
	return save_dict

func Load(data):
	open = data["open"]
	
	if !data["part1"]:
		$idk.queue_free()
		_on_idk_prop_on_break()
	
	if !data["part2"]:
		$Armature/Skeleton/krshka_att/krshkabody.queue_free()
		_on_krshkabody_prop_on_break()
	
	if data["anim"] != "":
		$AnimationPlayer.play(data["anim"])
		$AnimationPlayer.seek( data["anim_pos"], true)

var nxt_flush = 0

func CheckShitFlush():
	for ent in $Area.get_overlapping_bodies():
		ent.queue_free()

func Flush():
	if nxt_flush > common.time:
		return
	if open:
		$AnimationPlayer.play("flush", 0.1, 1, false)
	else:
		$AnimationPlayer.play("flush2", 0.1, 1, false)
	nxt_flush = common.time + $AnimationPlayer.current_animation_length

func Open():
	if nxt_flush > common.time:
		return
	if !open:
		$AnimationPlayer.play("open", 0.1, 1, false)
	else:
		$AnimationPlayer.play("close", 0.1, 1, false)
	open = !open

func _on_idk_prop_on_break():
	$Armature/Skeleton/idk.hide()
	part1 = false

func _on_krshkabody_prop_on_break():
	$Armature/Skeleton/krshka.hide()
	part2 = false
