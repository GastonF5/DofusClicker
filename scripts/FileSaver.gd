extends Node


const DATA_PATH := "user://data/"
const SAVE_PATH := "user://saves/"


## crée le dossier s'il n'existe pas
func check_directory_path(path: String):
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)


func save_data(data: Dictionary, file_name: String, path: String = DATA_PATH):
	var data_res := DataResource.new()
	data_res.data = data
	data_res.resource_name = file_name
	data_res.resource_path = path + file_name + ".tres"
	check_directory_path(path)
	ResourceSaver.save(data_res)


const ITEM_ASSET_PATH := "res://assets/items/images/"

func save_item_asset(texture: Texture2D, id: int):
	ResourceSaver.save(texture, ITEM_ASSET_PATH + "%d.png" % id)

const MONSTER_ASSET_PATH := "res://assets/monsters/images/"

func save_monster_asset(texture: Texture2D, id: int):
	ResourceSaver.save(texture, MONSTER_ASSET_PATH + "%d.png" % id)
