extends Spatial

var bodypart = null
var ownerr = null

export(bool) var save = true

func _ready():
	if !save:
		self.remove_from_group("save")

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
		"bodypart" : bodypart,
		"ownerr" : ownerr.get_path()
	}
	return save_dict

func Load(data):
	self.scale = Vector3(2,2,2)
	bodypart = data["bodypart"]
	ownerr = get_node(data["ownerr"])

func _process(delta):
	if ownerr != null and bodypart != null:
		if !ownerr.HasPart(bodypart):
			self.queue_free()