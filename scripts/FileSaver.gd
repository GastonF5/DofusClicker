class_name FileSaver
extends Node


const DATA_PATH := "user://data/"
const SAVE_PATH := "user://saves/"

## crée le dossier s'il n'existe pas
static func check_directory_path(path: String):
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)


func save_data(data: Dictionary, file_name: String, path: String = DATA_PATH):
	var data_res := DataResource.new()
	data_res.data = data
	data_res.resource_name = file_name
	data_res.resource_path = path + file_name + ".tres"
	check_directory_path(path)
	ResourceSaver.save(data_res)
