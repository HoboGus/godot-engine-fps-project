extends Spatial

var area = null
export(String) var level = ""

func _ready():
	area = $Area
	area.connect("body_entered", self, "collided")
	pass

func collided(ply):
	if ply is common.PLAYER:
		common.UpdateMagData(ply.vm.weapon, ply.vm.mag)
		common.UpdateTransitionData(ply.vm.weapon)
		sys.goto_scene("res://"+level+".tscn")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
