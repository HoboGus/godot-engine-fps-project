extends StaticBody

export(NodePath) var parent = null
var p 

func _ready():
	p = get_node(parent)
	pass

func Punch(dir, force):
	p.Punch(dir, force)
