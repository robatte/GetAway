extends CSGBox3D


func _ready():
	var selected_material = pick_random_material()
	material = load(selected_material)
	
func pick_random_material():
	var materials_list = get_files("res://Props/Billboards/BillboardMaterials/")
	return materials_list[randi() % materials_list.size()]

func get_files(folder):
	var gathered_file = {}
	var file_count = 0
	var dir = DirAccess.open(folder)
	
	dir.list_dir_begin()
	var file = dir.get_next()
	
	while file != "":
		if not file.begins_with("."):
			gathered_file[file_count] = folder + file
			file_count += 1
		file = dir.get_next()
		
	return gathered_file
