extends Node

var percentage = 100

func _ready():
	pass

var bool22 = false

func _process(delta):
	$cntrcntr/weedgay.scale.x = (cos(3 * common.time)*0.5)
	
	#$bottom/loadingtext.text = "Loading "+String(round(percentage*sys.progress))+" %"
	$bottom/ProgressBar.value = percentage*sys.progress
	
	if $cntrcntr/weedgay.scale.x < 0.1 and !bool22:
		bool22 = true
		var rand = randi() % 3
		$cntrcntr/weedgay.frame = rand
	
	if $cntrcntr/weedgay.scale.x > 0.1 and bool22:
		bool22 = false
		
	#$bottom/progress.value = 100*sys.progress
