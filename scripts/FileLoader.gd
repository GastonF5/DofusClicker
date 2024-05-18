class_name FileLoader


const SPELL_RES_PATH := "res://resources/spells/"
const SCENES_PATH := "res://scenes/"
const STAT_ASSET_PATH := "res://assets/stats/stat_icon/"

static var MONSTERS_PATH := "user://tmp/monsters/"
static var EQUIPMENTS_PATH := "user://tmp/equipment/"
static var ITEMS_PATH := "user://tmp/items/"


static func get_all_file_paths(path: String) -> Array[String]:
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
			file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths


static func get_monster_resources() -> Array[MonsterResource]:
	var monster_resource_paths = get_all_file_paths(MONSTERS_PATH)
	var monsters_res: Array[MonsterResource] = []
	for path in monster_resource_paths:
		monsters_res.append(load(path))
	return monsters_res


static func get_equipment_resources(type: String) -> Array[ItemResource]:
	var equipment_resource_paths = get_all_file_paths(EQUIPMENTS_PATH + type.to_lower())
	var equips_res: Array[ItemResource] = []
	for path in equipment_resource_paths:
		equips_res.append(load(path))
	return equips_res


static func get_equipment_resource(path: String) -> ItemResource:
	return load(path)


static func get_spell_resources(_class: String) -> Array[SpellResource]:
	var spell_asset_paths = get_all_file_paths(SPELL_RES_PATH + _class.to_lower())
	var spells_res: Array[SpellResource] = []
	spell_asset_paths.sort_custom(func(a, b): return int(a.get_file()[0]) < int(b.get_file()[0]))
	for path in spell_asset_paths:
		spells_res.append(load(path))
	return spells_res


static func get_packed_scene(scene_path: String) -> PackedScene:
	return load(SCENES_PATH + "%s.tscn" % scene_path)


static func get_stat_asset(stat: Caracteristique):
	var stat_path = stat.get_type().to_lower()
	if stat_path.begins_with("do_") and stat_path != "do_critiques":
		stat_path = "res_" + stat_path.split("_")[1]
	return load(STAT_ASSET_PATH + "%s.png" % stat_path)
