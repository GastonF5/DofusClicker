extends Node


const SPELL_RES_PATH := "res://resources/spells/"
const SCENES_PATH := "res://scenes/"
const STAT_ASSET_PATH := "res://assets/stats/stat_icon/"
const DUNGEON_PATH := "res://resources/dungeons/"
const MAP_IMG_PATH := "res://assets/maps/"
const DROP_EXCEPTIONS_PATH := "res://resources/drops/"

var MONSTERS_PATH := "user://tmp/monsters/"
var EQUIPMENTS_PATH := "user://tmp/equipment/"
var ITEMS_PATH := "user://tmp/items/"


func load_file(path: String):
	return load(path)


func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	if dir == null:
		return []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = "%s/%s" % [path, file_name]
		if dir.current_is_dir():
			file_paths += get_all_file_paths(file_path)
		else:
			file_paths.append(file_path.trim_suffix(".remap").trim_suffix(".import"))
		file_name = dir.get_next()
	return file_paths


func get_monster_resources() -> Array[MonsterResource]:
	var monster_resource_paths = get_all_file_paths(MONSTERS_PATH)
	var monsters_res: Array[MonsterResource] = []
	for path in monster_resource_paths:
		monsters_res.append(load(path))
	return monsters_res


func get_equipment_resources(type: String) -> Array[ItemResource]:
	var equipment_resource_paths = get_all_file_paths(EQUIPMENTS_PATH + type.to_lower())
	var equips_res: Array[ItemResource] = []
	for path in equipment_resource_paths:
		equips_res.append(load(path))
	return equips_res


func get_equipment_resource(path: String) -> ItemResource:
	return load(path)


func get_spell_resources(_class: String) -> Array[SpellResource]:
	var spell_asset_paths = get_all_file_paths(SPELL_RES_PATH + _class.to_lower())
	var spells_res: Array[SpellResource] = []
	spell_asset_paths.sort_custom(func(a, b): return int(a.get_file()[0]) < int(b.get_file()[0]))
	for path in spell_asset_paths:
		spells_res.append(load(path))
	return spells_res.filter(func(s): return s.available)


func get_packed_scene(scene_path: String) -> PackedScene:
	return load(SCENES_PATH + "%s.tscn" % scene_path)


func get_stat_asset(stat_type: String):
	var stat_path = stat_type.to_lower()
	if stat_path.begins_with("res_"):
		stat_path = "res_" + stat_path.split("_")[1]
	var dir = DirAccess.open(STAT_ASSET_PATH)
	var file_name = "%s.png" % stat_path
	if dir.file_exists(file_name) or dir.file_exists(file_name + ".import"):
		return load(STAT_ASSET_PATH + file_name)
	return null


func get_dungeon_resource(dungeon_id: int) -> DungeonResource:
	var dir = DirAccess.open(DUNGEON_PATH)
	if dir.file_exists("%d.tres" % dungeon_id) or dir.file_exists("%d.tres.remap" % dungeon_id):
		return load(DUNGEON_PATH + "%d.tres" % dungeon_id)
	return null


func load_save(file_name: String) -> DataResource:
	var dir = DirAccess.open(FileSaver.SAVE_PATH)
	if dir and dir.file_exists(file_name):
		return load(FileSaver.SAVE_PATH + file_name)
	else:
		push_error("Save file not found")
		return null


func get_subarea_asset(subarea_id: int):
	var dir = DirAccess.open(MAP_IMG_PATH)
	if dir.file_exists("%d.jpg" % subarea_id) or dir.file_exists("%d.jpg.import" % subarea_id):
		return load(MAP_IMG_PATH + "%d.jpg" % subarea_id)
	return null


func get_asset(path: String, id: int) -> CompressedTexture2D:
	path = "res://assets/" + path
	if DirAccess.dir_exists_absolute(path):
		var dir = DirAccess.open(path)
		if dir.file_exists("%d.png" % id) or dir.file_exists("%d.jpg.import" % id):
			return load(path + "%d.png" % id)
	return null
