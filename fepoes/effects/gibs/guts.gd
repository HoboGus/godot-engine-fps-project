extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	play_guts()

func play_guts():
	$AnimationPlayer.play("shot2")
	for i in range(5):
		$hitbox.TakeDamage(1, self)